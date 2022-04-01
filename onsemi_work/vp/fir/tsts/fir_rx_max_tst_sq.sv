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
class fir_rx_max_tst_sq extends base_sq;
    `uvm_object_utils(fir_rx_max_tst_sq)
    //----
    rand int data_arr_i [];
    rand int data_arr_q [];
    rand int size_sampl;
    int en_print_c_model_log = 1;

    qcs_fir_item #(QCS_FIR_ACT_PARAM) trn;

    localparam bit [FIR_GPIO_WIDTH - 1:0] DEFAULT_SYS_PATTERN = 5'b00100;

    c_model_queues   m_model_queues;

    extern function      new(string name = "fir_rx_max_tst_sq");
    extern task          pre_body();
    extern task          body();
    extern task          send_pkt();
    extern task          print_checkers_statistics();
endclass

function fir_rx_max_tst_sq::new(string name = "fir_rx_max_tst_sq");
    super.new (name);
endfunction: new

task fir_rx_max_tst_sq::pre_body();
    void'(uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_queues));
endtask: pre_body

task fir_rx_max_tst_sq::send_pkt();

    void'(std::randomize(size_sampl) with {size_sampl inside {[500:1000]};});

    data_arr_i = new[size_sampl];
    data_arr_q = new[size_sampl];
    
    void'(std::randomize(data_arr_q) with {foreach (data_arr_q[i]) data_arr_q[i] inside {12'd2047, -12'd2047};});
    void'(std::randomize(data_arr_i) with {foreach (data_arr_i[i]) data_arr_i[i] inside {12'd2047, -12'd2047};});

    run_ref_model_for_chain(data_arr_i, data_arr_q, size_sampl, en_print_c_model_log);
    print_checkers_statistics();

    `uvm_create_on(trn, p_sequencer.m_fir0_rx_sqr)

    for (int i=0; i < size_sampl; i++) begin
        trn.data_i = data_arr_i[i];
        trn.data_q = data_arr_q[i];
        `uvm_send(trn)
    end
endtask : send_pkt

task fir_rx_max_tst_sq::body();
    `uvm_info(get_name(), "Starting", local_vrb_lvl)
    fork
        begin
            generate_rst0(10*FIR_CLK_PERIOD);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == DEFAULT_SYS_PATTERN; clear == '1;})
            send_pkt();
            #wait_time;
        end
        set_clk0(FIR_CLK_PERIOD);
        set_clk1(FIR_CLK_RX_PERIOD);
    join
endtask : body

task fir_rx_max_tst_sq::print_checkers_statistics();
    m_model_queues.print_checkers_statistics();
endtask