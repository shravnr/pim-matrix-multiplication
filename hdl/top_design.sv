module top_design
import types::*;
(
    input         clk,
    input         rst,
    input logic [ADDRESS_LEN-1:0] src1_addr,
    input logic [ADDRESS_LEN-1:0] src2_addr,
    input logic [ADDRESS_LEN-1:0] dst_addr,
    input logic start
);

    logic [ADDRESS_LEN-1:0] addr;
    logic        read_en;
    logic        write_en;
    logic [BURST_ACCESS_WIDTH-1:0] wdata; 

    logic             dram_ready;
    logic dram_complete;
    logic [BURST_ACCESS_WIDTH-1:0] rdata; 
    logic             valid;

    

    top top_inst (
        .clk(clk),
        .rst(rst),
        .src1_addr(src1_addr),
        .src2_addr(src2_addr),
        .dst_addr(dst_addr),
        .start(start),


        .addr(addr),
        .read_en(read_en),
        .write_en(write_en),
        .wdata(wdata),
        .dram_ready(dram_ready),
        .dram_complete(dram_complete),
        .rdata(rdata),
        .valid(valid)

    );


    dram dram_inst (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .read_en(read_en),
        .write_en(write_en),
        .wdata(wdata),

        .dram_ready(dram_ready),
        .dram_complete(dram_complete),
        .rdata(rdata),
        .valid(valid)

    );

endmodule
