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
class qcs_clk_gen_drv #(
  parameter string ID = ""
) extends uvm_driver #(qcs_clk_gen_item);
  //----
  `uvm_component_param_utils(qcs_clk_gen_drv #(ID))
  //---- standard variables
  qcs_clk_gen_cfg     m_cfg;
  qcs_clk_gen_item     req;
  uvm_verbosity   local_vrb_lvl = UVM_LOW;
  logic           fl_new_sqi;
  time            cur_time;
  time            half_of_period;
  // string       wf_notice;
  virtual qcs_clk_gen_if vif;
  //----
  extern function       new(string name = "qcs_clk_gen_drv", uvm_component parent = null);
  extern function void  build_phase(uvm_phase phase);
  extern function void  connect_phase(uvm_phase phase);
  extern task           run_phase(uvm_phase phase);
  extern task           set_dflt_if();
  extern task           start_trn();
  extern task           finish_trn();
  //----
  extern task           get_new_sqi();
  extern task           drive();
endclass: qcs_clk_gen_drv

//----
function qcs_clk_gen_drv::new(string name = "qcs_clk_gen_drv", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

//----
function void qcs_clk_gen_drv::build_phase(uvm_phase phase);
  `uvm_info(get_name(), "build phase", UVM_FULL);
  super.build_phase(phase);
  if (!uvm_config_db #(qcs_clk_gen_cfg)::get(this, "", "m_cfg", m_cfg))
    `uvm_fatal(ID, QCS_CLK_GEN_RPTS_CFG_GETTING_FAILURE)
  local_vrb_lvl = m_cfg.vrb_lvl_drv;
endfunction: build_phase

//----
function void qcs_clk_gen_drv::connect_phase(uvm_phase phase);
  `uvm_info(get_name(), "connect phase", UVM_FULL);
  super.connect_phase(phase);
  if (!uvm_config_db #(virtual qcs_clk_gen_if)::get(this, "", "vif", vif))
    `uvm_fatal(ID, QCS_CLK_GEN_RPTS_IF_GETTING_FAILURE)
endfunction: connect_phase

//----
task qcs_clk_gen_drv::run_phase(uvm_phase phase);
  `uvm_info(get_name(), "run phase", UVM_FULL)
  set_dflt_if();
  get_new_sqi();
  fl_new_sqi = '0;
  //----
  forever begin
    fork
      get_new_sqi();
      drive();
    join
    fl_new_sqi = '0;
    //----
  end
endtask: run_phase

//---- set default statements
task qcs_clk_gen_drv::set_dflt_if();
  vif.r_clk = DEFAULT_OUPUT_LVL;
endtask: set_dflt_if

//---- get new sqi
task qcs_clk_gen_drv::get_new_sqi();
  seq_item_port.get_next_item(req);
  start_trn();
  //---- copy parameters into internal variables
  half_of_period = req.period/2;
  //----
  fl_new_sqi  = '1;
  //----
  finish_trn();
  seq_item_port.item_done();
endtask: get_new_sqi


//---- start a new transaction
task qcs_clk_gen_drv::start_trn();
  cur_time = $time;
  accept_tr(req, cur_time);
  void'(
    begin_tr(
      req, {ID, "_drv_stream"}, ID,
      {"clk generator settings"},
      cur_time
    )
  );
endtask

//---- finish an already started transtation
task qcs_clk_gen_drv::finish_trn();
  void'(end_tr(req, $time));
  `uvm_info(ID, {"The item is done:\n", req.convert2string(), "\n\n"}, local_vrb_lvl)
  //req.print(); // for debugging
endtask

//---- drive lines
task qcs_clk_gen_drv::drive();
  do begin
    vif.r_clk = '1;
    #(half_of_period);
    vif.r_clk = '0;
    #(half_of_period);
  end
  while (!fl_new_sqi);
endtask: drive
