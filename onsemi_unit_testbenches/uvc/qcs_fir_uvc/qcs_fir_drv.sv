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
class qcs_fir_drv #(qcs_fir_params_t PARAMS = QCS_FIR_DFLT_PARAMS) extends uvm_driver #(qcs_fir_item #(PARAMS));
    //----
    `uvm_component_param_utils(qcs_fir_drv #(PARAMS))
    //---- standard variables
    qcs_fir_cfg                             m_cfg;
    time                                    cur_time;
    uvm_verbosity     local_vrb_lvl    =    UVM_FULL;
    bit                                   fl_new_trn, fl_trn_done;
    //item
    qcs_fir_item #(PARAMS)                  rqst;
    //
    bfm_trn_t                               bfm_rqst;
    // BFM
    virtual qcs_fir_drv_bfm  #(PARAMS.DW)   bfm;
    //
    extern function       new(string name = "qcs_fir_drv", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
    extern task           run_phase(uvm_phase phase);
    extern task           start_trn();
    extern task           finish_trn();
    //----
    extern task           get_new_sqi();
    extern task           drive();
endclass: qcs_fir_drv
//----
function qcs_fir_drv::new(string name = "qcs_fir_drv", uvm_component parent = null);
    super.new(name, parent);
endfunction: new
//----
function void qcs_fir_drv::build_phase(uvm_phase phase);
    `uvm_info(ID, "build phase", UVM_FULL);
    super.build_phase(phase);
    if (!uvm_config_db #(qcs_fir_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(ID, QCS_FIR_RPTS_CFG_GETTING_FAILURE)
endfunction: build_phase
//----
function void qcs_fir_drv::connect_phase(uvm_phase phase);
    `uvm_info(ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    if (!uvm_config_db #(virtual qcs_fir_drv_bfm #(PARAMS.DW))::get(this, "", "bfm", bfm))
        `uvm_fatal(ID, QCS_FIR_RPTS_BFM_GETTING_FAILURE)
endfunction: connect_phase
//----
task qcs_fir_drv::run_phase(uvm_phase phase);
    `uvm_info(ID, "run phase", UVM_FULL)
    fl_new_trn  = '0;
    fl_trn_done = '0;
    @(bfm.cb);
    if (!bfm.port.reset_n) 
        @(posedge bfm.port.reset_n);
        @(bfm.cb);
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
task qcs_fir_drv::get_new_sqi();
    seq_item_port.get_next_item(rqst);
    start_trn();
    bfm_rqst = rqst.convert2bfm_rqst();

    fl_new_trn  = '1;
  //----
    while (!fl_trn_done) @(fl_trn_done);
    finish_trn();
    seq_item_port.item_done();
endtask: get_new_sqi


task qcs_fir_drv::start_trn();
    cur_time = $time;
    accept_tr(rqst, cur_time);
    void'(begin_tr(
        rqst,
        {PARAMS.ID, "_fir_drv_stream"},
        {PARAMS.ID, " pkt drv"},
        "values",
        cur_time
    ));
endtask: start_trn

task qcs_fir_drv::finish_trn();
    void'(end_tr(rqst, $time));
    `uvm_info(ID, {"The item is done:\n", rqst.convert2string(), "\n\n"}, local_vrb_lvl)
endtask: finish_trn

task qcs_fir_drv::drive();
    while (!fl_new_trn) @(fl_new_trn);
    bfm.drive(bfm_rqst);
    fl_trn_done = '1;
endtask: drive
