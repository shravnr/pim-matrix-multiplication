import types::*;
module result_aggregator
#(
    parameter ELEM_WIDTH = 32, // Each number 32 bits
    parameter PIM_MATRIX_SIZE = 8,
    parameter MAX_PIM_UNITS = 4
) 
(
    input logic clk,
    input logic rst,

    //From PIM
    input logic [ELEM_WIDTH-1:0] pim_results [MAX_PIM_UNITS][PIM_MATRIX_SIZE][PIM_MATRIX_SIZE];
    input logic [MAX_PIM_UNITS] pim_valid, // result_valid from all pims

    // From top
    input logic [15:0] matrix_size,
    input logic [3:0] pim_units_used,

    // To top
    output logic [ELEM_WIDTH-1:0] final_result [2*PIM_MATRIX_SIZE][2*PIM_MATRIX_SIZE], //Flatten
    output logic result_ready
);
    
    logic [ELEM_WIDTH-1:0] reconstructed [PIM_MATRIX_SIZE*2][PIM_MATRIX_SIZE*2];
    logic all_pims_done;

    // See if all PIM units we want to use have sent valid result
    assign all_pims_done = &pim_done[pim_units_used-1:0];

    always_ff @(posedge clk) begin
        if (rst) begin
            final_result <= 0;
            result_ready <= '0;
        end
        else if (pim_valid) begin
            // Put chunks together into full matrix
            for (int pim_id = 0; pim_id < MAX_PIM_UNITS; pim_id++) begin
                if (pim_id < pim_units_used) begin
                    // Offset of the tile
                    // PIM ID	Tile Position	Memory Region
                    //  0	    (0, 0)	        Rows 0:7, Cols 0:7
                    //  1	    (0, 8)	        Rows 0:7, Cols 8:15
                    //  2	    (8, 0)	        Rows 8:15, Cols 0:7
                    //  3	    (8, 8)	        Rows 8:15, Cols 8:15
                    int tile_row = (pim_id / (PIM_MATRIX_SIZE / PIM_MATRIX_SIZE)) * PIM_MATRIX_SIZE;
                    int tile_col = (pim_id % (PIM_MATRIX_SIZE / PIM_MATRIX_SIZE)) * PIM_MATRIX_SIZE;
                    
                    for (int i = 0; i < PIM_MATRIX_SIZE; i++) begin
                        for (int j = 0; j < PIM_MATRIX_SIZE; j++) begin
                            if (tile_row+i < PIM_MATRIX_SIZE && tile_col+j < PIM_MATRIX_SIZE) begin
                                reconstructed[tile_row+i][tile_col+j] = pim_results[pim_id][i][j];
                            end
                        end
                    end
                end
            end
            
            for (int i = 0; i < matrix_size; i++) begin
                for (int j = 0; j < matrix_size; j++) begin
                    final_result[i][j] <= reconstructed[i][j];
                end
            end
            
            result_ready <= '1;
        end
        else begin
            result_ready <= '0;
        end
    end

endmodule