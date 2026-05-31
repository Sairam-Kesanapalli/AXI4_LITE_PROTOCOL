module register_file #(
    parameter REG_DEPTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = $clog2(REG_DEPTH)  // HERE C IS CEILING (OPPOSITE TO STEP)
)(
    input clk,
    input rst_n, 

    input reg_write,
    input reg_read,
    input [ADDR_WIDTH-1:0] rd,              
    input [DATA_WIDTH-1:0] write_data,
    input [3:0] byte_en,

    output reg [DATA_WIDTH-1:0] read_data,
    output valid_address
);
        localparam REG_ADDR_WIDTH = $clog2(REG_DEPTH);
        wire [REG_ADDR_WIDTH-1:0] addr_index = rd[REG_ADDR_WIDTH+1:2];
        assign valid_address = (addr_index < REG_DEPTH);
        
        // REGISTER
        reg [DATA_WIDTH-1:0] regs [0:REG_DEPTH-1];

        // WRITE LOGIC
        always @(posedge clk) begin
            if(!rst_n) begin
                for(integer i =0; i<REG_DEPTH; i++)
                    regs[i] <= {DATA_WIDTH{1'b0}};
            end
            else begin
                if(reg_write && valid_address) begin
                    // $display("[Time %0t][RF WRITE] addr_index = %0d, data = %h, byte_en = %b", $time, addr_index, write_data, byte_en);
                    if (byte_en[0]) regs[addr_index][7:0]   <= write_data[7:0];
                    if (byte_en[1]) regs[addr_index][15:8]  <= write_data[15:8];
                    if (byte_en[2]) regs[addr_index][23:16] <= write_data[23:16];
                    if (byte_en[3]) regs[addr_index][31:24] <= write_data[31:24];
                end
            end
        end

        // COMBINATIONAL READ
        always @(*) begin
            if(reg_read && valid_address) begin
                read_data = regs[addr_index];
                // $display("[Time %0t][RF READ] addr_index = %0d, read_data = %h", $time, addr_index, read_data);
            end
            else
                read_data = {DATA_WIDTH{1'b0}};
        end


endmodule
