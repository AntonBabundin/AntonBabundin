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
class gen_eht_mu_gamma_rot_test extends base_tst;
  `uvm_component_utils(gen_eht_mu_gamma_rot_test)
  //----
    extern function      new(string name = "gen_eht_mu_gamma_rot_test", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
endclass: gen_eht_mu_gamma_rot_test

//----
function gen_eht_mu_gamma_rot_test::new(string name = "gen_eht_mu_gamma_rot_test", uvm_component parent = null);
    super.new (name, parent);
endfunction: new

//----
function void gen_eht_mu_gamma_rot_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
    //---- modification
    m_env_cfg.sb_en_report_to_file    = '1;

    m_clk_gen_cfg0.vrb_lvl_drv        = UVM_LOW;
    m_rst_gen_cfg0.vrb_lvl_drv        = UVM_LOW;
    m_gpio_cfg0.vrb_lvl_drv           = UVM_LOW;
    m_gen_in_ag_cfg0.vrb_lvl_drv      = UVM_LOW;
    //---- saving
    uvm_config_db#(tb_cfg)::set(this, "*m_env*", "m_cfg", m_env_cfg);
    uvm_config_db#(qcs_clk_gen_cfg)::set(this, "*m_clk_gen0*", "m_cfg", m_clk_gen_cfg0);
    uvm_config_db#(qcs_rst_gen_cfg)::set(this, "*m_rst_gen0*", "m_cfg", m_rst_gen_cfg0);
    uvm_config_db#(qcs_dyn_pre_gen_cfg)::set(this, "m_gen_in_ag", "m_cfg", m_gen_in_ag_cfg0);
  //---- create test environment
    m_env = tb_env::type_id::create("m_env", this);
  //----
    uvm_config_db#(uvm_object_wrapper)::set(this,"m_env.m_vsqr.run_phase", "default_sequence", gen_eht_mu_gamma_rot_sq::type_id::get());
endfunction: build_phase