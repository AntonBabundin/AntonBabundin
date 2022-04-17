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
class base_tst extends uvm_test;     //all tests should derive from uvm_test and use `uvm_component_utils
    `uvm_component_utils(base_tst)     //create constructor, registers with factory, etc
    //----
    tb_env              m_env;
    tb_cfg              m_env_cfg;
    qcs_rst_gen_cfg     m_rst_gen_cfg0;
    qcs_clk_gen_cfg     m_clk_gen_cfg0;
    qcs_clk_gen_cfg     m_clk_rx_gen_cfg0;
    qcs_gpio_cfg        m_gpio_cfg0;

    qcs_fir_cfg         m_fir_in_ag_cfg0;
    qcs_fir_cfg         m_fir_out_ag_cfg0;
    //----
    c_model_queues      m_model_queues;

    extern function         new(string name = "base_tst", uvm_component parent = null);
    extern function void    start_of_simulation_phase(uvm_phase phase);
    extern function void    build_phase(uvm_phase phase);
endclass: base_tst

//----
function base_tst::new(string name = "base_tst", uvm_component parent = null);
    super.new (name, parent);
    $timeformat(-9, 2, "ns", 5);
endfunction: new

//----
function void base_tst::start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_name(), "topology report", UVM_LOW);
    this.print();
endfunction

//----
function void base_tst::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "building", UVM_FULL);

    m_model_queues = new("m_model_queues");
    void'(uvm_resource_db #(c_model_queues)::set("*", "m_model_queues", m_model_queues));

    //---- configurate test env
    uvm_config_int::set(this, "*", "recording_detail", UVM_FULL);
    m_env_cfg = tb_cfg::type_id::create("m_env_cfg");
    m_env_cfg.en_sb = UVM_ACTIVE;
    uvm_config_db #(tb_cfg)::set(this, "*m_env*", "m_cfg", m_env_cfg);

    //---- rst configuration
    m_rst_gen_cfg0 = qcs_rst_gen_cfg::type_id::create("m_rst_gen_cfg0", this);
    uvm_config_db#(qcs_rst_gen_cfg)::set(this, "*m_rst_gen0*", "m_cfg", m_rst_gen_cfg0);

    //---- clk_gen configuration
    m_clk_gen_cfg0 = qcs_clk_gen_cfg::type_id::create("m_clk_gen_cfg0", this);
    uvm_config_db#(qcs_clk_gen_cfg)::set(this, "*m_clk_gen0*", "m_cfg", m_clk_gen_cfg0);

    m_clk_rx_gen_cfg0 = qcs_clk_gen_cfg::type_id::create("m_clk_rx_gen_cfg0", this);
    uvm_config_db#(qcs_clk_gen_cfg)::set(this, "*m_clk_rx_gen0*", "m_cfg", m_clk_rx_gen_cfg0);

    //---- gpio configuration
    m_gpio_cfg0 = qcs_gpio_cfg::type_id::create("m_gpio_cfg0", this);
    m_gpio_cfg0.active = UVM_ACTIVE;
    uvm_config_db#(qcs_gpio_cfg)::set(this, "*m_gpio*", "m_cfg", m_gpio_cfg0);

    // fir agents configuration
    m_fir_in_ag_cfg0 = qcs_fir_cfg::type_id::create("m_fir_in_ag_cfg0", this);
    m_fir_in_ag_cfg0.active = UVM_ACTIVE;
    uvm_config_db#(qcs_fir_cfg)::set(this, "*m_fir_in_ag*", "m_cfg", m_fir_in_ag_cfg0);

    m_fir_out_ag_cfg0 = qcs_fir_cfg::type_id::create("m_fir_out_ag_cfg0", this);
    m_fir_out_ag_cfg0.active = UVM_PASSIVE;
    uvm_config_db#(qcs_fir_cfg)::set(this, "*m_fir_out_ag*", "m_cfg", m_fir_out_ag_cfg0);

endfunction
