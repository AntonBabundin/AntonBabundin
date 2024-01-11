COMPILE_OPTS = PROJECT_HOME=$(PROJECT_HOME) XSC_DIR_ENV=$(XSC_DIR) TB_DIR_ENV=$(PWD) BUILD_OPT_ENV=compile TOP_LEVEL_ENV=$(TOP_LEVEL) PROJECT_NAME_ENV=$(PROJECT_NAME) DUMPDB_ENV=$(DUMPDB) DATABASE_FILE_ENV=$(PWD)/waves.wdb
ELAB_OPTS    = PROJECT_HOME=$(PROJECT_HOME) XSC_DIR_ENV=$(XSC_DIR) TB_DIR_ENV=$(PWD) BUILD_OPT_ENV=elaborate TOP_LEVEL_ENV=$(TOP_LEVEL) PROJECT_NAME_ENV=$(PROJECT_NAME) DUMPDB_ENV=$(DUMPDB) DATABASE_FILE_ENV=$(PWD)/waves.wdb
SIM_OPTS     = PROJECT_HOME=$(PROJECT_HOME) XSC_DIR_ENV=$(XSC_DIR) TB_DIR_ENV=$(PWD) BUILD_OPT_ENV=simulate TOP_LEVEL_ENV=$(TOP_LEVEL) PROJECT_NAME_ENV=$(PROJECT_NAME) DUMPDB_ENV=$(DUMPDB) DATABASE_FILE_ENV=$(PWD)/waves.wdb
ALL_OPTS     = PROJECT_HOME=$(PROJECT_HOME) XSC_DIR_ENV=$(XSC_DIR) TB_DIR_ENV=$(PWD) BUILD_OPT_ENV=all TOP_LEVEL_ENV=$(TOP_LEVEL) PROJECT_NAME_ENV=$(PROJECT_NAME) DUMPDB_ENV=$(DUMPDB) DATABASE_FILE_ENV=$(PWD)/waves.wdb

export PYTHONPATH = $(PROJECT_HOME)/scripts/

include $(PROJECT_HOME)/scripts/make/image.make

WAVES ?= 0
SIM ?= questa
SIM_BUILD ?= sim_build
EXPORT_SIM_DIR ?= export_sim
COVERAGE ?= 0
TEST ?= 0
GUI ?= 0
export_sim:
	python $(PROJECT_HOME)/scripts/generate_filelist_for_questa.py --filelist $(FILELIST) --toplevel $(TOP_LEVEL) --work_root $(EXPORT_SIM_DIR)

run:
	COVERAGE=$(COVERAGE) SIM_BUILD=$(SIM_BUILD) GUI=$(GUI) WAVES=$(WAVES) SIM=$(SIM) pytest -o log_cli=$(LOG_SIM) --capture=no --cocotbxml=$(shell date +'test_%m.%d_%H.%M.%S.xml') -s $(PYTHON_TEST_FILE)

run_spec_test:
	COVERAGE=$(COVERAGE) SIM_BUILD=$(SIM_BUILD) GUI=$(GUI) WAVES=$(WAVES) SIM=$(SIM) pytest -o log_cli=$(LOG_SIM) --capture=no --cocotbxml=$(shell date +'test_%m.%d_%H.%M.%S.xml') -s $(PYTHON_TEST_FILE)::$(TEST)

view:
	vsim -do view $(SIM_BUILD)/vsim.wlf

view_coverage:
	vsim -do "coverage open $(SIM_BUILD)/cover.ucdb" 