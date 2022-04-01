import math                                     # Math module for rounding in test
from collections.abc import Iterable            # Library for сonvert a multidimensional array of any depth to one-dimensional
import secrets                                  # Generate random hex token required number of bytes
import cocotb                                   # Cocotb framework for Python test for Verilog, Vhdl, SV e.t.c.
from cocotb.clock import Clock                  # Library for clock generation
from cocotb.triggers import RisingEdge, Timer          # Triggers to fire
from cocotb.utils import get_sim_time
from cocotbext.axi import AxiBus, AxiMaster, AxiStreamBus, AxiStreamSource, AxiStreamFrame, AxiStreamMonitor # Library for AXI and AXI Bus interfaces
from cocotb.result import TestSuccess

SKIP_TEST_1 = False # Constant's for skip(True) or not(False) test's
SKIP_TEST_2 = False #
SKIP_TEST_3 = False #
FILE_NAME = '../hw/axi/tb_full/read.txt' # Path to txt with Etherner raw packets
QTY_RANDOM_WORDS = 1000                   # Constant for qty random word's in 1'st test

def append_hex(a, b): # func for append hex using bit shift
    sizeof_b = 0
    while((b >> sizeof_b) > 0):  # Get size of b in bits
        sizeof_b += 1

    sizeof_b_hex = math.ceil(sizeof_b/4) * 4  # Every position in hex in represented by 4 bits
    return (a << sizeof_b_hex) | b
 
def flatten(l): # func for сonvert a multidimensional array of any depth to one-dimensional
    for el in l:
        if isinstance(el, Iterable) and not isinstance(el, (str, bytes)):
            yield from flatten(el)
        else:
            yield el

class TB: # For the convenience of announcing the clock signal and connecting the interfaces
    def __init__(self, dut): # dut it is our design
        self.dut = dut

        cocotb.fork(Clock(dut.clk, 8, units="ns").start()) # Generate clock 125 MHz
        
        self.axi_source = AxiMaster(AxiBus.from_prefix(dut, "s_axi"), dut.clk, dut.rst) # Connecting AXI Master interface to our design
        
        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst) # Connecting AXI Stream interface to our design
        self.axis_mon = AxiStreamMonitor(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst) # Connecting AXI Monitor to  AXI Stream interface design

    async def reset(self): # Func for reset
        self.dut.rst.setimmediatevalue(0) # Set immediate value for signal
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst <= 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst <= 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)


@cocotb.test(skip=SKIP_TEST_1) # Test 1
async def overloading_packages(dut):
    """Test overloading fifo"""
    tb = TB(dut)
    dut._log.info("Reset start")
    await tb.reset() # Start test with reset
    dut._log.info("Reset end")
    i = 0
    while i <= 1000:
        time = float(get_sim_time(units="us"))
        data = bytearray.fromhex(secrets.token_hex(4)) # Random 4 byte hex token
        await tb.axis_source.send(AxiStreamFrame(data, tuser=1,tdest=0))
        print(time)
        if time >= 8.256:
            await Timer(2, units="us")
            raise TestSuccess
        data_in = await tb.axis_mon.read()
        i+=1


@cocotb.test(skip=SKIP_TEST_2) # Test 2
async def test_words_sending(dut):
    """Test sending word"""
    tb = TB(dut) 
    dut._log.info("Reset start")
    await tb.reset() # Start test with reset
    dut._log.info("Reset end")
    data_in_stream = [] # Create some list for input data (Axi Stream)
    data_out_full_axi = [] # Create some list for data (Axi)
    for i in range(QTY_RANDOM_WORDS):
        data = bytearray.fromhex(secrets.token_hex(4)) # Random 4 byte hex token
        await tb.axis_source.send(AxiStreamFrame(data, tuser=1,tdest=0))# Sending a frame
        data_in = await tb.axis_mon.read() # Reading data from monitor
        data_in_stream.append(data_in)     # Append data to list
        while str(dut.IRQ_stream_pkt_ready.value) != '1': # Wait until flag will be exposed at 1
            await RisingEdge(dut.clk)
        status = await tb.axi_source.read(0x0000,4) # Read qty of bytes in packet
        assert status.data[0] == 0x04, f"Qty of bytes can't be {status.data[0]} for 1 word, pls check" # Check bytes of packet == 4, because we send 1 word
        axi_frame = await tb.axi_source.read(0x0004,4) # Read word
        for j in range(4):
            data_out_full_axi.append(axi_frame.data[j]) # Append data to list
    AxiStreamData = set(list(flatten(data_in_stream)))     # Multidimensional to one-dimensional array
    AxiFullData = set(list(flatten(data_out_full_axi))) # Multidimensional to one-dimensional array
    assert AxiStreamData == AxiFullData, f"Not equal, check data: Data in axi stream {AxiStreamData}, data in full axi {AxiFullData}" # Check data


@cocotb.test(skip=SKIP_TEST_3) # Test 3
async def test_packets_sending(dut):
    """Test sending packets"""
    tb = TB(dut)
    dut._log.info("Reset start")
    await tb.reset() # Start test with reset
    dut._log.info("Reset end")
    data_in_stream = [] # Create some list for input data (Axi Stream)
    data_out_full_axi = [] # Create some list for data (Axi)
    with open(f'{FILE_NAME}', 'r', encoding='utf-8') as f0: # Read Ether packets from txt
        while True:
            line = (f0.readline()).rstrip() # Delete '\n' symbols

            if not line: # Check end of file
                dut._log.info("End of test")
                break

            data = bytearray.fromhex(line) # Convert hex to byte
            await tb.axis_source.send(AxiStreamFrame(data, tuser=1,tdest=0))# Sending a frame
            data_in = await tb.axis_mon.read() # Reading data from monitor
            data_in_stream.append(data_in) # Append data to list
            while str(dut.IRQ_stream_pkt_ready.value) != '1': # Wait until flag will be exposed at 1
                await RisingEdge(dut.clk)
            status = await tb.axi_source.read(0x0000,4) # Read qty of bytes in packet
            qty_words = math.ceil((append_hex(status.data[1], status.data[0]))/4) # Calculate the number of words in a batch
            i = 0
            while i < qty_words: # Reading all words in packet
                axi_frame = await tb.axi_source.read(0x0004+i*4,4)
                for j in range(4):
                    data_out_full_axi.append(axi_frame.data[j]) # Append data
                i+=1
        AxiStreamData = set(list(flatten(data_in_stream)))     # Multidimensional to one-dimensional array
        AxiFullData = set(list(flatten(data_out_full_axi))) # Multidimensional to one-dimensional array
        assert AxiStreamData == AxiFullData, f"Not equal, check data: Data in axi stream {AxiStreamData}, data in full axi {AxiFullData}" # Check data