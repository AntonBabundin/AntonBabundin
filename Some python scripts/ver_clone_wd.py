import subprocess
from core.logger import Logger
from core.project import Project
from pathlib import Path
import shutil

_command = {'help': "Script for clonning directory", 
            'params': [{"name": "dest", "help": "Directory, where you will copy files", "default": None}]}

def create_dir(core):
    shared_sims_storage = core.project.get_var("SHARED_SIMS_STORAGE")
    subprocess.run(['mkdir', '-m', '777', f'{shared_sims_storage}'], stderr = subprocess.DEVNULL)
    core.args.dest = input('Enter absolute path where you will start copy:\n')
    Logger.info('Start сreating dir with full permission')
    dir_name = '/'.join(str(core.args.dest).split('/')[-1:]) # For more understandable code
    try:
        Logger.info(f'Your source path: {shared_sims_storage} \n     Your destination path: clone_{dir_name}')
        subprocess.run(['mkdir', '-m', '777', f'{shared_sims_storage}/clone_{dir_name}'], stderr = subprocess.DEVNULL)
        Logger.info(f'Success, directory clone_{dir_name} is created with full permission')
    except AttributeError:
        Logger.fatal('Check path')
        return 1
    return 0

def copy_dir(core):
    shared_sims_storage = core.project.get_var("SHARED_SIMS_STORAGE")
    dir_name_where = '/'.join(str(core.args.dest).split('/')[-1:])
    Logger.info('Start cloning dir with full permission')
    files_base = ['*.yaml', 'rpt', 'session_*.f', 'cad_settings_*.f', 'design.bin', 'vsim.wlf', '*.db', '*.do',
                'txVector*.txt', 'hwregSettings*.txt', 'cSettings*.txt', 'analogSettings*.txt', 'radarSettings*.txt', 'simSettings*.txt']
    for file in files_base:
        check_files = Path(shared_sims_storage, f"clone_{dir_name_where}",file).is_file()
        if check_files == False:
            try:
                shutil.copy(Path(core.args.dest, file), Path(shared_sims_storage, f'clone_{dir_name_where}'))
            except FileNotFoundError:
                Logger.warning(f'{file} file copy not success, please check files')
            else:
                Logger.info(f'{file} file copy success')
        else:
            Logger.warning(f'{file} file exist')
    subprocess.call(f'chmod -R 777 {shared_sims_storage}/clone_{dir_name_where}', shell = True, stderr = subprocess.DEVNULL)
    Logger.info('Success cloning dir with full permission')
    return 0

def run(core):
    create_dir(core)
    copy_dir(core)
