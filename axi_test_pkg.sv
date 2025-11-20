package axi_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    localparam ADDR_WIDTH = 8;
    localparam DATA_WIDTH = 32;

    typedef enum logic [2:0] {
        rst_op, 
        no_op, 
        w_op, 
        r_op,
        rw_op
    } op_code;           

    typedef struct {
        byte unsigned addr;
        byte unsigned data;
        op_code       op; 
    } command_s;
endpackage
