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
class tb_env extends uvm_env;
    `uvm_component_utils(tb_env)
    //----
    tb_cfg                                       m_env_cfg;
    qcs_rst_gen_ag #("rst_n_gen_0")              m_rst_gen0;
    qcs_clk_gen_ag #("clk_gen_0")                m_clk_gen0;
    qcs_clk_gen_ag #("clk_rx_gen_0")             m_clk_rx_gen0;
    
    qcs_fir_ag     #(QCS_FIR_ACT_PARAM)          m_fir_in_ag;
    qcs_gpio_ag    #(QCS_GPIO_ACT_PARAM)         m_gpio_ag;
    qcs_fir_ag     #(QCS_FIR_RX_PRI_PSV_PARAM)   m_fir_out_ag;   //passive


    tb_sb                                        m_sb;

    tb_vsqr                                      m_vsqr;
    //----
    extern function      new(string name = "env", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void set_server();
endclass : tb_env

//----
function tb_env::new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
    this.set_server();
endfunction

//----
function void tb_env::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
    super.build_phase(phase);
    //---- get cfg
    if (!uvm_config_db #(tb_cfg)::get(this, "", "m_cfg", m_env_cfg))
        `uvm_fatal(get_name(), TB_RPTS_CFG_GETTING_FAILURE)
    //---- create objects
    m_rst_gen0      = qcs_rst_gen_ag #("rst_n_gen_0")::type_id::create("m_rst_gen0", this);
    m_clk_gen0      = qcs_clk_gen_ag #("clk_gen_0")::type_id::create("m_clk_gen0", this);
    m_clk_rx_gen0   = qcs_clk_gen_ag #("clk_rx_gen_0")::type_id::create("m_clk_rx_gen0", this);
    m_fir_in_ag     = qcs_fir_ag #(QCS_FIR_ACT_PARAM)::type_id::create("m_fir_in_ag", this);
    m_gpio_ag       = qcs_gpio_ag #(QCS_GPIO_ACT_PARAM)::type_id::create("m_gpio_ag", this);
    m_fir_out_ag    = qcs_fir_ag #(QCS_FIR_RX_PRI_PSV_PARAM)::type_id::create("m_fir_out_ag", this);
 
    m_vsqr         = tb_vsqr::type_id::create("m_vsqr", this);
    if(m_env_cfg.en_sb == UVM_ACTIVE) begin
        m_sb = tb_sb::type_id::create("m_sb", this);
    end
endfunction

function void tb_env::connect_phase(uvm_phase phase);
    `uvm_info(get_name(), "connect phase", UVM_FULL);
    super.connect_phase(phase);
    //----
    m_vsqr.m_rst_gen0_sqr     = m_rst_gen0.m_sqr;
    m_vsqr.m_clk_gen0_sqr     = m_clk_gen0.m_sqr;
    m_vsqr.m_clk_rx_gen0_sqr  = m_clk_rx_gen0.m_sqr;

    m_vsqr.m_fir0_rx_sqr      = m_fir_in_ag.m_sqr;
    m_vsqr.m_gpio_sqr         = m_gpio_ag.m_sqr;

    if(m_env_cfg.en_sb == UVM_ACTIVE) begin
        m_fir_in_ag.o_ap.connect(m_sb.i_ap_fir_din_mon.analysis_export);
        m_fir_out_ag.o_ap.connect(m_sb.i_ap_fir_dout_mon.analysis_export);
    end
endfunction


function void tb_env::set_server();
    int unsigned hwidth, fwidth;
    qcs_uvm_rpt_srv srv = new();
    if($test$plusargs("UVM_DEFAULT_SERVER")) begin
        `uvm_info(get_full_name(), "Using default report server", UVM_NONE)
    end
    else begin
        if($value$plusargs("fname_width=%d", fwidth))
            srv.file_name_width = fwidth;
        if($value$plusargs("hier_width=%d", hwidth))
            srv.hier_width = hwidth;
        uvm_report_server::set_server(srv);
    end
endfunction