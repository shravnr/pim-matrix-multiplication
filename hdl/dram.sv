module dram 
import types::*;
(
    //From controller (Memory.sv)
    input logic clk,
    input logic rst,
    input logic [ADDRESS_LEN-1:0] addr, // [LEN-1:0]
    input logic        read_en,
    input logic        write_en,
    input logic [BURST_ACCESS_WIDTH-1:0] wdata, 

    //To controller (Memory.sv) 

    output  logic             dram_ready,
    output logic dram_complete,
    output  logic [BURST_ACCESS_WIDTH-1:0] rdata, 
    output  logic             valid
    
);

    // Memory
    logic [ROW_WIDTH-1:0] dram[NUM_BANKS-1:0][NUM_ROWS-1:0];

    //Internal addresses (increment with burst)
    logic [ADDRESS_LEN-1] r_waddr;

    //Counters
    logic [31:0] precharge_cycle_count;
    logic [31:0] discharge_cycle_count;
    logic [31:0] bank_activation_cycles_count;
    logic [31:0] burst_count;

        //Memory FSM States
    typedef enum logic [2:0] {
        IDLE,
        BANK_ACTIVATE,
        READ_BURST,
        WRITE_BURST,
        PRECHARGE,
        DONE
    } state_t;

    state_t current_state, next_state;
    


    //Drive State Machine
    always_ff @(posedge clk) begin
        if(rst) current_state <= IDLE;
        else    current_state <= next_state;
    end

    //State Transition Logic
    always_comb begin
        next_state = current_state;
        case(current_state) 
            //bank and row charge

            IDLE:               begin
                                    if(read_en | write_en) begin
                                        next_state = BANK_ACTIVATE;   
                                    
                                    end
                                end   
            BANK_ACTIVATE:      begin


                                if(read_en==0 && write_en==0)
                                    next_state = IDLE;


                                if(bank_activation_cycles_count== BANK_ACTIVATION_CYCLES) begin
                                    //Precharge everytime we switch row
                                    // if(read_en) next_state = READ_BURST;
                                    // else if (write_en) next_state = WRITE_BURST;
                                    next_state = PRECHARGE;
                                end

                                end

            READ_BURST:         begin
                                    if(burst_count== BURST_LEN) begin
                                        next_state = IDLE;
                                    end
                                 
                                end 

            WRITE_BURST:        begin
                                    if(burst_count== BURST_LEN) begin
                                        next_state = DONE;
                                    end
                                    
                                end 

            PRECHARGE:          if(precharge_cycle_count== PRECHARGE_CYCLES) begin
                                    if(read_en) next_state = READ_BURST;
                                    else if (write_en) next_state = WRITE_BURST; 
                                end 

            DONE:          
                                    next_state= IDLE;
                                
            
     
        endcase
    end

    always_ff @(posedge clk) begin
        logic [ROW_WIDTH-1:0] current_row;
        assign current_row = dram[0][addr];

        if(rst) begin // Initial Memory Population (Emulating "hex file")

        precharge_cycle_count <=0;
        bank_activation_cycles_count <=0;
        burst_count <=0;
        discharge_cycle_count <=0;
        dram_ready<=1;
        dram_complete<=0;
        valid<=1'b0;


            for (int i = 0; i < NUM_BANKS; i++) begin
                for (int j = 0; j < NUM_ROWS; j++) begin
                    for (int k = 0; k < ROW_WIDTH; k++) begin
                        dram[i][j][k]<=0;
                    end
                end
            end
        end

        else begin
            case (current_state)
                
                IDLE:               begin
                                        burst_count <= '0;
                                        dram_complete <= 1'b0;
                                        dram_ready <=1'b1;
                                        //bank_activation_cycles_count <= '0;

                                    end

                BANK_ACTIVATE:      begin
                                        bank_activation_cycles_count <= bank_activation_cycles_count + unsigned'(1);
                                        dram_ready <=1'b0;
                                        //wait
                                    end

                READ_BURST:         begin
                                        bank_activation_cycles_count <= '0;
                                        precharge_cycle_count <= '0;
                                        valid <= 1'b1;
                                        rdata <= current_row[((burst_count + 1)*BURST_ACCESS_WIDTH - 1) -: (BURST_ACCESS_WIDTH-1)];
                                        burst_count <= burst_count + unsigned'(1);
                                        if(burst_count== BURST_LEN) begin
                                            dram_complete <= 1'b1;
                                            valid <= 1'b0;
                                            //dram_ready <= 1'b1;
                                        end
                                    end

                WRITE_BURST:        begin
                                        precharge_cycle_count <= '0;
                                        valid <=1'b1;
                                        current_row[((burst_count + 1)*BURST_ACCESS_WIDTH - 1) -: (BURST_ACCESS_WIDTH)]<= wdata;
                                        burst_count <= burst_count + unsigned'(1);
                                        if(burst_count == BURST_LEN) begin
                                            dram_complete <= 1'b1;
                                            valid <=1'b0;
                                        end

                                        //else if(next_state==IDLE)
                                        //    dram_complete<=1'b0;
                                    end


                PRECHARGE:          begin
                                        bank_activation_cycles_count <= '0;          
                                        precharge_cycle_count <= precharge_cycle_count + unsigned'(1);
                                    //wait
                                    end

                DONE:               begin
                                        dram_complete =1'b0;
                                        bank_activation_cycles_count <=0;
                                        burst_count <=0;  
                                        dram_ready <= 1'b1;
                                    end

            endcase

        end
    end

endmodule


