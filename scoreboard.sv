class scoreboard extends uvm_subscriber #(axi_transaction);
    `uvm_component_utils(scoreboard);
    uvm_tlm_analysis_fifo #(axi_transaction) res;
    logic [DATA_WIDTH-1:0] mem [63:0];
    int total_count, success_count;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        res = new ("res", this);
        total_count = 0;
        success_count = 0;
    endfunction

    function void write(axi_transaction t);
        axi_transaction result;
        case (t.op)
            rst_op: foreach (mem[i]) mem[i] = '0;
            w_op: mem[t.addr] = t.data; 
        endcase
        if (res.try_get(result)) begin
            total_count += 1;
            if(mem[result.addr] != result.data) begin
                $error ("FAILED: addr: %2h  data: %2h  op: %s expected: %4h", result.addr, result.data, result.op.name(), mem[result.addr]);
            end
            else success_count += 1;
        end
    endfunction 

   function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("SCOREBOARD", $sformatf("Total ops: %0d, Success: %0d, Fail: %0d", 
                total_count, success_count, total_count - success_count), UVM_LOW)
    endfunction
endclass