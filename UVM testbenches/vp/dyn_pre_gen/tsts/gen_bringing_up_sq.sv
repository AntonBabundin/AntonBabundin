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
class gen_bringing_up_sq extends base_sq;
    `uvm_object_utils(gen_bringing_up_sq)
    //---- THIS VARS BELOW YOU CAN CHANGE ----//
    localparam int                         L_LTF_MEM_SIZE_READ   =  5216; //Size of LTF mem to read
    localparam int                         L_STF_MEM_SIZE_READ   =  5120; //Size of STF mem to read
    localparam logic [GEN_BW_W - 1 : 0]    SYS_BW_SWITHCER       =  5; // 160MHz
    localparam logic [GEN_BW_W - 1 : 0]    PKT_BW_SWITHCER       =  4; // 80MHz 
    localparam logic [3 : 0]               CH_TX_SWITHCER        =  4; // NHTP_4CH_SWITCHER == 1 -> CH_TX_SWITHCER == 4
    localparam logic                       NHTP_4CH_SWITCHER     =  1;
    localparam time                        CLK_PERIOD            =  1.5625ns;   // 640 MHz
    localparam logic [4 : 0]               FORMAT                =  8;          // eht su format
    localparam logic [GEN_GAMMA_W - 1 : 0] GAMMA_ROTATION_COEFFS =  2;
    localparam logic [SUBBAND_W - 1 : 0]   MU_SUBBAND_PUCNT      =  16'hFFFF;  // All subbands is on. Do not use yet
    localparam time                        RESET_PERIOD          =  CLK_PERIOD*10;

    //---- THIS VARS BELOW YOU CAN'T CHANGE ----//
    localparam bit [GEN_GPIO_WIDTH - 1:0] START_SYS_PATTERN = {1'b0, 1'b0, FORMAT, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, CH_TX_SWITHCER, NHTP_4CH_SWITCHER, PKT_BW_SWITHCER, SYS_BW_SWITHCER, MU_SUBBAND_PUCNT, GAMMA_ROTATION_COEFFS};
    localparam bit [GEN_GPIO_WIDTH - 1:0] START_STF_PATTERN = {1'b0, 1'b0, FORMAT, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, CH_TX_SWITHCER, NHTP_4CH_SWITCHER, PKT_BW_SWITHCER, SYS_BW_SWITHCER, MU_SUBBAND_PUCNT, GAMMA_ROTATION_COEFFS};
    localparam bit [GEN_GPIO_WIDTH - 1:0] START_LTF_PATTERN = {1'b0, 1'b1, FORMAT, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, CH_TX_SWITHCER, NHTP_4CH_SWITCHER, PKT_BW_SWITHCER, SYS_BW_SWITHCER, MU_SUBBAND_PUCNT, GAMMA_ROTATION_COEFFS};
    localparam bit [GEN_GPIO_WIDTH - 1:0] END_LTF_PATTERN   = {1'b0, 1'b1, FORMAT, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, CH_TX_SWITHCER, NHTP_4CH_SWITCHER, PKT_BW_SWITHCER, SYS_BW_SWITHCER, MU_SUBBAND_PUCNT, GAMMA_ROTATION_COEFFS};
    localparam bit [GEN_GPIO_WIDTH - 1:0] END_SYS_PATTERN   = {1'b0, 1'b0, FORMAT, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, CH_TX_SWITHCER, NHTP_4CH_SWITCHER, PKT_BW_SWITHCER, SYS_BW_SWITHCER, MU_SUBBAND_PUCNT, GAMMA_ROTATION_COEFFS};

    c_model_queues   m_model_queues;

    extern function      new(string name = "gen_bringing_up_sq");
    extern task          pre_body();
    extern task          body();
    extern task          send_stf();
    extern task          send_ltf();
endclass

function gen_bringing_up_sq::new(string name = "gen_bringing_up_sq");
    super.new (name);
endfunction: new

task gen_bringing_up_sq::pre_body();
    run_ref_model_for_chain(int'(SYS_BW_SWITHCER), int'(PKT_BW_SWITHCER), int'(FORMAT), 
    int'(GAMMA_ROTATION_COEFFS), int'(MU_SUBBAND_PUCNT), int'(CH_TX_SWITHCER), int'(NHTP_4CH_SWITCHER));
endtask: pre_body


task gen_bringing_up_sq :: send_stf();
    `uvm_create_on(trn, p_sequencer.m_dyn_pre_gen_sqr)
    fork 
        begin
            @(posedge $root.tb_hdl_top.clk);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == START_STF_PATTERN; clear == '1;})
        end
        for (int i =0; i < L_STF_MEM_SIZE_READ; i++) begin
            trn.raddr            = i;
            `uvm_send(trn)
        end
    join

endtask : send_stf

task gen_bringing_up_sq :: send_ltf();
    `uvm_create_on(trn, p_sequencer.m_dyn_pre_gen_sqr)
    fork
        begin            
            @(posedge $root.tb_hdl_top.clk);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == START_LTF_PATTERN; clear == '1;})
        end 
        for (int i = 0; i < L_LTF_MEM_SIZE_READ; i++) begin
            trn.raddr            = i;
            `uvm_send(trn)
        end
    join
endtask : send_ltf

task gen_bringing_up_sq :: body();
    `uvm_info(get_name(), "Starting", local_vrb_lvl)
    fork
        begin
            generate_rst0(RESET_PERIOD);
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == START_SYS_PATTERN; clear == '1;})
            #wait_time;
            send_stf();
            send_ltf();
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == END_LTF_PATTERN; clear == '1;})
            #wait_time_ltf;
            `uvm_do_on_with(sq_gpio0, p_sequencer.m_gpio_sqr, {set == END_SYS_PATTERN; clear == '1;})
        end
        set_clk0(CLK_PERIOD);
    join
    #1000ns;
endtask : body
