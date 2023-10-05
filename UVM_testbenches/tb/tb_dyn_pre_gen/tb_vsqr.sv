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
class tb_vsqr extends uvm_sequencer;
    `uvm_component_utils(tb_vsqr)
    //----
    qcs_rst_gen_sqr                                                       m_rst_gen0_sqr;
    qcs_clk_gen_sqr                                                       m_clk_gen0_sqr;

    qcs_dyn_pre_gen_sqr     #(QCS_GENERATOR_DYNAMIC_PREAMBULE_ACT_PARAMS) m_dyn_pre_gen_sqr;
    qcs_gpio_sqr                            #(QCS_GPIO_ACT_PARAM)         m_gpio_sqr;

    //----
    extern function new(string name = "tb_vsqr", uvm_component parent = null);
endclass: tb_vsqr

//----
function tb_vsqr::new(string name = "tb_vsqr", uvm_component parent = null);
    super.new(name, parent);
endfunction: new
