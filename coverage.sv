import axi_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "transaction.sv"
    
class coverage extends uvm_subscriber #(axi_transaction);
   `uvm_component_utils(coverage)
   axi_transaction cmd;

   localparam int HISTORY_SIZE = 4;
   op_e op_history[$];
   int addr_history[$];

   covergroup cg_axi_lite @(posedge clk);
      coverpoint cmd.addr;
      coverpoint cmd.data;

      coverpoint cmd.op {
         bins rst   = {rst_op};
         bins write = {w_op};
         bins read  = {r_op};
         bins noop  = {no_op};
      }

      coverpoint addr_history[0] {ignore_bins all = addr_history[0];}
      coverpoint addr_history[1] {ignore_bins all = addr_history[1];}
      coverpoint addr_history[2] {ignore_bins all = addr_history[2];}
      coverpoint addr_history[3] {ignore_bins all = addr_history[3];}

      cross addr_history[0], addr_history[1], addr_history[2], addr_history[3] {
         bins one_sequential = {addr_history[0]+4 == addr_history[1]};
         bins two_sequential = {addr_history[0]+8 == addr_history[1]+4 == addr_history[2]};
         bins three_sequential = {addr_history[0]+8 == addr_history[1]+4 == addr_history[2]};
      }

      coverpoint op_history[0] {ignore_bins all = op_history[0];}
      coverpoint op_history[1] {ignore_bins all = op_history[1];}
      coverpoint op_history[2] {ignore_bins all = op_history[2];}
      coverpoint op_history[3] {ignore_bins all = op_history[3];}

      // Cross op_history sequences
      cross op_history[0], op_history[1], op_history[2], op_history[3] {
         bins two_write = {w_op, w_op};
         bins three_write = {w_op, w_op, w_op};
         bins four_write = {w_op, w_op, w_op, w_op};

         bins two_read  = {r_op, r_op};
         bins three_read  = {r_op, r_op, r_op};
         bins four_read  = {r_op, r_op, r_op, r_op};
      }

      cross cmd.addr, cmd.data;

   endgroup

   function new (string name, uvm_component parent);
      super.new(name, parent);
      cg_axi_lite = new();
   endfunction

   function void write(axi_transaction t);
      cmd = t.do_copy();

      op_history.push_back(cmd.op);
      addr_history.push_back(cmd.addr);
      if(op_history.size() > HISTORY_SIZE) op_history.pop_front();
      if(addr_history.size() > HISTORY_SIZE) addr_history.pop_front();

      cg_axi_lite.sample();
   endfunction
endclass