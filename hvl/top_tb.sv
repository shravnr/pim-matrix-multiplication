module top_tb;
    timeunit 1ps;
    timeprecision 1ps;

    // Clock period: read plusarg and compute half period.
    int clock_half_period_ps;
    initial begin
        $value$plusargs("CLOCK_PERIOD_PS_ECE511=%d", clock_half_period_ps);
        clock_half_period_ps = clock_half_period_ps / 2;
    end

    // Clock generation
    bit clk;
    always #(clock_half_period_ps) clk = ~clk;

    // Reset and timeout signals
    bit rst;
    longint timeout;

    // Declare signals to drive the memory module inputs:
    logic [31:0] src1_addr;
    logic [31:0] src2_addr;
    logic [31:0] dst_addr;
    logic [2:0]  matrix_size;  // 3-bit signals: valid values are 0 to 7

    // Drive the stimulus for the memory DUT (set to your desired test values)
    initial begin
        // Set the memory addresses and matrix size.
        src1_addr   = 32'h1000;
        src2_addr   = 32'h2000;
        dst_addr    = 32'h3000;
        matrix_size = 3'd7;  // Changed from 3'd8 to 3'd7, which fits in 3 bits
    end

    // Reset generation and FSDB dumping
    initial begin
        $fsdbDumpfile("dump.fsdb");
        $value$plusargs("TIMEOUT_ECE511=%d", timeout);
        if ($test$plusargs("NO_DUMP_ALL_ECE511")) begin
            $fsdbDumpvars(0, dut, "+all");
            $fsdbDumpoff();
        end else begin
            $fsdbDumpvars(0, "+all");
        end
        
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst = 1'b0;
    end

    // Instantiate the DUT. Using ".*" connects signals with matching names.
    memory dut(.*);

    // Timeout monitoring: check each clock edge for timeout condition.
    always @(posedge clk) begin
        if (timeout == 0) begin
            $display("Monitor: Timed out");
            $finish;
        end
        timeout <= timeout - 1;
    end

    final begin
        $display("Monitor: Simulation finished");
    end
endmodule
