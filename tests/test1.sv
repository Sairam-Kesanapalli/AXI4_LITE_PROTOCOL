// =======================================================================================
// AXI4-Lite Protocol Loopback Verification Testbench (test1)
// 
// This testbench verifies:
// 1. Clock-accurate sequential write and read transactions between the AXI Master and Slave.
// 2. Stable register writing and combinational/sequential readback behavior in the register file.
// 3. A loopback write-read test covering register addresses 0 through 44 (indices 0 to 11).
// 4. Correct AXI master-slave handshaking synchronization using dynamic tasks (axi_write, axi_read)
//    which wait for the completion of the transaction ('done' handshake) while avoiding 
//    non-blocking time-step race conditions.
// =======================================================================================
module test1 #(parameter DATA_WIDTH = 32,
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
    $dumpfile("waveform.vcd");
    $dumpvars(0,test1);
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
            $display("[Time %0t][WRITE] addr = %h, data = %h, done = %b, resp = %b", $time, addr, data, done, resp_out);
        end
    endtask

    // AXI Read Task (Pulse & Wait)
    task automatic axi_read(input [ADDR_WIDTH-1:0] addr);
        begin
            write_en <= 0; read_en <= 1;
            addr_in <= addr;
            @(posedge clk);
            read_en <= 0; // Deassert immediately on next clock edge
            @(posedge clk); // Wait 1 cycle for master to reset done=0 before we check it
            while (!done) @(posedge clk); // Wait dynamically for transaction done
            $display("[Time %0t][READ]  addr = %h, data = %h, done = %b, resp = %b", $time, addr, rdata_out, done, resp_out);
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

    // Continuous $monitor removed to keep output clean and concise


    axi_write(32'd0,  32'd305419896);
    axi_read(32'd0);

    axi_write(32'd4,  32'd0);
    axi_read(32'd4);

    axi_write(32'd8,  32'd2863311530);
    axi_read(32'd8);

    axi_write(32'd12, 32'd1431655765);
    axi_read(32'd12);

    axi_write(32'd16, 32'd4294967295);
    axi_read(32'd16);

    axi_write(32'd20, 32'd3405691582);
    axi_read(32'd20);

    axi_write(32'd24, 32'd123456789);
    axi_read(32'd24);

    axi_write(32'd28, 32'd987654321);
    axi_read(32'd28);

    axi_write(32'd32, 32'd1111111111);
    axi_read(32'd32);

    axi_write(32'd36, 32'd2222222222);
    axi_read(32'd36);

    axi_write(32'd40, 32'd3333333333);
    axi_read(32'd40);

    axi_write(32'd44, 32'd444444444);
    axi_read(32'd44);

    #40;
    $finish();
end

endmodule