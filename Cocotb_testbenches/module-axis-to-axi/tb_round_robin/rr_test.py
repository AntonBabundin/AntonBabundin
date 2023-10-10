# -----------------------------------------------------
#       Company Name                   : Artec 3D
#       DUT top file name              : tb.sv
#       Function                       : Script for starting regressions or single tests
#       Last Сhanges                   : 
#       Required GIT Libraries         : cocotb-test 0.2.2, pytest 7.1.2
#       Required Proprietary Libraries : generate_filelist_for_questa
#       Main Coder                     : Babundin Anton
# -----------------------------------------------------
import generate_filelist_for_questa as questa 
from cocotb_test.simulator import run
import os
_gui_start  = bool(int(os.environ["GUI"]))
sim_args = []

_test_name = "rr_seq"


if (os.environ['WAVES'] == "1"):
    sim_args.append('-input {:}/scripts/tcl/xcelium_database.tcl'.format(os.environ['PROJECT_HOME']))

def test_regs():
    settings = questa.get_questa_settings(coverage=False, xcelium=True)
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                   
    )