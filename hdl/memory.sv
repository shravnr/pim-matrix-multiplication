module memory
import types::*;
(
    input         clk,
    input         rst,
    input logic [ADDRESS_LEN-1:0] src1_addr,
    input logic [ADDRESS_LEN-1:0] src2_addr,
    input logic [ADDRESS_LEN-1:0] dst_addr,
    input logic start,

    //To DRAM (dram.sv)
    output logic [ADDRESS_LEN-1:0] addr, // [LEN-1:0]
    output logic        read_en,
    output logic        write_en,
    output logic [BURST_ACCESS_WIDTH-1:0] wdata, 

    //From DRAM (dram.sv) 
    input  logic             dram_ready,
    input  logic             dram_complete,
    input  logic [BURST_ACCESS_WIDTH-1:0] rdata, 
    input  logic             valid


);

    // Memory
    logic [WIDTH-1:0] mem[MEM_ELEMENTS-1:0];

    //Inputs to PIM-C
    logic [WIDTH-1:0] matrix_A [MATRIX_SIZE**2-1:0];
    logic [WIDTH-1:0] matrix_B [MATRIX_SIZE**2-1:0];
    logic [WIDTH-1:0] result [MATRIX_SIZE**2-1:0];
    logic pim_unit_start;

    //Output from PIM-C
    logic result_ready;

    logic [2:0] i;

    logic [31:0] a_req_count, b_req_count, w_req_count;

    //Memory FSM States
    typedef enum logic [2:0] {
        IDLE,
        READ_A,
        READ_B,
        COMPUTE,
        WRITE_RESULT
    } state_t;

    state_t current_state, next_state;



    //Drive State Machine
    always_ff @(posedge clk) begin
        if(rst) current_state <= IDLE;
        else    begin
            current_state <= next_state;

            case(current_state) 
                IDLE:               begin
                                        i <= 0;
                                        a_req_count <= '0;
                                        b_req_count <= '0;
                                        w_req_count <= '0;
                                        write_en <= 1'b0;
                                        read_en <= 1'b0;
                                    end



                READ_A:             begin
                                        if(dram_ready) begin
                                            
                                            read_en <= 1'b1;
                                            addr <= src1_addr; // + a_burst_count/4;
                                        end

                                        if(valid) begin
                                            i <= i + 1;

                                            // matrix_A[a_req_count*BURST_LEN + i] <= rdata; //ASSUMPTION WORD LENGTH= BURST ACCESS WIDTH

                                            //BURST_LENGTH = ROW_WIDTH
                                            for(int y=0; y<(ROW_WIDTH/WIDTH); y++)
                                                matrix_A[a_req_count*(ROW_WIDTH/WIDTH) + y] <= rdata[ ((y+1)*WIDTH -1) -: (WIDTH-1) ];

                                            
                                        end

                                        if(dram_complete) begin
                                            i <= 0;
                                            a_req_count <= a_req_count + unsigned'(1);  
                                            read_en = 1'b0;
                                        end


                                        
                                    end


                READ_B:             begin
                                        
                                        if(dram_ready) begin

                                            read_en <= 1'b1;
                                            addr <= src2_addr; // + b_burst_count/4;
                                        end

                                        if(valid) begin
                                            i <= i + 1;
                                            //matrix_B[b_req_count*BURST_LEN + i] <= rdata; //ASSUMPTION WORD LENGTH= BURST ACCESS WIDTH

                                            //BURST_LENGTH = ROW_WIDTH
                                            for(int y=0; y<(ROW_WIDTH/WIDTH); y++)
                                                matrix_B[b_req_count*(ROW_WIDTH/WIDTH) + y] <= rdata[ ((y+1)*WIDTH -1) -: (WIDTH-1) ];
                                        end

                                        

                                        if(dram_complete) begin
                                            i <= 0;
                                            b_req_count <= b_req_count + unsigned'(1);
                                            //matrix_A[b_burst_count] <= rdata; //ASSUMPTION WORD LENGTH= BURST ACCESS WIDTH
                                            read_en = 1'b0;

                                            //if (b_req_count == MATRIX_SIZE**2/BURST_LEN) begin
                                            if (b_req_count == MATRIX_SIZE**2/(ROW_WIDTH/WIDTH)) begin
                                                pim_unit_start <= 1'b1;

                                            end
                                        end

                                        

                                     
                                    end     

                COMPUTE:            begin 
                                        read_en <=1'b0;
                                        write_en<=1'b0;

                                    end                 

                WRITE_RESULT:       
                                    begin
                                        if(dram_ready) begin
                                            write_en <= 1'b1;
                                            addr <= src1_addr; // + w_burst_count/4;
                                        end

                                        if(valid) begin
                                            i <= i + 1;
                                            //wdata <= result[w_req_count*BURST_LEN + i]; //ASSUMPTION WORD LENGTH= BURST ACCESS WIDTH

                                            //BURST_LENGTH = ROW_WIDTH
                                            for(int y=0; y<(ROW_WIDTH/WIDTH); y++)
                                                // wdata[ ((y+1)*WIDTH -1) -: (WIDTH-1) ] <= result[w_req_count*(ROW_WIDTH/WIDTH) + y] ;
                                                wdata[y*WIDTH +: WIDTH] <= result[w_req_count*(ROW_WIDTH/WIDTH) + y];
                                        end

                                        

                                        if(dram_complete) begin
                                            w_req_count <= w_req_count + unsigned'(1);
                                            i <= 0;
                                            write_en <= 1'b0;
                                        end

                                    end

                // default: next_state = IDLE;
            endcase
        end
    end

    //State Transition Logic
    always_comb begin
        next_state = current_state;
        // write_en = 1'b0;
        // read_en =1'b0;
        
        case(current_state) 
            IDLE:               if(start) next_state = READ_A;
                            
            READ_A:             begin
                                    if(dram_complete) begin
                                        //if (a_req_count == MATRIX_SIZE**2/BURST_LEN) begin
                                        if (a_req_count == MATRIX_SIZE**2/(ROW_WIDTH/WIDTH)) begin
                                            next_state = READ_B;
                                        end
                                    end
                                end


            READ_B:             begin
                                    if(dram_complete) begin
                                        //if (b_req_count == MATRIX_SIZE**2/BURST_LEN) begin
                                        if (b_req_count == (MATRIX_SIZE**2)/(ROW_WIDTH/WIDTH)) begin
                                            next_state = COMPUTE;
                                        end
                                    end
                                end

                               

            COMPUTE:            if(result_ready) next_state = WRITE_RESULT;

            WRITE_RESULT:       
                                begin
                                    if(dram_complete) begin
                                        //if (w_req_count == MATRIX_SIZE**2/BURST_LEN) begin
                                        if (w_req_count == MATRIX_SIZE**2/(ROW_WIDTH/WIDTH)) begin
                                            next_state = IDLE;
                                        end
                                    end
                                end

            // default: next_state = IDLE;
        endcase
    end

    pim_controller pim_ctl (
        .clk(clk), //clock synchronization ensured. so I don't think modules need to be called within an always_ff (i don't think that's valid either)
        .rst(rst),
        .start(pim_unit_start), 
        .matrix_A(matrix_A), 
        .matrix_B(matrix_B), 
        // .matrix_size(matrix_size),
        //.no_of_pims(no_of_pims),
        .result(result),
        .result_ready(result_ready)//output from PIM-C-- but does it need to communicate with memory? might need another wrapper here 
    );



endmodule