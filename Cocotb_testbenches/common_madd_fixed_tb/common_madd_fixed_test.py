# -----------------------------------------------------
#       Company Name                   : Artec 3D
#       DUT top file name              : tb.sv
#       Function                       : AXIS template for designers
#       Required GIT Libraries         : cocotb-test 0.2.2
#       Required Proprietary Libraries : generate_filelist_for_questa
#       Main Coder                     : Babundin Anton
#       Last Сhanges                   : 10.01.2023
# -----------------------------------------------------
import generate_filelist_for_questa as questa
from cocotb_test.simulator import run
import os
import pytest
import vsc
import subprocess
from pathlib import Path

# Constants #
AP_FIXED_HEADER_PATH = "./c_model/ap_fixed"
FIXED_POINT_HEADER_PATH = "/c_model/FixedPoint.hh"
CPP_FILE_PATH = "./c_model/model.cpp"
C_MODEL_NAME_LIB = "cmodel.so"
A_B_WIDTH_MAX_SIGNED = 13
A_B_C_WIDTH_MIN_SIGNED = 2
A_B_C_WIDTH_MIN_UNSIGNED = A_B_C_WIDTH_MIN_SIGNED -1 
A_B_WIDTH_MAX_UNSIGNED = A_B_WIDTH_MAX_SIGNED-1
C_WIDTH_MAX_SIGNED = 13
C_WIDTH_MAX_UNSIGNED = C_WIDTH_MAX_SIGNED-1

_gui_start  = bool(int(os.environ["GUI"]))
settings = questa.get_questa_settings(coverage=False, xcelium=True)

sim_args = []
_test_name = "common_madd_fixed_seq"

if (os.environ['WAVES'] == "1"):
    sim_args.append('-input {:}/scripts/tcl/xcelium_database.tcl'.format(os.environ['PROJECT_HOME']))


@vsc.randobj
class module_params_c(object):
    def __init__(self):
        self._a_signed = vsc.rand_bit_t()
        self._a_width = vsc.rand_uint32_t()
        self._a_point = vsc.rand_uint32_t()

        self._b_signed = vsc.rand_bit_t()
        self._b_width = vsc.rand_uint32_t()
        self._b_point = vsc.rand_uint32_t()

        self._c_signed = vsc.rand_bit_t()
        self._c_width = vsc.rand_uint32_t()
        self._c_point = vsc.rand_uint32_t()

        self._res_wi = vsc.rand_int32_t()
        self._res_wf = vsc.rand_int32_t()

        self._awi = vsc.rand_int32_t()
        self._bwi = vsc.rand_int32_t()
        self._cwi = vsc.rand_int32_t()

        self._awf = vsc.rand_int32_t()
        self._bwf = vsc.rand_int32_t()
        self._cwf = vsc.rand_int32_t()

        self._out_signed = vsc.rand_bit_t()
        self._out_width = vsc.rand_uint32_t()
        self._out_point = vsc.rand_uint32_t()
        self._round = vsc.rand_bit_t()

        self._a_b_unsigned_width_rangelist = vsc.rangelist(vsc.rng(A_B_C_WIDTH_MIN_UNSIGNED, A_B_WIDTH_MAX_UNSIGNED))
        self._a_b_signed_width_rangelist = vsc.rangelist(vsc.rng(A_B_C_WIDTH_MIN_SIGNED, A_B_WIDTH_MAX_SIGNED))
        self._c_signed_width_rangelist = vsc.rangelist(vsc.rng(A_B_C_WIDTH_MIN_SIGNED, C_WIDTH_MAX_SIGNED))
        self._c_unsigned_width_rangelist = vsc.rangelist(vsc.rng(A_B_C_WIDTH_MIN_UNSIGNED, C_WIDTH_MAX_UNSIGNED))

    @vsc.constraint
    def a_width_c(self):
        if self._a_signed:
            self._a_width in self._a_b_signed_width_rangelist
        else:
            self._a_width in self._a_b_unsigned_width_rangelist

    @vsc.constraint
    def a_point_c(self):
        if self._a_signed:
            self._a_point in vsc.rangelist(vsc.rng(0, self._a_width-1))
        else:
            self._a_point in vsc.rangelist(vsc.rng(0, self._a_width))

    @vsc.constraint
    def b_width_c(self):
        if self._b_signed:
            self._b_width in self._a_b_signed_width_rangelist
        else:
            self._b_width in self._a_b_unsigned_width_rangelist

    @vsc.constraint
    def b_point_c(self):
        if self._b_signed:
            self._b_point in vsc.rangelist(vsc.rng(0, self._b_width-1))
        else:
            self._b_point in vsc.rangelist(vsc.rng(0, self._b_width))

    @vsc.constraint
    def c_width_c(self):
        if self._c_signed:
            self._c_width in self._c_signed_width_rangelist
        else:
            self._c_width in self._c_unsigned_width_rangelist

    @vsc.constraint
    def c_point_c(self):
        if self._c_signed:
            self._c_point in vsc.rangelist(vsc.rng(0, self._c_width-1))
        else:
            self._c_point in vsc.rangelist(vsc.rng(0, self._c_width))

    @vsc.constraint
    def out_width_point_c(self):

        self._awi == self._a_width - self._a_point
        self._bwi == self._b_width - self._b_point
        self._cwi == self._c_width - self._c_point
        
        self._awf == self._a_point
        self._bwf == self._b_point
        self._cwf == self._c_point

        self._res_wi == self._awi + self._bwi if (self._awi + self._bwi) > self._cwi else self._cwi
        self._res_wf == self._awf + self._bwf if (self._awf + self._bwf) > self._cwf else self._cwf
        
        
        self._out_width == self._res_wi + self._res_wf
        self._out_point == self._res_wf
    
    def get_a_width(self) -> int: return int(self._a_width)
    def get_a_signed(self) -> int: return int(self._a_signed)
    def get_a_point(self) -> int: return int(self._a_point)

    def get_b_width(self) -> int: return int(self._b_width)
    def get_b_signed(self) -> int: return int(self._b_signed)
    def get_b_point(self) -> int: return int(self._b_point)

    def get_c_width(self) -> int: return int(self._c_width)
    def get_c_signed(self) -> int: return int(self._c_signed)
    def get_c_point(self) -> int: return int(self._c_point)

    def get_out_width(self) -> int: return int(self._out_width)
    def get_out_signed(self) -> int: return int(self._out_signed)
    def get_out_point(self) -> int: return int(self._out_point)

    def get_ai(self) -> int: return int(self._awi)

    def get_bi(self) -> int: return int(self._bwi)

    def get_ci(self) -> int: return int(self._cwi)

    def get_outi(self) -> int: return int(self._out_width - self._out_point)

    def get_round(self) -> int: return int(self._round)

    def __str__(self) -> str:
        return f"""\n\t\t\t   A_SIGNED = {self._a_signed} , A_WIDTH = {self._a_width}, A_POINT = {self._a_point}\n
                   B_SIGNED = {self._b_signed}, B_WIDTH = {self._b_width}, B_POINT = {self._b_point}\n
                   C_SIGNED = {self._c_signed}, C_WIDTH = {self._c_width}, C_POINT = {self._c_point}\n
                   OUT_WIDTH = {self._out_width}, OUT_POINT = {self._out_point}\n
                   DDAF={self.get_a_point()}, DDAI={self.get_ai()}, DDBI={self.get_bi()}, DDBF={self.get_b_point()}, DDCI={self.get_ci()}, DDCF={self.get_c_point()}, DDOUTI={self.get_outi()}, DDOUTF={self.get_out_point()}"""
# FIXTURES(random before each test) #
@pytest.fixture
def create_item() -> module_params_c:
    p = module_params_c()
    p.randomize()
    return p

def compile_xilinx_model(compile_params:module_params_c):
    defines = [f'-DDAI={compile_params.get_ai()}', f'-DDAF={compile_params.get_a_point()}', f'-DDBI={compile_params.get_bi()}', f'-DDBF={compile_params.get_b_point()}', f'-DDCI={compile_params.get_ci()}', f'-DDCF={compile_params.get_c_point()}', f'-DDOUTI={compile_params.get_outi()}', f'-DDOUTF={compile_params.get_out_point()}']
    if compile_params.get_a_signed():
       defines.append('-DA_SIGNED=1')
    if compile_params.get_b_signed():
       defines.append('-DB_SIGNED=1')
    if compile_params.get_c_signed():
       defines.append('-DC_SIGNED=1')
    if compile_params.get_out_signed():
        defines.append('-DOUT_SIGNED=1')
    compile_command = subprocess.call(f"gcc -shared -o {Path(Path.cwd(),C_MODEL_NAME_LIB)} -fPIC {' '.join(defines)} -I ./c_model/ap_fixed ./c_model/FixedPoint.hh ./c_model/model.cpp" , shell=True, stdout=subprocess.PIPE)
    # if compile_command != 0:
    #     raise Exception("Model compilation error, please check")

def test_common_madd_fixed(create_item):
    item_in_test = create_item
    print(item_in_test)
    compile_xilinx_model(item_in_test)
    _params_to_module = {}
    _params_to_module.update({"A_WIDTH" : item_in_test.get_a_width(), "A_SIGNED" : item_in_test.get_a_signed(), "A_POINT" : item_in_test.get_a_point(),
                              "B_WIDTH" : item_in_test.get_b_width(), "B_SIGNED" : item_in_test.get_b_signed(), "B_POINT" : item_in_test.get_b_point(),
                              "C_WIDTH" : item_in_test.get_c_width(), "C_SIGNED" : item_in_test.get_c_signed(), "C_POINT" : item_in_test.get_c_point(),
                              "OUT_WIDTH" : item_in_test.get_out_width(), "OUT_POINT" : item_in_test.get_out_point(), "OUT_SIGNED" : item_in_test.get_out_signed(),
                              "ROUND" : item_in_test.get_round()})
    _params_for_test = {}
    _params_for_test.update({"A_SIGNED" : str(item_in_test.get_a_signed()),
                             "B_SIGNED" : str(item_in_test.get_b_signed()),
                             "C_SIGNED" : str(item_in_test.get_c_signed()),
                             "AI_WIDTH" : str(item_in_test.get_ai()),
                             "BI_WIDTH" : str(item_in_test.get_bi()),
                             "CI_WIDTH" : str(item_in_test.get_ci()),
                             "A_WIDTH" : str(item_in_test.get_a_width()),
                             "B_WIDTH" : str(item_in_test.get_b_width()),
                             "C_WIDTH" : str(item_in_test.get_c_width()),
                             "OUT_WIDTH": str(item_in_test.get_out_width())})
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],
        parameters           = _params_to_module,
        extra_env            = _params_for_test,

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                                                    # name of cocotb test module
    )
