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
class qcs_gpio_sqr  #(
    qcs_gpio_param_t PARAMS = QCS_GPIO_UVC_DFLT_PARAMS
) extends uvm_sequencer #(qcs_gpio_item  #(PARAMS));
    `uvm_component_param_utils(qcs_gpio_sqr #(PARAMS))
    //----
    qcs_gpio_cfg   m_cfg;
    uvm_verbosity local_vrb_lvl = UVM_LOW;
    //----
    extern function       new(string name = "qcs_gpio_sqr", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern task           run_phase(uvm_phase phase);
endclass: qcs_gpio_sqr

//----
function qcs_gpio_sqr::new(string name = "qcs_gpio_sqr", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void qcs_gpio_sqr::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
    super.build_phase(phase);
    if (!uvm_config_db #(qcs_gpio_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(get_name(), QCS_GPIO_RPTS_CFG_GETTING_FAILURE)
    local_vrb_lvl = m_cfg.vrb_lvl_sqr;
endfunction: build_phase

//----
task qcs_gpio_sqr::run_phase(uvm_phase phase);
endtask: run_phase
