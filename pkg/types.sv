package types;

    parameter int NUM_OF_PIM_UNITS = 4; // square of 4 number always, even power of 4
    parameter int PIM_UNIT_CAPACITY = 2;
    //PIM unit cap should not be more than matrix size 

    parameter int MATRIX_SIZE = 4;
    // parameter int PIM_UNIT_CAPACITY = MATRIX_SIZE;
    parameter int CHUNK_SIZE = MATRIX_SIZE/$sqrt(NUM_OF_PIM_UNITS);

    parameter int NUM_PIM_UNIT_CHUNKS = MATRIX_SIZE/PIM_UNIT_CAPACITY;
    
    parameter int WIDTH = 64; // Data width
    parameter int MEM_ELEMENTS = 1024;
    parameter int LEN = $clog2(MEM_ELEMENTS); // Adress width, original 10, changed to align with top_tb.sv

    
    

    //DRAM

    //ASSUMPTION WIDTH = BURST ACCESS WIDTH
        //parameter int BURST_LEN= 4;
        //parameter int BURST_ACCESS_WIDTH= 64;

    //ASSUMPTION BURST_ACCESS_LEN = ROW_WIDTH
    parameter int BURST_LEN= 1;
    parameter int BURST_ACCESS_WIDTH= 512;

    parameter int PRECHARGE_CYCLES= 10; //20ns
    parameter int BANK_ACTIVATION_CYCLES= 21; // 44 ns

    parameter int ROW_WIDTH= 512;
    parameter int NUM_BANKS= 1;
    parameter int NUM_ROWS=100;
    parameter int ADDRESS_LEN=10;         //(at least $clog2(NUM_BANKS*NUM_ROWS))

endpackage




