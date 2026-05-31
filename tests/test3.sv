// =======================================================================================
// AXI4-Lite Protocol Loopback Verification Testbench (test1)

// =======================================================================================
module test3 #(parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
    )();
reg clk;
reg rst_n;
reg read_en;
reg write_en;
reg [ADDR_WIDTH-1:0] addr_in;
reg [DATA_WIDTH-1:0] wdata_in;
reg [(DATA_WIDTH/8)-1:0] wstrb_in;

wire [DATA_WIDTH-1:0] rdata_out;
wire [1:0] resp_out;
wire done;
wire error;
wire busy;

wire [ADDR_WIDTH-1:0] AWADDR;
wire [2:0] AWPROT;
wire AWVALID;
wire AWREADY;
wire WVALID;
wire [DATA_WIDTH-1:0] WDATA;
wire [(DATA_WIDTH/8)-1:0] WSTRB;
wire WREADY;
wire BREADY;
wire [1:0] BRESP;
wire BVALID;
wire [ADDR_WIDTH-1:0] ARADDR;
wire [2:0] ARPROT;
wire ARVALID;
wire ARREADY;
wire RREADY;
wire RVALID;
wire [DATA_WIDTH-1:0] RDATA;
wire [1:0] RRESP;

axi4_lite_master axi_master(
    .clk(clk),
    .rst_n(rst_n),
    .read_en(read_en),
    .write_en(write_en),
    .addr_in(addr_in),
    .wdata_in(wdata_in),
    .wstrb_in(wstrb_in),
    .rdata_out(rdata_out),
    .resp_out(resp_out),
    .done(done),
    .error(error),
    .busy(busy),
    .AWADDR(AWADDR),
    .AWPROT(AWPROT),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),
    .WVALID(WVALID),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WREADY(WREADY),
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),
    .ARADDR(ARADDR),
    .ARPROT(ARPROT),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),
    .RREADY(RREADY),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP)  
);

axi4_lite_slave  axi_slave(
    .clk(clk),
    .rst_n(rst_n),
    .AWADDR(AWADDR),
    .AWPROT(AWPROT),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),
    .WVALID(WVALID),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WREADY(WREADY),
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),
    .ARADDR(ARADDR),
    .ARPROT(ARPROT),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),
    .RREADY(RREADY),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP)  
);


always #5 clk = ~clk;

initial begin
    $dumpfile("waveform3.vcd");
    $dumpvars(0,test3);
end

    // AXI Write Task (Pulse & Wait)
    task automatic axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data, input [3:0] wstrb_test);
        begin
            write_en <= 1; read_en <= 0;
            addr_in <= addr;
            wdata_in <= data;
            wstrb_in <= wstrb_test;
            @(posedge clk);
            write_en <= 0; // Deassert immediately on next clock edge
            @(posedge clk); // Wait 1 cycle for master to reset done=0 before we check it
            while (!done) @(posedge clk); // Wait dynamically for transaction done
            // $display("[Time %0t][WRITE] addr = %h, data = %h, done = %b, resp = %b, wstrb = %b", $time, addr, data, done, resp_out, wstrb_test);
        end
    endtask

    // AXI Read Task (Pulse & Wait)
    task automatic axi_read(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data_check);
        begin
            write_en <= 0; read_en <= 1;
            addr_in <= addr;
            @(posedge clk);
            read_en <= 0; // Deassert immediately on next clock edge
            @(posedge clk); // Wait 1 cycle for master to reset done=0 before we check it
            while (!done) @(posedge clk); // Wait dynamically for transaction done
            if(data_check != rdata_out)begin
                $display("[Time %0t][ERROR] addr = %h, data = %h, check_data = %h", $time, addr, rdata_out, data_check);
            end else 
                $display("[Time %0t][PASS]  addr = %h, data = %h, check_data = %h", $time, addr, rdata_out, data_check);
            
        end
    endtask

initial begin
    clk   = 0;
    wstrb_in = 4'hF;  
    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    axi_write(32'd0, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd0, 32'h000000AA, 4'b0001);

    axi_write(32'd4, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd4, 32'h0000BB00, 4'b0010);

    axi_write(32'd8, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd8, 32'h00CC0000, 4'b0100);

    axi_write(32'd12, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd12, 32'hDD000000, 4'b1000);

    axi_write(32'd16, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd16, 32'h0000ABCD, 4'b0011);

    axi_write(32'd20, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd20, 32'h12340000, 4'b1100);

    axi_write(32'd24, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd24, 32'h11AA22BB, 4'b0101);

    axi_write(32'd28, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd28, 32'hAA11BB22, 4'b1010);

    axi_write(32'd32, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd32, 32'h00AABBCC, 4'b0111);

    axi_write(32'd36, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd36, 32'hAABBCC00, 4'b1110);

    axi_write(32'd40, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd40, 32'hAA00CCDD, 4'b1011);

    axi_write(32'd44, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd44, 32'h00BBCCDD, 4'b1101);

    axi_read(32'd0,  32'hFFFFFFAA);
    axi_read(32'd4,  32'hFFFFBBFF);
    axi_read(32'd8,  32'hFFCCFFFF);
    axi_read(32'd12, 32'hDDFFFFFF);
    axi_read(32'd16, 32'hFFFFABCD);
    axi_read(32'd20, 32'h1234FFFF);
    axi_read(32'd24, 32'hFFAAFFBB);
    axi_read(32'd28, 32'hAAFFBBFF);
    axi_read(32'd32,  32'hFFAABBCC); // Strobe 0111 preserves Byte 3 (FF)
    axi_read(32'd36,  32'hAABBCCFF); // Strobe 1110 preserves Byte 0 (FF)
    axi_read(32'd40,  32'hAAFFCCDD);
    axi_read(32'd44,  32'h00BBFFDD); // Strobe 1101 preserves Byte 1 (FF) and writes Byte 3 (00)
    #40;
    $finish();
end

endmodule