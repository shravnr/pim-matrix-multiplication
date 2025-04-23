# pim-matrix-multiplication

Design and verification a Processing-In-Memory (PIM) architecture for accelerating matrix multiplication, by distributing computation across multiple PIM units and aggregating results efficiently, using SystemVerilog. 
The project addresses the von Neumann bottleneck by reducing data movement between CPU and memory, and is challenging because we are implementing different chunking strategies for parallelism, and choosing the number of PIM units to be used dynamically. 


Graph 1: Execution time vs Type of Processor (PIM and normal CPU)
![Graph 1](https://github.com/user-attachments/assets/e1834a42-30c9-4673-a722-244ed1a0fe52)

Tool flow- RTL implementation in SystemVerilog -> Simulation in VCS  

 

Graph 2: Execution time vs PIM Unit Capacity (for matrix size 64)
![Graph 2](https://github.com/user-attachments/assets/9928bf25-74ce-4d33-9b4d-237f434af0e8)


Tool flow- RTL implementation in SystemVerilog -> Simulation in VCS  


Graph 3: Execution Time- Dense vs Sparse
Specs- 4 x 4 matrix size, 2 PIM_UNIT_CAPACITY, 4 PIM units, first sub-chunk A is 0
Sparse- start time 7k, end time 23k
Dense- start time 7k, end time 27k

Graph 3: Execution time vs No. of PIM units for a given matrix size 

Tool flow- RTL implementation in SystemVerilog with Dynamic allocation (scaling) -> Simulation in VCS (PIM) -> Full RTL Implementation of CPU for comparison

Date of Completion- 1st May 2025 

 
