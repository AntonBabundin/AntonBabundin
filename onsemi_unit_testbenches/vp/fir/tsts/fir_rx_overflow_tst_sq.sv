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
class fir_rx_overflow_tst_sq extends base_sq;
    `uvm_object_utils(fir_rx_overflow_tst_sq)
    //----
    rand int data_arr_data [];
    rand int data_arr_sum  [];
    rand int pulse_qty;
    int size_sampl           = 7;
    int coef_fir_arr [7]     = '{6, -20, 78, 127, 78, -20, 6};
    int en_print_c_model_log = 1;
    int counter = 0;

    qcs_fir_item #(QCS_FIR_ACT_PARAM) trn;

    localparam bit [FIR_GPIO_WIDTH - 1:0] DEFAULT_SYS_PATTERN = 5'b00100;

    c_model_queues   m_model_queues;

    extern function      new(string name = "fir_rx_overflow_tst_sq");
    extern task          pre_body();
    extern task          body();
    extern task          send_pkt();
    extern task          print_checkers_statistics();

endclass

function fir_rx_overflow_tst_sq::new(string name = "fir_rx_overflow_tst_sq");
    super.new (name);
endfunction: new

task fir_rx_overflow_tst_sq::pre_body();
    void'(uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_queues));
endtask: pre_body

task fir_rx_overflow_tst_sq::send_pkt();

    void'(std::randomize(pulse_qty) with {pulse_qty inside {[50:100]};});

    data_arr_data = new[size_sampl];
    data_arr_sum  = new[pulse_qty * size_sampl];

    void'(std::randomize(data_arr_data) with 
    {foreach (coef_fir_arr[i]) 
        if (coef_fir_arr[i] > 0)
            data_arr_data[i] inside {[1:2047]};
        else  
            data_arr_data[i] inside {[-2047:-1]};
    });

    
    for (int i=0; i < data_arr_sum.size(); i++) begin
        counter = i % data_arr_data.size();
        data_arr_sum[i] = data_arr_data[counter];
    end

    run_ref_model_for_chain(data_arr_sum, data_arr_sum, pulse_qty * size_sampl, en_print_c_model_log);
    print_checkers_statistics();

    `uvm_create_on(trn, p_sequencer.m_fir0_rx_sqr)

    for (int j = 0; j < pulse_qty; j++) begin
        for (int i=0; i < data_arr_data.size(); i++) begin
            trn.data_i = data_arr_data[i];
            trn.data_q = data_arr_data[i];
            `uvm_send(trn)
        end
    end
endtask : send_pkt

task fir_rx_overflow_tst_sq::body();
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

task fir_rx_overflow_tst_sq::print_checkers_statistics();
    m_model_queues.print_checkers_statistics();
endtask: print_checkers_statistics