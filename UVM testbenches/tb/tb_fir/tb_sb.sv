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
    uvm_tlm_analysis_fifo  #(qcs_fir_item #(QCS_FIR_ACT_PARAM))         i_ap_fir_din_mon;
    uvm_tlm_analysis_fifo  #(qcs_fir_item #(QCS_FIR_RX_PRI_PSV_PARAM))  i_ap_fir_dout_mon;
    //----
    qcs_fir_item  #(QCS_FIR_RX_PRI_PSV_PARAM)   fir_dout_wrd;
    //----
    bit                                   en_rpt_in_hoarder;
    bit                                   en_rpt_in_analyzer;
    bit                                   rpt_symbols_only;
    bit                                   rpt_errors_only;
    bit                                   en_report_to_file = 0;
    uvm_verbosity   local_vrb_lvl = UVM_HIGH;
    //----
    c_model_queues          m_model_queues;
    tb_cfg                  m_env_cfg;

    //----
    sb_waveform_checker_t checker_fir_out;

    uvm_verbosity           vrb_lvl;
    string                  rpt_str;
    event                   e_new_trn;
    int                     trn_cnt = 0;
    int                     fir_err_cnt;
    int                     glob_err_cnt;
    string                  conclusion;

    //----
    localparam string RPT_FILENAME           = "fir_sb_report.txt";
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
    i_ap_fir_dout_mon     = new("i_ap_fir_dout_mon", this);
    i_ap_fir_din_mon      = new("i_ap_fir_din_mon", this);
    if (!uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_queues))
        `uvm_fatal(get_name(), {TB_RPTS_CQUEUE_GETTING_FAILURE, "c_model_queues"})
    if (!uvm_config_db #(tb_cfg)::get(this, "", "m_cfg", m_env_cfg))
        `uvm_fatal(get_name(), {TB_RPTS_CFG_GETTING_FAILURE, "cfg_env"})
    vrb_lvl             = m_env_cfg.vrb_lvl_sb;
    en_rpt_in_hoarder   = m_env_cfg.sb_en_rpt_in_hoarder;
    en_rpt_in_analyzer  = m_env_cfg.sb_en_rpt_in_analyzer;
    en_report_to_file   = m_env_cfg.sb_en_report_to_file;
endfunction: build_phase

//----
task tb_sb::run_phase(uvm_phase phase);
    `uvm_info(get_name(), "run phase", UVM_FULL)
    //----
    fir_dout_wrd  = qcs_fir_item#(QCS_FIR_RX_PRI_PSV_PARAM) ::type_id::create("TB SB_fir_output_wrd");
    //----
    fork
        hoarder();
        analyzer();
    join_none
    fir_err_cnt += checker_fir_out.error_count;
endtask: run_phase
//----
function void tb_sb::report_phase(uvm_phase phase);
    int rpt_file;
    `uvm_info(get_name(), "report phase", UVM_FULL)
    glob_err_cnt += fir_err_cnt;
    rpt_str = {
        "\n", RPT_POINTS_TABLE_HEAD,
        $sformatf("\t %0d transactions have been received\n\n", trn_cnt),
        "\t    # | Conclusion |         Received                  |   Expectation from C model        |\n",
        "\t------+------------+-----------------------------------+-----------------------------------+\n",
        rpt_str, RPT_TABLE_BOTTOM
    };
    // Report to file (useful for detailed reports)
    if(en_report_to_file) begin
        rpt_file = $fopen(RPT_FILENAME);
        $fwrite(rpt_file, rpt_str);
        $fclose(rpt_file);
    end
    //
    `uvm_info(get_name(), $sformatf("Total error's: %0d \n" ,checker_fir_out.error_count), local_vrb_lvl)
    if(glob_err_cnt > 0) begin
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
        i_ap_fir_dout_mon.get(fir_dout_wrd);
        if (en_rpt_in_hoarder) begin
            `uvm_info(get_name(), $sformatf("The scoreboard has got a pri transaction: %s\n", fir_dout_wrd.convert2string()), local_vrb_lvl)
        end
        -> e_new_trn;
    end
endtask: hoarder


task tb_sb::get_ref_aux_chkp_value(string id, ref  c_model_queues::checker_val_t data);
    if(m_model_queues.size(id) > 0) begin
        data = m_model_queues.pop_front(id);
    end
endtask
//----
task tb_sb::analyzer();
    string conclusion;
    c_model_queues::checker_val_t   c_sample;
    bit                             cmp_ok;
    forever begin
        @e_new_trn;
        get_ref_aux_chkp_value("RX",c_sample);
        cmp_ok = (c_sample.re_val[11:0] === fir_dout_wrd.data_q &&
                  c_sample.im_val[11:0] === fir_dout_wrd.data_i);
        checker_fir_out.data = '{
            cmp_ok,
            $signed(c_sample.re_val[11:0]),
            $signed(c_sample.im_val[11:0]),
            $signed(fir_dout_wrd.data_q),
            $signed(fir_dout_wrd.data_i)
        };
        if (!cmp_ok) begin 
            checker_fir_out.error_count += 1;
        end
        if (cmp_ok)    conclusion = "PASS";
        else           conclusion = "FAIL";
        trn_cnt++;
        rpt_str = {rpt_str, $sformatf("\t %4d | %7s    |  DATA_Q = %5d /  DATA_I = %5d |  DATA_Q = %5d /  DATA_I = %5d |\n", 
            trn_cnt, conclusion,
            fir_dout_wrd.data_q, fir_dout_wrd.data_i,
            $signed(c_sample.re_val[11:0]), $signed(c_sample.im_val[11:0])
        )};
    end
endtask: analyzer