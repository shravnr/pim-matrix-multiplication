module pim_controller 
import types::*;
(
  input logic clk,
  input logic rst,

  input logic [WIDTH-1:0] matrix_A[MATRIX_SIZE**2-1:0],
  input logic [WIDTH-1:0] matrix_B[MATRIX_SIZE**2-1:0],


  input logic start,

  output logic [WIDTH-1:0] result[MATRIX_SIZE**2-1:0],
  output logic result_ready // to top

);
  localparam int CHUNK_INDEX_DIVIDE = $sqrt(NUM_OF_PIM_UNITS);

  logic ready;
  logic [WIDTH-1:0] chunk_a[CHUNK_INDEX_DIVIDE-1:0][CHUNK_SIZE-1:0][MATRIX_SIZE-1:0]; // [1:0] = [NUM_OF_PIM_UNITS]/2 -1 : 0]
  logic [WIDTH-1:0] chunk_b[CHUNK_INDEX_DIVIDE-1:0][MATRIX_SIZE-1:0][CHUNK_SIZE-1:0];


  //_new => PIM_UNIT_CAPACITY
  logic [WIDTH-1:0] chunk_a_new[CHUNK_INDEX_DIVIDE-1:0][NUM_PIM_UNIT_CHUNKS-1:0][CHUNK_SIZE-1:0][PIM_UNIT_CAPACITY-1:0];
  logic [WIDTH-1:0] chunk_b_new[CHUNK_INDEX_DIVIDE-1:0][NUM_PIM_UNIT_CHUNKS-1:0][PIM_UNIT_CAPACITY-1:0][CHUNK_SIZE-1:0];
  

  logic [WIDTH-1:0] pim_results[NUM_OF_PIM_UNITS-1:0][CHUNK_SIZE**2-1:0];
  logic [WIDTH-1:0] pim_results_new[NUM_OF_PIM_UNITS-1:0][NUM_PIM_UNIT_CHUNKS-1:0][CHUNK_SIZE**2-1:0];

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


  always_comb begin
    // Initialize  chunks
    
    for (int a = 0; a < CHUNK_INDEX_DIVIDE; a++) begin
      for (int x = 0; x < NUM_PIM_UNIT_CHUNKS; x++) begin
        for (int b = 0; b < CHUNK_SIZE; b++) begin
          for (int c = 0; c < PIM_UNIT_CAPACITY; c++) begin
            chunk_a_new[a][x][b][c] = 0;
            chunk_b_new[a][x][c][b] = 0;
          end
        end
      end
    end


    //chunk_a to chunk_a_new
    
    for (int idx = 0; idx < CHUNK_INDEX_DIVIDE; idx++) begin
      for (int x = 0; x < NUM_PIM_UNIT_CHUNKS; x++) begin
        for (int i = 0; i < CHUNK_SIZE; i++) begin
          for (int j = 0; j < PIM_UNIT_CAPACITY; j++) begin
            chunk_a_new[idx][x][i][j] = chunk_a[idx][i][j+PIM_UNIT_CAPACITY*x];
          end
        end
      end
    end

    for (int idx = 0; idx < CHUNK_INDEX_DIVIDE; idx++) begin
      for (int x = 0; x < NUM_PIM_UNIT_CHUNKS; x++) begin
        for (int i = 0; i < PIM_UNIT_CAPACITY; i++) begin
          for (int j = 0; j < CHUNK_SIZE; j++) begin
            chunk_b_new[idx][x][i][j] = chunk_b[idx][i+PIM_UNIT_CAPACITY*x][j];
          end
        end
      end
    end
  end

  ///Chunking done/////////////////////////////////////////////////////////////////////////////////

  // Chunk control signals
  logic all_chunks_sent;
  //logic [NUM_OF_PIM_UNITS-1:0] pim_unit_done_last_0;

  typedef enum logic [1:0] {
      IDLE,
      SEND_CHUNK,
      WAIT_PIM_UNIT,
      DONE
  } state_t;

  typedef struct packed {
      state_t current_state, next_state;
      logic [$clog2(NUM_PIM_UNIT_CHUNKS)-1:0] current_chunk;
      logic chunk_sent;
      logic busy;
      logic pim_fully_done;
      logic all_zeros;
  } pim_unit_struct;

  pim_unit_struct [NUM_OF_PIM_UNITS-1:0] pim_states;
  logic [WIDTH-1:0] pim_result_intermediate[NUM_OF_PIM_UNITS-1:0][CHUNK_SIZE**2-1:0];

  generate
    genvar i;
    for (i = 0; i < NUM_OF_PIM_UNITS; i++) begin : PIM_UNIT_GEN

    //Call PIM unit
      localparam int row = i / CHUNK_INDEX_DIVIDE;
      localparam int col = i % CHUNK_INDEX_DIVIDE;

      pim_unit #(.ID(i)) pim_unit_inst (
          .clk(clk),
          .rst(rst),
          .valid(pim_states[i].chunk_sent), // Should be chunk_sent : trigger when a sub chunk is being sent
          .matrixA(chunk_a_new[row][pim_states[i].current_chunk]),   // chunk_a[0] or chunk_a[1] //chunk_a_new[row][something]   something goes from 0 to NUM_PIM_UNIT_CHUNKS-1
          .matrixB(chunk_b_new[col][pim_states[i].current_chunk]),   // chunk_b[0] or chunk_b[1]  //chunk_a_new[column][something]
          .result(pim_result_intermediate[i]),  // get result for each pim unit, each sub chunk, store and add into a register => send this to result aggr
          .result_valid(pim_unit_done[i]) //done for each pim unit, each sub chunk
      );

      // Assign intermediate to the original multi-dimensional array
      always_comb begin
        for (int idx = 0; idx < CHUNK_SIZE**2; idx++) begin
          if(pim_states[i].all_zeros==0)
            pim_results_new[i][pim_states[i].current_chunk][idx] = pim_result_intermediate[i][idx];
          else
            pim_results_new[i][pim_states[i].current_chunk][idx] = {(CHUNK_SIZE * PIM_UNIT_CAPACITY){1'b0}}; //setting 0 to result

        end
      end

      
      //continuously adding the sub chunks together to get pim_result[i] final value
      always_ff @(posedge clk) begin
        if (rst) begin
          for(int k=0;k<CHUNK_SIZE**2;k++)
            pim_results[i][k] <= 0;
        end 
        else if (pim_unit_done[i]) begin
          for(int k=0;k<CHUNK_SIZE**2;k++)
            pim_results[i][k] <= pim_results[i][k] + pim_results_new[i][pim_states[i].current_chunk][k];
        end
      end

      
    
      always_comb begin
        pim_states[i].next_state = pim_states[i].current_state;
        case(pim_states[i].current_state) 
            IDLE:               if(start) pim_states[i].next_state = SEND_CHUNK;
            SEND_CHUNK:  begin     
              pim_states[i].all_zeros =1'b1;
              for(int j=0; j<CHUNK_SIZE ;j++) 
                for(int k=0; k<PIM_UNIT_CAPACITY; k++) 
                  pim_states[i].all_zeros = pim_states[i].all_zeros &  ((chunk_a_new[row][pim_states[i].current_chunk][j][k]==0) || (chunk_b_new[col][pim_states[i].current_chunk][k][j]==0));

              //pim_unit_done_last_0[i]= 1'b0;
              if(pim_states[i].all_zeros) 
                pim_states[i].next_state = SEND_CHUNK; //already know result is 0, so we don't need PIM WAIT.
                /*
                if (pim_states[i].current_chunk == NUM_PIM_UNIT_CHUNKS - 1) begin
                  //LOGIC HERE TO GO TO DONE
                  pim_states[i].next_state = DONE;
                  //pim_unit_done_last_0[i]= 1'b1;
                end 
                */
              else             
                pim_states[i].next_state = WAIT_PIM_UNIT;

              if (pim_states[i].current_chunk == NUM_PIM_UNIT_CHUNKS - 1) begin
                //ADD LOGIC HERE TO GO TO DONE
              end

            end

            WAIT_PIM_UNIT:    begin
                if (pim_states[i].current_chunk == NUM_PIM_UNIT_CHUNKS - 1) begin
                  if (pim_unit_done[i]) begin
                    pim_states[i].next_state = DONE;
                  end else begin
                    pim_states[i].next_state = WAIT_PIM_UNIT; 
                  end
                end
                  
                else begin
                  if (pim_unit_done[i])
                    pim_states[i].next_state = SEND_CHUNK;
                  else
                    pim_states[i].next_state = WAIT_PIM_UNIT;
                end
            end       
            DONE:    pim_states[i].next_state = IDLE;
        endcase
      end

      always_ff @(posedge clk) begin
        //Full FSM
              //add individual chunk results =>  for result aggregator
              //generate current_chunk value and keep incrementing
              //get pim_unit_done from pim_unit module and increment only if it's high

        if (rst) begin
          
          pim_states[i].current_state <= IDLE;
          pim_states[i].current_chunk <= '0;
          pim_states[i].chunk_sent <= '0;
          pim_states[i].pim_fully_done <= '0;
        end

        else begin
          pim_states[i].current_state <= pim_states[i].next_state;

          case (pim_states[i].current_state)

            IDLE: begin
                if (start) begin
                    pim_states[i].current_chunk <= '0;
                end
            end

            SEND_CHUNK: begin

                if(pim_states[i].all_zeros) begin
                  pim_states[i].chunk_sent <= 1'b0; //NO TRIGGER for PIM_UNIT
                  pim_states[i].current_chunk <= pim_states[i].current_chunk + unsigned'(1);
                end

                else begin
                  pim_states[i].chunk_sent <= 1'b1;
                end
            end

            WAIT_PIM_UNIT: begin
                pim_states[i].chunk_sent <= 1'b0; //release trigger
                if (pim_states[i].current_chunk == NUM_PIM_UNIT_CHUNKS - 1) begin
                  if (pim_unit_done[i]) begin
                    pim_states[i].pim_fully_done <= 1'b1;
                  end
                end
                  
                else if (pim_states[i].next_state == SEND_CHUNK) begin
                  pim_states[i].current_chunk <= pim_states[i].current_chunk + unsigned'(1); //increment, go to next chunk
                end
            end

            DONE: begin
              pim_states[i].pim_fully_done <= 1'b0; //Reset for next matrix operation (overall)- CHECK
            end

          endcase
        end
      end
    end 
  endgenerate
        

// RESULT AGGREGATOR
logic [NUM_OF_PIM_UNITS-1:0] fully_done_bits;

//ORIGINAL- NOT WORKING IF THE 0 chunk is at the end////
generate
for (genvar idx = 0; idx < NUM_OF_PIM_UNITS; idx++) begin
    assign fully_done_bits[idx] = pim_states[idx].pim_fully_done;
end
endgenerate


//MESSED UP, BROKEN result_ready is messed up and the memory fsm is wrong because of that////
/*
always_comb begin
  for (int idx = 0; idx < NUM_OF_PIM_UNITS; idx++) begin
      if(pim_unit_done_last_0[idx]==0)
        fully_done_bits[idx] = pim_states[idx].pim_fully_done;
      else
        fully_done_bits[idx] = '1;
  end
end
*/
//////////////////////////


assign all_pims_done = &fully_done_bits;

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