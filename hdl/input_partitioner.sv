// File: hdl/input_partitioner.sv
// Description: Partitions input matrices into smaller blocks for allocation to PIM units.
// Assumptions:
// - If matrix_size < 8, use 1 PIM unit; otherwise, partition into 4 blocks (2x2 grid).
// - Each PIM unit can process a maximum block of size 8x8.
// - The input matrices are square and their dimensions are given by matrix_size.
// - The module uses a simple start/ready handshake.

module input_partitioner #(
    parameter int DATA_WIDTH      = 32,
    parameter int NUM_PIM_UNITS   = 4,
    parameter int MAX_MATRIX_SIZE = 8
)(
    input  logic                     clk,
    input  logic                     rst,
    input  logic                     start,       // start partitioning signal
    input  logic [31:0]              matrix_size, // actual matrix dimension (<= MAX_MATRIX_SIZE)
    input  logic [DATA_WIDTH-1:0]    matrix_A [0:MAX_MATRIX_SIZE-1][0:MAX_MATRIX_SIZE-1],
    input  logic [DATA_WIDTH-1:0]    matrix_B [0:MAX_MATRIX_SIZE-1][0:MAX_MATRIX_SIZE-1],
    output logic                   partition_done,  // indicates partitioning complete
    output logic [NUM_PIM_UNITS-1:0] valid_out,       // valid flags for each output block
    // Each chunk is stored in a 2D array; size of each chunk is variable.
    // For simplicity, we declare the maximum chunk dimension here.
    output logic [DATA_WIDTH-1:0] chunk_A [0:NUM_PIM_UNITS-1][0:MAX_MATRIX_SIZE-1][0:MAX_MATRIX_SIZE-1],
    output logic [DATA_WIDTH-1:0] chunk_B [0:NUM_PIM_UNITS-1][0:MAX_MATRIX_SIZE-1][0:MAX_MATRIX_SIZE-1]
);

  // Local variables for dynamic allocation
  integer allocated_units;
  integer chunk_size; // effective dimension of each partitioned block
  integer unit, i, j, r, c;
  integer block_row, block_col;
  
  // A simple state machine: on 'start', perform partitioning in one clock cycle.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      partition_done <= 0;
      valid_out      <= '0;
    end
    else if (start) begin
      // Determine the number of PIM units to use and chunk size based on matrix_size.
      if (matrix_size < 8) begin
        allocated_units = 1;
        chunk_size      = matrix_size;
      end
      else begin
        allocated_units = NUM_PIM_UNITS;  // use all 4 PIM units for an 8x8 matrix
        // Partition the 8x8 matrix into 4 blocks arranged in a 2x2 grid.
        chunk_size = matrix_size / 2;
      end

      // Loop over the allocated PIM units and extract the corresponding sub-block
      for (unit = 0; unit < allocated_units; unit = unit + 1) begin
        // Calculate the row and column offset for this block
        // For a 2x2 grid: unit 0 -> (0,0), unit 1 -> (0,1), unit 2 -> (1,0), unit 3 -> (1,1)
        block_row = unit / 2;
        block_col = unit % 2;
        for (i = 0; i < chunk_size; i = i + 1) begin
          for (j = 0; j < chunk_size; j = j + 1) begin
            // Compute global indices based on block offset and local indices within the chunk.
            r = block_row * chunk_size + i;
            c = block_col * chunk_size + j;
            chunk_A[unit][i][j] <= matrix_A[r][c];
            chunk_B[unit][i][j] <= matrix_B[r][c];
          end
        end
        valid_out[unit] <= 1'b1;  // Mark this block as valid
      end

      // Mark remaining PIM unit outputs as invalid if they are not used
      for (unit = allocated_units; unit < NUM_PIM_UNITS; unit = unit + 1) begin
        valid_out[unit] <= 1'b0;
      end
      
      partition_done <= 1'b1;
    end
    else begin
      partition_done <= 1'b0;
    end
  end

endmodule
