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
class qcs_fir_sqr #(qcs_fir_params_t PARAMS = QCS_FIR_DFLT_PARAMS) extends uvm_sequencer #(qcs_fir_item #(PARAMS));
    `uvm_component_param_utils(qcs_fir_sqr #(PARAMS))
    //----
    uvm_verbosity local_vrb_lvl = UVM_LOW;
    //----
    extern function       new(string name = "qcs_fir_sqr", uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
endclass: qcs_fir_sqr

//----
function qcs_fir_sqr::new(string name = "qcs_fir_sqr", uvm_component parent = null);
    super.new(name, parent);
endfunction

//----
function void qcs_fir_sqr::build_phase(uvm_phase phase);
    `uvm_info(get_name(), "build phase", UVM_FULL);
    super.build_phase(phase);
endfunction: build_phase
