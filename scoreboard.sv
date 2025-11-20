class scoreboard extends uvm_subscriber #(command_s);
    `uvm_component_utils(scoreboard);
    uvm_tlm_analysis_fifo #(command_s) cmd_f;
    logic [DATA_WIDTH-1:0] mem [63:0];

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction

    function void write(command_s t);
        command_s result;
        case (t.op)
            rst_op: foreach (mem[i]) mem[i] = '0;
            w_op: mem[t.addr] = t.data;
            r_op: begin 
                if (!cmd_f.try_get(result)) begin
                    $error("SCOREBOARD", "No result available in FIFO for read operation");
                    $fatal;
                end
                if(mem[result.addr] != result.data) begin
                    $error ("FAILED: addr: %2h  data: %2h  op: %s expected: %4h", result.addr, result.data, result.op.name(), mem[result.addr]);
                end
            end
        endcase
    endfunction 

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass