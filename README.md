# pim-matrix-multiplication

Design and verification a Processing-In-Memory (PIM) architecture for accelerating matrix multiplication, by distributing computation across multiple PIM units and aggregating results efficiently, using SystemVerilog. 
The project addresses the von Neumann bottleneck by reducing data movement between CPU and memory, and is challenging because we are implementing different chunking strategies for parallelism, and choosing the number of PIM units to be used dynamically. 


Graph 1: Execution time vs Type of Processor (PIM and normal CPU)
![Graph 1](https://github.com/user-attachments/assets/e1834a42-30c9-4673-a722-244ed1a0fe52)

Tool flow- RTL implementation in SystemVerilog -> Simulation in VCS  

 

Graph 2: Execution time vs PIM Unit Capacity (for matrix size 64- dense matrix)
![Graph 2](https://github.com/user-attachments/assets/9928bf25-74ce-4d33-9b4d-237f434af0e8)


Tool flow- RTL implementation in SystemVerilog -> Simulation in VCS  

Graph 3: Execution time vs Matrix Size
Specs- 2 PIM_UNIT_CAPACITY, 4 PIM units
![Graph 3](https://github.com/user-attachments/assets/458be83f-7248-418b-bde2-c354895c1caa)

Graph 4: Execution Time- Dense vs Sparse
Specs- 16 x 16  matrices, 4 PIM units 
![Graph 4](https://github.com/user-attachments/assets/5dc6aceb-49b3-48bd-8164-0dad2ade1480)

Graph 5: Execution time vs No. of PIM units for a given matrix size // (additional)
Equal timing, hopefully power is different (Vivado)


Tool flow- RTL implementation in SystemVerilog with Dynamic allocation (scaling) -> Simulation in VCS (PIM) -> Full RTL Implementation of CPU for comparison

Date of Completion- 1st May 2025 

 
