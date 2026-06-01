// =======================================================================================
// AXI4-Lite Protocol Verification Testbench (test2)
// THIS TEST WRITES EACH REGISTER THEIR OWN ADDRESS AND CHECKS WHETHER EACH REGISTER'S DATA IS
// SAME AS THE DATA WRITTEN BY THE MASTER AND PRINTS FINAL PASS OR FAIL
// =======================================================================================
module test2 #(parameter DATA_WIDTH = 32,
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
    $dumpfile("waveform2.vcd");
    $dumpvars(0,test2);
end

    // AXI Write Task (Pulse & Wait)
    task automatic axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            write_en <= 1; read_en <= 0;
            addr_in <= addr;
            wdata_in <= data;
            @(posedge clk);
            write_en <= 0; // Deassert immediately on next clock edge
            @(posedge clk); // Wait 1 cycle for master to reset done=0 before we check it
            while (!done) @(posedge clk); // Wait dynamically for transaction done
            // $display("[Time %0t][WRITE] addr = %h, data = %h, done = %b, resp = %b", $time, addr, data, done, resp_out);
        end
    endtask

    // AXI Read Task (Pulse & Wait)
    task automatic axi_read(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] expected_data);
        begin
            write_en <= 0; read_en <= 1;
            addr_in <= addr;
            @(posedge clk);
            read_en <= 0; // Deassert immediately on next clock edge
            @(posedge clk); // Wait 1 cycle for master to reset done=0 before we check it
            while (!done) @(posedge clk); // Wait dynamically for transaction done
            if (rdata_out == expected_data)begin
                $display("[PASS] Addr =%h data =%h", addr, rdata_out);
            end
            else 
                $display("[FAIL] Addr =%h expected =%h got =%h", addr, expected_data, rdata_out);
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

    $display("--- [Test 2] Sweep 1: Write Address to Each Register ---");
    axi_write(32'd0,   32'd0);
    axi_write(32'd4,   32'd4);
    axi_write(32'd8,   32'd8);
    axi_write(32'd12,  32'd12);
    axi_write(32'd16,  32'd16);
    axi_write(32'd20,  32'd20);
    axi_write(32'd24,  32'd24);
    axi_write(32'd28,  32'd28);
    axi_write(32'd32,  32'd32);
    axi_write(32'd36,  32'd36);
    axi_write(32'd40,  32'd40);
    axi_write(32'd44,  32'd44);
    axi_write(32'd48,  32'd48);
    axi_write(32'd52,  32'd52);
    axi_write(32'd56,  32'd56);
    axi_write(32'd60,  32'd60);
    axi_write(32'd64,  32'd64);
    axi_write(32'd68,  32'd68);
    axi_write(32'd72,  32'd72);
    axi_write(32'd76,  32'd76);
    axi_write(32'd80,  32'd80);
    axi_write(32'd84,  32'd84);
    axi_write(32'd88,  32'd88);
    axi_write(32'd92,  32'd92);
    axi_write(32'd96,  32'd96);
    axi_write(32'd100, 32'd100);
    axi_write(32'd104, 32'd104);
    axi_write(32'd108, 32'd108);
    axi_write(32'd112, 32'd112);
    axi_write(32'd116, 32'd116);
    axi_write(32'd120, 32'd120);
    axi_write(32'd124, 32'd124);

    $display("--- [Test 2] Sweep 1: Read back and Verify ---");
    axi_read(32'd0,   32'd0);
    axi_read(32'd4,   32'd4);
    axi_read(32'd8,   32'd8);
    axi_read(32'd12,  32'd12);
    axi_read(32'd16,  32'd16);
    axi_read(32'd20,  32'd20);
    axi_read(32'd24,  32'd24);
    axi_read(32'd28,  32'd28);
    axi_read(32'd32,  32'd32);
    axi_read(32'd36,  32'd36);
    axi_read(32'd40,  32'd40);
    axi_read(32'd44,  32'd44);
    axi_read(32'd48,  32'd48);
    axi_read(32'd52,  32'd52);
    axi_read(32'd56,  32'd56);
    axi_read(32'd60,  32'd60);
    axi_read(32'd64,  32'd64);
    axi_read(32'd68,  32'd68);
    axi_read(32'd72,  32'd72);
    axi_read(32'd76,  32'd76);
    axi_read(32'd80,  32'd80);
    axi_read(32'd84,  32'd84);
    axi_read(32'd88,  32'd88);
    axi_read(32'd92,  32'd92);
    axi_read(32'd96,  32'd96);
    axi_read(32'd100, 32'd100);
    axi_read(32'd104, 32'd104);
    axi_read(32'd108, 32'd108);
    axi_read(32'd112, 32'd112);
    axi_read(32'd116, 32'd116);
    axi_read(32'd120, 32'd120);
    axi_read(32'd124, 32'd124);

    $display("\n--- [Test 2] Sweep 2: Write Inverted Address (~Addr) to Each Register ---");
    axi_write(32'd0,   ~32'd0);
    axi_write(32'd4,   ~32'd4);
    axi_write(32'd8,   ~32'd8);
    axi_write(32'd12,  ~32'd12);
    axi_write(32'd16,  ~32'd16);
    axi_write(32'd20,  ~32'd20);
    axi_write(32'd24,  ~32'd24);
    axi_write(32'd28,  ~32'd28);
    axi_write(32'd32,  ~32'd32);
    axi_write(32'd36,  ~32'd36);
    axi_write(32'd40,  ~32'd40);
    axi_write(32'd44,  ~32'd44);
    axi_write(32'd48,  ~32'd48);
    axi_write(32'd52,  ~32'd52);
    axi_write(32'd56,  ~32'd56);
    axi_write(32'd60,  ~32'd60);
    axi_write(32'd64,  ~32'd64);
    axi_write(32'd68,  ~32'd68);
    axi_write(32'd72,  ~32'd72);
    axi_write(32'd76,  ~32'd76);
    axi_write(32'd80,  ~32'd80);
    axi_write(32'd84,  ~32'd84);
    axi_write(32'd88,  ~32'd88);
    axi_write(32'd92,  ~32'd92);
    axi_write(32'd96,  ~32'd96);
    axi_write(32'd100, ~32'd100);
    axi_write(32'd104, ~32'd104);
    axi_write(32'd108, ~32'd108);
    axi_write(32'd112, ~32'd112);
    axi_write(32'd116, ~32'd116);
    axi_write(32'd120, ~32'd120);
    axi_write(32'd124, ~32'd124);

    $display("--- [Test 2] Sweep 2: Read back and Verify ---");
    axi_read(32'd0,   ~32'd0);
    axi_read(32'd4,   ~32'd4);
    axi_read(32'd8,   ~32'd8);
    axi_read(32'd12,  ~32'd12);
    axi_read(32'd16,  ~32'd16);
    axi_read(32'd20,  ~32'd20);
    axi_read(32'd24,  ~32'd24);
    axi_read(32'd28,  ~32'd28);
    axi_read(32'd32,  ~32'd32);
    axi_read(32'd36,  ~32'd36);
    axi_read(32'd40,  ~32'd40);
    axi_read(32'd44,  ~32'd44);
    axi_read(32'd48,  ~32'd48);
    axi_read(32'd52,  ~32'd52);
    axi_read(32'd56,  ~32'd56);
    axi_read(32'd60,  ~32'd60);
    axi_read(32'd64,  ~32'd64);
    axi_read(32'd68,  ~32'd68);
    axi_read(32'd72,  ~32'd72);
    axi_read(32'd76,  ~32'd76);
    axi_read(32'd80,  ~32'd80);
    axi_read(32'd84,  ~32'd84);
    axi_read(32'd88,  ~32'd88);
    axi_read(32'd92,  ~32'd92);
    axi_read(32'd96,  ~32'd96);
    axi_read(32'd100, ~32'd100);
    axi_read(32'd104, ~32'd104);
    axi_read(32'd108, ~32'd108);
    axi_read(32'd112, ~32'd112);
    axi_read(32'd116, ~32'd116);
    axi_read(32'd120, ~32'd120);
    axi_read(32'd124, ~32'd124);

    #40;
    $finish();
end

endmodule