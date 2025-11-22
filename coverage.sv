class coverage extends uvm_subscriber #(axi_transaction);
   `uvm_component_utils(coverage)
   axi_transaction cmd;

   localparam int HISTORY_SIZE = 4;
   op_code [HISTORY_SIZE-1:0] op_history;
   int prev_addr;
   int consecutive_count;
   
   covergroup cg_axi_lite;
      coverpoint cmd.addr;
      coverpoint cmd.data;

      coverpoint cmd.op {
         bins rst   = {rst_op};
         bins write = {w_op};
         bins read  = {r_op};
         bins noop  = {no_op};
      }
      
      coverpoint consecutive_count {
        bins consecutive_bins[] = {1,2,3,4,5};
      }
      
      //Erroring not sure how to fix
      //coverpoint op_history;
    
      cross cmd.addr, cmd.data;

   endgroup

   function new (string name, uvm_component parent);
      super.new(name, parent);
      cg_axi_lite = new();
   endfunction

   function void write(axi_transaction t);
      cmd = t.get_copy();

      for (int i=0; i<3; i++) begin
          op_history[i] = op_history[i+1];
      end
      op_history[0] = cmd.op;
      
      if(prev_addr == cmd.addr) begin
        consecutive_count += 1;
      end else begin
        consecutive_count = 0;
      end
      prev_addr = cmd.addr;
      
      cg_axi_lite.sample();
   endfunction
endclass