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
class c_model_queues;
    typedef struct {
        int     no_active_chkp_q;
        int     no_inactive_chkp_q;
        string  uniq_active_chkp_id[string];
        string  uniq_inactive_chkp_id[string];
        int     no_non_zl_active_chkp_q;
        int     avg_active_chkp_q_size;
        int     active_chkp_q_max_size;
        int     active_chkp_q_min_size;
    } checkers_stat_t;

    typedef struct packed {
        int     tag;
        longint time_stamp;
        longint re_val;
        longint im_val;
    } checker_val_t;

    protected string id;
    protected uvm_queue #(checker_val_t) q [string];
    protected checkers_stat_t stat;

    //----
    extern function                new(input string id = "c_model_queues");
    extern task                    push_back(input string indx, input bit mask, input checker_val_t val);
    extern function checker_val_t  pop_front(input string indx);
    extern function int            size(input string indx);
    extern function c_model_queues get_handle();
    extern function bit            is_exist(input string indx);
    extern task                    print_checkers_statistics();
    extern task                    print_stat();
endclass: c_model_queues

//----
function c_model_queues::new(input string id = "c_model_queues");
    this.id  = id;
    stat.no_active_chkp_q   = 0;
    stat.no_inactive_chkp_q = 0;
    `uvm_info(id, $sformatf("\nA 'c_model_queues' class instance has been created - handle %0d\n", this), UVM_LOW)
endfunction

//----
task c_model_queues::push_back(input string indx, input bit mask, input c_model_queues::checker_val_t val);
    if (mask == 0) begin
        // `uvm_info(id, $sformatf("C-queue: pushing back %0s, %4h j%4h", indx, val.re_val, val.im_val), UVM_LOW)
        if (!is_exist(indx)) begin
            q[indx] = new();
            stat.no_active_chkp_q++;
            // stat.active_indxs_log.push_back(indx);
        end
        q[indx].push_back(val);
        if (!stat.uniq_active_chkp_id.exists(indx)) stat.uniq_active_chkp_id[indx] = indx;
    end
    else begin
        stat.no_inactive_chkp_q++;
        if (!stat.uniq_inactive_chkp_id.exists(indx)) stat.uniq_inactive_chkp_id[indx] = indx;
    end
endtask

//----
function c_model_queues::checker_val_t c_model_queues::pop_front(input string indx);
    pop_front = q[indx].pop_front();
endfunction

//----
function int c_model_queues::size(input string indx);
    if (is_exist(indx))
        size = q[indx].size();
    else
        `uvm_error(id, {"The requested element of 'c_model_queues' with index - ", indx, " does not exist"})
endfunction

//----
function c_model_queues c_model_queues::get_handle();
    if (this == null)
        `uvm_error(id, "An exemplar of the 'c_model_queues' object was not created")
    else
        get_handle = this;
endfunction

//----
function bit c_model_queues::is_exist(input string indx);
    if (q.exists(indx)) is_exist = '1;
    else                is_exist = '0;
endfunction

//---- results of the function are adequate until you invoke the 'pop_front' task first time
task c_model_queues::print_checkers_statistics();
    int     size;
    stat.avg_active_chkp_q_size = 0;
    stat.no_non_zl_active_chkp_q = 0;
    stat.active_chkp_q_max_size = 0;
    stat.active_chkp_q_min_size = 0;
    foreach (q[i]) begin
        size = q[i].size();
        if (size > 0) begin
            stat.avg_active_chkp_q_size += size;
            stat.no_non_zl_active_chkp_q++;
        end
        if (stat.active_chkp_q_max_size < size) stat.active_chkp_q_max_size = size;
        if (stat.active_chkp_q_min_size > size) stat.active_chkp_q_min_size = size;
        `uvm_info(id, $sformatf("C-queue %0s, size %0d", i, size), UVM_LOW)
    end
    stat.avg_active_chkp_q_size /= stat.no_non_zl_active_chkp_q;
    print_stat();
endtask

//----
task c_model_queues::print_stat();
    string rpt;
    rpt = "\n\n*****";
    rpt = {rpt, "\n\nCheckpoints statistics:"};
    rpt = {rpt, $sformatf({
                "\n\tGeneral:",
                "\n\t\tNumber of active queues:         \t%0d",
                "\n\t\tNumber of inactive queues:       \t%0d",
                "\n\t\tNumber of non-zero active queues:\t%0d",
                "\n\t\tAverage non-zero queue size:     \t%0d",
                "\n\t\tMaximum active queue size:       \t%0d",
                "\n\t\tMinimum active queue size:       \t%0d"
            },
            stat.no_active_chkp_q,
            stat.no_inactive_chkp_q,
            stat.no_non_zl_active_chkp_q,
            stat.avg_active_chkp_q_size,
            stat.active_chkp_q_max_size,
            stat.active_chkp_q_min_size
        )
    };
    rpt = {rpt, "\n\tActive checkpoints IDs:\n\t\t"};
    foreach (stat.uniq_active_chkp_id[i]) rpt = {rpt, stat.uniq_active_chkp_id[i]};
    rpt = {rpt, "\n\tInactive checkpoints IDs:\n\t\t"};
    foreach (stat.uniq_inactive_chkp_id[i]) rpt = {rpt, stat.uniq_inactive_chkp_id[i]};
    rpt = {rpt, "\n\n*****\n\n"};
    `uvm_info(id, rpt, UVM_LOW)
endtask
