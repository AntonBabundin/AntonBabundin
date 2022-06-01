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
package tb_dpi_pkg;
    import   uvm_pkg::*;
    import   tb_globals_pkg::*;
    `include "uvm_macros.svh"

    //Variables
    bit             fl_c_model_aux_queues_is_got = 1'b0;
    c_model_queues  m_model_aux_chkp_queues;
    //---- C -> SV: C-model tasks/functions wrappers
    import "DPI-C" context task dyn_pre_gen_wrapper (
        input  int     sys_bw,
        input  int     pkt_bw,
        input  int     format,
        input  int     gamma_rot,
        input  int     subband_punct,
        input  int     chain_tx,
        input  int     n_4ch
    );

    //---- SV -> C: tasks to use in a C-model
    export "DPI-C" push_aux_chkp = task sv_dpi_push_aux_chkp;
    //----
    //----
    task sv_dpi_push_chkp (
        input string id,
        input bit mask,
        input c_model_queues::checker_val_t val
    );
        if (!fl_c_model_aux_queues_is_got) begin
            void'(uvm_resource_db #(c_model_queues)::read_by_name("*", "m_model_queues", m_model_aux_chkp_queues));
            fl_c_model_aux_queues_is_got = '1;
        end
        //----
        m_model_aux_chkp_queues.push_back(id, mask, val);
    endtask : sv_dpi_push_chkp

    //----
    task sv_dpi_push_aux_chkp (input longint val, input string id);
        sv_dpi_push_chkp(
            id,
            0,
            '{0, 0, val[($bits(longint) - 1) : ($bits(longint)/2)], val[($bits(longint)/2 - 1) : 0]}
        );
    endtask : sv_dpi_push_aux_chkp

endpackage
