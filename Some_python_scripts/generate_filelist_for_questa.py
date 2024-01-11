import sys
import os
import shutil
import pandas as pd
import filelist_yaml as fly

def get_questa_settings(coverage=False, xcelium=False):

    toplevel  = os.environ['TOPLEVEL']
    filelist  = os.environ['FILELIST']
    tool      = os.environ['SIM']
    work_lib  = os.environ['WORK_LIB']
    sim_build = os.environ['SIM_BUILD']

    df = fly.get_df(filelist = filelist, work_lib_in = work_lib)

    df_sv_src   = df[df['filetype']=='systemVerilogSource']
    df_v_src    = df[df['filetype']=='verilogSource']
    df_vhdl_src = df[df['filetype']=='vhdlSource']
    df_py_src   = df[df['filetype']=='pythonSource']
    df_dat_src  = df[df['filetype']=='dataSource']

    svv_global = df_sv_src[df_sv_src['global']==True]

    vhdl_compile_args = []
    verilog_sources = {}
    vhdl_sources = {}
    python_search = []    
    includes = []
    data_sources = []
    # Initialisation inputs to cocotb
    if coverage == True:
        verilog_compile_args = ['-mfcu', '-cover', 'bcesf', '+acc']
        sim_args = ['-coverage ', '-vopt', '-c', '-do', '"coverage save -onexit -directive -codeAll cover.ucdb;"']
        reprot_cover = ['vcover', 'report', '-output', 'coverage_report.txt', 'cover.ucdb'] ## I WILL ADD IN FUTURE
    elif xcelium == True:
        verilog_compile_args = []
        sim_args = []
        extra_args = ['+sv', '-cdslib {:}/scripts/lib/cds.lib'.format(os.environ['PROJECT_HOME'])]
    else:
        verilog_compile_args = ['-mfcu']
        sim_args = []
        extra_args = []

    # Fill the inputs

    includes = list(set([os.path.dirname(x) for x in df[df['include']==True]['filepath'].values.tolist()]))

    python_search = list(set([os.path.dirname(x) for x in df_py_src['filepath'].values.tolist()]))

    data_sources = df[df['filetype']=='dataSource']['filepath'].values.tolist()

    # SystemVerilog & Verilog

    for lib in df_sv_src['library'].unique():

        if (lib not in verilog_sources):
            verilog_sources[lib] = []

        verilog_sources[lib] += df_sv_src[df_sv_src['library']==lib]['filepath'].values.tolist()

    for lib in df_v_src['library'].unique():

        if (lib not in verilog_sources):
            verilog_sources[lib] = []

        verilog_sources[lib] += df_v_src[df_v_src['library']==lib]['filepath'].values.tolist()

    # VHDL

    for lib in df_vhdl_src['library'].unique():

        if (lib not in vhdl_sources):
            vhdl_sources[lib] = []

        vhdl_sources[lib] += df_vhdl_src[df_vhdl_src['library']==lib]['filepath'].values.tolist()

    # Copy data files to work_dir
    if (os.path.exists(sim_build)==False):
        os.mkdir(sim_build)

    for f in data_sources:
        shutil.copy(f,sim_build)

    # Output settings 
    output = {'verilog_sources'      : verilog_sources,
              'vhdl_sources'         : vhdl_sources,
              'includes'             : includes,
              'python_search'        : python_search,
              'work_lib'             : work_lib,
              'sim_build'            : sim_build,
              'tool'                 : tool,
              'toplevel'             : toplevel,
              'verilog_compile_args' : verilog_compile_args,
              'vhdl_compile_args'    : vhdl_compile_args,
              'sim_args'             : sim_args,
              'extra_args'           : extra_args}

    return output
