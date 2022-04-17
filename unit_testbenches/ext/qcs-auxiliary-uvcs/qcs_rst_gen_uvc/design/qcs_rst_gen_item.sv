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
class qcs_rst_gen_item extends uvm_sequence_item;
  `uvm_object_utils (qcs_rst_gen_item)
  //----
  rand rst_level_t rst_lvl = RST_LVL_PASSIVE;
  //----
  extern  function        new (string name = "qcs_rst_gen_item");
  extern  function void   do_record (uvm_recorder recorder);
  extern  function void   do_print (uvm_printer printer);
  extern  function string convert2string ();
  extern  function void   do_copy (uvm_object rhs);
  extern  function bit    do_compare (uvm_object rhs, uvm_comparer comparer);
  //---- extern function void   do_pack ();
  //---- extern function void   do_unpack ();
endclass: qcs_rst_gen_item

//----
function qcs_rst_gen_item::new (string name = "qcs_rst_gen_item");
  super.new(name);
endfunction: new

//----
function void qcs_rst_gen_item::do_record (uvm_recorder recorder);
  super.do_record(recorder);
  `uvm_record_string   ("rst_lvl ", rst_lvl.name())
endfunction: do_record

//----
function void qcs_rst_gen_item::do_print (uvm_printer printer);
  super.do_print(printer);
  printer.print_int       ("id",          get_transaction_id(), 'd4, UVM_DEC);
  printer.print_string    ("rst state",   rst_lvl.name());
endfunction

//----
function string qcs_rst_gen_item::convert2string ();
  string s;
  s = $sformatf("\n| rst level |");
  s = {s, $sformatf("\n+-----------+")};
  s = {s, $sformatf("\n| %9s |",
      rst_lvl.name()
    )
  };
  return s;
endfunction

//----
function void qcs_rst_gen_item::do_copy (uvm_object rhs);
  qcs_rst_gen_item rhs_;
  //----
  if(!$cast(rhs_, rhs)) `uvm_fatal(get_name(), QCS_RST_GEN_RPTS_SQI_CAST_FAILURE)
  super.do_copy(rhs);
  //----
  rst_lvl = rhs_.rst_lvl;
endfunction: do_copy

//----
function bit qcs_rst_gen_item::do_compare (uvm_object rhs, uvm_comparer comparer);
  qcs_rst_gen_item rhs_;
  //----
  if(!$cast(rhs_, rhs)) begin
    `uvm_error(get_name(), QCS_RST_GEN_RPTS_SQI_CAST_FAILURE)
    return 0;
  end
  //----
  return (
    super.do_compare(rhs, comparer) &&
    rst_lvl == rhs_.rst_lvl
  );
endfunction: do_compare
