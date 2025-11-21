import uvm_pkg::*;
`include "uvm_macros.svh"
class axi_transaction extends uvm_sequence_item;
    `uvm_object_utils(axi_transaction);

    function new(string name = "");
        super.new(name);
    endfunction
    
    rand logic [DATA_WIDTH-1:0]    data;
    rand logic [ADDR_WIDTH-1:0]    addr;
    rand op_code             op;
    
    constraint op_con {op dist {no_op := 1, w_op := 9, r_op:=9, rst_op:=1};}

    function void random_write();
        randomize();
        op = w_op;
    endfunction

    function void random_read();
        randomize();
        op = r_op;
    endfunction

    function void set_read();
        op = r_op;
    endfunction

    function void do_copy(uvm_object rhs);
        axi_transaction RHS;
        assert(rhs != null) else
            $fatal(1,"Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(RHS,rhs)) else
            $fatal(1,"Faied cast in do_copy");
        data = RHS.data;
        addr = RHS.addr;
        op = RHS.op;
    endfunction

    function axi_transaction get_copy();
        axi_transaction out;
        out.data = this.data;
        out.addr = this.addr;
        out.op = this.op;
        return out;
    endfunction
    
    function string convert2string();
        string transaction;
        transaction = $sformatf("OP: %s = %4h || data: %8h  addr: %8h ", op.name(), data, addr);
        return transaction;
    endfunction
endclass