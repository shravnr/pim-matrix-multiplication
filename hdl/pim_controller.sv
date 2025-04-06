module pim_controller #(
  MAX_SIZE=8
)
{ 
  input logic clk,
  input logic rst,
  input logic [WIDTH-1:0] matrix_A[MAX_SIZE**2 -1],
  input logic [WIDTH-1:0] matrix_B[MAX_SIZE**2 -1],
  input logic [2:0] matrix_size,                       //1-8 need 3 bits
  //input logic [2:0] no_of_pims,                      //total number is 8

  output logic [WIDTH-1:0] result[MAX_SIZE**2 -1],
  output logic result_ready // to top

};

logic ready;
logic [WIDTH-1:0][(matrix_size/4)**2-1:0] chunk_a[3:0];
logic [WIDTH-1:0][(matrix_size/4)**2-1:0] chunk_b[3:0];
logic [WIDTH-1:0][(matrix_size/4)**2-1:0] result_from_pim_unit[3:0];
logic [3:0] result_done;


/*****Input Partition Logic******/

/********************************/

  pim_unit pim_unit_1 #(.ID(0))
  (
    .clk(clk),
    .rst(rst),
    .valid(1'b1),
    .matrixA(chunk_a[0]), 
    .matrixB(chunk_b[0]),
    .result(result_from_pim_unit[0]),
    .done(result_done[0])
  );

  pim_unit pim_unit_2 #(.ID(1))
  (
    .clk(clk),
    .rst(rst),
    .valid(1'b1),
    .matrixA(chunk_a[1]), 
    .matrixB(chunk_b[1]),
    .result(result_from_pim_unit[1]),
    .done(result_done[1])
  );

  pim_unit pim_unit_3 #(.ID(2))
  (
    .clk(clk),
    .rst(rst),
    .valid(1'b1),
    .matrixA(chunk_a[2]), 
    .matrixB(chunk_b[2]),
    .result(result_from_pim_unit[2]),
    .done(result_done[2])
  );

  pim_unit pim_unit_4 #(.ID(3))
  (
    .clk(clk),
    .rst(rst),
    .valid(1'b1),
    .matrixA(chunk_a[3]), 
    .matrixB(chunk_b[3]),
    .result(result_from_pim_unit[3]),
    .done(result_done[3])
  );


// for(i=0, i<4,i++) begin
//     pim_unit #(.ID(i))
//     (
//       .valid(1'b1),
//       .matrixA(chunk_a[i]), 
//       .matrixB(chunk_b[i]),
//       .result(result_from_pim_unit[i])
//     );
// end 

// RESULT AGGREGATOR
always_ff @(posedge clk) begin
  if (rst) begin
    // rest logic goes here
  end else begin
    if (&result_done) begin

    end
  end
end


endmodule