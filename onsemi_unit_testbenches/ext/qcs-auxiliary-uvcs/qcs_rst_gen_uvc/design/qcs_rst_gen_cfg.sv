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
class qcs_rst_gen_cfg extends uvm_object;
  `uvm_object_utils(qcs_rst_gen_cfg)
  //----
  uvm_active_passive_enum active = UVM_ACTIVE;

  //---- verbosity levels and reports
  uvm_verbosity vrb_lvl_drv = UVM_HIGH; //UVM_LOW UVM_HIGH
  uvm_verbosity vrb_lvl_sqr = UVM_HIGH; //UVM_LOW UVM_HIGH

  //----
  rst_level_t dflt_rst_lvl = RST_LVL_PASSIVE;

  //----
  extern function              new(string name = "qcs_rst_gen_cfg");
  extern function qcs_rst_gen_cfg  get_config(uvm_component c);
endclass: qcs_rst_gen_cfg

//----
function qcs_rst_gen_cfg::new(string name = "qcs_rst_gen_cfg");
  super.new(name);
endfunction: new

//----
function qcs_rst_gen_cfg qcs_rst_gen_cfg::get_config(uvm_component c);
  qcs_rst_gen_cfg t;
  if (!uvm_config_db #(qcs_rst_gen_cfg)::get(c, "", "qcs_rst_gen_cfg", t) ) begin
    `uvm_fatal(get_type_name(), QCS_RST_GEN_RPTS_CFG_GETTING_FAILURE)
  end
  return t;
endfunction: get_config
