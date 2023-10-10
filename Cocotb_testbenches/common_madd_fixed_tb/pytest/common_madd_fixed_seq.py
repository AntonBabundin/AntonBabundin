# -----------------------------------------------------
#       Company Name                   : Artec 3D
#       Pytest top file name           : axi_template_test.py
#       DUT top file name              : tb.sv
#       Function                       : AXIS template for designers
#       Required GIT Libraries         : cocotb 1.6.2, cocotb-test 0.2.2, cocotbext-axi 0.1.18, cocotb-bus 0.2.1 
#       Main Coder                     : Babundin Anton
#       Last Сhanges                   : 10.01.2023
# -----------------------------------------------------
#Cocotb libs
import cocotb
from cocotb.triggers import Timer
from cocotb.types import LogicArray, Range
from ctypes import *
import os
import random
from misc import reset_on_clock
from artec3d_vr import artec_vr_master, artec_vr_slave

LIB_PATH = '../cmodel.so'


class Connection:
    def __init__(self, dut):
        self.dut = dut
        print(self.dut.master.data.value)
        self.master_vr = artec_vr_master(dut.master, name=None, clock=dut.clk)
        self.slave_vr = artec_vr_slave(dut.slave, name=None, clock=dut.clk)

class SeqItem:
    def __init__(self, ai_width, bi_width, ci_width, a_signed, b_signed, c_signed) -> None:
        self._ai_width = ai_width
        self._bi_width = bi_width
        self._ci_width = ci_width

        self._a_signed = a_signed
        self._b_signed = b_signed
        self._c_signed = c_signed

    def _randomize_a(self):
        if self._a_signed:
            self.a_val = random.uniform(-1*((2**self._ai_width)/2), ((2**self._ai_width)/2)-1)
        else:
            self.a_val = random.uniform(0, (2**self._ai_width)-1)

    def _randomize_b(self):
        if self._b_signed:
            self.b_val = random.uniform(-1*((2**self._bi_width)/2), ((2**self._bi_width)/2)-1)
        else:
            self.b_val = random.uniform(0, (2**self._bi_width)-1)

    def _randomize_c(self):
        if self._c_signed:
            self.c_val = random.uniform(-1*((2**self._ci_width)/2), ((2**self._ci_width)/2)-1)
        else:
            self.c_val = random.uniform(0, (2**self._ci_width)-1)

    def randomize(self):
        self._randomize_a()
        self._randomize_b()
        self._randomize_c()

@cocotb.test()
async def simple_test(dut):
    ### Create connection ###
    connect_with_dut = Connection(dut)
    a_signed = int(os.environ.get('A_SIGNED'))
    b_signed = int(os.environ.get('B_SIGNED'))
    c_signed = int(os.environ.get('C_SIGNED'))
    ai_width = int(os.environ.get('AI_WIDTH'))
    bi_width = int(os.environ.get('BI_WIDTH'))
    ci_width = int(os.environ.get('CI_WIDTH'))
    a_width = int(os.environ.get('A_WIDTH'))
    b_width = int(os.environ.get('B_WIDTH'))
    c_width = int(os.environ.get('C_WIDTH'))
    out_width = int(os.environ.get('OUT_WIDTH'))
    item = SeqItem(ai_width, bi_width, ci_width, a_signed, b_signed, c_signed)
    item.randomize()

    testlib = cdll.LoadLibrary(LIB_PATH)
    testlib.get_madd.argtypes = POINTER(c_float), POINTER(c_int32)
    data_in = (c_float*3)(c_float(item.a_val), c_float(item.b_val), c_float(item.c_val))
    data_out = (c_int32*4)()
    testlib.get_madd(data_in, data_out)
    print(list(data_in))
    print(list(data_out))
    ###   Start   reset   ###
    await reset_on_clock(dut.rstn, dut.clk, active_level=0)
    # Wait 100 ns ###
    await Timer(100, 'ns')
    a_value = int(list(data_out)[0]) & ((1<<a_width) - 1)
    b_value = int(list(data_out)[1]) & ((1<<b_width) - 1)
    c_value = int(list(data_out)[2]) & ((1<<c_width) - 1)
    print (a_value,b_value,c_value)
    tmp = (a_value << (b_width + c_width)) | (b_value<< c_width) | (c_value) 
    print (tmp)
    hex
    await connect_with_dut.master_vr.write_data(tmp)
    out = await connect_with_dut.slave_vr.receive_data()
    dut._log.critical(f"OUT FROM RTL: {hex(out)}")
    dut._log.critical(f"OUT FROM C_MODEL: {hex(list(data_out)[3] & ((1<<out_width)-1))}")