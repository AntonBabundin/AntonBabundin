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
class qcs_dyn_pre_gen_ag_out #(
    qcs_dyn_pre_gen_params_out_t PARAMS) 
extends uvm_agent;
    //----я
    `uvm_component_param_utils(qcs_dyn_pre_gen_ag_out #(PARAMS))
    //----
    qcs_dyn_pre_gen_cfg_out                                         m_cfg;
    qcs_dyn_pre_gen_mon_out  #(PARAMS)                              m_mon;
    uvm_analysis_port        #(qcs_dyn_pre_gen_item_out #(PARAMS))  o_ap;
    //----
    extern function       new(string name = "qcs_dyn_pre_gen_ag_out", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
endclass: qcs_dyn_pre_gen_ag_out

//----
function qcs_dyn_pre_gen_ag_out::new(string name = "qcs_dyn_pre_gen_ag_out", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void qcs_dyn_pre_gen_ag_out::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
  //----
    super.build_phase(phase);
  //----
    if (!uvm_config_db #(qcs_dyn_pre_gen_cfg_out)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(PARAMS.ID, QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_CFG_GETTING_FAILURE)
  //----
    m_mon  = qcs_dyn_pre_gen_mon_out#(PARAMS)::type_id::create("m_mon",this);
endfunction: build_phase

//----
function void qcs_dyn_pre_gen_ag_out::connect_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    //----
    o_ap       = m_mon.o_ap_whole_trn;
endfunction: connect_phase
