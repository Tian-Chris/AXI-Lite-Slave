import axi_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_transaction #(parameter DW = DATA_WIDTH, parameter AW = ADDR_WIDTH) extends uvm_sequence_item;
    `uvm_object_utils(axi_transaction);

    function new(string name = "");
        super.new(name);
    endfunction
    
    localparam ADDR_SIZE = $clog2(AW);
    rand logic [DW-1:0]         data;
    rand logic [ADDR_SIZE-1:0]  addr;
    rand op_code                op;
    
    constraint op_con {op dist {no_op := 1, w_op := 9, r_op:=9, rst_op:=1};}

    function void random_write();
        if (!this.randomize()) begin
            `uvm_error("RAND", "random_write() randomize failed")
        end
        op = w_op;
    endfunction
    
    function void random_read();
        if (!this.randomize()) begin
            `uvm_error("RAND", "random_read() randomize failed")
        end
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
        axi_transaction out = axi_transaction::type_id::create("out");
        out.data = data;
        out.addr = addr;
        out.op = op;
        return out;
    endfunction
    
    function string convert2string();
        string transaction;
        transaction = $sformatf("OP: %s || data: %8h  addr: %8h ", op.name(), data, addr);
        return transaction;
    endfunction
endclass