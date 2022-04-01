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
class start_tst extends base_tst;
  `uvm_component_utils(start_tst)
  //----
  extern function      new(string name = "start_tst", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
endclass: start_tst

//----
function start_tst::new(string name = "start_tst", uvm_component parent = null);
  super.new (name, parent);
endfunction: new

//----
function void start_tst::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_name(), "build phase", UVM_FULL);
  //---- modification
  m_clk_gen_cfg0.vrb_lvl_drv       = UVM_LOW;
  m_rst_gen_cfg0.vrb_lvl_drv       = UVM_LOW;
  //---- saving
  uvm_config_db#(tb_cfg)::set(this, "*m_env*", "m_cfg", m_env_cfg);
  uvm_config_db#(qcs_clk_gen_cfg)::set(this, "*m_clk_gen0*", "m_cfg", m_clk_gen_cfg0);
  uvm_config_db#(qcs_rst_gen_cfg)::set(this, "*m_rst_gen0*", "m_cfg", m_rst_gen_cfg0);
  //---- create test environment
  m_env = tb_env::type_id::create("m_env", this);
  //----
  uvm_config_db#(uvm_object_wrapper)::set(this,"m_env.m_vsqr.run_phase", "default_sequence", start_sq::type_id::get());
endfunction: build_phase