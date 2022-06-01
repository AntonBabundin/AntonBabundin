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
class qcs_dyn_pre_gen_item_out #(qcs_dyn_pre_gen_params_out_t PARAMS) extends uvm_sequence_item;
    `uvm_object_param_utils (qcs_dyn_pre_gen_item_out #(PARAMS))
    //
    logic signed [PARAMS.DW-1:0] data_i_0;
    logic signed [PARAMS.DW-1:0] data_q_0;
    logic signed [PARAMS.DW-1:0] data_i_1;
    logic signed [PARAMS.DW-1:0] data_q_1;
    //----
    extern  function            new (string name = "qcs_dyn_pre_gen_item_out");
    extern  function string     convert2string ();
    extern  function void       do_print(uvm_printer printer);
    extern  function void       do_record (uvm_recorder recorder);
    extern  function void       do_copy (uvm_object rhs);
    extern  function bit        do_compare (uvm_object rhs, uvm_comparer comparer);
    extern  function bfm_trn_t  convert2bfm_rqst ();
    extern  task                convert2sqi (bfm_trn_t s);
endclass: qcs_dyn_pre_gen_item_out

//----
function qcs_dyn_pre_gen_item_out::new (string name = "qcs_dyn_pre_gen_item_out");
    super.new(name);
endfunction : new

function string qcs_dyn_pre_gen_item_out::convert2string ();
    string s;
    s =     $sformatf("\n operation | value\t\t(%s item)", PARAMS.ID);
    s = {s, $sformatf("\n-----------+-----------")};
    s = {s, $sformatf("\n dout_i_0| %0h", data_i_0)};
    s = {s, $sformatf("\n data_q_0| %0h", data_q_0)};
    s = {s, $sformatf("\n dout_i_1| %0h", data_i_1)};
    s = {s, $sformatf("\n data_q_1| %0h", data_q_1)};
    return s;
endfunction : convert2string
//----
function void qcs_dyn_pre_gen_item_out::do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_int ("id",        get_transaction_id(),  'd4,            UVM_DEC);
    printer.print_int ("data_i_0",    data_i_0,                $bits(data_i_0),   UVM_DEC);
    printer.print_int ("data_q_0",    data_q_0,                $bits(data_q_0),   UVM_DEC);
    printer.print_int ("data_i_1",    data_i_1,                $bits(data_i_1),   UVM_DEC);
    printer.print_int ("data_q_1",    data_q_1,                $bits(data_q_1),   UVM_DEC);

endfunction : do_print
//----
function void qcs_dyn_pre_gen_item_out::do_record (uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_int     ("data_i_0  ", data_i_0,   $bits(data_i_0), UVM_HEX)
    `uvm_record_int     ("data_q_0  ", data_q_0,   $bits(data_q_0), UVM_HEX)
    `uvm_record_int     ("data_i_1  ", data_i_1,   $bits(data_i_1), UVM_HEX)
    `uvm_record_int     ("data_q_1  ", data_q_1,   $bits(data_q_1), UVM_HEX)

endfunction: do_record
//----
function void qcs_dyn_pre_gen_item_out::do_copy (uvm_object rhs);
    qcs_dyn_pre_gen_item_out #(PARAMS) rhs_;
    if(!$cast(rhs_, rhs)) `uvm_fatal(get_name(), QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_CAST_FAILURE)
    super.do_copy(rhs);
    data_i_0    = rhs_.data_i_0;
    data_q_0    = rhs_.data_q_0;
    data_i_1    = rhs_.data_i_1;
    data_q_1    = rhs_.data_q_1;
endfunction: do_copy
//----
function bit qcs_dyn_pre_gen_item_out::do_compare (uvm_object rhs, uvm_comparer comparer);
    qcs_dyn_pre_gen_item_out #(PARAMS) rhs_;

    if(!$cast(rhs_, rhs)) begin
        `uvm_error(get_name(), QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_CAST_FAILURE)
        return 0;
    end
    
    return (
        super.do_compare(rhs, comparer) &&
        data_i_0    === rhs_.data_i_0 &&
        data_q_0    === rhs_.data_q_0 &&
        data_i_1    === rhs_.data_i_1 &&
        data_q_1    === rhs_.data_q_1
        );
endfunction: do_compare
//----
function bfm_trn_t qcs_dyn_pre_gen_item_out::convert2bfm_rqst ();
    bfm_trn_t r;
    r.data_i_0 = data_i_0;
    r.data_q_0 = data_q_0;
    r.data_i_1 = data_i_1;
    r.data_q_1 = data_q_1;
    return r;
endfunction: convert2bfm_rqst
//----
task qcs_dyn_pre_gen_item_out::convert2sqi (bfm_trn_t s);
    data_i_0 = s.data_i_0;
    data_q_0 = s.data_q_0;
    data_i_1 = s.data_i_1;
    data_q_1 = s.data_q_1;
endtask: convert2sqi
