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
class qcs_gpio_ag #(
    qcs_gpio_param_t PARAMS = QCS_GPIO_UVC_DFLT_PARAMS
) extends uvm_agent;
    //----
    `uvm_component_param_utils(qcs_gpio_ag #(PARAMS))
    //----
    qcs_gpio_cfg            m_cfg;
    qcs_gpio_drv  #(PARAMS) m_drv;
    qcs_gpio_sqr  #(PARAMS) m_sqr;
    qcs_gpio_mon  #(PARAMS) m_mon;
    //----
    uvm_analysis_port#(qcs_gpio_item #(PARAMS)) o_ap;
    //----
    extern function       new(string name = "qcs_gpio_ag", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
endclass: qcs_gpio_ag

//----
function qcs_gpio_ag::new(string name = "qcs_gpio_ag", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void qcs_gpio_ag::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
    //----
    super.build_phase(phase);
    //----
    if (!uvm_config_db #(qcs_gpio_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(PARAMS.ID, QCS_GPIO_RPTS_CFG_GETTING_FAILURE)
    //----
    if(m_cfg.active == UVM_ACTIVE) begin
        m_sqr = qcs_gpio_sqr#(PARAMS)::type_id::create("m_sqr", this);
        m_drv = qcs_gpio_drv#(PARAMS)::type_id::create("m_drv", this);
    end
    m_mon = qcs_gpio_mon#(PARAMS)::type_id::create("m_mon", this);
endfunction: build_phase

//----
function void qcs_gpio_ag::connect_phase(uvm_phase phase);
    `uvm_info(get_name(), "connect phase", UVM_FULL);
    super.connect_phase(phase);
    //----
    o_ap = m_mon.o_ap_whole_trn;
    //----
    if(m_cfg.active == UVM_ACTIVE) m_drv.seq_item_port.connect(m_sqr.seq_item_export);
endfunction: connect_phase
