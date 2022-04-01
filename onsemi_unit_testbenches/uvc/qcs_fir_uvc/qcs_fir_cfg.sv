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
class qcs_fir_cfg extends uvm_object;
    `uvm_object_utils(qcs_fir_cfg)
    //----
    uvm_active_passive_enum active            = UVM_ACTIVE;
    //---- verbosity levels and reports
    uvm_verbosity vrb_lvl_mon = UVM_LOW; //UVM_FULL UVM_HIGH
    uvm_verbosity vrb_lvl_drv = UVM_LOW; //UVM_FULL UVM_HIGH
    uvm_verbosity vrb_lvl_sqr = UVM_LOW; //UVM_FULL UVM_HIGH
  
    extern function                new(string name = "qcs_fir_cfg");
    extern function qcs_fir_cfg  get_config(uvm_component c);
endclass: qcs_fir_cfg

//----
function qcs_fir_cfg::new(string name = "qcs_fir_cfg");
    super.new(name);
endfunction: new

//----
function qcs_fir_cfg qcs_fir_cfg::get_config(uvm_component c);
    qcs_fir_cfg t;
    if (!uvm_config_db #(qcs_fir_cfg)::get(c, "", "qcs_fir_cfg", t) ) begin
        `uvm_fatal(get_type_name(), QCS_FIR_RPTS_CFG_GETTING_FAILURE)
    end
    return t;
endfunction: get_config
