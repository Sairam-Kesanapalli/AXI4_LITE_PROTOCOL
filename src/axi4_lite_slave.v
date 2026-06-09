/* verilator lint_off MULTITOP */
module axi4_lite_slave#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter REG_DEPTH = 32,
    parameter WSTRB_WIDTH = (DATA_WIDTH/8)
)(
    //Clock and reset 
    input clk,
    input rst_n,

    //AXI4-Lite interface
    //WRITE ADDRESS CHANNELS
    input [ADDR_WIDTH-1:0] AWADDR,
    /* verilator lint_off UNUSEDSIGNAL */
    input [2:0] AWPROT,
    /* verilator lint_on UNUSEDSIGNAL */
    input AWVALID,
    output reg AWREADY,

    //WRITE DATA CHANNELS
    input WVALID,
    input [DATA_WIDTH-1:0] WDATA,
    input [WSTRB_WIDTH-1:0] WSTRB,
    output reg WREADY,

    //WRITE RESPONSE CHANNELS
    output reg [1:0] BRESP,
    output reg BVALID,
    input BREADY,
    
    //READ ADDRESS CHANNELS
    input [ADDR_WIDTH-1:0] ARADDR,
    /* verilator lint_off UNUSEDSIGNAL */
    input [2:0] ARPROT,
    /* verilator lint_on UNUSEDSIGNAL */
    input ARVALID,
    output reg ARREADY,

    //READ DATA CHANNELS
    output reg RVALID,
    output reg [DATA_WIDTH-1:0] RDATA,
    output reg [1:0] RRESP,
    input RREADY
);    

localparam IDLE         = 3'd0;
localparam WAIT_DATA    = 3'd1;
localparam WRITE_REG	= 3'd2;
localparam SEND_RESP	= 3'd3;
localparam FETCH_DATA	= 3'd4;
localparam SEND_DATA    = 3'd5;

localparam OKAY	   = 2'd0;
// localparam EXOKAY  = 2'd1;
localparam SLVERR  = 2'd2;
// localparam DECERR  = 2'd3;

reg [2:0] current_state, next_state;
reg [ADDR_WIDTH-1:0] raddr_reg, waddr_reg;
reg [DATA_WIDTH-1:0] write_data_reg, read_data_reg;
reg AW_CAPTURED, W_CAPTURED;
wire valid_address = (current_state == FETCH_DATA || current_state == SEND_DATA) ? 
                     (raddr_reg < (REG_DEPTH * 4)) : (waddr_reg < (REG_DEPTH * 4));

reg reg_write;
reg reg_read;
reg [ADDR_WIDTH-1:0] rd;
reg [WSTRB_WIDTH-1:0] WSTRB_reg;
wire [DATA_WIDTH-1:0] read_data;

//STATE UPDATE REGISTER
always @(posedge clk) begin
	if (!rst_n) current_state <= IDLE;
	else 	    current_state <= next_state;
end

//NEXT STATE LOGIC
always @(*) begin
	case (current_state)
		IDLE : begin
			if (AW_CAPTURED && W_CAPTURED)  next_state = WRITE_REG;
			else if (AW_CAPTURED)       next_state = WAIT_DATA;
			else if (ARVALID) 	next_state = FETCH_DATA;
			else 	          	next_state = IDLE;
		end
		WAIT_DATA : begin
			next_state = WVALID ? WRITE_REG : WAIT_DATA;
		end
		WRITE_REG : begin
			next_state = SEND_RESP;
		end
		SEND_RESP : next_state = (BVALID && BREADY)? IDLE : SEND_RESP;
        FETCH_DATA: next_state = SEND_DATA;
        SEND_DATA : next_state = (RVALID && RREADY) ? IDLE : SEND_DATA;
		default: next_state = IDLE;
	endcase
end

always @(posedge clk) begin
	if (!rst_n) begin
        AW_CAPTURED    <= 0;
        W_CAPTURED     <= 0;
        WSTRB_reg      <= 0;
        read_data_reg  <= 0;
        write_data_reg <= 0;
        raddr_reg      <= 0;
        waddr_reg      <= 0;
	end else begin
        // $display("[Time %0t][SLAVE posedge] state=%0d, WVALID=%b, WREADY=%b, WDATA=%h, write_data_reg=%h, WSTRB=%b, WSTRB_reg=%b", $time, current_state, WVALID, WREADY, WDATA, write_data_reg, WSTRB, WSTRB_reg);
		if (current_state == IDLE) begin
            if(AWVALID && AWREADY) begin
                AW_CAPTURED <= 1;
                waddr_reg   <= AWADDR;
            end
            if(WVALID && WREADY) begin
                W_CAPTURED  <= 1;
                write_data_reg <= WDATA;
                WSTRB_reg      <= WSTRB;
            end
            if(ARVALID && ARREADY) begin
                raddr_reg   <= ARADDR;
            end
        end
        else if (current_state == WAIT_DATA) begin
            if(WVALID && WREADY) begin
                W_CAPTURED  <= 1;
                write_data_reg <= WDATA;
                WSTRB_reg      <= WSTRB;
            end
        end
        else if (current_state == SEND_RESP && BVALID && BREADY) begin
            AW_CAPTURED <= 0;
            W_CAPTURED  <= 0;
            WSTRB_reg   <= 0;
        end
        else if (current_state == FETCH_DATA) begin
            read_data_reg <= read_data;
        end
	end	
end

//OUTPUT lOGIC
//DONT WRITE ADDRESS REG OR WRITE DATA REG TO 0
always @(*) begin
    AWREADY = 0;
    WREADY  = 0;
    ARREADY = 0;
	BRESP   = 2'b00;
	BVALID  = 0;
	RVALID  = 0;
	RDATA   = 0;
	RRESP   = 2'b00;
	reg_write = 0;
	reg_read  = 0;
	rd        = 0;
	
	case(current_state) 
		IDLE : begin
            AWREADY = rst_n ? 1 : 0;
            WREADY  = rst_n ? 1 : 0;
            ARREADY = rst_n ? 1 : 0;
        end //AWREADY = 1;WREADY  = 1;ARREADY = 1;
		WAIT_DATA : begin
            AWREADY = 0;
            WREADY  = rst_n ? 1 : 0;
            ARREADY = 0;
        end //AWREADY = 0;ARREADY = 0;WREADY  = 1;
		WRITE_REG : begin
            WREADY  = 0;
			reg_write = 1;
			rd 	  = waddr_reg;
		end 
		SEND_RESP : begin
			BVALID  = 1;
			BRESP   = valid_address ? OKAY : SLVERR ; 
			rd      = waddr_reg;
		end
        FETCH_DATA: begin
            reg_read = 1;
            rd       = raddr_reg;
        end
        SEND_DATA : begin
            RVALID  = 1;
            RRESP   = valid_address ? OKAY : SLVERR ; 
            RDATA   = valid_address ? read_data_reg : 0; 
            rd      = raddr_reg;
        end
		default: ;
    endcase
end

register_file #(
    .REG_DEPTH(REG_DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) rf (
    .clk(clk),
    .rst_n(rst_n), 

    .reg_write(reg_write),
    .reg_read(reg_read),
    .rd(rd),              
    .write_data(write_data_reg),
    .byte_en(WSTRB_reg),

    .read_data(read_data),
    /* verilator lint_off PINCONNECTEMPTY */
    .valid_address()
    /* verilator lint_on PINCONNECTEMPTY */
);
endmodule
