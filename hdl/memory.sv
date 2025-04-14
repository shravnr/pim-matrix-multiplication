import types::*;
module memory
(
    input         clk,
    input         rst,
    input logic [LEN-1:0] src1_addr,
    input logic [LEN-1:0] src2_addr,
    input logic [LEN-1:0] dst_addr,
    // input logic [2:0]     matrix_size,

    input logic start
);

    // File descriptor and registers to hold file-read values
    int fd;
    logic [LEN-1:0] f_src1_addr, f_src2_addr, f_dst_addr;
    // logic [2:0]     f_matrix_size;

    // Open the input test vector file at simulation start
    initial begin
        fd = $fopen("memory_inputs.txt", "r");
        if (fd == 0) begin
            $error("Failed to open memory_inputs.txt");
            $finish;
        end
    end

    // Read a line from the test file (once, after reset is deasserted)
    // and display the values.
    // You can extend this to read multiple lines in a loop if needed.
    always_ff @(posedge clk) begin
        if (!rst) begin
            if ($fscanf(fd, "%h %h %h %d\n", f_src1_addr, f_src2_addr, f_dst_addr) == 3) begin
                $display("File Input: src1_addr=0x%h, src2_addr=0x%h, dst_addr=0x%h", 
                         f_src1_addr, f_src2_addr, f_dst_addr);
            end else begin
                $display("File read error or EOF reached");
                // $finish;
            end
        end
    end

    // Display the inputs received from the testbench.
    // This helps you verify that the testbench is correctly driving these signals.
    always_ff @(posedge clk) begin
        if (!rst) begin
            $display("Driven Inputs: src1_addr=0x%h, src2_addr=0x%h, dst_addr=0x%h, start=%0d",
                     src1_addr, src2_addr, dst_addr, start);
        end
    end

    // Memory
    logic [WIDTH-1:0] mem[MEM_ELEMENTS-1:0];

    //Inputs to PIM-C
    logic [WIDTH-1:0] matrix_A [MATRIX_SIZE**2-1:0];
    logic [WIDTH-1:0] matrix_B [MATRIX_SIZE**2-1:0];
    logic [WIDTH-1:0] result [MATRIX_SIZE**2-1:0];
    logic pim_unit_start;

    //Output from PIM-C
    logic result_ready;

    //Memory FSM States
    typedef enum logic [1:0] {
        IDLE,
        READ_MATRICES,
        COMPUTE,
        WRITE_RESULT
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
            IDLE:               if(start) next_state = READ_MATRICES;
            READ_MATRICES:      next_state = COMPUTE;
            COMPUTE:            if(result_ready) next_state = WRITE_RESULT;
            WRITE_RESULT:       next_state= IDLE;
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

    //State Logic
    always_ff @(posedge clk) begin
        if(rst) begin
            for (int i = 0; i < MEM_ELEMENTS; i++) begin
                mem[i] <= i;
            end
        end else begin
            case(current_state)

                IDLE: begin
                    // busy<=0;
                    // done<=0;
                end

                READ_MATRICES: begin

                    for (int i = 0; i < MATRIX_SIZE**2; i++) begin
                        matrix_A[i] <= mem[src1_addr + i];
                        matrix_B[i] <= mem[src2_addr + i];
                    end

                    // busy<=1;
                    pim_unit_start <= 1'b1;

                end

                COMPUTE: begin
                    pim_unit_start <= 1'b0;
                end

                WRITE_RESULT: begin

                    for (int i = 0; i < MATRIX_SIZE**2; i++) begin
                        mem[dst_addr + i] <= result[i];
                    end

                    // done<=1;
                    // busy<=0;
                end
                

            endcase
        end

    end


endmodule