package types;

    parameter int MATRIX_SIZE = 8;
    parameter int CHUNK_SIZE = MATRIX_SIZE/2;

    parameter int LEN = 32; // Adress width, original 10, changed to align with top_tb.sv
    parameter int WIDTH = 32; // Data width
    parameter int MEM_ELEMENTS = 1024;

endpackage




