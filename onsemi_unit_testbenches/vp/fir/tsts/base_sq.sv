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
    qcs_clk_gen_item                           sq_clk_rx_gen0;
    qcs_gpio_item    #(QCS_GPIO_ACT_PARAM)     sq_gpio0;
    qcs_fir_item     #(QCS_FIR_ACT_PARAM)      sq_fir0;

    uvm_verbosity                              local_vrb_lvl = UVM_FULL;

    const time          wait_time             = (10*FIR_CLK_PERIOD);
    localparam  int     CHIRP_DURATION        = 3500;
    //---- Common functions and tasks
    extern function         new(string name = "base_sq");
    extern task             pre_body();
    extern function time    get_rnd_time(time min, max);
    extern function int     get_rnd_int(int min, max);
    extern task             generate_rst0(input time delay);
    extern task             set_active_rst0();
    extern task             set_inactive_rst0();
    extern task             set_clk0(input time prd);
    extern task             set_clk1(input time prd);
    extern protected task   run_ref_model_for_chain(
                                const ref int            in_i[],
                                const ref int            in_q[],
                                input int               in_sampl,
                                input int               en_logger
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
    sq_clk_rx_gen0  = qcs_clk_gen_item::type_id::create("req_clk_rx_gen0");
    sq_gpio0        = qcs_gpio_item #(QCS_GPIO_ACT_PARAM)::type_id::create("sq_gpio0");

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

task base_sq::set_clk1(input time prd);
    `uvm_do_on_with(sq_clk_rx_gen0, p_sequencer.m_clk_rx_gen0_sqr, {period == prd;})
    `uvm_info(get_name(), $sformatf("\nNew CLK1 period is set\n"), local_vrb_lvl)
endtask: set_clk1

task base_sq::run_ref_model_for_chain(
    const ref int                in_i[],
    const ref int                in_q[],
    input int                   in_sampl,
    input int                  en_logger
);
    `uvm_info(get_name(), $sformatf("Calling C function.."), UVM_LOW)
    fir_wrapper (
        in_i,
        in_q,
        in_sampl,
        en_logger
    );
endtask: run_ref_model_for_chain


