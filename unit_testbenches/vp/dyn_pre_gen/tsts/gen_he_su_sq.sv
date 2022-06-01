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
class gen_he_su_sq extends base_sq;
    `uvm_object_utils(gen_he_su_sq)
    //----
    rand logic unsigned [GEN_BW_W - 1 : 0]      sys_bw;
    rand logic unsigned [3 : 0]                 ch_tx;
    rand logic unsigned                         nhtp_4ch;
    //----
    logic unsigned [GEN_BW_W - 1 : 0]           pkt_bw;
    logic unsigned [GEN_SUBBAND_W - 1 : 0]      mu_subband_punct_coeff = 16'hFFFF;
    localparam logic unsigned [4 : 0]                      format_he_su           = 4;
    //----
    int gamma_rotation_coeff;
    //----
    localparam bit [GEN_GPIO_WIDTH - 1:0] START_SYS_PATTERN = {1'b0, 1'b0, format_he_su, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
    localparam bit [GEN_GPIO_WIDTH - 1:0] START_STF_PATTERN = {1'b0, 1'b0, format_he_su, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0};
    localparam bit [GEN_GPIO_WIDTH - 1:0] START_LTF_PATTERN = {1'b0, 1'b1, format_he_su, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};
    localparam bit [GEN_GPIO_WIDTH - 1:0] END_LTF_PATTERN   = {1'b0, 1'b1, format_he_su, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
    localparam bit [GEN_GPIO_WIDTH - 1:0] END_SYS_PATTERN   = {1'b0, 1'b0, format_he_su, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
    //----
    c_model_queues   m_model_queues;
    //----
    extern function      new(string name = "gen_he_su_sq");
    extern task          pre_body();
    extern task          body();
    extern task          send_stf();
    extern task          send_ltf();
endclass

function gen_he_su_sq::new(string name = "gen_he_su_sq");
    super.new (name);
endfunction: new

task gen_he_su_sq::pre_body();
    void'(uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_queues));
    void'(std::randomize(sys_bw) with {sys_bw inside {[0:5]};});
    void'(std::randomize(pkt_bw) with {pkt_bw inside  {[0:3]};
                                       pkt_bw <= sys_bw;});
    void'(std::randomize(nhtp_4ch));
    void'(std::randomize(ch_tx) with  { if(nhtp_4ch == 0){
                                            ch_tx == 2;
                                        } else {
                                            ch_tx == 4;
                                        }});
    gamma_rotation_coeff   = 0;
    run_ref_model_for_chain(int'(sys_bw), int'(pkt_bw), int'(format_he_su), 
    gamma_rotation_coeff, int'(mu_subband_punct_coeff), int'(ch_tx), int'(nhtp_4ch));
endtask: pre_body


task gen_he_su_sq :: send_stf();
    `uvm_create_on(trn, p_sequencer.m_dyn_pre_gen_sqr)
    fork 
        begin
            @(posedge $root.tb_hdl_top.clk);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == START_STF_PATTERN; clear == '1;})
        end
        for (int i = 0; i < L_STF_MEM_SIZE; i++) begin
            trn.raddr            = i;
            trn.sys_bw           = sys_bw;
            trn.pkt_bw           = pkt_bw;
            trn.n_tx             = ch_tx;
            trn.gamma_rotation   = '0;
            trn.mu_subband_punct = mu_subband_punct_coeff;
            trn.nhtp_4ch         = nhtp_4ch;
            `uvm_send(trn)
        end
    join
endtask : send_stf

task gen_he_su_sq :: send_ltf();
    `uvm_create_on(trn, p_sequencer.m_dyn_pre_gen_sqr)
    fork
        begin            
            @(posedge $root.tb_hdl_top.clk);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == START_LTF_PATTERN; clear == '1;})
        end 
        for (int i = 0; i < L_LTF_MEM_SIZE; i++) begin
            trn.raddr            = i;
            trn.sys_bw           = sys_bw;
            trn.pkt_bw           = pkt_bw;
            trn.n_tx             = ch_tx;
            trn.gamma_rotation   = '0;
            trn.mu_subband_punct = mu_subband_punct_coeff;
            trn.nhtp_4ch         = nhtp_4ch;
            `uvm_send(trn)
        end
    join
endtask : send_ltf

task gen_he_su_sq :: body();
    `uvm_info(get_name(), "Starting", local_vrb_lvl)
    fork
        begin
            generate_rst0(10*GENERATOR_CLK_PERIOD);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == START_SYS_PATTERN; clear == '1;})
            #wait_time;
            send_stf();
            send_ltf();
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == END_LTF_PATTERN; clear == '1;})
            #wait_time_ltf;
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == END_SYS_PATTERN; clear == '1;})
        end
        set_clk0(GENERATOR_CLK_PERIOD);
    join
    #1000ns;
endtask : body