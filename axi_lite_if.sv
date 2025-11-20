interface axi_lite_if #(parameter ADDR_WIDTH=8, DATA_WIDTH=32);
    import axi_test_pkg::*;
    logic                    clk;
    logic                    rst_n;
    logic                    AWVALID;
    logic                    AWREADY;
    logic [ADDR_WIDTH - 1:0] AWADDR;

    logic                    WVALID;
    logic                    WREADY;
    logic [DATA_WIDTH - 1:0] WDATA;
    logic [3:0]              WSTRB;

    logic                    BREADY;
    logic                    BVALID;

    logic                    ARVALID;
    logic                    ARREADY;
    logic [ADDR_WIDTH - 1:0] ARADDR;

    logic                    RVALID;
    logic                    RREADY;
    logic [DATA_WIDTH - 1:0] RDATA;
    op_code                  op;
    bit                      start;
    logic [ADDR_WIDTH - 1:0] addr_for_monitor;
    bit                      result_produced;
    command_monitor          command_monitor_h;
    result_monitor           result_monitor_h;

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
        start = 0;
        result_produced = 0;
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
        op     <= w_op;
        start  <= 1;
        
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

        @(posedge clk);
        while (!ARREADY)
            @(posedge clk);
        ARVALID <= 0;

        // Wait for read data valid
        @(posedge clk);
        while (!RVALID)
            @(posedge clk);
        RREADY <= 0;
        result_produced <= 1;
        op              <= r_op;
        start           <= 1;
    endtask
    
    task reset();
        rst_n = 0;
        #20
        rst_n = 1;
    endtask

    always @(posedge clk) begin : cmd_monitor
        if (start) begin
            if (op == w_op) command_monitor_h.write_to_monitor(AWADDR, WDATA, op);
            else if (op == r_op) command_monitor_h.write_to_monitor(ARADDR, RDATA, op);
            start = 0;
        end else begin
            command_monitor_h.write_to_monitor(AWADDR, WDATA, no_op);
        end
    end
    always @(negedge rst_n) begin
        if (command_monitor_h != null) begin
            command_monitor_h.write_to_monitor(AWADDR, WDATA, rst_op);
        end
    end
    always @(posedge clk) begin : rslt_monitor
        if (result_produced == 1) begin
            result_produced <= 0;
            result_monitor_h.write_to_monitor(ARADDR, RDATA, op);
        end
    end
endinterface //axi_lite_if
    