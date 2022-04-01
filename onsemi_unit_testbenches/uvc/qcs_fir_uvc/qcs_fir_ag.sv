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
class qcs_fir_ag #(
    qcs_fir_params_t PARAMS = QCS_FIR_DFLT_PARAMS) 
extends uvm_agent;
    //----
    `uvm_component_param_utils(qcs_fir_ag #(PARAMS))
    //----
    qcs_fir_cfg             m_cfg;
    qcs_fir_sqr  #(PARAMS)  m_sqr;
    qcs_fir_mon  #(PARAMS)  m_mon;
    qcs_fir_drv  #(PARAMS)  m_drv;
    uvm_analysis_port #(qcs_fir_item #(PARAMS))  o_ap;
    //----
    extern function       new(string name = "qcs_fir_ag", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
endclass: qcs_fir_ag

//----
function qcs_fir_ag::new(string name = "qcs_fir_ag", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void qcs_fir_ag::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
  //----
    super.build_phase(phase);
  //----
    if (!uvm_config_db #(qcs_fir_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(PARAMS.ID, QCS_FIR_RPTS_CFG_GETTING_FAILURE)
  //----
    m_mon  = qcs_fir_mon#(PARAMS)::type_id::create("m_mon",this);
    if(m_cfg.active == UVM_ACTIVE) begin
        m_sqr = qcs_fir_sqr #(PARAMS)::type_id::create("m_sqr", this);
        m_drv = qcs_fir_drv #(PARAMS)::type_id::create("m_drv", this);
    end
endfunction: build_phase

//----
function void qcs_fir_ag::connect_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    //----
    o_ap       = m_mon.o_ap_whole_trn;
    //----
    if(m_cfg.active == UVM_ACTIVE) begin
        m_drv.seq_item_port.connect(m_sqr.seq_item_export);
    end
endfunction: connect_phase
