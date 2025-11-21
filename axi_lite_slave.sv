`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 06:34:59 PM
// Design Name: 
// Module Name: axi_lite_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "axi_lite_if.sv"

module axi_lite_slave #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    axi_lite_if.Slave slave_if,
    output reg [DATA_WIDTH-1:0] dut_mem [0:63]
);
    reg   [DATA_WIDTH-1:0] mem    [0:63];
    localparam ADDR_LSB = $clog2(DATA_WIDTH/8);

    logic                  axi_awready;
    logic                  axi_wready;
    logic                  axi_bvalid;
    logic [ADDR_WIDTH-1:0] axi_waddr;
    logic [DATA_WIDTH-1:0] axi_wdata;
    logic [3:0]            axi_wstrb;
    logic [ADDR_WIDTH-1:0] waddr_buffer;
    logic [DATA_WIDTH-1:0] wdata_buffer;
    logic [3:0]            wstrb_buffer;

    logic                  axi_arready;
    logic                  axi_rvalid;
    logic [ADDR_WIDTH-1:0] axi_araddr;
    logic [DATA_WIDTH-1:0] axi_rdata;
    logic [ADDR_WIDTH-1:0] raddr_buffer;

    logic        read_stalled;
    logic        write_addr_received;
    logic        write_data_received;
    logic        write_response_stalled;

    //FOR DEBUG
    logic                  clk_measured;
    logic                  rst_measured;
    
    assign clk_measured = slave_if.clk;
    assign rst_measured = slave_if.rst_n;
    assign slave_if.AWREADY = axi_awready;
    assign slave_if.WREADY = axi_wready;
    assign slave_if.BVALID = axi_bvalid;

    assign slave_if.ARREADY = axi_arready;
    assign slave_if.RVALID = axi_rvalid;
    assign slave_if.RDATA = axi_rdata;
    
    assign read_stalled = axi_rvalid && !slave_if.RREADY;
    assign write_addr_received = slave_if.AWVALID || !axi_awready;
    assign write_data_received = slave_if.WVALID  || !axi_wready;
    assign write_response_stalled = !slave_if.BREADY && axi_bvalid;

    always @(posedge slave_if.clk ) begin
        if (!slave_if.rst_n) begin
            axi_awready <= 1;
            axi_wready  <= 1;
            axi_bvalid  <= 0;
        end
        //if its stalled
        else if (write_response_stalled && slave_if.AWVALID) axi_awready <= 0;
        else if (!write_data_received && slave_if.AWVALID) axi_awready <= 0;
        else axi_awready <= 1;
        
        if (write_response_stalled && slave_if.WVALID) axi_wready <= 0;
        else if (!write_addr_received && slave_if.WVALID) axi_wready <= 0;
        else axi_wready <= 1;

        if (write_addr_received && write_data_received) axi_bvalid <= 1;
        else axi_bvalid <= 0;

        if (axi_awready) waddr_buffer <= slave_if.AWADDR;
        if (axi_wready) begin 
            wdata_buffer <= slave_if.WDATA;
            wstrb_buffer <= slave_if.WSTRB;
        end
    end

    always @(*) begin
        if (axi_awready) axi_waddr = slave_if.AWADDR;
        else axi_waddr = waddr_buffer;

        if (axi_wready) begin
            axi_wdata = slave_if.WDATA;
            axi_wstrb = slave_if.WSTRB;
        end else begin
            axi_wdata = wdata_buffer;
            axi_wstrb = wstrb_buffer;
        end
    end

    always @(posedge slave_if.clk) begin
        if(write_addr_received && write_data_received && slave_if.BREADY) begin
            automatic int word_index = axi_waddr[ADDR_WIDTH-1:ADDR_LSB];
            if (axi_wstrb[0]) mem[word_index][7:0]     <= axi_wdata[7:0];
            if (axi_wstrb[1]) mem[word_index][15:8]    <= axi_wdata[15:8];
            if (axi_wstrb[2]) mem[word_index][23:16]   <= axi_wdata[23:16];
            if (axi_wstrb[3]) mem[word_index][31:24]   <= axi_wdata[31:24];
        end
    end

    always @(posedge slave_if.clk) begin
        //On reset = 1
        //If RREADY = 1 arready = 1
        //If slave is empty arready = 1 rvalid = 0 => empty
        if (!slave_if.rst_n) axi_arready <= 1;
        else if (slave_if.RREADY || !axi_rvalid) axi_arready <= 1;
        else axi_arready <= 0;

        //On reset = 0
        //Valid is 1 when there is a request inside the slave which occurs when their is either incoming message or stored message
        //ARVALID is incoming while (axi_rvalid && !slave_if.RREADY) is stalled
        if(!slave_if.rst_n) axi_rvalid <= 0;
        else if(slave_if.ARVALID || read_stalled) axi_rvalid <= 1;
        else axi_rvalid <= 0;
        
        //Handshake
        if(slave_if.ARVALID && axi_arready) raddr_buffer <= slave_if.ARADDR;
        if(!read_stalled) begin
            automatic int word_index = axi_araddr[ADDR_WIDTH-1:ADDR_LSB];
            axi_rdata <= mem[word_index];
        end
    end

    always @(*) begin
        //Handshake
        if (slave_if.ARVALID && axi_arready) axi_araddr = slave_if.ARADDR; 
        else axi_araddr = raddr_buffer;
    end

    always @(*) begin
        //Data output for UVM
        dut_mem = mem;
    end
endmodule