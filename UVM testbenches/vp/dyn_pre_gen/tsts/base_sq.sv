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
class base_sq extends uvm_sequence;
    `uvm_object_utils(base_sq)
    `uvm_declare_p_sequencer(tb_vsqr)
    //----
    //---- Using items
    qcs_rst_gen_item                           sq_rst_gen0;
    qcs_clk_gen_item                           sq_clk_gen0;
    qcs_gpio_item    #(QCS_GPIO_ACT_PARAM)     sq_gpio0;
    qcs_dyn_pre_gen_item #(QCS_GENERATOR_DYNAMIC_PREAMBULE_ACT_PARAMS)          trn;

    uvm_verbosity                              local_vrb_lvl = UVM_FULL;

    const time          wait_time             = (10*GENERATOR_CLK_PERIOD);
    const time          wait_time_ltf         = (48*GENERATOR_CLK_PERIOD);
    //---- Common functions and tasks
    extern function         new(string name = "base_sq");
    extern task             pre_body();
    extern function time    get_rnd_time(time min, max);
    extern function int     get_rnd_int(int min, max);
    extern task             generate_rst0(input time delay);
    extern task             set_active_rst0();
    extern task             set_inactive_rst0();
    extern task             set_clk0(input time prd);
    extern protected task   run_ref_model_for_chain(
                            input int     in_sys_bw,
                            input int     in_pkt_bw,
                            input int     in_format,
                            input int     in_gamma_rot,
                            input int     in_subband_punct,
                            input int     in_tx_chains,
                            input int     in_4ch
                        );
endclass: base_sq
//----
function base_sq::new(string name = "base_sq");
    super.new(name);
    set_automatic_phase_objection(1);
endfunction: new
//----
task base_sq::pre_body();
    //----
    sq_rst_gen0     = qcs_rst_gen_item::type_id::create("req_rst_gen0");
    sq_clk_gen0     = qcs_clk_gen_item::type_id::create("req_clk_gen0");
    sq_gpio0        = qcs_gpio_item #(QCS_GPIO_ACT_PARAM)::type_id::create("sq_gpio0");
    trn             = qcs_dyn_pre_gen_item #(QCS_GENERATOR_DYNAMIC_PREAMBULE_ACT_PARAMS)::type_id::create("trn");
endtask: pre_body

function time base_sq::get_rnd_time(time min, max);
    void'(std::randomize(get_rnd_time) with {get_rnd_time inside {[min:max]};});
endfunction: get_rnd_time

function int base_sq::get_rnd_int(int min, max);
    void'(std::randomize(get_rnd_int) with {get_rnd_int inside {[min:max]};});
endfunction: get_rnd_int

task base_sq::generate_rst0(input time delay);
    set_active_rst0();
    #delay;
    set_inactive_rst0();
endtask: generate_rst0

task base_sq::set_active_rst0();
    `uvm_do_on_with(sq_rst_gen0, p_sequencer.m_rst_gen0_sqr, {rst_lvl == RST_LVL_ACTIVE;})
    `uvm_info(get_name(), $sformatf("\nReset is set\n"), local_vrb_lvl)
endtask: set_active_rst0

task base_sq::set_inactive_rst0();
    `uvm_do_on_with(sq_rst_gen0, p_sequencer.m_rst_gen0_sqr, {rst_lvl == RST_LVL_PASSIVE;})
    `uvm_info(get_name(), $sformatf("\nReset is released\n"), local_vrb_lvl)
endtask: set_inactive_rst0

task base_sq::set_clk0(input time prd);
    `uvm_do_on_with(sq_clk_gen0, p_sequencer.m_clk_gen0_sqr, {period == prd;})
    `uvm_info(get_name(), $sformatf("\nNew CLK0 period is set\n"), local_vrb_lvl)
endtask: set_clk0

task base_sq::run_ref_model_for_chain(
    input int     in_sys_bw,
    input int     in_pkt_bw,
    input int     in_format,
    input int     in_gamma_rot,
    input int     in_subband_punct,
    input int     in_tx_chains,
    input int     in_4ch
);
    `uvm_info(get_name(), $sformatf("Calling C function.."), UVM_LOW)
    dyn_pre_gen_wrapper (
        in_sys_bw,
        in_pkt_bw,
        in_format,
        in_gamma_rot,
        in_subband_punct,
        in_tx_chains,
        in_4ch
        );
endtask: run_ref_model_for_chain
