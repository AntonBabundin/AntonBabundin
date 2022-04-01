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
class qcs_gpio_drv #(
    qcs_gpio_param_t PARAMS = QCS_GPIO_UVC_DFLT_PARAMS
) extends uvm_driver #(qcs_gpio_item #(PARAMS));
    //----
    `uvm_component_param_utils(qcs_gpio_drv #(PARAMS))
    //---- standard variables
    qcs_gpio_cfg            m_cfg;
    qcs_gpio_item #(PARAMS) rqst;
    uvm_verbosity           local_vrb_lvl = UVM_LOW;
    bit                     fl_new_trn, fl_trn_done;
    time                    cur_time;
    bfm_drv_rqst_trn_t      rqst_bfm;
    //----
    virtual qcs_gpio_drv_bfm #(PARAMS.WIDTH) bfm;
    //----
    extern function       new(string name = "qcs_gpio_drv", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  connect_phase(uvm_phase phase);
    extern task           run_phase(uvm_phase phase);
    extern task           start_trn();
    extern task           finish_trn();
    //----
    extern task           get_new_sqi();
    extern task           drive();
endclass: qcs_gpio_drv

//----
function qcs_gpio_drv::new(string name = "qcs_gpio_drv", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//----
function void qcs_gpio_drv::build_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "build phase", UVM_FULL);
    super.build_phase(phase);

    if (!uvm_config_db #(qcs_gpio_cfg)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal(PARAMS.ID, QCS_GPIO_RPTS_CFG_GETTING_FAILURE)
    local_vrb_lvl = m_cfg.vrb_lvl_drv;
endfunction: build_phase

//----
function void qcs_gpio_drv::connect_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "connect phase", UVM_FULL);
    super.connect_phase(phase);
    if (!uvm_config_db #(virtual qcs_gpio_drv_bfm #(PARAMS.WIDTH))::get(this, "", "bfm", bfm))
        `uvm_fatal(PARAMS.ID, QCS_GPIO_RPTS_IF_GETTING_FAILURE)
endfunction: connect_phase

//----
task qcs_gpio_drv::run_phase(uvm_phase phase);
    `uvm_info(PARAMS.ID, "run phase", UVM_FULL)
    fl_new_trn  = '0;
    fl_trn_done = '0;
    bfm.set_dflt_if();
    //----
    forever begin
      fork
        get_new_sqi();
        drive();
      join
      fl_new_trn  = '0;
      fl_trn_done = '0;
      //----
    end
endtask: run_phase


//---- get new sqi
task qcs_gpio_drv::get_new_sqi();
    seq_item_port.get_next_item(rqst);
    start_trn();
    //---- copy parameters into internal variables
    rqst_bfm = rqst.convert2bfm_rqst();
    //----
    fl_new_trn  = '1;
    //----
    while (!fl_trn_done) @(fl_trn_done);
    finish_trn();
    seq_item_port.item_done();
endtask: get_new_sqi


//---- start a new transaction
task qcs_gpio_drv::start_trn();
    cur_time = $time;
    accept_tr(rqst, cur_time);
    void'(begin_tr(
        rqst,
        {PARAMS.ID, "_drv_stream"},
        PARAMS.ID,
        {"gpio values"},
        cur_time
    ));
endtask

//---- finish an already started transtation
task qcs_gpio_drv::finish_trn();
    void'(end_tr(rqst, $time));
    `uvm_info(PARAMS.ID, {"The item is done:\n", rqst.convert2string(), "\n\n"}, local_vrb_lvl)
endtask

task qcs_gpio_drv::drive();
    while (!fl_new_trn) @(fl_new_trn);
    bfm.drive(rqst_bfm);
    fl_trn_done = '1;
endtask
