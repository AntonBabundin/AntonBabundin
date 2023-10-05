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
class tb_sb extends uvm_component;
    `uvm_component_param_utils(tb_sb)
    //----
    uvm_tlm_analysis_fifo    #(qcs_dyn_pre_gen_item     #(QCS_GENERATOR_DYNAMIC_PREAMBULE_ACT_PARAMS))  i_ap_gen_din_mon;
    uvm_tlm_analysis_fifo    #(qcs_dyn_pre_gen_item_out #(QCS_GENERATOR_DYNAMIC_PREAMBULE_PSV_PARAMS))  i_ap_gen_dout_mon;
    uvm_tlm_analysis_fifo    #(qcs_gpio_item            #(QCS_GPIO_ACT_PARAM))                          i_ap_gpio_mon;

    //----
    qcs_dyn_pre_gen_item_out #(QCS_GENERATOR_DYNAMIC_PREAMBULE_PSV_PARAMS)    gen_dout_wrd;
    qcs_dyn_pre_gen_item     #(QCS_GENERATOR_DYNAMIC_PREAMBULE_ACT_PARAMS)    gen_din_wrd;
    qcs_gpio_item            #(QCS_GPIO_ACT_PARAM)                            gpio_wrd;
    //----
    bit                     en_rpt_in_hoarder = 1;
    bit                     en_rpt_in_analyzer;
    bit                     rpt_symbols_only;
    bit                     rpt_errors_only;
    bit                     en_report_to_file;
    uvm_verbosity           local_vrb_lvl     = UVM_FULL;
    //----
    c_model_queues          m_model_queues;
    tb_cfg                  m_env_cfg;
    //----
    sb_waveform_checker_t   checker_dyn_pre_gen_out;

    uvm_verbosity           vrb_lvl;
    string                  rpt_str;
    event                   e_new_trn;
    int                     trn_cnt = 0;
    int                     glob_err_cnt;
    int                     delete_trn = 0;
    string                  conclusion;
    int                     NUM_OF_DEL_TRNS;
    int                     NUM_OF_PASS_TRN;

    //----
    localparam string RPT_FILENAME           = "gen_sb_report.txt";
    localparam string RPT_POINTS_TABLE_HEAD  = {"\n\n\t\t\t\t", "---- Detailed Report Begin ----\n"};
    localparam string RPT_TABLE_BOTTOM       = {"\n\n\t\t\t\t", "---- END OF REPORT ----\n\n"};
    //----
    extern function         new(string name = "tb_sb", uvm_component parent = null);
    extern function void    build_phase(uvm_phase phase);
    extern task             run_phase(uvm_phase phase);
    extern function void    report_phase(uvm_phase phase);
    extern task             hoarder();
    extern task             analyzer();
    extern task             get_ref_aux_chkp_value(string id, ref  c_model_queues::checker_val_t data);
    //----
endclass: tb_sb

//----
function tb_sb::new(string name = "tb_sb", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void tb_sb::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL)
    i_ap_gen_din_mon     = new("i_ap_gen_din_mon", this);
    i_ap_gen_dout_mon    = new("i_ap_gen_dout_mon", this);
    i_ap_gpio_mon    = new("i_ap_gpio_mon", this);
    if (!uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_queues))
        `uvm_fatal(get_name(), {TB_RPTS_CQUEUE_GETTING_FAILURE, "c_model_queues"})
    if (!uvm_config_db #(tb_cfg)::get(this, "", "m_cfg", m_env_cfg))
        `uvm_fatal(get_name(), {TB_RPTS_CFG_GETTING_FAILURE, "cfg_env"})
    vrb_lvl             = m_env_cfg.vrb_lvl_sb;
    en_rpt_in_analyzer  = m_env_cfg.sb_en_rpt_in_analyzer;
    en_report_to_file   = m_env_cfg.sb_en_report_to_file;
endfunction: build_phase

//----
task tb_sb::run_phase(uvm_phase phase);
    `uvm_info(get_name(), "run phase", UVM_FULL)
    //----
    gen_dout_wrd  = qcs_dyn_pre_gen_item_out#(QCS_GENERATOR_DYNAMIC_PREAMBULE_PSV_PARAMS) ::type_id::create("TB gen_output_wrd");
    gen_din_wrd   = qcs_dyn_pre_gen_item#(QCS_GENERATOR_DYNAMIC_PREAMBULE_ACT_PARAMS) ::type_id::create("TB gen_in_wrd");
    gpio_wrd      = qcs_gpio_item#(QCS_GPIO_ACT_PARAM) ::type_id::create("TB gpio");
    //----
    i_ap_gpio_mon.get(gpio_wrd);
    fork
        hoarder();
        analyzer();
    join_none
endtask: run_phase
//----
function void tb_sb::report_phase(uvm_phase phase);
    int rpt_file;
    `uvm_info(get_name(), "report phase", UVM_FULL)
    rpt_str = {
        "\n", RPT_POINTS_TABLE_HEAD,
        $sformatf("\t %0d transactions have been received\n\n", trn_cnt),
        "\t    # | Conclusion |               Received                 |          Expectation from C model        |\n",
        "\t      |            | DATA_Q_0  DATA_I_0| DATA_Q_1  DATA_I_1 |  DATA_Q_0  DATA_I_0| DATA_Q_1  DATA_I_1  |\n",
        "\t------+------------+----------------------------------------+------------------------------------------+\n",

        rpt_str, RPT_TABLE_BOTTOM
    };
    // Report to file
    if(en_report_to_file) begin
        rpt_file = $fopen(RPT_FILENAME);
        $fwrite(rpt_file, rpt_str);
        $fclose(rpt_file);
    end 
    if(glob_err_cnt >= 0) begin
        `uvm_error(
            get_name(),
            "\nSome errors have been detected during the test. Please see the log above."
        )
    end
    $display(rpt_str);
endfunction: report_phase
//----
task tb_sb::hoarder();
    forever begin
        delete_trn++;
        fork
            i_ap_gen_din_mon.get(gen_din_wrd);
            i_ap_gen_dout_mon.get(gen_dout_wrd);
        join
        case(int'(gpio_wrd.set[21:19])) // system bandwidth from gpio
            'd0     : begin //20MHz
                        NUM_OF_DEL_TRNS = 7; 
                        NUM_OF_PASS_TRN = 4;
            end
            default : begin
                        NUM_OF_DEL_TRNS = 7;
                        NUM_OF_PASS_TRN = 1;
            end 
        endcase
        if (delete_trn >= NUM_OF_DEL_TRNS && delete_trn % NUM_OF_PASS_TRN == 0) -> e_new_trn; // Delete NUM_OF_DEL_TRNS trns and then start analyz
    end
endtask: hoarder
//----
task tb_sb::get_ref_aux_chkp_value(string id, ref  c_model_queues::checker_val_t data);
    if(m_model_queues.size(id) > 0) begin
        data = m_model_queues.pop_front(id);
    end
endtask
//----
task tb_sb::analyzer();
    string conclusion;
    c_model_queues::checker_val_t   c_sample_0_chan;
    c_model_queues::checker_val_t   c_sample_1_chan;
    //
    bit                             cmp_0_chan;
    bit                             cmp_1_chan;
    forever begin
        @e_new_trn;
        if (gen_din_wrd.nhtp_4ch)
            begin
                get_ref_aux_chkp_value("TX_2",c_sample_0_chan);
                get_ref_aux_chkp_value("TX_3",c_sample_1_chan);
            end
        else
            begin
                get_ref_aux_chkp_value("TX_0",c_sample_0_chan);
                get_ref_aux_chkp_value("TX_1",c_sample_1_chan);
            end
        cmp_0_chan = (c_sample_0_chan.re_val[11:0] === gen_dout_wrd.data_i_0 &&
        c_sample_0_chan.im_val[11:0] === gen_dout_wrd.data_q_0);
        cmp_1_chan = (c_sample_1_chan.re_val[11:0] === gen_dout_wrd.data_i_1 &&
        c_sample_1_chan.im_val[11:0] === gen_dout_wrd.data_q_1);
        checker_dyn_pre_gen_out.data = '{
            cmp_0_chan,
            cmp_1_chan,
            $signed(c_sample_0_chan.re_val[11:0]),
            $signed(c_sample_0_chan.im_val[11:0]),
            $signed(c_sample_1_chan.re_val[11:0]),
            $signed(c_sample_1_chan.im_val[11:0]),
            $signed(gen_dout_wrd.data_i_0),
            $signed(gen_dout_wrd.data_q_0),
            $signed(gen_dout_wrd.data_i_1),
            $signed(gen_dout_wrd.data_q_1)
        };
        if (!(cmp_0_chan && cmp_1_chan)) begin
            checker_dyn_pre_gen_out.error_count += 1;
        end
        if (cmp_0_chan && cmp_1_chan) conclusion = "PASS";
        else                          conclusion = "FAIL";
        trn_cnt++;
        rpt_str = {rpt_str, $sformatf("\t %5d| %7s    | %5d / %5d     | %5d / %5d      | %5d / %5d      | %5d / %5d       | \n",
            trn_cnt, conclusion,
            gen_dout_wrd.data_q_0, gen_dout_wrd.data_i_0,
            gen_dout_wrd.data_q_1, gen_dout_wrd.data_i_1,
            $signed(c_sample_0_chan.re_val[11:0]), $signed(c_sample_0_chan.im_val[11:0]),
            $signed(c_sample_1_chan.re_val[11:0]), $signed(c_sample_1_chan.im_val[11:0])
        )};
    end
endtask: analyzer