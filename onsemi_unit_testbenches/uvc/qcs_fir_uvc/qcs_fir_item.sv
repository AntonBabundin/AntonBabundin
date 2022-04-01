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
class qcs_fir_item #(qcs_fir_params_t PARAMS) extends uvm_sequence_item;
    `uvm_object_param_utils (qcs_fir_item #(PARAMS))
    rand logic signed [PARAMS.DW-1:0] data_i ;
    rand logic signed [PARAMS.DW-1:0] data_q ;
  //----
    extern  function            new (string name = "qcs_fir_item");
    extern  function string     convert2string ();
    extern  function void       do_print(uvm_printer printer);
    extern  function void       do_record (uvm_recorder recorder);
    extern  function void       do_copy (uvm_object rhs);
    extern  function bit        do_compare (uvm_object rhs, uvm_comparer comparer);
    extern  function bfm_trn_t  convert2bfm_rqst ();
    extern  task                convert2sqi (bfm_trn_t s);
endclass: qcs_fir_item

//----
function qcs_fir_item::new (string name = "qcs_fir_item");
    super.new(name);
endfunction : new

function string qcs_fir_item::convert2string ();
    string s;
    s =     $sformatf("\n operation | value\t\t(%s item)", PARAMS.ID);
    s = {s, $sformatf("\n-----------+-----------")};
    s = {s, $sformatf("\n data_i     | %0h", data_i)};
    s = {s, $sformatf("\n data_q     | %0h", data_q)};
    return s;
endfunction : convert2string
//----
function void qcs_fir_item::do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_int ("id",        get_transaction_id(),  'd4,            UVM_DEC);
    printer.print_int ("data_i",    data_i,                $bits(data_i),   UVM_DEC);
    printer.print_int ("data_q",    data_q,                $bits(data_q),     UVM_DEC);
endfunction : do_print
//----
function void qcs_fir_item::do_record (uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_int     ("data in real  ", data_i,   $bits(data_i), UVM_HEX)
    `uvm_record_int     ("data in imaginary  ", data_q,     $bits(data_q), UVM_HEX)
endfunction: do_record
//----
function void qcs_fir_item::do_copy (uvm_object rhs);
    qcs_fir_item #(PARAMS) rhs_;
    if(!$cast(rhs_, rhs)) `uvm_fatal(get_name(), QCS_FIR_RPTS_SQI_CAST_FAILURE)
    super.do_copy(rhs);
    data_i    = rhs_.data_i;
    data_q    = rhs_.data_q;
endfunction: do_copy
//----
function bit qcs_fir_item::do_compare (uvm_object rhs, uvm_comparer comparer);
    qcs_fir_item #(PARAMS) rhs_;

    if(!$cast(rhs_, rhs)) begin
        `uvm_error(get_name(), QCS_FIR_RPTS_SQI_CAST_FAILURE)
        return 0;
    end
    
    return (
        super.do_compare(rhs, comparer) &&
        data_i    ===  rhs_.data_i &&
        data_q    ===  rhs_.data_q
    );
endfunction: do_compare
//----
function bfm_trn_t qcs_fir_item::convert2bfm_rqst ();
    bfm_trn_t r;
    r.data_re = data_i;
    r.data_im = data_q;
    return r;
endfunction: convert2bfm_rqst
//----
task qcs_fir_item::convert2sqi (bfm_trn_t s);
    data_i = s.data_re;
    data_q = s.data_im;
endtask: convert2sqi
