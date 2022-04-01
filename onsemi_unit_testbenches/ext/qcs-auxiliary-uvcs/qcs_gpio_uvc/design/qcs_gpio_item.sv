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
class qcs_gpio_item #(
    qcs_gpio_param_t PARAMS = QCS_GPIO_UVC_DFLT_PARAMS
) extends uvm_sequence_item;
    `uvm_object_param_utils (qcs_gpio_item #(PARAMS))
    //----
    rand bit [PARAMS.WIDTH-1:0] clear;
    rand bit [PARAMS.WIDTH-1:0] set;
         logic [PARAMS.WIDTH-1:0] raw_data;

    //----
    extern  function        new (string name = "qcs_gpio_item");
    extern  function void   do_record (uvm_recorder recorder);
    extern  function void   do_print (uvm_printer printer);
    extern  function string convert2string ();
    extern  function void   do_copy (uvm_object rhs);
    extern  function bit    do_compare (uvm_object rhs, uvm_comparer comparer);
    //---- extern function void   do_pack ();
    //---- extern function void   do_unpack ();
    extern  function bfm_drv_rqst_trn_t convert2bfm_rqst ();
    extern  task            convert2sqi (bfm_mon_trn_t s);
endclass: qcs_gpio_item

//----
function qcs_gpio_item::new (string name = "qcs_gpio_item");
    super.new(name);
endfunction: new

//----
function void qcs_gpio_item::do_record (uvm_recorder recorder);
  super.do_record(recorder);
  `uvm_record_int     ("clear operation", clear,   $bits(clear), UVM_HEX)
  `uvm_record_int     ("set operation  ", set,     $bits(set), UVM_HEX)
endfunction: do_record

//----
function void qcs_gpio_item::do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_int ("id",        get_transaction_id(),  'd4,            UVM_DEC);
    printer.print_int ("clear",     clear,                 $bits(clear),   UVM_HEX);
    printer.print_int ("set",       set,                   $bits(set),     UVM_HEX);
    printer.print_int ("raw data",  raw_data,              $bits(raw_data),UVM_BIN);
endfunction

//----
function string qcs_gpio_item::convert2string ();
    string s;
    s =     $sformatf("\n operation | value\t\t(%s item)", PARAMS.ID);
    s = {s, $sformatf("\n-----------+-----------")};
    s = {s, $sformatf("\n clear     | 0x%0h", clear)};
    s = {s, $sformatf("\n set       | 0x%0h", set)};
    return s;
endfunction

//----
function void qcs_gpio_item::do_copy (uvm_object rhs);
    qcs_gpio_item #(PARAMS) rhs_;
    //----
    if(!$cast(rhs_, rhs)) `uvm_fatal(get_name(), QCS_GPIO_RPTS_SQI_CAST_FAILURE)
    super.do_copy(rhs);
    //----
    clear = rhs_.clear;
    set = rhs_.set;
    raw_data = rhs_.raw_data;
endfunction: do_copy

//----
function bit qcs_gpio_item::do_compare (uvm_object rhs, uvm_comparer comparer);
    qcs_gpio_item #(PARAMS) rhs_;
    //----
    if(!$cast(rhs_, rhs)) begin
      `uvm_error(get_name(), QCS_GPIO_RPTS_SQI_CAST_FAILURE)
      return 0;
    end
    //----
    return (
      super.do_compare(rhs, comparer) &&
      clear == rhs_.clear &&
      set == rhs_.set &&
      raw_data === rhs_.raw_data
    );
endfunction: do_compare

//----
function bfm_drv_rqst_trn_t qcs_gpio_item::convert2bfm_rqst ();
    bfm_drv_rqst_trn_t r = 'x;
    r.clear[PARAMS.WIDTH-1:0] = clear;
    r.set[PARAMS.WIDTH-1:0]   = set;
    return r;
endfunction: convert2bfm_rqst

//----
task qcs_gpio_item::convert2sqi (bfm_mon_trn_t s);
    clear       = s.clear[PARAMS.WIDTH-1:0];
    set         = s.set[PARAMS.WIDTH-1:0];
    raw_data    = s.raw_data[PARAMS.WIDTH-1:0];
endtask: convert2sqi