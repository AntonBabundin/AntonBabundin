class fir_rx_chirp_tst_sq extends base_sq;
    `uvm_object_utils(fir_rx_chirp_tst_sq)
    //----
    const int MAX_AMPLITUDE  = 2048;
    const real PI            = 3.1416;
    int data_arr_i [];
    int data_arr_q [];
    int en_print_c_model_log = 1;
    
    qcs_fir_item #(QCS_FIR_ACT_PARAM) trn;

    localparam bit [FIR_GPIO_WIDTH - 1:0] DEFAULT_SYS_PATTERN = 5'b00100;

    c_model_queues   m_model_queues;

    extern function      new(string name = "fir_rx_chirp_tst_sq");
    extern task          pre_body();
    extern task          body();
    extern task          send_sample();
    extern task          print_checkers_statistics();
endclass

function fir_rx_chirp_tst_sq::new(string name = "fir_rx_chirp_tst_sq");
    super.new (name);
endfunction: new

task fir_rx_chirp_tst_sq::pre_body();
    void'(uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_queues));
endtask: pre_body

task fir_rx_chirp_tst_sq::send_sample();

    data_arr_i = new[CHIRP_DURATION];
    data_arr_q = new[CHIRP_DURATION];

    for (int t=0; t < CHIRP_DURATION; t++) begin
        data_arr_i[t] = signed'($rtoi(MAX_AMPLITUDE/4 * $cos(PI * ((t-CHIRP_DURATION/2)**2)/CHIRP_DURATION)));
    end

    for (int t=0; t < CHIRP_DURATION; t++) begin
        data_arr_q[t] = signed'($rtoi(MAX_AMPLITUDE/4 * $sin(PI * ((t-CHIRP_DURATION/2)**2)/CHIRP_DURATION)));
    end
    
    run_ref_model_for_chain(data_arr_i, data_arr_q, CHIRP_DURATION, en_print_c_model_log);
    print_checkers_statistics();

    `uvm_create_on(trn, p_sequencer.m_fir0_rx_sqr)

    for (int i=0; i < CHIRP_DURATION; i++) begin
        trn.data_i = data_arr_i[i];
        trn.data_q = data_arr_q[i];
        `uvm_send(trn)
    end

endtask : send_sample

task fir_rx_chirp_tst_sq::body();
    `uvm_info(get_name(), "Starting", local_vrb_lvl)
    fork
        begin
            generate_rst0(10*FIR_CLK_PERIOD);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == DEFAULT_SYS_PATTERN; clear == '1;})
            send_sample();
            #wait_time;
        end
        set_clk0(FIR_CLK_PERIOD);
        set_clk1(FIR_CLK_RX_PERIOD);
    join
endtask : body

task fir_rx_chirp_tst_sq::print_checkers_statistics();
    m_model_queues.print_checkers_statistics();
endtask