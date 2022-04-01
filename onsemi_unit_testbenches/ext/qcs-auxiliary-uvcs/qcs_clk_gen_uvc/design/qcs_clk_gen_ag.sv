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
class qcs_clk_gen_ag #(
  parameter string ID = ""
) extends uvm_agent;
  //----
  `uvm_component_param_utils(qcs_clk_gen_ag #(ID))
  //----
  qcs_clk_gen_cfg                       m_cfg;
  qcs_clk_gen_drv  #(ID)                m_drv;
  qcs_clk_gen_sqr                       m_sqr;

  //----
  extern function       new(string name = "qcs_clk_gen_ag", uvm_component parent = null);
  extern function void  build_phase(uvm_phase phase);
  extern function void  connect_phase(uvm_phase phase);
endclass: qcs_clk_gen_ag

//----
function qcs_clk_gen_ag::new(string name = "qcs_clk_gen_ag", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

//----
function void qcs_clk_gen_ag::build_phase(uvm_phase phase);
  `uvm_info(get_name(), "build phase", UVM_FULL);
  //----
  super.build_phase(phase);
  //----
  if (!uvm_config_db #(qcs_clk_gen_cfg)::get(this, "", "m_cfg", m_cfg))
    `uvm_fatal(ID, QCS_CLK_GEN_RPTS_CFG_GETTING_FAILURE)
  //----
  if(m_cfg.active == UVM_ACTIVE) begin
    m_sqr = qcs_clk_gen_sqr::type_id::create("m_sqr", this);
    m_drv = qcs_clk_gen_drv#(ID)::type_id::create("m_drv", this);
  end
endfunction: build_phase

//----
function void qcs_clk_gen_ag::connect_phase(uvm_phase phase);
  `uvm_info(get_name(), "connect phase", UVM_FULL);
  super.connect_phase(phase);
  //----
  if(m_cfg.active == UVM_ACTIVE)
    m_drv.seq_item_port.connect(m_sqr.seq_item_export);
endfunction: connect_phase
