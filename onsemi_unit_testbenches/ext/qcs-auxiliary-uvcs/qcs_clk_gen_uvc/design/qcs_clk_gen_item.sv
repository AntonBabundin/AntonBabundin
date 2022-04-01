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
class qcs_clk_gen_item extends uvm_sequence_item;
  `uvm_object_utils (qcs_clk_gen_item)
  //----
  rand time period = DEFAULT_CLK_PERIOD;
  //----
  extern  function        new (string name = "qcs_clk_gen_item");
  extern  function void   do_record (uvm_recorder recorder);
  extern  function void   do_print (uvm_printer printer);
  extern  function string convert2string ();
  extern  function void   do_copy (uvm_object rhs);
  extern  function bit    do_compare (uvm_object rhs, uvm_comparer comparer);
  //---- extern function void   do_pack ();
  //---- extern function void   do_unpack ();
endclass: qcs_clk_gen_item

//----
function qcs_clk_gen_item::new (string name = "qcs_clk_gen_item");
  super.new(name);
endfunction: new

//----
function void qcs_clk_gen_item::do_record (uvm_recorder recorder);
  super.do_record(recorder);
  `uvm_record_time  ("period", period)
endfunction: do_record

//----
function void qcs_clk_gen_item::do_print (uvm_printer printer);
  super.do_print(printer);
  printer.print_int       ("id",          get_transaction_id(), 'd4, UVM_DEC);
  printer.print_time      ("period",      period);
endfunction

//----
function string qcs_clk_gen_item::convert2string ();
  string s;
  s = $sformatf("\n| period       |\n");
  s = {s, $sformatf("+--------------+\n")};
  s = {s, $sformatf("| %10t |", period)};
  return s;
endfunction

//----
function void qcs_clk_gen_item::do_copy (uvm_object rhs);
  qcs_clk_gen_item rhs_;
  //----
  if(!$cast(rhs_, rhs)) `uvm_fatal(get_name(), QCS_CLK_GEN_RPTS_SQI_CAST_FAILURE)
  super.do_copy(rhs);
  //----
  period = rhs_.period;
endfunction: do_copy

//----
function bit qcs_clk_gen_item::do_compare (uvm_object rhs, uvm_comparer comparer);
  qcs_clk_gen_item rhs_;
  //----
  if(!$cast(rhs_, rhs)) begin
    `uvm_error(get_name(), QCS_CLK_GEN_RPTS_SQI_CAST_FAILURE)
    return 0;
  end
  //----
  return (
    super.do_compare(rhs, comparer) &&
    period == rhs_.period
  );
endfunction: do_compare
