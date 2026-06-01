// =======================================================================================
// AXI4-Lite Protocol Verification Testbench (test3)
// THIS TEST VERIFIES THE BYTE-LANE SELECT STROBE (WSTRB) FUNCTIONALITY.
// BY WRITING DATA TO REGISTERS WITH DIFFERENT BYTE STROBES AND VERIFYING THE SAME.
// THIS TEST CHECKS THE ACTUAL DATA AND EXPECTED DATA AND PRINTS FINAL PASS OR FAIL.
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

    // Remaining Strobe Combinations (0000, 0110, 1001, 1111)
    axi_write(32'd48, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd48, 32'h12345678, 4'b0000); // 0000: Write completely ignored

    axi_write(32'd52, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd52, 32'h00112200, 4'b0110); // 0110: Overwrites Bytes 1 and 2

    axi_write(32'd56, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd56, 32'h33000044, 4'b1001); // 1001: Overwrites Bytes 0 and 3

    axi_write(32'd60, 32'hFFFFFFFF, 4'b1111);
    axi_write(32'd60, 32'h55667788, 4'b1111); // 1111: Overwrites all Bytes

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
    
    // Reads for the new strobe combinations
    axi_read(32'd48,  32'hFFFFFFFF); // Ignored write should leave FF intact
    axi_read(32'd52,  32'hFF1122FF); // Preserved Byte 0 and 3
    axi_read(32'd56,  32'h33FFFF44); // Preserved Byte 1 and 2
    axi_read(32'd60,  32'h55667788); // Overwritten fully

    // Strobe Test Case 2: Incremental Multi-Byte Writes
    $display("\n--- [Test 3 Extra] Incremental Multi-Byte Writes ---");
    axi_write(32'd64, 32'h00000000, 4'b1111); // Initialize to 00000000
    axi_write(32'd64, 32'h11111111, 4'b0001); // Write Byte 0
    axi_write(32'd64, 32'h22222222, 4'b0010); // Write Byte 1
    axi_write(32'd64, 32'h33333333, 4'b0100); // Write Byte 2
    axi_write(32'd64, 32'h44444444, 4'b1000); // Write Byte 3
    axi_read(32'd64,  32'h44332211); // Expect 44332211

    // Strobe Test Case 3: Alternate Byte Overwrite overlays
    $display("\n--- [Test 3 Extra] Alternate Byte Overwrite overlays ---");
    axi_write(32'd68, 32'hA5A5A5A5, 4'b1111); // Set to A5A5A5A5
    axi_write(32'd68, 32'h5A5A5A5A, 4'b1010); // Overwrite Bytes 1 and 3 -> 5AA55AA5
    axi_read(32'd68,  32'h5AA55AA5); // Expect 5AA55AA5
    axi_write(32'd68, 32'hF0F0F0F0, 4'b0101); // Overwrite Bytes 0 and 2 -> 5AF05AF0
    axi_read(32'd68,  32'h5AF05AF0); // Expect 5AF05AF0

    #40;
    $finish();
end

endmodule