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
class qcs_dyn_pre_gen_ag #(qcs_dyn_pre_gen_params_t PARAMS) 
extends uvm_agent;
    //----
    `uvm_component_param_utils(qcs_dyn_pre_gen_ag #(PARAMS))
    //----
    qcs_dyn_pre_gen_cfg                                    m_cfg;
    qcs_dyn_pre_gen_sqr  #(PARAMS)                         m_sqr;
    qcs_dyn_pre_gen_mon  #(PARAMS)                         m_mon;
    qcs_dyn_pre_gen_drv  #(PARAMS)                         m_drv;
    uvm_analysis_port    #(qcs_dyn_pre_gen_item #(PARAMS)) o_ap;
    //----
    extern function       new(string name = "qcs_dyn_pre_gen_ag", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
endclass: qcs_dyn_pre_gen_ag

//----
function qcs_dyn_pre_gen_ag::new(string name = "qcs_dyn_pre_gen_ag", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void qcs_dyn_pre_gen_ag::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
  //----
    super.build_phase(phase);
  //----
    if (!uvm_config_db #(qcs_dyn_pre_gen_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(PARAMS.ID, QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_CFG_GETTING_FAILURE)
  //----
    m_mon = qcs_dyn_pre_gen_mon#(PARAMS)::type_id::create("m_mon",this);
    m_sqr = qcs_dyn_pre_gen_sqr #(PARAMS)::type_id::create("m_sqr", this);
    m_drv = qcs_dyn_pre_gen_drv #(PARAMS)::type_id::create("m_drv", this);
endfunction: build_phase

//----
function void qcs_dyn_pre_gen_ag::connect_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    //----
    o_ap       = m_mon.o_ap_whole_trn;
    m_drv.seq_item_port.connect(m_sqr.seq_item_export);
endfunction: connect_phase
