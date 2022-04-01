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
class tb_checkin_sq extends base_sq;
    `uvm_object_utils(tb_checkin_sq)
    //----
    rand int data_arr_i [];
    rand int data_arr_q [];
    rand int size;
    qcs_fir_item #(QCS_FIR_ACT_PARAM) trn;
    localparam bit [FIR_GPIO_WIDTH - 1:0] DEFAULT_SYS_PATTERN = 14'b00100100100000;
    localparam bit [FIR_GPIO_WIDTH - 1:0] SYS_PATTERN_RX_EN   = 14'b00110100100000;
    c_model_queues   m_model_queues;


    extern function      new(string name = "tb_checkin_sq");
    extern task          pre_body();
    extern task          body();
    extern task          send_pkt();
    extern task          print_checkers_statistics();

endclass

function tb_checkin_sq::new(string name = "tb_checkin_sq");
    super.new (name);
endfunction: new

task tb_checkin_sq::pre_body();
    void'(uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_queues));
endtask: pre_body

task tb_checkin_sq :: send_pkt();

    void'(std::randomize(size) with {size inside {[500:1000]};});

    data_arr_i = new[size];
    data_arr_q = new[size];
    
    void'(std::randomize(data_arr_i) with {foreach (data_arr_i[i]) data_arr_i[i] inside {12'd2047, -12'd2047};});
    void'(std::randomize(data_arr_q) with {foreach (data_arr_q[i]) data_arr_q[i] inside {12'd2047, -12'd2047};});

    // run_ref_model_for_chain(data_arr_i, data_arr_q, data_arr_i.size());
    // print_checkers_statistics();

    `uvm_create_on(trn, p_sequencer.m_fir0_rx_sqr)

    for (int i=0; i < data_arr_i.size(); i++) begin
        trn.data_i = data_arr_i[i];
        trn.data_q = data_arr_q[i];
        `uvm_send(trn)
        trn.print();
    end
endtask : send_pkt

task tb_checkin_sq :: body();
    `uvm_info(get_name(), "Starting", local_vrb_lvl)
    fork
        begin
            generate_rst0(10*FIR_CLK_PERIOD);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == DEFAULT_SYS_PATTERN; clear == '1;})
            send_pkt();
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == SYS_PATTERN_RX_EN; clear == '1;})
            #40ns;
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == DEFAULT_SYS_PATTERN; clear == '1;})
            #1000ns;
            $display("\tSize of data_arr_i %0d",data_arr_i.size());
            $display("\tSize of data_arr_q %0d",data_arr_q.size());
        end
        set_clk0(FIR_CLK_PERIOD);
        set_clk1(FIR_CLK_RX_PERIOD);
    join
    #1000ns;
endtask : body

task tb_checkin_sq::print_checkers_statistics();
    m_model_queues.print_checkers_statistics();
endtask


