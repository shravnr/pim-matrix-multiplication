module memory
#(
    parameter LEN = 32,               // Data length per element
    parameter MEM_ELEMENTS = 1024,      // Total memory entries
    parameter MAX_MATRIX_SIZE = 16      // Supports up to 16x16 matrices
)
(
    input         clk,
    input         rst,
    input logic [LEN-1:0] src1_addr,
    input logic [LEN-1:0] src2_addr,
    input logic [LEN-1:0] dst_addr,
    input logic [2:0]     matrix_size
);

    // File descriptor and registers to hold file-read values
    int fd;
    logic [LEN-1:0] f_src1_addr, f_src2_addr, f_dst_addr;
    logic [2:0]     f_matrix_size;

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
            if ($fscanf(fd, "%h %h %h %d\n", f_src1_addr, f_src2_addr, f_dst_addr, f_matrix_size) == 4) begin
                $display("File Input: src1_addr=0x%h, src2_addr=0x%h, dst_addr=0x%h, matrix_size=%0d", 
                         f_src1_addr, f_src2_addr, f_dst_addr, f_matrix_size);
            end else begin
                $display("File read error or EOF reached");
                $finish;
            end
        end
    end

    // Display the inputs received from the testbench.
    // This helps you verify that the testbench is correctly driving these signals.
    always_ff @(posedge clk) begin
        if (!rst) begin
            $display("Driven Inputs: src1_addr=0x%h, src2_addr=0x%h, dst_addr=0x%h, matrix_size=%0d",
                     src1_addr, src2_addr, dst_addr, matrix_size);
        end
    end

endmodule