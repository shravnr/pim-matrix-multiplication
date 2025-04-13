import types::*;
module pim_unit
#(
    parameter ID
) 
(
    input logic clk,
    input logic rst,

    // From partition
    input logic valid,      // Matrix chunk inputs are valid :  NEEDS TO COME FROM TOP
    input logic [WIDTH-1:0] matrixA [CHUNK_SIZE**2-1:0],      // 1D arraiy
    input logic [WIDTH-1:0] matrixB [CHUNK_SIZE**2-1:0],      
    
    // To result aggregator
    output logic [WIDTH-1:0] result [CHUNK_SIZE**2-1:0],      // 1D array
    output logic result_valid
);

    logic [WIDTH-1:0] matrixA_2d [CHUNK_SIZE-1:0][CHUNK_SIZE-1:0];
    logic [WIDTH-1:0] matrixB_2d [CHUNK_SIZE-1:0][CHUNK_SIZE-1:0];
    logic [WIDTH-1:0] result_2d [CHUNK_SIZE-1:0][CHUNK_SIZE-1:0];

    // 1D -> 2D conversion
    always_comb begin
        for (int i = 0; i < CHUNK_SIZE; i++) begin
            for (int j = 0; j < CHUNK_SIZE; j++) begin
                automatic int idx = i * CHUNK_SIZE + j;
                matrixA_2d[i][j] = matrixA[idx];
                matrixB_2d[i][j] = matrixB[idx];
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < CHUNK_SIZE; i++) begin
                for (int j = 0; j < CHUNK_SIZE; j++) begin
                    result_2d[i][j] <= '0;
                end
            end
            result_valid <= '0;
        end
        else if (valid) begin
            // Matrix multiplication logic
            for (int i = 0; i < CHUNK_SIZE; i++) begin
                for (int j = 0; j < CHUNK_SIZE; j++) begin
                    result_2d[i][j] <= '0;
                    for (int k = 0; k < CHUNK_SIZE; k++) begin
                        result_2d[i][j] <= result_2d[i][j] + (matrixA[i][k] * matrixB[k][j]);
                    end
                end
            end

            // 2D -> 1D conversion
            for (int i = 0; i < CHUNK_SIZE; i++) begin
                for (int j = 0; j < CHUNK_SIZE; j++) begin
                    automatic int idx = i * CHUNK_SIZE + j;
                    result[idx] <= result_2d[i][j];
                end
            end
            result_valid <= '1;
        end
        else begin
            result_valid <= '0;
        end
    end

endmodule