module top_tb;
    timeunit 1ps;
    timeprecision 1ps;

    import types::*;
    
    int clock_half_period_ps;
    initial begin
        $value$plusargs("CLOCK_PERIOD_PS_ECE511=%d", clock_half_period_ps);
        clock_half_period_ps = clock_half_period_ps / 2;
    end

    bit clk;
    always #(clock_half_period_ps) clk = ~clk;

    bit rst;
    longint timeout;

    logic [LEN-1:0] src1_addr;
    logic [LEN-1:0] src2_addr;
    logic [LEN-1:0] dst_addr;
    logic start;

    int fd, status;
    logic [LEN-1:0] t_src1, t_src2, t_dst;
    logic t_start; 
    int t_delay;

    initial begin
        // Open the test vector file.
        fd = $fopen("memory_inputs.txt", "r");
        if (fd == 0) begin
            $error("Failed to open memory_inputs.txt");
            $finish;
        end

        @(negedge rst);

        // Loop through the file until EOF.
        while (!$feof(fd)) begin
            status = $fscanf(fd, "%d %d %d %d %d\n", t_src1, t_src2, t_dst, t_start, t_delay);
            if (status != 5) begin
                $display("Incomplete data read (status = %0d), stopping stimulus.", status);
                break;
            end

            $display("TB File Input: src1_addr=%0d, src2_addr=%0d, dst_addr=%0d, start=%0d, delay=%0d",
                     t_src1, t_src2, t_dst, t_start, t_delay);

            src1_addr = t_src1;
            src2_addr = t_src2;
            dst_addr  = t_dst;
            start     = (t_start != 0) ? 1'b1 : 1'b0;

            #t_delay;
            start = 1'b0;
            #1000;
        end

        $fclose(fd);
    end

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

    //Power
    initial begin
        // Start toggle monitoring
        $set_toggle_region("dut");  // 'dut' is the name of your memory module instance
        $toggle_start();

        // Wait until simulation ends (or timeout)
        wait (timeout == 0);
        $toggle_stop();
        $toggle_report("dump.saif", 1.0e-9, "dut");
    end


    memory dut (
        .clk(clk),
        .rst(rst),
        .src1_addr(src1_addr),
        .src2_addr(src2_addr),
        .dst_addr(dst_addr),
        .start(start)
    );

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
