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
class qcs_dyn_pre_gen_mon #(qcs_dyn_pre_gen_params_t PARAMS) extends uvm_monitor;
//----
    `uvm_component_param_utils(qcs_dyn_pre_gen_mon #(PARAMS))
    qcs_dyn_pre_gen_item #(PARAMS) trn, trn2out;
    //----
    qcs_dyn_pre_gen_cfg            m_cfg;
    //----
    int                            trn_id;
    uvm_verbosity                  local_vrb_lvl = UVM_LOW;
    bfm_trn_t                      bfm_trn;
    time                           cur_time;
    event                          e_end_of_trn;
    //---- BFM
    virtual qcs_dyn_pre_gen_mon_bfm #(PARAMS.ADDR_W, PARAMS.BW_W, PARAMS.GAMMA_W, PARAMS.SUBBAND_W)     bfm;
    //---- Ananalysis port
    uvm_analysis_port               #(qcs_dyn_pre_gen_item #(PARAMS))                                   o_ap_whole_trn;
    //---- user defined variables
    extern function       new(string name = "qcs_dyn_pre_gen_mon", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
    extern task           run_phase(uvm_phase phase);
    //----
    extern task           reporter();
    extern task           collector();
    extern task           start_trn();
    extern task           finish_trn();
endclass: qcs_dyn_pre_gen_mon

//----
function qcs_dyn_pre_gen_mon::new(string name = "qcs_dyn_pre_gen_mon", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void qcs_dyn_pre_gen_mon::build_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "build phase", UVM_FULL);
    super.build_phase(phase);
    if (!uvm_config_db #(qcs_dyn_pre_gen_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(ID, QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_CFG_GETTING_FAILURE)
    o_ap_whole_trn  = new("o_ap_whole_trn", this);
    local_vrb_lvl       = m_cfg.vrb_lvl_mon;
endfunction: build_phase

//----
function void qcs_dyn_pre_gen_mon::connect_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    if (!uvm_config_db #(virtual qcs_dyn_pre_gen_mon_bfm #(PARAMS.ADDR_W, PARAMS.BW_W, PARAMS.GAMMA_W, PARAMS.SUBBAND_W))::get(this, "", "bfm", bfm))
        `uvm_fatal(ID, QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_BFM_GETTING_FAILURE)
endfunction: connect_phase

task qcs_dyn_pre_gen_mon::run_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "run phase", UVM_FULL)
    trn = qcs_dyn_pre_gen_item #(PARAMS)::type_id::create({ID, "_tmp_trn"});
    trn_id = 0;
    bfm.start_mon();
    fork
        reporter();
        collector();
    join_none
endtask: run_phase

//----
task qcs_dyn_pre_gen_mon::reporter();
    forever begin
        @e_end_of_trn;
        trn2out = qcs_dyn_pre_gen_item #(PARAMS)::type_id::create({ID, "_whole_trn"});
        trn2out.copy(trn);
        trn2out.set_transaction_id(trn_id++);
        o_ap_whole_trn.write(trn2out);
    end
endtask: reporter

task qcs_dyn_pre_gen_mon::collector();
    forever begin
        @(bfm.e_pkt_rdy);
        start_trn();
        bfm_trn = bfm.get_pkt();
        trn.convert2sqi(bfm_trn);
        finish_trn();
        -> e_end_of_trn;
    end
endtask: collector

task qcs_dyn_pre_gen_mon::start_trn();
    cur_time = $time;
    accept_tr(trn, cur_time);
    void'(begin_tr(
        trn,
        {PARAMS.ID, "_mon_stream"},
        PARAMS.ID,
        "gen packet",
        cur_time
    ));
endtask

task qcs_dyn_pre_gen_mon::finish_trn();
    void'(end_tr(trn, $time));
endtask