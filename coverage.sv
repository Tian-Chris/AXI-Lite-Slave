class coverage extends uvm_subscriber #(command_s);
   `uvm_component_utils(coverage)
   command_s cmd;

   covergroup cg_axi_lite;
      // addr bins: list explicit registers and grouped others
      coverpoint cmd.addr {
         bins reg0 = {32'h00};
         bins reg1 = {32'h04};
         bins reg2 = {32'h08};
         bins reserved = {[32'h0C:32'h0FFF]};
      }

      coverpoint cmd.data {
         bins all = {[32'h00:32'h0FFF]};
      }

      // operation type
      // coverpoint cmd.op {
      //    bins 
      // }

      // // write strobes (WSTRB) - include common partial combos
      // coverpoint wstrb {
      //    bins b0 = {4'b0001};
      //    bins b1 = {4'b0010};
      //    bins b2 = {4'b0100};
      //    bins b3 = {4'b1000};
      //    bins low_half = {4'b0011,4'b1100};
      //    bins all = {4'b1111};
      // }

      // // response codes
      // coverpoint resp {
      //    bins okay   = {2'b00};
      //    bins slverr = {2'b10};
      //    bins decerr = {2'b11};
      // }

      // // handshake delays measured in cycles
      // coverpoint awready_delay {
      //    bins zero = {0};
      //    bins short = {[1:3]};
      //    bins long  = {[4:31]};
      // }
      // coverpoint wready_delay = awready_delay;
      // coverpoint rvalid_delay {
      //    bins zero  = {0};
      //    bins short = {[1:3]};
      //    bins long  = {[4:31]};
      // }

      // cross coverage (most important)
      cross cmd.addr, cmd.data;         // every reg both read & written (if applicable)
      // cross addr, wstrb;            // partial write effects per register
      // cross is_write, resp;         // writes/reads with different responses
      // cross addr, awready_delay;    // registers w/ wait states
   endgroup

   function new (string name, uvm_component parent);
      super.new(name, parent);
      cg_axi_lite = new();
   endfunction

   function void write(command_s t);
      cmd.addr = t.addr;
      cmd.data = t.data;
      cg_axi_lite.sample();
   endfunction
endclass