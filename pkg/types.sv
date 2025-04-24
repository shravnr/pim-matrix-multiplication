package types;

    parameter int NUM_OF_PIM_UNITS = 4; // square of 4 number always, even power of 4
    parameter int PIM_UNIT_CAPACITY = 16;
    //PIM unit cap should not be more than matrix size
    

    parameter int MATRIX_SIZE =16;
    parameter int CHUNK_SIZE = MATRIX_SIZE/$sqrt(NUM_OF_PIM_UNITS);

    parameter int NUM_PIM_UNIT_CHUNKS = MATRIX_SIZE/PIM_UNIT_CAPACITY;
    
    parameter int WIDTH = 32; // Data width
    parameter int MEM_ELEMENTS = 1024;   // Usually 1024 for 4x4 matrix
    parameter int LEN = $clog2(MEM_ELEMENTS); // Adress width, original 10, changed to align with top_tb.sv


endpackage




