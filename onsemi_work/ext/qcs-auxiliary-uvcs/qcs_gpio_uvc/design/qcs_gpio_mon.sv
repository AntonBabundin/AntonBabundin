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
class qcs_gpio_mon #(
    qcs_gpio_param_t PARAMS = QCS_GPIO_UVC_DFLT_PARAMS
) extends uvm_monitor;
    `uvm_component_param_utils(qcs_gpio_mon #(PARAMS))
    //---- standard variables
    qcs_gpio_cfg            m_cfg;
    uvm_verbosity           local_vrb_lvl = UVM_LOW;
    int                     trn_id;
    qcs_gpio_item #(PARAMS) trn, trn2out;
    event                   e_end_of_trn;
    time                    cur_time;
    bfm_mon_trn_t           bfm_trn;
    virtual qcs_gpio_mon_bfm #(PARAMS.WIDTH) bfm;
    //----
    uvm_analysis_port #(qcs_gpio_item #(PARAMS))    o_ap_whole_trn;
    //----
    extern function       new(string name = "qcs_gpio_mon", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
    extern task           run_phase(uvm_phase phase);
    extern task           reporter();
    extern task           collector();
    extern task           start_trn();
    extern task           finish_trn();
endclass: qcs_gpio_mon

//----
function qcs_gpio_mon::new(string name = "qcs_gpio_mon", uvm_component parent = null);
    super.new(name, parent);
    o_ap_whole_trn  = new("o_ap_whole_trn", this);
endfunction: new

//----
function void qcs_gpio_mon::build_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "build phase", UVM_FULL);
    super.build_phase(phase);
    if (!uvm_config_db #(qcs_gpio_cfg)::get(this, "", "m_cfg", m_cfg))
        `uvm_fatal(PARAMS.ID, QCS_GPIO_RPTS_CFG_GETTING_FAILURE)
    local_vrb_lvl = m_cfg.vrb_lvl_mon;
endfunction: build_phase

//----
function void qcs_gpio_mon::connect_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    if (!uvm_config_db #(virtual qcs_gpio_mon_bfm #(PARAMS.WIDTH))::get(this, "", "bfm", bfm))
        `uvm_fatal(PARAMS.ID, QCS_GPIO_RPTS_IF_GETTING_FAILURE)
endfunction: connect_phase

//----
task qcs_gpio_mon::run_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "run phase", UVM_FULL)
    trn = qcs_gpio_item #(PARAMS)::type_id::create({PARAMS.ID, "_tmp_trn"});
    trn_id = 0;
    bfm.start();
    //----
    fork
        reporter();
        collector();
    join_none
endtask: run_phase

//----
task qcs_gpio_mon::reporter();
    forever begin
        @e_end_of_trn;
        trn2out = qcs_gpio_item #(PARAMS)::type_id::create({PARAMS.ID, "_whole_trn"});
        trn2out.copy(trn);
        `uvm_info(PARAMS.ID, $sformatf("\nMON is ready to transfer whole trn:\n%s\n", trn2out.convert2string()), local_vrb_lvl)
        trn2out.set_transaction_id(trn_id++);
        o_ap_whole_trn.write(trn2out);
    end
endtask: reporter

//----
task qcs_gpio_mon::collector();
    forever begin
        @(bfm.e_resp);
        start_trn();
        bfm_trn = bfm.get_values();
        trn.convert2sqi(bfm_trn);
        finish_trn();
        -> e_end_of_trn;
    end
endtask: collector

//---- start a new transaction
task qcs_gpio_mon::start_trn();
    cur_time = $time;
    accept_tr(trn, cur_time);
    void'(begin_tr(
        trn,
        {PARAMS.ID, "_mon_stream"},
        PARAMS.ID,
        "gpio values",
        cur_time
    ));
endtask

//---- finish an already started transtation
task qcs_gpio_mon::finish_trn();
    void'(end_tr(trn, $time));
    // `uvm_info(PARAMS.ID, {"The item is done:\n", trn.convert2string(), "\n\n"}, local_vrb_lvl)
endtask