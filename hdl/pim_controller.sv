import types::*;
module pim_controller 
(
  input logic clk,
  input logic rst,

  input logic [WIDTH-1:0] matrix_A[MATRIX_SIZE**2-1:0],
  input logic [WIDTH-1:0] matrix_B[MATRIX_SIZE**2-1:0],
  // input logic [2:0] matrix_size,                       //1-8 need 3 bits
  // input logic [2:0] no_of_pims,                      //total number is 8

  input logic start,

  output logic [WIDTH-1:0] result[MATRIX_SIZE**2-1:0],
  output logic result_ready // to top

  //NEED VALID HERE
);
  localparam int CHUNK_INDEX_DIVIDE = $sqrt(NUM_OF_PIM_UNITS);

  logic ready;
  logic [WIDTH-1:0] chunk_a[CHUNK_INDEX_DIVIDE-1:0][CHUNK_SIZE-1:0][MATRIX_SIZE-1:0]; // [1:0] = [NUM_OF_PIM_UNITS]/2 -1 : 0]
  logic [WIDTH-1:0] chunk_b[CHUNK_INDEX_DIVIDE-1:0][MATRIX_SIZE-1:0][CHUNK_SIZE-1:0];
  logic [WIDTH-1:0] pim_results[NUM_OF_PIM_UNITS-1:0][CHUNK_SIZE**2-1:0];
  logic [NUM_OF_PIM_UNITS-1:0] pim_unit_done;
  logic all_pims_done;

  logic [WIDTH-1:0] matrixA_2d [MATRIX_SIZE-1:0][MATRIX_SIZE-1:0];
  logic [WIDTH-1:0] matrixB_2d [MATRIX_SIZE-1:0][MATRIX_SIZE-1:0];
/*****Input Partition Logic******/
  always_comb begin
    // Initialize  chunks
    for (int a = 0; a < CHUNK_INDEX_DIVIDE; a++) begin
      for (int b = 0; b < CHUNK_SIZE; b++) begin
        for (int c = 0; c < MATRIX_SIZE; c++) begin
          chunk_a[a][b][c] = 0;
          chunk_b[a][c][b] = 0;
        end
      end
    end

    // Matrix A and Matrix B 1D -> 2D conversion
    for (int i = 0; i < MATRIX_SIZE; i++) begin
        for (int j = 0; j < MATRIX_SIZE; j++) begin
            automatic int idx = i * MATRIX_SIZE + j;
            matrixA_2d[i][j] = matrix_A[idx];
            matrixB_2d[i][j] = matrix_B[idx];
        end
    end

    // Partition matrices into 4 chunks
    for (int idx = 0; idx < CHUNK_INDEX_DIVIDE; idx++) begin
      for (int i = 0; i < CHUNK_SIZE; i++) begin
        for (int j = 0; j < MATRIX_SIZE; j++) begin
          chunk_a[idx][i][j] = matrixA_2d[i+CHUNK_SIZE*idx][j];
        end
      end
    end

    for (int idx = 0; idx < NUM_OF_PIM_UNITS/2; idx++) begin
      for (int i = 0; i < MATRIX_SIZE; i++) begin
        for (int j = 0; j < CHUNK_SIZE; j++) begin
          chunk_b[idx][i][j] = matrixB_2d[i][j+CHUNK_SIZE*idx];
        end
      end
    end


  end
/********************************/

  generate
    genvar i;
    for (i = 0; i < NUM_OF_PIM_UNITS; i++) begin : PIM_UNIT_GEN
        // Calculate row and column index (assuming 2x2 grid)
        localparam int row = i / CHUNK_INDEX_DIVIDE;
        localparam int col = i % CHUNK_INDEX_DIVIDE;

        pim_unit #(.ID(i)) pim_unit_inst (
            .clk(clk),
            .rst(rst),
            .valid(start),
            .matrixA(chunk_a[row]),   // chunk_a[0] or chunk_a[1]
            .matrixB(chunk_b[col]),   // chunk_b[0] or chunk_b[1]
            .result(pim_results[i]),
            .result_valid(pim_unit_done[i])
        );
    end
  endgenerate



// RESULT AGGREGATOR
assign all_pims_done = &pim_unit_done;

always_ff @(posedge clk) begin
  if (rst) begin
    for (int i = 0; i < MATRIX_SIZE**2; i++) begin
        result[i] <= 0;
    end
    result_ready <= 1'b0;
  end else if (all_pims_done) begin
      // Reconstruct full matrix from chunks
      for (int i = 0; i < MATRIX_SIZE; i++) begin
        for (int j = 0; j < MATRIX_SIZE; j++) begin
          automatic int chunk_id = (i/CHUNK_SIZE)*CHUNK_INDEX_DIVIDE + (j/CHUNK_SIZE);
          automatic int chunk_i = i % CHUNK_SIZE;
          automatic int chunk_j = j % CHUNK_SIZE;
          
          if (chunk_id < NUM_OF_PIM_UNITS) begin
            result[i*MATRIX_SIZE + j] <= pim_results[chunk_id][chunk_i*CHUNK_SIZE + chunk_j];
          end
        end
      end
      result_ready <= 1'b1;
  end
  else begin
    result_ready <= 1'b0;
  end
end


endmodule