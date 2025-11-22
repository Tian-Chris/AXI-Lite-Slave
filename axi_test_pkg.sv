package axi_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 32;

    typedef enum logic [2:0] {
        rst_op, 
        no_op, 
        w_op, 
        r_op,
        rw_op
    } op_code;           

    typedef struct {
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
        op_code          op; 
    } command_s;
endpackage
