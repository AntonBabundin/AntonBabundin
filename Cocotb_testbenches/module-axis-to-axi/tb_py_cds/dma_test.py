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
import pytest
import random
import sys
_gui_start  = bool(int(os.environ["GUI"]))
sim_args = []

_test_name = "dma_seq"
_test_case_1 = "apb_regs_seq"
_test_case_2 = "axis_channel_seq"
_test_case_3 = "axis_full_channel_seq"
_test_case_4 = "frame_reg_status_seq"
_test_case_5 = "turn_off_on_seq"
_test_case_6 = "test_default"

axis_channel = [x for x in range(6)]
frame_ptr = [x for x in range(8)]


extra_args = ['-cdslib {:}/scripts/lib/cds.lib'.format(os.environ['PROJECT_HOME']),
                '-top glbl']

if (os.environ['WAVES'] == "1"):
    sim_args.append('-input {:}/scripts/tcl/xcelium_database.tcl'.format(os.environ['PROJECT_HOME']))
##--FIXTURES--##
@pytest.fixture
def random_frames() -> int:
    return random.randrange(10, 80)

def test_regs():
    settings = questa.get_questa_settings(coverage=False, xcelium=True)
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'] +['-top glbl'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                                                 ,# name of cocotb test module
        testcase             = _test_case_1
    )

@pytest.mark.parametrize("axis_channel", axis_channel, ids=lambda x: f"CHANNEL={x}")
def test_each_axis_channel(axis_channel):
    settings = questa.get_questa_settings(coverage=False, xcelium=True)
    parameters = {}
    parameters["axis_channel"] = axis_channel
    params_for_test = {k : str(v) for k, v in parameters.items()}
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'] +['-top glbl'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],
        extra_env            = params_for_test,

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                                                 ,# name of cocotb test module
        testcase             = _test_case_2
    )

def test_full_axis_channel():
    settings = questa.get_questa_settings(coverage=False, xcelium=True)
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'] +['-top glbl'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                                                 ,# name of cocotb test module
        testcase             = _test_case_3
    )

@pytest.mark.parametrize("frame_ptr", frame_ptr, ids=lambda x: f"FRAME_REG_STATUS={x}")
def test_frame_reg_status(frame_ptr):
    settings = questa.get_questa_settings(coverage=False, xcelium=True)
    parameters = {}
    parameters["frame_ptr"] = frame_ptr
    params_for_test = {k : str(v) for k, v in parameters.items()}
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'] +['-top glbl'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],
        seed                 = 1667310453,

        extra_env            = params_for_test,

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                                                 ,# name of cocotb test module
        testcase             = _test_case_4
    )

def test_turn_off_on(random_frames):
    settings = questa.get_questa_settings(coverage=False, xcelium=True)
    parameters = {}
    parameters["frames"] = random_frames
    params_for_test = {k : str(v) for k, v in parameters.items()}
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'] +['-top glbl'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],
        seed                 = 1667310453,

        extra_env            = params_for_test,

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                                                 ,# name of cocotb test module
        testcase             = _test_case_5
    )

def test_default():
    settings = questa.get_questa_settings(coverage=False, xcelium=True)
    run(
        vhdl_sources         = settings['vhdl_sources'],                                     # vhdl sources
        verilog_sources      = settings['verilog_sources'],                                  # verilog sources
        includes             = settings['includes'],
        python_search        = settings['python_search'],                                    # python directories
        
        extra_args           = settings['extra_args'] +['-top glbl'],
        sim_args             = sim_args,
        sim_build            = settings['sim_build'],
        seed                 = 1667310453,

        force_compile        = True,
        toplevel_lang        = 'verilog',
        gui                  = _gui_start,
        toplevel             = "{:}.{:}".format(settings['work_lib'],settings['toplevel']),  # top level HDL
        module               = _test_name                                                 ,# name of cocotb test module
        testcase             = _test_case_6
    )