# -----------------------------------------------------
#       Company Name                   : Artec 3D
#       Pytest top file name           : dma_test.py
#       DUT top file name              : tb.sv
#       Function                       : Regression tests for DMA
#       Required GIT Libraries         : cocotb 1.6.2, cocotb-test 0.2.2, cocotbext-axi 0.1.18, cocotb-bus 0.2.1 
#       Required Proprietary Libraries : artec3d_apb, artec3d_regs
#       Main Coder                     : Babundin Anton
#       Last Сhanges                   : 02.08.2022 - Added TestFactory(Autocreate tests), 
#                                        Added random ready(AXISlave)and valid(AXIStream)
#                                        04.08.2022 - Added regression for FRAME_STATUS_PTR
#                                        05.08.2022 - Added parallel wirte on AXIStream channels with random start
#                                                     Added watchdog timer
#                                        06.10.2022 - Added test for HEADER
#                                        10.11.2022 - Added test with unfinished frames
# -----------------------------------------------------
#Standart libs
import os
import random
import logging
#Cocotb libs
import cocotb
from cocotb.triggers import Timer,Combine, RisingEdge
from cocotbext.axi import AxiBus, AxiRam, AxiStreamBus, AxiStreamSource, AxiStreamFrame, AxiStreamSink
from cocotb.utils import get_sim_time
#Test libs
from constants import Status, Constants
from dma_item import SeqItem
from logger import SetupLog
from monitors import APBContainer, AXISContainer, FrameStatusHeaderContainer
#Artec libs
from artec3d_apb import artec_apb_master
import artec3d_regs as a3d_regs
from artec3d_vr import artec_vr_master, artec_vr_slave
import misc
from misc import AXISIdleGenerator, AXIBackpressureGenerator

class Scoreboard:
    def __init__(self, first_var, second_var, name, type_test=None):
        if type_test == 'APB_REGS':
            assert first_var == second_var, f"""Test incorrect, please check. \n 
                                      {name}  MUST BE: {hex(first_var)} \n
                                      {name} IS: {hex(second_var)}"""
        assert first_var == second_var, f"""Test incorrect, please check. \n 
                                      {name}  MUST BE: {first_var} \n
                                      {name} IS: {second_var}"""

class Connection:
    def __init__(self, dut):
        self.dut = dut

        self.width_axis_list = [] # Create list with axis widths
        self.width_axis_list.append(Constants.AXIS_0_WIDTH)
        self.width_axis_list.append(Constants.AXIS_1_WIDTH)
        self.width_axis_list.append(Constants.AXIS_2_WIDTH)
        self.width_axis_list.append(Constants.AXIS_3_WIDTH)
        self.width_axis_list.append(Constants.AXIS_4_WIDTH)
        self.width_axis_list.append(Constants.AXIS_5_WIDTH)
        # Init interfaces
        self.axi_ram = AxiRam(AxiBus.from_prefix(dut, prefix='dma_tb_axi'), dut.clk, dut.rstn, size=2**32, reset_active_level=False)
        print(dut.apb.m.penable, dut.apb.s.pready)
        self.req_slave   = artec_vr_slave(dut.read_req, name=None, clock=dut.clk)
        self.req_master  = artec_vr_master(dut.read_ack, name=None, clock=dut.clk)
        self.apb         = artec_apb_master(dut.apb, name=None, clock=dut.apb_clk)
        self.axis_source = [AxiStreamSource(AxiStreamBus.from_prefix(dut, prefix=f"dma_tb_axis{k}"), dut.clk, dut.rstn, reset_active_level=False, byte_lanes=self.width_axis_list[k]//8) for k in range(len(self.width_axis_list))] # Connecting AXI Stream interface to our design
        self.axis_sink = [AxiStreamSink(AxiStreamBus.from_prefix(dut, prefix=f"dma_tb_axis{k}"), dut.clk, dut.rstn, reset_active_level=False, byte_lanes=self.width_axis_list[k]//8) for k in range(len(self.width_axis_list))] # Connecting AXI Stream interface to our design

### Test seqeunces ###
@cocotb.test()
async def apb_regs_seq(dut):
    """APB regs test DMA"""
    SetupLog()
    tb=Connection(dut)                                   # Connect with DUT phase
    apb_monitor=APBContainer()
    logging.critical("Resets start")
    await Combine(misc.reset_on_clock(dut.rstn, dut.clk), misc.reset_on_clock(dut.apb_rstn, dut.clk))  # Reset phase
    logging.critical("Resets end")
    regmap = a3d_regs.get_register_map(os.environ["RDL_FILE"])['DMA'] # Create regmap (RDL)


    item = SeqItem("Item", rand_range=Constants.FRAME_PTR_QTY, min_mem_step=Constants.MEM_SIZE)
    item._random_adr()

    await write_frame_addr_ptr_list(item, tb, regmap)
    for i in range(len(item.frame_ptr_addr_list)):
        read_addr = await tb.apb.reg_read(regmap[f"FRAME_PTR_{i}"].baseaddr)
        apb_monitor.frame_ptr_addr_list_output.append(int(read_addr))

    Scoreboard(item.frame_ptr_addr_list, apb_monitor.frame_ptr_addr_list_output, "ADDR", type_test="APB_REGS")

    logging.critical("APB read offsets")
    await read_offsets(tb, regmap, apb_monitor.offsets_list)
    logging.critical("APB read offsets end")

    for i in  range(len(apb_monitor.offsets_list)):
        Scoreboard(regmap[f'OFFSET_{i}'].get_value(), apb_monitor.offsets_list[i], f"OFFSET_{i}", type_test="APB_REGS")

    _apb_id      = await tb.apb.reg_read(regmap["APB_ID"].baseaddr)
    Scoreboard(regmap[f"APB_ID"].get_value(), _apb_id, "APB_ID", type_test="APB_REGS")

    _version     = await tb.apb.reg_read(regmap["VERSION"].baseaddr)
    Scoreboard(regmap[f"VERSION"].get_value(), _version, "VERSION", type_test="APB_REGS")

    _ch_num      = await tb.apb.reg_read(regmap["CH_NUM"].baseaddr)
    Scoreboard(regmap["CH_NUM"].get_value(), _ch_num, "CH_NUM", type_test="APB_REGS")

    _header_size = await tb.apb.reg_read(regmap["HEADER_SIZE"].baseaddr)
    Scoreboard(regmap["HEADER_SIZE"].get_value(), _header_size, "HEADER_SIZE", type_test="APB_REGS")

    for i in  range(6):
        _bpe = await tb.apb.reg_read(regmap[f"BPE_{i}"].baseaddr)
        _type = await tb.apb.reg_read(regmap[f"TYPE_{i}"].baseaddr)
        Scoreboard(regmap[f"BPE_{i}"].get_value(), _bpe, f"BPE_{i}", type_test="APB_REGS")
        Scoreboard(regmap[f"TYPE_{i}"].get_value(), _type, f"TYPE_{i}", type_test="APB_REGS")

    logging.critical("Test complete")

@cocotb.test()
async def axis_channel_seq(dut):
    """AXI Stream test DMA (each channel)"""
    SetupLog()
    tb = Connection(dut)        # Connect with DUT phase 
    apb_monitor=APBContainer()
    axis_monitor=AXISContainer()
    channel = int(os.environ.get('axis_channel'))
    _en_chan = 1<<channel

    logging.critical("Resets start")
    await Combine(misc.reset_on_clock(dut.rstn, dut.clk), misc.reset_on_clock(dut.apb_rstn, dut.clk))  # Reset phase
    logging.critical("Resets end")

    logging.critical("Regmap initialize")
    regmap = a3d_regs.get_register_map(os.environ["RDL_FILE"])['DMA']

    item = SeqItem("Item", rand_range=Constants.FRAME_PTR_QTY, min_mem_step=Constants.FRAME_PTR_QTY, 
                   qty_of_bytes=Constants.QTY_OF_BYTES_RND_DATA, qty_of_axis_channel = len(tb.width_axis_list))
    item.randomize()


    logging.critical("APB write start")
    await write_frame_addr_ptr_list(item, tb, regmap)
    await tb.apb.reg_write(regmap[f"FRAME_STATUS_PTR"].baseaddr, Status.FRAME_STATUS_PTR_ADDR) # Last var is FRAME_STS_PTR addr
    logging.critical("APB write end")

    logging.critical("APB read offsets")
    await read_offsets(tb, regmap, apb_monitor.offsets_list)
    logging.critical("APB read offsets end")

    logging.critical(f"DMA and channel {channel} enable")
    await run_channels(tb, regmap, _en_chan)
    
    logging.critical(f"AXI Stream start trns {channel} channel")
    await send_frame_axis_each_channel(tb, item.data, channel, frame=item.tuser)
    logging.critical(f"AXI Stream end trns {channel} channel")

    await Timer(20000,'ns')
    logging.critical(f"AXI read start, addr: {hex(item.frame_ptr_addr_list[item.tuser]+ apb_monitor.offsets_list[channel])}")
    axis_monitor.data_out = tb.axi_ram.read(item.frame_ptr_addr_list[item.tuser] + apb_monitor.offsets_list[channel], Constants.QTY_OF_BYTES_RND_DATA)
    Scoreboard(item.data, axis_monitor.data_out, "DATA")
    logging.critical("AXI read end")
    logging.critical("Test complete")

@cocotb.test()
async def axis_full_channel_seq(dut):
    """AXI Stream full test DMA. Test header (Monitor simulation)"""
    SetupLog()
    tb = Connection(dut)                                        # Connect with DUT phase
    apb_monitor=APBContainer()
    axis_monitor=AXISContainer()
    logging.critical("Regmap initialize")
    cocotb.start_soon(read_write_header(tb, axis_monitor.frame_header_dict))
    regmap = a3d_regs.get_register_map(os.environ["RDL_FILE"])['DMA']

    logging.critical("Resets start")
    await Combine(misc.reset_on_clock(dut.rstn, dut.clk), misc.reset_on_clock(dut.apb_rstn, dut.clk))  # Reset phase
    logging.critical("Resets end")
    ### Set up AXIS and AXI generators ###
    for i in range(6):
        AXISIdleGenerator(tb.axis_source[i])
    AXIBackpressureGenerator(tb.axi_ram)

    item = SeqItem("Item", rand_range=Constants.FRAME_PTR_QTY, min_mem_step=Constants.MEM_SIZE, 
                   qty_of_bytes=Constants.QTY_OF_BYTES_RND_DATA, qty_of_axis_channel = len(tb.width_axis_list))
    item.randomize()

    logging.critical("APB write start")
    await write_frame_addr_ptr_list(item, tb, regmap)
    await tb.apb.reg_write(regmap[f"FRAME_STATUS_PTR"].baseaddr, Status.FRAME_STATUS_PTR_ADDR) # Last var is FRAME_STS_PTR addr
    logging.critical("APB write end")

    logging.critical("APB read offsets")
    await read_offsets(tb, regmap, apb_monitor.offsets_list)
    logging.critical("APB read offsets end")

    logging.critical(f"DMA and all channels enable")
    await run_channels(tb, regmap, Status.ENABLE_ALL_AXIS_CHANNEL)

    _tuser_rnd_frame = random.randrange(0,8)
    logging.critical(f"AXI Stream start trns")
    await start_parallel_sending_with_waiting_the_end(tb, item, _tuser_rnd_frame)
    logging.critical(f"AXI Stream end trns channel")

    await Timer(100000, 'ns')
    for i in range (len(apb_monitor.offsets_list)):
        ram_address = item.frame_ptr_addr_list[_tuser_rnd_frame] + apb_monitor.offsets_list[i]
        logging.critical(f"AXI read start, addr: {hex(ram_address)}")
        data_to_ram  = {ram_address: item.data_for_axis[i]}
        data_from_ram = tb.axi_ram.read(ram_address, item.data_bytes_len_ram[i])
        assert len(data_to_ram.get(ram_address)) == len(data_from_ram.hex()), f"""Length incorrect. Address = {hex(ram_address)}\n"""
        compare_two_strings_each_position(data_to_ram.get(ram_address), data_from_ram.hex())

    logging.critical("Start read and check header")
    await read_and_check_header_from_ram(tb, regmap, dut, axis_monitor.frame_header_dict, item.frame_ptr_addr_list, apb_monitor.offsets_list)
    logging.critical("Header is correct")
    logging.critical("Test complete")

@cocotb.test()
async def frame_reg_status_seq(dut):
    """DMA REG_STATUS test"""
    SetupLog()
    tb = Connection(dut)
    apb_monitor=APBContainer()
    frame_status_monitor=FrameStatusHeaderContainer()
    logging.critical("Regmap initialize")
    cocotb.start_soon(read_write_header(tb, frame_status_monitor.frame_header))
    regmap = a3d_regs.get_register_map(os.environ["RDL_FILE"])['DMA']
    frame_ptr = int(os.environ.get('frame_ptr'))

    logging.critical("Resets start")
    await Combine(misc.reset_on_clock(dut.rstn, dut.clk), misc.reset_on_clock(dut.apb_rstn, dut.clk))  # Reset phase
    logging.critical("Resets end")
    ### Set up AXIS and AXI generators ###
    for i in range(6):
        AXISIdleGenerator(tb.axis_source[i])
    AXIBackpressureGenerator(tb.axi_ram)

    item = SeqItem("Item", rand_range=Constants.FRAME_PTR_QTY, min_mem_step=Constants.MEM_SIZE, 
                   qty_of_bytes=Constants.QTY_OF_BYTES_RND_DATA, qty_of_axis_channel = len(tb.width_axis_list))
    item.randomize()
    
    logging.critical("APB write start")
    await write_frame_addr_ptr_list(item, tb, regmap)
    await tb.apb.reg_write(regmap[f"FRAME_STATUS_PTR"].baseaddr, Status.FRAME_STATUS_PTR_ADDR) # Last var is FRAME_STS_PTR addr
    logging.critical("APB write end")

    logging.critical("APB read offsets")
    await read_offsets(tb, regmap, apb_monitor.offsets_list)
    logging.critical("APB read offsets end")

    logging.critical(f"DMA and all channels enable")
    await run_channels(tb, regmap, Status.ENABLE_ALL_AXIS_CHANNEL)

    logging.critical(f"AXI Stream start trns")
    await start_parallel_sending_with_waiting_the_end(tb, item, frame_ptr)
    logging.critical(f"AXI Stream end trns channel")

    frame_status_monitor.frame_status = await waiting_frame_status_ptr(item, tb)

    Scoreboard(int(1<<frame_ptr), int.from_bytes(frame_status_monitor.frame_status, 'big'), "FRAME_STATUS")

    logging.critical("Test complete")

@cocotb.test()
async def turn_off_on_seq(dut):
    """DMA REG_STATUS test"""
    SetupLog()
    tb = Connection(dut)
    apb_monitor=APBContainer()
    frame_header_monitor=FrameStatusHeaderContainer()
    logging.critical("Regmap initialize")
    regmap = a3d_regs.get_register_map(os.environ["RDL_FILE"])['DMA']
    _tuser_rnd_frame = random.randrange(0,8)
    frames = int(os.environ.get('frames'))


    logging.critical("Resets start")
    await Combine(misc.reset_on_clock(dut.rstn, dut.clk), misc.reset_on_clock(dut.apb_rstn, dut.clk))  # Reset phase
    logging.critical("Resets end")
    ### Set up AXIS and AXI generators ###
    for i in range(6):
        AXISIdleGenerator(tb.axis_source[i])
    AXIBackpressureGenerator(tb.axi_ram)

    item = SeqItem("Item", rand_range=Constants.FRAME_PTR_QTY, min_mem_step=Constants.MEM_SIZE, 
                   qty_of_bytes=Constants.QTY_OF_BYTES_RND_DATA, qty_of_axis_channel = len(tb.width_axis_list))

    await sendind_frames_with_stop(frames, item, tb, dut, regmap)

    await Timer(random.randint(15000, 25000), 'ns')
    cocotb.start_soon(read_write_header(tb, frame_header_monitor.frame_header))
    logging.critical("APB write start")
    await write_frame_addr_ptr_list(item, tb, regmap)
    await tb.apb.reg_write(regmap[f"FRAME_STATUS_PTR"].baseaddr, Status.FRAME_STATUS_PTR_ADDR) # Last var is FRAME_STS_PTR addr
    tb.axi_ram.write(Status.FRAME_STATUS_PTR_ADDR, 0)
    logging.critical("APB write end")

    logging.critical("APB read offsets")
    await read_offsets(tb, regmap, apb_monitor.offsets_list)
    logging.critical("APB read offsets end")

    logging.critical(f"DMA and all channels enable")
    await run_channels(tb, regmap, Status.ENABLE_ALL_AXIS_CHANNEL)

    logging.critical(f"AXI Stream start trns")
    await start_parallel_sending_with_waiting_the_end(tb, item, _tuser_rnd_frame)
    logging.critical(f"AXI Stream end trns channel")

    await waiting_frame_status_ptr(item, tb)

    for i in range (len(apb_monitor.offsets_list)):
        ram_address = item.frame_ptr_addr_list[_tuser_rnd_frame] + apb_monitor.offsets_list[i]
        logging.critical(f"AXI read start, addr: {hex(ram_address)}")
        data_to_ram  = {ram_address: item.data_for_axis[i]}
        data_from_ram = tb.axi_ram.read(ram_address, item.data_bytes_len_ram[i])
        assert len(data_to_ram.get(ram_address)) == len(data_from_ram.hex()), f"""Length incorrect. Address = {hex(ram_address)}\n"""
        compare_two_strings_each_position(data_to_ram.get(ram_address), data_from_ram.hex())

    logging.critical("Start read and check header")
    await read_and_check_header_from_ram(tb, regmap, dut, frame_header_monitor.frame_header, 
                                        item.frame_ptr_addr_list, apb_monitor.offsets_list) ## Compare header
    logging.critical("Header is correct")
    logging.critical(f"Frames qty = {frames}")
    logging.critical("Test complete")

@cocotb.test()
async def test_default(dut):
    """DMA DEFAULT TEST"""
    SetupLog()
    tb = Connection(dut)
    apb_monitor=APBContainer()
    frame_header_monitor=FrameStatusHeaderContainer()
    logging.critical("Regmap initialize")
    regmap = a3d_regs.get_register_map(os.environ["RDL_FILE"])['DMA']

    logging.critical("Resets start")
    await Combine(misc.reset_on_clock(dut.rstn, dut.clk), misc.reset_on_clock(dut.apb_rstn, dut.clk))  # Reset phase
    logging.critical("Resets end")

    logging.critical("Test complete")
##################################
### Little sequences for tests ###
##################################
@cocotb.coroutine
async def read_and_check_header_from_ram(tb:Connection, reg, dut, frame_header_dict: dict,
                                _frame_ptr_addr_list : list, _offsets_list:list):           # Read from RAM and check
    dut._log.critical(f"HEADER FOR FRAME = {int(list(frame_header_dict.keys())[0], 16)}")
    _header_from_ram = tb.axi_ram.read_words(_frame_ptr_addr_list[int(list(frame_header_dict.keys())[0], 16)]+_offsets_list[-1] + Constants.MEM_SIZE , 32, byteorder = 'little', ws=16)
    _generated_data_for_header = frame_header_dict.get(list(frame_header_dict.keys())[0])
    Scoreboard(_generated_data_for_header, _header_from_ram, "GENERATED HEADER")

async def turn_off_dma(connect_to_dut : Connection, regs): # Turn off DMA
    await connect_to_dut.apb.reg_write(int(regs['MASK_ENABLE'].baseaddr), 0x0, verbose=True)
    await connect_to_dut.apb.reg_write(int(regs['DMA_ENABLE'].baseaddr), 0x0, verbose=True)
    while True:
        await Timer(100,'ns')
        finish_field = await connect_to_dut.apb.reg_read(regs["DMA_ENABLE"].baseaddr)
        if hex(finish_field) == Status.FINISH_FIELD:  # Waiting 1 in finish field in DMA_ENABLE reg
            break

async def clear_dma(connect_to_dut : Connection, regs): # Clear off DMA
    await connect_to_dut.apb.reg_write(int(regs['DMA_ENABLE'].baseaddr), 0x2, verbose=True)
    while True:
        await Timer(500,'ns')
        clear_field = await connect_to_dut.apb.reg_read(regs["DMA_ENABLE"].baseaddr)
        if hex(clear_field) == Status.CLEAR_FIELD:
            break

@cocotb.coroutine
async def start_parallel_sending_with_waiting_the_end(connect_to_dut:Connection, item:SeqItem, _tuser_rnd_frame): # Send axis data and waiting ending
    await Combine(send_frame_axis(connect_to_dut, item.data_for_axis, frame=_tuser_rnd_frame, channel =0),
                  send_frame_axis(connect_to_dut, item.data_for_axis, frame=_tuser_rnd_frame, channel =1),
                  send_frame_axis(connect_to_dut, item.data_for_axis, frame=_tuser_rnd_frame, channel =2),
                  send_frame_axis(connect_to_dut, item.data_for_axis, frame=_tuser_rnd_frame, channel =3),
                  send_frame_axis(connect_to_dut, item.data_for_axis, frame=_tuser_rnd_frame, channel =4),
                  send_frame_axis(connect_to_dut, item.data_for_axis, frame=_tuser_rnd_frame, channel =5))
    

async def write_frame_addr_ptr_list(item:SeqItem, connect_to_dut : Connection, regs): # Writing random addr in frame_ptr_i regs
    for i in range(len(item.frame_ptr_addr_list)):
        await connect_to_dut.apb.reg_write(regs[f"FRAME_PTR_{i}"].baseaddr, item.frame_ptr_addr_list[i])

@cocotb.coroutine
async def turn_off_clear(connect_to_dut:Connection, regs, dut):
    await Timer(random.randint(6500, 9500), 'ns')
    dut._log.critical("Waiting for shutdown DMA")
    await turn_off_dma(connect_to_dut, regs)
    dut._log.critical("DMA is disabled")
    dut._log.critical("Started clearing dma")
    await clear_dma(connect_to_dut, regs)
    dut._log.critical("Finished clearing dma")

@cocotb.coroutine
async def send_unfinished_frame(dut, connection_with_dut:Connection, regs, _en_chan, item:SeqItem, random_tuser):
    header_parallel = cocotb.start_soon(read_write_header(connection_with_dut, {})) # Start parallel write and read header

    dut._log.critical("APB write start")
    await write_frame_addr_ptr_list(item, connection_with_dut, regs)
    await connection_with_dut.apb.reg_write(regs[f"FRAME_STATUS_PTR"].baseaddr, Status.FRAME_STATUS_PTR_ADDR) # Last var is FRAME_STS_PTR addr
    dut._log.critical("APB write end")

    _offsets_list = []
    dut._log.critical("APB read offsets")
    await read_offsets(connection_with_dut, regs, _offsets_list)
    dut._log.critical("APB read offsets end")

    dut._log.critical(f"DMA and all channels enable")
    await run_channels(connection_with_dut, regs, _en_chan)

    dut._log.critical(f"AXI Stream start trns")
    cocotb.start_soon(send_frame_axis(connection_with_dut, item.data_for_axis, frame=random_tuser, channel =0))
    cocotb.start_soon(send_frame_axis(connection_with_dut, item.data_for_axis, frame=random_tuser, channel =1))
    cocotb.start_soon(send_frame_axis(connection_with_dut, item.data_for_axis, frame=random_tuser, channel =2))
    cocotb.start_soon(send_frame_axis(connection_with_dut, item.data_for_axis, frame=random_tuser, channel =3))
    cocotb.start_soon(send_frame_axis(connection_with_dut, item.data_for_axis, frame=random_tuser, channel =4))
    cocotb.start_soon(send_frame_axis(connection_with_dut, item.data_for_axis, frame=random_tuser, channel =5))
    await turn_off_clear(connection_with_dut, regs, dut)
    header_parallel.kill()
    await Timer(50000, "ns")

@cocotb.coroutine
async def waiting_frame_status_ptr(item:SeqItem, connection_with_dut : Connection):
    while True:                                          # Waiting frame status
        await Timer(10000,'ns')
        _frame_status = connection_with_dut.axi_ram.read(Status.FRAME_STATUS_PTR_ADDR, 1)
        if int.from_bytes(_frame_status, 'big') != Status.FRAME_STATUS:
            break
    return _frame_status

@cocotb.coroutine
async def read_write_header(connection_with_dut : Connection, header_dict:dict): # Random data for HEADER (send and save to dict)
    frame = await connection_with_dut.req_slave.receive_data()
    await RisingEdge(connection_with_dut.dut.clk)
    list = [random.getrandbits(128) for x in range(32)]
    await connection_with_dut.req_master.write_packet(list)
    header_dict.update({hex(frame): list})

@cocotb.coroutine
async def read_offsets(connection_with_dut : Connection, reg, _offset_empty_list:list): # Func for sendindh axis frame with sof and eof
    for i in range(Constants.OFFSETS_QTY):
        _offsets = await connection_with_dut.apb.reg_read(reg[f'OFFSET_{i}'].baseaddr)
        _offset_empty_list.append(_offsets)

@cocotb.coroutine
async def send_frame_axis_each_channel(connection_with_dut : Connection, data, channel, frame): # Func for sendind axis frame with sof and eof
    width = connection_with_dut.width_axis_list[channel]//8
    _tuser_start = (frame<<1) | 1
    _tuser_frame = (frame<<1)
    _tuser_end   = (frame<<1) | (1<<4)

    await connection_with_dut.axis_source[channel].send(AxiStreamFrame(bytearray.fromhex(data)[:width], tuser=_tuser_start))
    await connection_with_dut.axis_sink[channel].recv()
    await connection_with_dut.axis_source[channel].send(AxiStreamFrame(bytearray.fromhex(data)[width :-width], tuser=_tuser_frame))
    await connection_with_dut.axis_sink[channel].recv()
    await connection_with_dut.axis_source[channel].send(AxiStreamFrame(bytearray.fromhex(data)[-width:], tuser=_tuser_end))
    await connection_with_dut.axis_sink[channel].recv()

@cocotb.coroutine
async def send_frame_axis(connection_with_dut : Connection, data:list, frame, channel): # Func for sendind axis frame with sof and eof
    _tuser_start = (frame<<1) | 1
    _tuser_frame = (frame<<1)
    _tuser_end   = (frame<<1) | (1<<4)

    width = connection_with_dut.width_axis_list[channel]//8
    end = len(bytearray.fromhex(data[channel]))%width
    if end==0:
        end = width
    await Timer(random.randrange(1000, 5000),'ns')
    await connection_with_dut.axis_source[channel].send(AxiStreamFrame(bytearray.fromhex(data[channel])[:width], tuser=_tuser_start))
    await connection_with_dut.axis_sink[channel].recv()
    await connection_with_dut.axis_source[channel].send(AxiStreamFrame(bytearray.fromhex(data[channel])[width :-end], tuser=_tuser_frame))
    await connection_with_dut.axis_sink[channel].recv()
    await connection_with_dut.axis_source[channel].send(AxiStreamFrame(bytearray.fromhex(data[channel])[-end:], tuser=_tuser_end))
    await connection_with_dut.axis_sink[channel].recv()

@cocotb.coroutine
async def run_channels(connection_with_dut : Connection, regs, mask):  # Func for init axis channels and DMA
    regs['MASK_ENABLE'].value = mask
    regs['MASK_ENABLE'].baseaddr
    await connection_with_dut.apb.reg_write(int(regs['MASK_ENABLE'].baseaddr), mask, verbose=True) #0xc4 = Mask enable reg address
    await connection_with_dut.apb.reg_write(int(regs['DMA_ENABLE'].baseaddr), 0x1, verbose=True)

def compare_two_strings_each_position(string_1:str, string_2:str):
    for position, symbol in enumerate(string_1):
         assert symbol == string_2[position], f"Fail address offset = {hex(position*2)}"

@cocotb.coroutine
async def sendind_frames_with_stop(frame_qnt:int, item:SeqItem, connection_with_dut:Connection, dut, regs):
    for frame in range(frame_qnt):
        _tuser_rnd_frame = random.randrange(0,8)
        if frame == frame_qnt - 1:
            item.randomize()
            await start_parallel_sending_with_waiting_the_end(connection_with_dut, item, _tuser_rnd_frame)
            await turn_off_clear(connection_with_dut, regs, dut)
        else:
            item.randomize()
            await send_unfinished_frame(dut, connection_with_dut, regs, Status.ENABLE_ALL_AXIS_CHANNEL, item, _tuser_rnd_frame)
