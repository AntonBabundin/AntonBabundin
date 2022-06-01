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
class qcs_dyn_pre_gen_sqr #(qcs_dyn_pre_gen_params_t PARAMS) extends uvm_sequencer #(qcs_dyn_pre_gen_item #(PARAMS));
    `uvm_component_param_utils(qcs_dyn_pre_gen_sqr #(PARAMS))
    //----
    uvm_verbosity local_vrb_lvl = UVM_LOW;
    //----
    extern function       new(string name = "qcs_dyn_pre_gen_sqr", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
endclass: qcs_dyn_pre_gen_sqr

//----
function qcs_dyn_pre_gen_sqr::new(string name = "qcs_dyn_pre_gen_sqr", uvm_component parent = null);
    super.new(name, parent);
endfunction

//----
function void qcs_dyn_pre_gen_sqr::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
    super.build_phase(phase);
endfunction: build_phase
