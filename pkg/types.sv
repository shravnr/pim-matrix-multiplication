package types;

    // MEMORY MODEL : DDR3-1066-Like : tRCD + tCL + Read/Write Burst + (tWR) + tRP
    parameter int PIM_ENABLE = 1; // set as 1 for CPU-in-memory emulation, set as 0 for CPU-outside-DRAM baseline emulation 
    //also set the BURST_LENGTH and BURST_ACCESS_WIDTH parameter accordingly, instructions below! 

    // DRAM Parameters

    //if(PIM_ENABLE==1)   set the below two parameters for in-memory Emulation (comment out for Baseline) 
    //BURST_ACCESS_LEN = ROW_WIDTH = 65536
        parameter int BURST_LEN = 1;
        parameter int BURST_ACCESS_WIDTH = 65536;

    // else if (PIM_ENABLE==0) set the below parameters for Baseline Emulation (comment out for in-memory)
    // CPU-DRAM EMULATION WIDTH = BURST ACCESS WIDTH =64
        //parameter int BURST_LEN= 4;
        //parameter int BURST_ACCESS_WIDTH= 64;

    // DRAM Size

    parameter int ROW_WIDTH = 65536;
    parameter int NUM_BANKS = 1;
    parameter int NUM_ROWS = 100;
    parameter int ADDRESS_LEN = 10;
    parameter int QUEUE_LEN = 1;
    
    // DRAM Delay
    
    parameter int TRCD_CYCLES = 8;                // 16 ns BANK_ACTIVATION_CYCLES
    parameter int TCL_CYCLES = 8;                 // 16 ns
    parameter int TRP_CYCLES = 8;                 // 16 ns PRECHARGE_CYCLES
    parameter int TWR_CYCLES = 7;                 // 14 ns WAIT_AFTER_WRITE
    
    //Accelerator Specs

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


endpackage




