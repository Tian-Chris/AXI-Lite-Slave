interface axi_lite_if #(parameter ADDR_WIDTH=8, DATA_WIDTH=32);
    import axi_test_pkg::*;

    logic                  clk;
    logic                  rst_n;

    //AXI SIGNALS
    logic                  AWVALID;
    logic                  AWREADY;
    logic [ADDR_WIDTH-1:0] AWADDR;

    logic                  WVALID;
    logic                  WREADY;
    logic [DATA_WIDTH-1:0] WDATA;
    logic [3:0]            WSTRB;

    logic                  BREADY;
    logic                  BVALID;

    logic                  ARVALID;
    logic                  ARREADY;
    logic [ADDR_WIDTH-1:0] ARADDR;

    logic                  RVALID;
    logic                  RREADY;
    logic [DATA_WIDTH-1:0] RDATA;
    
    // UVM communication
    command_monitor        command_monitor_h;
    result_monitor         result_monitor_h;

    // For UVM checking only
    logic [DATA_WIDTH-1:0] dut_mem [ADDR_WIDTH-1:0];

    modport Master (
        input  AWREADY, WREADY, BVALID, ARREADY, RVALID, RDATA,
        output AWVALID, AWADDR,
        output WVALID, WDATA, WSTRB, 
        output BREADY, 
        output ARVALID, ARADDR,
        output RREADY
    );
    
    modport Slave (
        input  clk, rst_n,
        output AWREADY, WREADY, BVALID, ARREADY, RVALID, RDATA,
        input  AWVALID, AWADDR,
        input  WVALID, WDATA, WSTRB, 
        input  BREADY, 
        input  ARVALID, ARADDR,
        input  RREADY
    );

    initial begin
        clk = 0;
        rst_n = 0;
        forever begin
            #10;
            clk = ~clk;
        end
    end

    // -------------------------
    // AXI-Lite WRITE
    // -------------------------
    task axi_write(input [ADDR_WIDTH-1:0] addr,
                   input [DATA_WIDTH-1:0] data,
                   input [3:0]            strb = 4'hF);
        // Address
        AWADDR  <= addr;
        AWVALID <= 1;

        // Data
        WDATA   <= data;
        WSTRB   <= strb;
        WVALID  <= 1;

        // Response
        BREADY  <= 1;

        // Wait for AW and W handshake
        @(posedge clk);
        while (!AWREADY || !WREADY)
            @(posedge clk);

        AWVALID <= 0;
        WVALID  <= 0;

        // Wait for BVALID
        @(posedge clk);
        while (!BVALID)
            @(posedge clk);
        axi_if.BREADY <= 0;
    endtask

    // -------------------------
    // AXI-Lite READ
    // -------------------------
    task axi_read(input [ADDR_WIDTH-1:0] addr);
        // Send read address
        ARADDR  <= addr;
        ARVALID <= 1;
        RREADY  <= 1;
        while (!ARREADY)
            @(posedge clk);
        ARVALID <= 0;

        // Wait for read data valid
        @(posedge clk);
        while (!RVALID)
            @(posedge clk);
        RREADY <= 0;
    endtask
    
    task reset();
        rst_n = 0;
        #20
        rst_n = 1;
    endtask

    axi_transaction write_buffer[$];
    axi_transaction read_buffer[$];

    task do_op(axi_transaction cmd);
        command_monitor_h.write_to_monitor(cmd);

        case (cmd.op)
            w_op: begin
                write_buffer.push_back(cmd);
                axi_write(cmd.addr, cmd.data);
            end
            r_op: begin 
                read_buffer.push_back(cmd);
                axi_read(cmd.addr);
            end
            rst_op: reset();
        endcase
    endtask

    always @(posedge clk) begin : rslt_monitor
        if (RVALID == 1) begin
            if (read_buffer.size() == 0) begin
                `uvm_info("AXI_IF", "READ FAILED DUE TO MISSING BUFFER", UVM_LOW)
            end else begin
                axi_transaction tr = read_buffer.pop_front();
                tr.data = RDATA; 
                result_monitor_h.write_to_monitor(tr);
            end
        end

        if (BVALID == 1) begin
            if (write_buffer.size() == 0) begin
                `uvm_info("AXI_IF", "WRITE FAILED DUE TO MISSING BUFFER", UVM_LOW)
            end else begin
                axi_transaction tr = write_buffer.pop_front();
                tr.data = dut_mem[tr.addr]; 
                result_monitor_h.write_to_monitor(tr);
            end
        end
    end
endinterface