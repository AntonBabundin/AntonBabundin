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
class qcs_rst_gen_sqr extends uvm_sequencer #(qcs_rst_gen_item);
  `uvm_component_utils(qcs_rst_gen_sqr)
  //----
  qcs_rst_gen_cfg   m_cfg;
  uvm_verbosity local_vrb_lvl = UVM_LOW;
  //----
  extern function       new(string name = "qcs_rst_gen_sqr", uvm_component parent = null);
  extern function void  build_phase(uvm_phase phase);
  extern task           run_phase(uvm_phase phase);
endclass: qcs_rst_gen_sqr

//----
function qcs_rst_gen_sqr::new(string name = "qcs_rst_gen_sqr", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

//----
function void qcs_rst_gen_sqr::build_phase(uvm_phase phase);
  `uvm_info(get_name(), "build phase", UVM_FULL);
  super.build_phase(phase);
  if (!uvm_config_db #(qcs_rst_gen_cfg)::get(this, "", "m_cfg", m_cfg))
    `uvm_fatal(get_name(), QCS_RST_GEN_RPTS_CFG_GETTING_FAILURE)
  local_vrb_lvl = m_cfg.vrb_lvl_sqr;
endfunction: build_phase

//----
task qcs_rst_gen_sqr::run_phase(uvm_phase phase);
endtask: run_phase
