package types;

    // PIM
    // Assumptions:
    // Num of PIM unit should be even power of 4
    // PIM unit cap should not be more than matrix size 

    parameter int NUM_OF_PIM_UNITS = 4;
    parameter int PIM_UNIT_CAPACITY = 2;
    parameter int MATRIX_SIZE = 16;
    parameter int CHUNK_SIZE = MATRIX_SIZE/$sqrt(NUM_OF_PIM_UNITS);
    parameter int NUM_PIM_UNIT_CHUNKS = MATRIX_SIZE/PIM_UNIT_CAPACITY;
    parameter int WIDTH = 64;
    parameter int MEM_ELEMENTS = 1024;

    // For testing:
    // parameter int PIM_UNIT_CAPACITY = MATRIX_SIZE;
    // parameter int LEN = $clog2(MEM_ELEMENTS);


    // DRAM
    // CPU-DRAM EMULATION WIDTH = BURST ACCESS WIDTH =64
    // parameter int BURST_LEN= 4;
    // parameter int BURST_ACCESS_WIDTH= 64;
    // PIM EMULATION: BURST_ACCESS_LEN = ROW_WIDTH = 65536
    // ADDRESS_LEN should be at least $clog2(NUM_BANKS*NUM_ROWS

    parameter int BURST_LEN = 1;
    parameter int BURST_ACCESS_WIDTH = 65536;
    parameter int PRECHARGE_CYCLES = 10;         //20ns
    parameter int TRCD_CYCLES = 10;              //20ns
    parameter int BANK_ACTIVATION_CYCLES = 7;    // 14 ns
    parameter int TRAS_CYCLES = 22;              // 44 ns
    parameter int TWR_CYCLES = 7;                // 14ns
    parameter int ROW_WIDTH = 65536;
    parameter int NUM_BANKS = 1;
    parameter int NUM_ROWS = 100;
    parameter int ADDRESS_LEN = 10;
    parameter int QUEUE_LEN = 1;

endpackage




