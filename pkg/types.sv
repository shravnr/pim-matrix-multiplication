package types;

    parameter int MATRIX_SIZE = 4;
    parameter int CHUNK_SIZE = MATRIX_SIZE/2;
    
    parameter int WIDTH = 32; // Data width
    parameter int MEM_ELEMENTS = 1024;
    parameter int LEN = $clog2(MEM_ELEMENTS); // Adress width, original 10, changed to align with top_tb.sv
endpackage




