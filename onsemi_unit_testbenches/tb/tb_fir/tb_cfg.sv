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
class tb_cfg extends uvm_object;
    `uvm_object_utils(tb_cfg)
    //---- parameters
    uvm_active_passive_enum en_sb               = UVM_PASSIVE;
    //---- verbosity levels
    uvm_verbosity vrb_lvl_sqr = UVM_HIGH; // UVM_HIGH
    uvm_verbosity vrb_lvl_sb  = UVM_HIGH; // UVM_HIGH
    //---- scoreboard settings
    bit sb_en_rpt_in_hoarder     = '1;  //
    bit sb_en_rpt_in_analyzer    = '0;  //
    bit sb_en_report_to_file     = '0;
    bit sq_en_rpt_print          = '0;
    extern function new(string name = "tb_cfg");
    extern function tb_cfg  get_config(uvm_component c);
endclass: tb_cfg

//----
function tb_cfg::new(string name = "tb_cfg");
    super.new(name);
endfunction: new

//----
function tb_cfg tb_cfg::get_config(uvm_component c);
    tb_cfg t;
    if (!uvm_config_db #(tb_cfg)::get(c, "", "tb_cfg", t) ) begin
        `uvm_fatal(get_type_name(), TB_RPTS_CFG_GETTING_FAILURE)
    end
    return t;
endfunction: get_config
