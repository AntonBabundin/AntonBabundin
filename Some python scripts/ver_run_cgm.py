import subprocess
import git
import shutil
import zipfile
import yaml
import re
from pathlib import Path
from core.logger import Logger
_run_dir = Path().absolute()

_mode_list = ['shared', 'original', 'update']
_files_base = ['main.so', 'str2cfg.py']
_files_base_to_del = ['main.so', 'str2cfg.py', 'txRxTest11ac', 'dpi_defines.svh']
_c_model_arch = 'c_model.zip'
_c_model_meta = 'c_model_meta.txt'
_main_cmpl_output = 'main.so'
_makefile_name = 'makefile.f'
_dir_with_settings_name = 'txRxTest11ac'
_files_to_del = ['test', 'src', 'Readme.txt', 'makefile.f', 'build', 'modules', 'prj', 
                'CMakeLists.txt', 'exec_regression', 'rtl_test.mk', 'run_precommit', 'RFICfiles']

_command = {"help": "This command is for clone and compile C model from SYS repo with different modes.", 
            "params": [{"name": "mode",
                        "help": f"You need choose 1 of 3 modes: {','.join(_mode_list)}",
                        "default": _mode_list[0]},

                       {"name": "repo_commit",
                        "help": "Hash or branch name",
                        "default": None}]}
####Main func(Start for script)####
def run(core):
    path_to_zip = core.project.get_var("GM_DIR")
    if core.args.mode == _mode_list[0]:
        check_zip = Path(path_to_zip, _c_model_arch).is_file()
        check_meta = Path(path_to_zip, _c_model_meta).is_file()
        if not check_zip: # check exist zip
            Logger.fatal(f"Please add: {_c_model_arch} to dir: {path_to_zip}.\nAnd rerun script")
        elif not check_meta: # check exist meta
            Logger.fatal(f"Please add: {_c_model_meta} to dir: {path_to_zip}.\nAnd rerun script")
        elif not (check_zip and check_meta):
            Logger.fatal(f"Please add: {_c_model_arch} and {_c_model_meta}  to dir: {path_to_zip}.\nAnd rerun script")
        else:
            unpack_zip(path_to_zip)
            copy_dir(path_to_zip)
            Logger.info("Script completed")
    elif core.args.mode == _mode_list[1]:
        check_repo = Path(_makefile_name).is_file()
        if not check_repo: # check exist repo
            seq_with_clone_repo(core, path_to_zip)
        else:
            seq_without_clone_repo(core)
####Internal functions####
def seq_with_clone_repo(core, path_to_zip):
    clone_git_repo(core, path_to_zip)
    c_main_cmpl(core)
    clear_repo_dir()
    return 0

def seq_without_clone_repo(core):
    c_main_cmpl(core)
    clear_repo_dir()
    return 0

def clear_repo_dir():
    shutil.copytree(Path(Path.cwd(), "test", _dir_with_settings_name), Path.cwd(), dirs_exist_ok = True) # Copy all settings from folder
    for file in _files_to_del:
        Path(Path.cwd(), file).unlink()
    Logger.info("Script completed")

def unpack_zip(_path_to_zip):
    Logger.info(f'Unpacking {_c_model_arch}')
    with zipfile.ZipFile(f'{Path(_path_to_zip, _c_model_arch)}',"r") as zip_ref:
        try:
            zip_ref.extractall(_path_to_zip)
        except FileNotFoundError:
            Logger.fatal("Error, unpacking fail")
        else:
            Logger.info("Unpacking success!!")
            return 0

def copy_dir(_path_to_zip):
    Logger.info('Start cloning files')
    shutil.copy(Path(_path_to_zip, _c_model_meta), _run_dir)
    try:
        shutil.copy(Path(_path_to_zip, _dir_with_settings_name, "*"), _run_dir)
    except FileNotFoundError:
        Logger.warning("File copy doesn't success, please check files")
    else:
        Logger.info('Files copy success')
    for file in _files_base:
        try:
            shutil.copy(Path(_path_to_zip, file), _run_dir)
        except FileNotFoundError:
            Logger.warning(f'{file} file copy not success, please check files')
        else:
            Logger.info(f'{file} file copy success')
    Logger.info('Delete unnecessary files')
    for file in _files_base_to_del:
        Path(_path_to_zip, file).unlink()
    Logger.info(f'Success cloning to dir {_run_dir}')
    return 0

def clone_git_repo(core, _path_to_zip):
    git_repo_commit = core.args.repo_commit
    git_repo_addr   = core.project.get_var("GIT_SYS_REP_ADDR")
    def clone_git(commit):
        git.Git().clone(git_repo_addr)
        git.cmd.Git().pull()
        subprocess.run(['git', 'init'], stderr = subprocess.DEVNULL)
        subprocess.run(['git', 'remote', 'add', 'origin', f"{git_repo_addr}"], stderr = subprocess.DEVNULL)
        subprocess.run(['git', 'fetch', '--depth', '1', "--recurse-submodules", '--no-tags', 'origin',  f"{commit}"], stderr = subprocess.DEVNULL)
        subprocess.run(['git', 'reset', '--hard', 'FETCH_HEAD'], stderr = subprocess.DEVNULL)
        subprocess.run(['git', 'submodule', 'update', '--init'], stderr = subprocess.DEVNULL)
        return 0
    if git_repo_commit == None:
        Logger.info(f"You use default commit from {_c_model_meta}")
        with open(f"{Path(_path_to_zip, _c_model_meta)}", mode = 'r', encoding = 'utf-8') as f:
            content = f.readlines()
            string = ''.join(content)
        commit_dflt = re.search(r'commit (\w+)', string).group(1) # Reading commit from meta with regexp
        Logger.info("Clonning sys repo")
        clone_git(commit_dflt)
    else:
        Logger.info("Clonning sys repo")
        clone_git(git_repo_commit)
        return 0

def c_main_cmpl(core):
    def from_str_to_list(str) -> list:     # Return list with absolute path for each element
        intermediate_list = str.split()
        return [f"{_run_dir}/"+ str_in_list for str_in_list in intermediate_list]
    # Reading make
    with open(_makefile_name, mode = 'r', encoding = 'utf-8') as f:
        Logger.info(f"Reading data from {_makefile_name}")
        content = f.readlines()
        makefile_list = []
        for string in content:
            new_string = string.replace("\\\n", "")
            makefile_list.append(new_string)
    string = ' '.join(makefile_list)  # from overall list to overall string
    # Strings with paths
    clib_cpp_files_string = string[ : string.find('CLIB_INCLUDE_DIRS')].replace("CLIB_MODEM11AC_CPPFILES := ", "")
    clib_dirs_string = string[string.find('$(CLIB_DIR)') : string.find(" CLIB_MODEM11AC_OBJFILES")].replace("$(CLIB_DIR)/", "")
    clib_h_files_string = clib_cpp_files_string.replace(".cpp", ".h")
    clib_o_files_string = clib_cpp_files_string.replace(".cpp", ".o")
    # Lists with paths
    clib_o_files_list = from_str_to_list(clib_o_files_string)
    clib_h_files_list = from_str_to_list(clib_h_files_string)
    clib_cpp_files_list = from_str_to_list(clib_cpp_files_string)
    clib_dirs_list = from_str_to_list(clib_dirs_string)
    # Flags for compile obj and so files
    tool = core.get_tool("CPP")    # Get c++ compilator path from tools.yaml
    tool.setup()
    with open(core.project.get_var('GCC_SETTING_BASE'), "r") as stream:  # Open gcc.yaml with flags
        flags_dict = (yaml.safe_load(stream))
    comp_flags = flags_dict["compilation"]
    _so_flags = comp_flags["so_flags"]
    _cosim_defs = comp_flags["defines"]
    _obj_flags = f'{comp_flags["obj_flags"]} -I {" -I ".join(clib_dirs_list)} -I {Path(tool.lib,"..", "include")} {_cosim_defs} '
    Logger.info("Start compilation")
    for i in range(len(clib_cpp_files_list)):
        check_cmpl = subprocess.call(f"{Path(tool.bin_path, tool.executable)} {_obj_flags} -o {clib_o_files_list[i]} {clib_cpp_files_list[i]}", shell=True, stderr = subprocess.DEVNULL)
        if check_cmpl != 0:
            Logger.fatal(f"{clib_cpp_files_list[i]} was not compiled")
        else:
            Logger.info(f"{clib_cpp_files_list[i]} was compiled")
    # Compile .so file
    check_so = subprocess.call(f"{Path(tool.bin_path, tool.executable)} {_so_flags} -o {_main_cmpl_output} {' '.join(clib_o_files_list)}", shell=True, stderr = subprocess.DEVNULL)
    if check_so != 0:
        Logger.fatal(f"{_main_cmpl_output} was not compiled")
    else:
        Logger.info(f"{_main_cmpl_output} was compiled")
        Logger.info("Compilation Success")
        return 0