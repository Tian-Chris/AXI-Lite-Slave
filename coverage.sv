class coverage extends uvm_subscriber #(axi_transaction);
   `uvm_component_utils(coverage)
   axi_transaction cmd;

   localparam int HISTORY_SIZE = 4;
   axi_transaction op_history[$];
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

      coverpoint addr_history[0] {ignore_bins all = default;}
      coverpoint addr_history[1] {ignore_bins all = default;}
      coverpoint addr_history[2] {ignore_bins all = default;}
      coverpoint addr_history[3] {ignore_bins all = default;}
      cross addr_history[0], addr_history[1], addr_history[2], addr_history[3] {
         bins one_sequential = {addr_history[0]+4 == addr_history[1]};
         bins two_sequential = {addr_history[0]+8 == addr_history[1]+4 == == addr_history[2]};
         bins three_sequential = {addr_history[0]+8 == addr_history[1]+4 == == addr_history[2]};
         bins non_sequential = default;
      }

      coverpoint op_history[0] {ignore_bins all = default;}
      coverpoint op_history[1] {ignore_bins all = default;}
      coverpoint op_history[2] {ignore_bins all = default;}
      coverpoint op_history[3] {ignore_bins all = default;}

      cross op_history[0], op_history[1], op_history[2], op_history[3] {
         bins 2_write = {w_op, w_op, default, default};
         bins 3_write = {w_op, w_op, w_op, default};
         bins 4_write = {w_op, w_op, w_op, w_op};

         bins 2_read = {r_op, r_op, default, default};
         bins 3_read = {r_op, r_op, r_op, default};
         bins 4_read = {r_op, r_op, r_op, r_op};
      }

      cross addr, data;
      
   endgroup

   function new (string name, uvm_component parent);
      super.new(name, parent);
      cg_axi_lite = new();
   endfunction

   function void write(axi_transaction t);
      cmd = t.do_copy;

      op_history.push_back(cmd.op);
      addr_history.push_back(cmd.addr);
      if(op_history.size() > HISTORY_SIZE) op_history.pop_front();
      if(addr_history.size() > HISTORY_SIZE) addr_history.pop_front();

      cg_axi_lite.sample();
   endfunction
endclass
