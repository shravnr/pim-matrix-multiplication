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

  logic ready;
  logic [WIDTH-1:0] chunk_a[3:0][CHUNK_SIZE**2-1:0];
  logic [WIDTH-1:0] chunk_b[3:0][CHUNK_SIZE**2-1:0];
  logic [WIDTH-1:0] pim_results[3:0][CHUNK_SIZE**2-1:0];
  logic [3:0] pim_unit_done;
  logic all_pims_done;


/*****Input Partition Logic******/
  always_comb begin
    // Initialize  chunks
    for (int a = 0; a < 4; a++) begin
      for (int b = 0; b < CHUNK_SIZE**2; b++) begin
        chunk_a[a][b] = '0;
        chunk_b[a][b] = '0;
      end
    end

    // Partition matrices into 1D 4x4 chunks
    for (int i = 0; i < MATRIX_SIZE; i++) begin
      for (int j = 0; j < MATRIX_SIZE; j++) begin
        automatic int chunk_id = (i/CHUNK_SIZE)*2 + (j/CHUNK_SIZE);
        automatic int chunk_i = i % CHUNK_SIZE;
        automatic int chunk_j = j % CHUNK_SIZE;
        if (chunk_id < 4) begin
            chunk_a[chunk_id][chunk_i*CHUNK_SIZE + chunk_j] = matrix_A[i*MATRIX_SIZE + j];
            chunk_b[chunk_id][chunk_i*CHUNK_SIZE + chunk_j] = matrix_B[i*MATRIX_SIZE + j];
        end
      end
    end
  end
/********************************/

  pim_unit #(.ID(0)) pim_unit_1 
  (
    .clk(clk),
    .rst(rst),
    .valid(start),
    .matrixA(chunk_a[0]), 
    .matrixB(chunk_b[0]),
    .result(pim_results[0]),
    .result_valid(pim_unit_done[0])
  );

  pim_unit #(.ID(1)) pim_unit_2
  (
    .clk(clk),
    .rst(rst),
    .valid(start),
    .matrixA(chunk_a[1]), 
    .matrixB(chunk_b[1]),
    .result(pim_results[1]),
    .result_valid(pim_unit_done[1])
  );

  pim_unit #(.ID(2)) pim_unit_3
  (
    .clk(clk),
    .rst(rst),
    .valid(start),
    .matrixA(chunk_a[2]), 
    .matrixB(chunk_b[2]),
    .result(pim_results[2]),
    .result_valid(pim_unit_done[2])
  );

  pim_unit #(.ID(3)) pim_unit_4
  (
    .clk(clk),
    .rst(rst),
    .valid(start),
    .matrixA(chunk_a[3]), 
    .matrixB(chunk_b[3]),
    .result(pim_results[3]),
    .result_valid(pim_unit_done[3])
  );




// RESULT AGGREGATOR
assign all_pims_done = &pim_unit_done;

always_ff @(posedge clk) begin
  if (rst) begin
    for (int i = 0; i < MATRIX_SIZE; i++) begin
      for (int j = 0; j < MATRIX_SIZE; j++) begin
        result[i][j] <= '0;
      end
    end
    result_ready <= 1'b0;
  end else if (all_pims_done) begin
      // Reconstruct full matrix from chunks
      for (int i = 0; i < MATRIX_SIZE; i++) begin
        for (int j = 0; j < MATRIX_SIZE; j++) begin
          automatic int chunk_id = (i/CHUNK_SIZE)*2 + (j/CHUNK_SIZE);
          automatic int chunk_i = i % CHUNK_SIZE;
          automatic int chunk_j = j % CHUNK_SIZE;
          
          if (chunk_id < 4) begin
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