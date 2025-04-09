module pim_unit
#(
    parameter ID,
    parameter ELEM_WIDTH = 32, // Each number 32 bits
    parameter PIM_MATRIX_SIZE = 8
) 
(
    input logic clk,
    input logic rst,

    // From partition
    input logic valid,      // Matrix chunk inputs are valid
    input logic [ELEM_WIDTH-1:0] matrixA [PIM_MATRIX_SIZE][PIM_MATRIX_SIZE],      // 8x8
    input logic [ELEM_WIDTH-1:0] matrixB [PIM_MATRIX_SIZE][PIM_MATRIX_SIZE],      // 8x8
    
    // To result aggregator
    output logic [ELEM_WIDTH-1:0] result [PIM_MATRIX_SIZE][PIM_MATRIX_SIZE],
    output logic result_valid
);

    logic [ELEM_WIDTH-1:0] result_calc [PIM_MATRIX_SIZE][PIM_MATRIX_SIZE];

    always_ff @(posedge clk) begin
        if (rst) begin
            result <= 0;
            result_valid <= '0;
        end
        else if (valid) begin
            // Matrix multiplication logic
            for (int i = 0; i < PIM_MATRIX_SIZE; i++) begin
                for (int j = 0; j < PIM_MATRIX_SIZE; j++) begin
                    result_calc[i][j] = 0;
                    for (int k = 0; k < PIM_MATRIX_SIZE; k++) begin
                        result_calc[i][j] += matrixA[i][k] * matrixB[k][j];
                    end
                end
            end
            result <= result_calc;
            result_valid <= '1;
        end
        else begin
            result_valid <= '0;
        end
    end

endmodule