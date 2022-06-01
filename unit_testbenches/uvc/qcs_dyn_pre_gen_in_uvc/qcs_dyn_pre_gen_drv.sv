//------------------------------------------------------------------------------
//
//  *** *** ***
// *   *   *   *
// *   *    *     Quantenna
// *   *     *    Connectivity
// *   *      *   Solutions
// * * *   *   *
//  *** *** ***
//     *
//------------------------------------------------------------------------------
class qcs_dyn_pre_gen_drv #(qcs_dyn_pre_gen_params_t PARAMS) extends uvm_driver #(qcs_dyn_pre_gen_item #(PARAMS));
    //----
    `uvm_component_param_utils(qcs_dyn_pre_gen_drv #(PARAMS))
    //---- standard variables
    qcs_dyn_pre_gen_cfg                          m_cfg;
    time                                         cur_time;
    uvm_verbosity                                local_vrb_lvl = UVM_FULL;
    bit                                          fl_new_trn, fl_trn_done;
    //item
    qcs_dyn_pre_gen_item #(PARAMS)               rqst;
    //
    bfm_trn_t                                    bfm_rqst;
    // BFM
    virtual qcs_dyn_pre_gen_drv_bfm  #(PARAMS.ADDR_W, PARAMS.BW_W, PARAMS.GAMMA_W, PARAMS.SUBBAND_W)  bfm;
    //
    extern function       new(string name = "qcs_dyn_pre_gen_drv", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
    extern task           run_phase(uvm_phase phase);
    extern task           start_trn();
    extern task           finish_trn();
    //----
    extern task           get_new_sqi();
    extern task           drive();
endclass: qcs_dyn_pre_gen_drv
//----
function qcs_dyn_pre_gen_drv::new(string name = "qcs_dyn_pre_gen_drv", uvm_component parent = null);
    super.new(name, parent);
endfunction: new
//----
function void qcs_dyn_pre_gen_drv::build_phase(uvm_phase phase);
    `uvm_info(ID, "build phase", UVM_FULL);
    super.build_phase(phase);
    if (!uvm_config_db #(qcs_dyn_pre_gen_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(ID, QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_CFG_GETTING_FAILURE)
endfunction: build_phase
//----
function void qcs_dyn_pre_gen_drv::connect_phase(uvm_phase phase);
    `uvm_info(ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    if (!uvm_config_db #(virtual qcs_dyn_pre_gen_drv_bfm #(PARAMS.ADDR_W, PARAMS.BW_W, PARAMS.GAMMA_W, PARAMS.SUBBAND_W))::get(this, "", "bfm", bfm))
        `uvm_fatal(ID, QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_BFM_GETTING_FAILURE)
endfunction: connect_phase
//----
task qcs_dyn_pre_gen_drv::run_phase(uvm_phase phase);
    `uvm_info(ID, "run phase", UVM_FULL)
    fl_new_trn  = '0;
    fl_trn_done = '0;
    @(bfm.cb);
    if (!bfm.port.reset_n) 
        @(posedge bfm.port.reset_n);
    //----
    forever begin
        fork
            get_new_sqi();
            drive();
        join
        fl_new_trn  = '0;
        fl_trn_done = '0;
    end
endtask: run_phase
//---- get new sqi
task qcs_dyn_pre_gen_drv::get_new_sqi();
    seq_item_port.get_next_item(rqst);
    start_trn();
    bfm_rqst = rqst.convert2bfm_rqst();

    fl_new_trn  = '1;
  //----
    while (!fl_trn_done) @(fl_trn_done);
    finish_trn();
    seq_item_port.item_done();
endtask: get_new_sqi


task qcs_dyn_pre_gen_drv::start_trn();
    accept_tr(rqst, 0);
    void'(begin_tr(
        rqst,
        {PARAMS.ID, "_fir_drv_stream"},
        {PARAMS.ID, " pkt drv"},
        "values",
        0
    ));
endtask: start_trn

task qcs_dyn_pre_gen_drv::finish_trn();
    void'(end_tr(rqst, 0, 0));
    `uvm_info(ID, {"The item is done:\n", rqst.convert2string(), "\n\n"}, local_vrb_lvl)
endtask: finish_trn

task qcs_dyn_pre_gen_drv::drive();
    while (!fl_new_trn) @(fl_new_trn);
    bfm.drive(bfm_rqst);
    fl_trn_done = '1;
endtask: drive
