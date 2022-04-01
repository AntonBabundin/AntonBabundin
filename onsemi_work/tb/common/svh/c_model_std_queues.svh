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
//---- classes
class c_model_std_queues extends c_model_queues;
    extern function                                 new(input string id = "c_model_std_queues");
    extern task                                     push_back(input int chkp, modem, chain, stream, tone, segment, user, field, symbol, input bit mask, input checker_val_t val);
    extern function c_model_queues::checker_val_t   pop_front(input int chkp, modem, chain, stream, tone, segment, user, field, symbol);
    extern function int                             size(input int chkp, modem, chain, stream, tone, segment, user, field, symbol);
    extern function string                          prepare_indx(input int chkp, modem, chain, stream, tone, segment, user, field, symbol);
endclass: c_model_std_queues

//----
function c_model_std_queues::new(string id = "c_model_std_queues");
    super.new(id);
endfunction

//----
task c_model_std_queues::push_back(input int chkp, modem, chain, stream, tone, segment, user, field, symbol, input bit mask, input checker_val_t val);
    string indx = prepare_indx(chkp, modem, chain, stream, tone, segment, user, field, symbol);
    super.push_back(indx, mask, val);
endtask

//----
function c_model_queues::checker_val_t c_model_std_queues::pop_front(input int chkp, modem, chain, stream, tone, segment, user, field, symbol);
    string indx = prepare_indx(chkp, modem, chain, stream, tone, segment, user, field, symbol);
    pop_front = super.pop_front(indx);
endfunction

//----
function int c_model_std_queues::size(input int chkp, modem, chain, stream, tone, segment, user, field, symbol);
    string indx = prepare_indx(chkp, modem, chain, stream, tone, segment, user, field, symbol);
    size = super.size(indx);
endfunction

//----
function string c_model_std_queues::prepare_indx(input int chkp, modem, chain, stream, tone, segment, user, field, symbol);
    prepare_indx = $sformatf(
        "%0d_%0d_%0d_%0d_%0d_%0d_%0d_%0d_%0d",
        chkp,
        modem,
        chain,
        stream,
        tone,
        segment,
        user,
        field,
        symbol
    );
endfunction
