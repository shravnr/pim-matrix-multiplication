module pim_unit
import types::*;
#(
    parameter ID
) 
(
    input logic clk,
    input logic rst,

    // From PIM-C (partition)
    input logic valid,
    input logic [WIDTH-1:0] matrixA [CHUNK_SIZE-1:0][PIM_UNIT_CAPACITY-1:0],
    input logic [WIDTH-1:0] matrixB [PIM_UNIT_CAPACITY-1:0][CHUNK_SIZE-1:0],
    
    // To PIM-C (result aggregator)
    output logic [WIDTH-1:0] result [CHUNK_SIZE**2-1:0],
    output logic result_valid
);

    logic [WIDTH-1:0] result_2d [CHUNK_SIZE-1:0][CHUNK_SIZE-1:0];

    // Matrix multiplication logic
    always_comb begin
        for (int i = 0; i < CHUNK_SIZE; i++) begin
            for (int j = 0; j < CHUNK_SIZE; j++) begin
                result_2d[i][j] = 0;
                for (int k = 0; k < PIM_UNIT_CAPACITY; k++) begin
                    result_2d[i][j] += matrixA[i][k] * matrixB[k][j];
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            result_valid <= '0;
        end
        else if (valid) begin
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