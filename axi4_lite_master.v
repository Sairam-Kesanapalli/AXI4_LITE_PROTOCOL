module axi4_lite_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    //Clock and reset 
    input clk,
    input rst_n,

    //EXTERNAL SIGNALS
    input write_en,
    input read_en,
    input [ADDR_WIDTH-1:0] addr_in,
    input [DATA_WIDTH-1:0] wdata_in,
    input [(DATA_WIDTH/8)-1:0] wstrb_in,
    
    output reg [DATA_WIDTH-1:0] rdata_out,
    output reg [1:0] resp_out,
    output reg done,
    output reg error,
    output reg busy,
    
    //AXI4-Lite interface
    //WRITE ADDRESS CHANNELS
    output reg [ADDR_WIDTH-1:0] AWADDR,
    output reg [2:0] AWPROT,
    output reg AWVALID,
    input AWREADY,

    //WRITE DATA CHANNELS
    output reg WVALID,
    output reg [DATA_WIDTH-1:0] WDATA,
    output reg [(DATA_WIDTH/8)-1:0] WSTRB,
    input WREADY,

    //WRITE RESPONSE CHANNELS
    output reg BREADY,
    input [1:0] BRESP,
    input BVALID,
    
    //READ ADDRESS CHANNELS
    output reg [ADDR_WIDTH-1:0] ARADDR,
    output reg [2:0] ARPROT,
    output reg ARVALID,
    input ARREADY,

    //READ DATA CHANNELS
    output reg RREADY,
    input RVALID,
    input [DATA_WIDTH-1:0] RDATA,
    input [1:0] RRESP
);

//REGISTERS AND INTERAL SIGNALS
reg [ADDR_WIDTH-1:0] addr_reg;
reg [DATA_WIDTH-1:0] wdata_reg;
reg [(DATA_WIDTH/8)-1:0] wstrb_reg;
reg aw_accepted;
reg w_accepted;

//STATES
localparam IDLE    = 3'd0;
localparam AW_W    = 3'd1;
localparam WAIT_B  = 3'd2;
localparam AR      = 3'd3;
localparam WAIT_R  = 3'd4;

localparam OKAY	   = 2'd0;
localparam EXOKAY  = 2'd1;
localparam SLVERR  = 2'd2;
localparam DECERR  = 2'd3;

reg [2:0] current_state, next_state;

always @(posedge clk) begin
	if (!rst_n) begin
		done	      <= 0;
		busy 	      <= 0;
		error	      <= 0;
		rdata_out     <= 0;
		resp_out      <= 0;
		addr_reg      <= 0;
		wdata_reg     <= 0;
		wstrb_reg     <= 0;
		aw_accepted   <= 0;
		w_accepted    <= 0;
	end
	else begin
		busy <= (next_state != IDLE);
	        // Clear when a new transaction starts
		if(write_en || read_en) begin
			done 	      <= 0;
			error         <= 0;
			rdata_out     <= 0;
			resp_out      <= 0;
		end
		
		// Latch inputs at start of transaction
		if (current_state == IDLE) begin
			if (write_en || read_en) begin
				addr_reg  <= addr_in;
				wdata_reg <= wdata_in;
				wstrb_reg <= wstrb_in;
			end
		end

		// Track independent write handshakes
		if (current_state == IDLE) begin
			aw_accepted <= 0;
			w_accepted  <= 0;
		end else if (current_state == AW_W) begin
			if (AWVALID && AWREADY) aw_accepted <= 1;
			if (WVALID && WREADY)   w_accepted  <= 1;
		end

		// Set when response arrives
		if (current_state == WAIT_B && BVALID) begin
			if (BRESP == OKAY) done  <= 1;
			else 		   error <= 1;
		end
		if (current_state == WAIT_R && RVALID) begin
			rdata_out <= RDATA;
			resp_out  <= RRESP;
			if (RRESP == OKAY) done <= 1;
			else 		   error <= 1;
		end
	end
end

//STATE REGISTER UPDATE
always @(posedge clk) begin
	if (!rst_n) 
		current_state <= IDLE;
	else 
		current_state <= next_state;
end

//NEXT STATE LOGIC
always @(*) begin
	case(current_state)
		IDLE : begin
			if(write_en) 	  next_state = AW_W;
			else if (read_en) next_state = AR;
			else 		  next_state = IDLE;
		end
		AW_W : next_state = ((AWREADY || aw_accepted) && (WREADY || w_accepted)) ? WAIT_B : AW_W;
		WAIT_B : next_state = BVALID ? IDLE : WAIT_B;
		AR   :  next_state = ARREADY ? WAIT_R :  AR;
		WAIT_R : next_state = RVALID ? IDLE : WAIT_R ;
		default: next_state = IDLE;
	endcase
end

//OUTPUT CONTROL LOGIC
always @(*) begin
		AWADDR	= 0;
		AWPROT	= 0;	
		AWVALID = 0;
		WVALID  = 0;
		WDATA	= 0;
		WSTRB	= 0;
		BREADY	= 0;
		ARADDR	= 0;
		ARPROT	= 0;
		ARVALID	= 0;
		RREADY	= 0;
		
	case(current_state) 
		IDLE: ;
		AW_W: begin
			AWVALID = !aw_accepted;
			AWADDR	= addr_reg;
			WVALID  = !w_accepted;
			WDATA	= wdata_reg;
			WSTRB	= wstrb_reg;
			//AWPROT	= 0;	
		end
		WAIT_B: begin
			BREADY	= 1;	
		end
		AR  : begin
			ARVALID	= 1;
			ARADDR	= addr_reg;
		end
		WAIT_R : begin
			RREADY = 1;
		end
	endcase
end
endmodule
