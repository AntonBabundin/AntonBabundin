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
class qcs_dyn_pre_gen_item #(qcs_dyn_pre_gen_params_t PARAMS) extends uvm_sequence_item;
    `uvm_object_param_utils (qcs_dyn_pre_gen_item #(PARAMS))
    logic unsigned [PARAMS.ADDR_W-1:0]    raddr;
    logic unsigned [PARAMS.BW_W-1:0]      sys_bw;
    logic unsigned [PARAMS.BW_W-1:0]      pkt_bw;
    logic unsigned [PARAMS.GAMMA_W-1:0]   gamma_rotation;
    logic unsigned [PARAMS.SUBBAND_W-1:0] mu_subband_punct;
    logic unsigned [3:0]                  n_tx;
    logic unsigned                        nhtp_4ch;
    //----
    extern  function            new (string name = "qcs_dyn_pre_gen_item");
    extern  function string     convert2string ();
    extern  function void       do_print(uvm_printer printer);
    extern  function void       do_record (uvm_recorder recorder);
    extern  function void       do_copy (uvm_object rhs);
    extern  function bit        do_compare (uvm_object rhs, uvm_comparer comparer);
    extern  function bfm_trn_t  convert2bfm_rqst ();
    extern  task                convert2sqi (bfm_trn_t s);
endclass: qcs_dyn_pre_gen_item

//----
function qcs_dyn_pre_gen_item::new (string name = "qcs_dyn_pre_gen_item");
    super.new(name);
endfunction : new

function string qcs_dyn_pre_gen_item::convert2string ();
    string s;
    s =     $sformatf("\n operation                 | value\t\t(%s item)", PARAMS.ID);
    s = {s, $sformatf("\n---------------------------+------------")};
    s = {s, $sformatf("\n nhtp_raddr                | %0h", raddr)};
    s = {s, $sformatf("\n sys_bw_mode               | %0h", sys_bw)};
    s = {s, $sformatf("\n txconfig_bw               | %0h", pkt_bw)};
    s = {s, $sformatf("\n config_gamma_rotation     | %0h", gamma_rotation)};
    s = {s, $sformatf("\n config_mu_subband_present | %0h", mu_subband_punct)};
    s = {s, $sformatf("\n tx chains                 | %0h", n_tx)};
    s = {s, $sformatf("\n nhtp 4ch                  | %0h", nhtp_4ch)};

    return s;
endfunction : convert2string
//----
function void qcs_dyn_pre_gen_item::do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_int ("id",                        get_transaction_id(), 'd4,                     UVM_DEC);
    printer.print_int ("nhtp_raddr",                raddr,                $bits(raddr),            UVM_DEC);
    printer.print_int ("sys_bw_mode",               sys_bw,               $bits(sys_bw),           UVM_DEC);
    printer.print_int ("txconfig_bw",               pkt_bw,               $bits(pkt_bw),           UVM_DEC);
    printer.print_int ("config_gamma_rotation",     gamma_rotation,       $bits(gamma_rotation),   UVM_DEC);
    printer.print_int ("config_mu_subband_present", mu_subband_punct,     $bits(mu_subband_punct), UVM_DEC);
    printer.print_int ("tx chains",                 n_tx,                 $bits(n_tx),             UVM_DEC);
    printer.print_int ("nhtp 4ch",                  nhtp_4ch,             $bits(nhtp_4ch),         UVM_DEC);

endfunction : do_print
//----
function void qcs_dyn_pre_gen_item::do_record (uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_int     ("nhtp_raddr  ",                raddr,            $bits(raddr), UVM_HEX)
    `uvm_record_int     ("sys_bw_mode  ",               sys_bw,           $bits(sys_bw), UVM_HEX)
    `uvm_record_int     ("txconfig_bw  ",               pkt_bw,           $bits(pkt_bw), UVM_HEX)
    `uvm_record_int     ("config_gamma_rotation  ",     gamma_rotation,   $bits(gamma_rotation), UVM_HEX)
    `uvm_record_int     ("config_mu_subband_present  ", mu_subband_punct, $bits(mu_subband_punct), UVM_HEX)
    `uvm_record_int     ("tx chains  ",                 n_tx,             $bits(n_tx), UVM_HEX)
    `uvm_record_int     ("nhtp 4ch  ",                  nhtp_4ch,         $bits(nhtp_4ch), UVM_HEX)
endfunction: do_record
//----
function void qcs_dyn_pre_gen_item::do_copy (uvm_object rhs);
    qcs_dyn_pre_gen_item #(PARAMS) rhs_;
    if(!$cast(rhs_, rhs)) `uvm_fatal(get_name(), QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_CAST_FAILURE)
    super.do_copy(rhs);
    raddr            = rhs_.raddr;
    sys_bw           = rhs_.sys_bw;
    pkt_bw           = rhs_.pkt_bw;
    gamma_rotation   = rhs_.gamma_rotation;
    mu_subband_punct = rhs_.mu_subband_punct;
    n_tx             = rhs_.n_tx;
    nhtp_4ch         = rhs_.nhtp_4ch;
endfunction: do_copy
//----
function bit qcs_dyn_pre_gen_item::do_compare (uvm_object rhs, uvm_comparer comparer);
    qcs_dyn_pre_gen_item #(PARAMS) rhs_;

    if(!$cast(rhs_, rhs)) begin
        `uvm_error(get_name(), QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_CAST_FAILURE)
        return 0;
    end
    
    return (
        super.do_compare(rhs, comparer) &&
        raddr            ===  rhs_.raddr &&
        sys_bw           ===  rhs_.sys_bw &&
        pkt_bw           ===  rhs_.pkt_bw &&
        gamma_rotation   ===  rhs_.gamma_rotation &&
        mu_subband_punct ===  rhs_.mu_subband_punct &&
        n_tx             ===  rhs_.n_tx &&
        nhtp_4ch         ===  rhs_.nhtp_4ch
        );
endfunction: do_compare
//----
function bfm_trn_t qcs_dyn_pre_gen_item::convert2bfm_rqst ();
    bfm_trn_t r;
    r.addr             = raddr;
    r.sys_bw           = sys_bw;
    r.pkt_bw           = pkt_bw;
    r.gamma_rotation   = gamma_rotation;
    r.mu_subband_punct = mu_subband_punct;
    r.num_of_tx_chains = n_tx;
    r.num_4ch          = nhtp_4ch;
    return r;
endfunction: convert2bfm_rqst
//----
task qcs_dyn_pre_gen_item::convert2sqi (bfm_trn_t s);
    raddr            = s.addr;
    sys_bw           = s.sys_bw;
    pkt_bw           = s.pkt_bw;
    gamma_rotation   = s.gamma_rotation;
    mu_subband_punct = s.mu_subband_punct;
    n_tx             = s.num_of_tx_chains;
    nhtp_4ch         = s.num_4ch;
endtask: convert2sqi
