// =======================================================================================
// AXI4-Lite Protocol Verification Testbench (test4)
// This test checks the AXI slave for illegal address ranges. 
// This is a self checking test which prints pass or fail after comparing.
// =======================================================================================
module test4 #(parameter DATA_WIDTH = 32,
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
    $dumpfile("waveform4.vcd");
    $dumpvars(0,test4);
end

    // AXI Write Task (Pulse & Wait)
    task automatic axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data, input expected_error, input [1:0] expected_resp_out);
        begin
            write_en <= 1; read_en <= 0;
            addr_in <= addr;
            wdata_in <= data;
            @(posedge clk);
            write_en <= 0; // Deassert immediately on next clock edge
            @(posedge clk); // Wait 1 cycle for master to reset done=0 before we check it
            while (!done) @(posedge clk); // Wait dynamically for transaction done
            if ((error !== expected_error) || (resp_out !== expected_resp_out)) 
                $display("[Time %0t][WRITE_FAIL] addr = %h, data = %h, done = %b, error = %b, resp = %b", $time, addr, data, done, error, resp_out);
            else 
                $display("[Time %0t][WRITE_PASS] addr = %h, data = %h, done = %b, error = %b, resp = %b", $time, addr, data, done, error, resp_out);

        end
    endtask

    // AXI Read Task (Pulse & Wait)
    task automatic axi_read(input [ADDR_WIDTH-1:0] addr, input expected_error, input [1:0] expected_resp_out);
        begin
            write_en <= 0; read_en <= 1;
            addr_in <= addr;
            @(posedge clk);
            read_en <= 0; // Deassert immediately on next clock edge
            @(posedge clk); // Wait 1 cycle for master to reset done=0 before we check it
            while (!done) @(posedge clk); // Wait dynamically for transaction done
            if ((error !== expected_error) || (resp_out !== expected_resp_out)) 
                $display("[Time %0t][READ_FAIL] addr = %h, data = %h, done = %b, error = %b, resp = %b", $time, addr, rdata_out, done, error, resp_out);
            else 
                $display("[Time %0t][READ_PASS] addr = %h, data = %h, done = %b, error = %b, resp = %b", $time, addr, rdata_out, done, error, resp_out);        
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

    
    // Test Case 1: Valid Upper Boundary Check (Address 124 / Index 31)
    $display("--- [Test 4] Valid Boundary Check ---");
    axi_write(32'd124, 32'hAAAA5555, 0, 2'b00); // Should Pass
    axi_read(32'd124, 0, 2'b00);               // Should Pass

    // Test Case 2: Out of Bounds Boundary Check (Address 128 / Index 32)
    $display("\n--- [Test 4] First Invalid Address Check ---");
    axi_write(32'd128, 32'd1111111111, 1, 2'b10); // Should Fail (SLVERR)
    axi_read(32'd128, 1, 2'b10);

    // Test Case 3: Other Arbitrary Out of Bounds Checks
    $display("\n--- [Test 4] Arbitrary Invalid Addresses ---");
    axi_write(32'd300, 32'd2222222222, 1, 2'b10);
    axi_read(32'd300, 1, 2'b10);

    axi_write(32'd240, 32'd3333333333, 1, 2'b10);
    axi_read(32'd240, 1, 2'b10);

    // Test Case 4: Extreme High Address Space Checks
    $display("\n--- [Test 4] Extreme High Addresses ---");
    axi_write(32'h7FFFFFFF, 32'hDEADBEEF, 1, 2'b10);
    axi_read(32'h7FFFFFFF, 1, 2'b10);

    axi_write(32'hFFFFFFFC, 32'hCAFECAFE, 1, 2'b10);
    axi_read(32'hFFFFFFFC, 1, 2'b10);

    // Test Case 5: Unaligned Address Alignment Masking Verification
    $display("\n--- [Test 4 Extra] Unaligned Address Alignment Masking ---");
    axi_write(32'd1, 32'hDEADBEEF, 1, 2'b10); // Should Fail (SLVERR) due to alignment violation
    axi_read(32'd0, 0, 2'b00);                // Should Pass (aligned 0)
    // Note: The previous write to address 1 failed, so address 0 should not contain DEADBEEF.
    axi_read(32'd2, 1, 2'b10);                // Should Fail (SLVERR) due to alignment violation

    axi_write(32'd127, 32'hCAFEF00D, 1, 2'b10); // Should Fail (SLVERR) due to alignment violation
    axi_read(32'd124, 0, 2'b00);                // Should Pass (aligned 124)

    // Test Case 6: Mixed Valid/Invalid Sequential Access Stream
    $display("\n--- [Test 4 Extra] Mixed Valid/Invalid Sequential Access Stream ---");
    axi_write(32'd4, 32'h11223344, 0, 2'b00);  // Valid (Register 1)
    axi_write(32'd128, 32'h55667788, 1, 2'b10); // Invalid (Out of bounds)
    axi_write(32'd8, 32'h99AABBCC, 0, 2'b00);  // Valid (Register 2)
    axi_write(32'd200, 32'hDDEEFF00, 1, 2'b10); // Invalid (Out of bounds)
    
    axi_read(32'd4, 0, 2'b00);
    if (rdata_out !== 32'h11223344) $display("[ERROR] Expected 32'h11223344, got %h", rdata_out);
    axi_read(32'd128, 1, 2'b10);
    axi_read(32'd8, 0, 2'b00);
    if (rdata_out !== 32'h99AABBCC) $display("[ERROR] Expected 32'h99AABBCC, got %h", rdata_out);
    axi_read(32'd200, 1, 2'b10);

    #40;
    $finish();
end

endmodule