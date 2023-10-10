export MODULE_HOME = $(shell git rev-parse --show-toplevel)
export PROJECT_HOME = $(MODULE_HOME)/../../
export MODULES_DIR = $(PROJECT_HOME)/src
export TOPLEVEL = tb
export FILELIST = all.yaml
#export TOOL = questa
export TOOL = xcelium
export WORK_LIB = artec3d
export LOG_SIM = True
export RDL_FILE = $(PWD)/tb.rdl
# export COCOTB_RESULTS_FILE = $(shell date --iso=seconds)_result.xml
#include $(PROJECT_HOME)/scripts/make/questa.make
include $(PROJECT_HOME)/scripts/make/xcelium.make

export PYTHON_TEST_FILE = $(PWD)/dma_test.py

echo:
	echo $(PROJECT_HOME)