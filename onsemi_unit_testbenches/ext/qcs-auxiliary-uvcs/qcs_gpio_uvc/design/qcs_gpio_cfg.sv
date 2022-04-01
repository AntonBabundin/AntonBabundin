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
class qcs_gpio_cfg extends uvm_object;
    `uvm_object_utils(qcs_gpio_cfg)
    //----
    uvm_active_passive_enum active = UVM_ACTIVE;
    //---- verbosity levels and reports
    uvm_verbosity vrb_lvl_drv = UVM_LOW; // UVM_NONE, UVM_LOW, UVM_MEDIUM, UVM_HIGH, UVM_FULL, UVM_DEBUG
    uvm_verbosity vrb_lvl_mon = UVM_LOW; // UVM_NONE, UVM_LOW, UVM_MEDIUM, UVM_HIGH, UVM_FULL, UVM_DEBUG
    uvm_verbosity vrb_lvl_sqr = UVM_LOW; // UVM_NONE, UVM_LOW, UVM_MEDIUM, UVM_HIGH, UVM_FULL, UVM_DEBUG
    //----
    extern function               new(string name = "qcs_gpio_cfg");
    extern function qcs_gpio_cfg  get_config(uvm_component c, string path = "", string tag = "m_cfg", ref qcs_gpio_cfg m_cfg);
endclass: qcs_gpio_cfg

//----
function qcs_gpio_cfg::new(string name = "qcs_gpio_cfg");
    super.new(name);
endfunction: new

//----
function qcs_gpio_cfg qcs_gpio_cfg::get_config(uvm_component c, string path = "", string tag = "m_cfg", ref qcs_gpio_cfg m_cfg);
    qcs_gpio_cfg t;
    if (!uvm_config_db #(qcs_gpio_cfg)::get(c, "", "qcs_gpio_cfg", t) ) begin
        `uvm_fatal(get_full_name(), QCS_GPIO_RPTS_CFG_GETTING_FAILURE)
    end
    return t;
endfunction: get_config
