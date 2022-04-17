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
class start_sq extends base_sq;
  `uvm_object_utils(start_sq)
  //----
  localparam time CLK_PRD0 = 20ns;
  //----
  extern function  new(string name = "start_sq");
  extern task      body();
endclass: start_sq

//----
function start_sq::new(string name = "start_sq");
  super.new(name);
  local_vrb_lvl = UVM_HIGH;
endfunction: new

//----
task start_sq::body();
  `uvm_info(get_name(), "starting", local_vrb_lvl)
  #50ns;
  //---- set clk and reset
  fork
    generate_rst0(10*CLK_PRD0);
    set_clk0(CLK_PRD0);
  join_any
  #1000ns;
endtask: body
