class fir_rx_chirp_tst extends base_tst;
  `uvm_component_utils(fir_rx_chirp_tst)
  //----
    extern function      new(string name = "fir_rx_chirp_tst", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
endclass: fir_rx_chirp_tst

//----
function fir_rx_chirp_tst::new(string name = "fir_rx_chirp_tst", uvm_component parent = null);
    super.new (name, parent);
endfunction: new

//----
function void fir_rx_chirp_tst::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
    //---- modification
    m_env_cfg.sb_en_rpt_in_hoarder    = '1;
    m_env_cfg.sb_en_report_to_file    = '1;
    m_env_cfg.sb_en_rpt_in_analyzer   = '1;

    m_clk_gen_cfg0.vrb_lvl_drv        = UVM_HIGH;
    m_rst_gen_cfg0.vrb_lvl_drv        = UVM_HIGH;
    m_gpio_cfg0.vrb_lvl_drv           = UVM_HIGH;
    m_fir_in_ag_cfg0.vrb_lvl_drv      = UVM_HIGH;
    m_fir_out_ag_cfg0.vrb_lvl_drv     = UVM_HIGH;
    //---- saving
    uvm_config_db#(tb_cfg)::set(this, "*m_env*", "m_cfg", m_env_cfg);
    uvm_config_db#(qcs_clk_gen_cfg)::set(this, "*m_clk_gen0*", "m_cfg", m_clk_gen_cfg0);
    uvm_config_db#(qcs_rst_gen_cfg)::set(this, "*m_rst_gen0*", "m_cfg", m_rst_gen_cfg0);
    uvm_config_db#(qcs_fir_cfg)::set(this, "m_fir_in_ag*", "m_cfg", m_fir_in_ag_cfg0);
    uvm_config_db#(qcs_fir_cfg)::set(this, "*m_fir_out_ag*", "m_cfg", m_fir_out_ag_cfg0);
  //---- create test environment
    m_env = tb_env::type_id::create("m_env", this);
  //----
  uvm_config_db#(uvm_object_wrapper)::set(
    this,"m_env.m_vsqr.run_phase",
    "default_sequence",
    fir_rx_chirp_tst_sq::type_id::get()
  );endfunction: build_phase