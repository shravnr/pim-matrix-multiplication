# pim-matrix-multiplication

Design and verification a Processing-In-Memory (PIM) architecture for accelerating matrix multiplication, by distributing computation across multiple PIM units and aggregating results efficiently, using SystemVerilog. 
The project addresses the von Neumann bottleneck by reducing data movement between CPU and memory, and is challenging because we are implementing different chunking strategies for parallelism, and choosing the number of PIM units to be used dynamically. 


Graph 1: Execution time vs Type of Processor (PIM and normal CPU)
![Graph 1 - Execution cycle comparison for a 4x4 matrix multiplication](https://github.com/user-attachments/assets/e1834a42-30c9-4673-a722-244ed1a0fe52)

Tool flow- RTL implementation in SystemVerilog -> Simulation in VCS  

Date of Completion- 15th April 2025 

 

Graph 2: Execution time vs Matrix Size for a given number of PIM units 

Tool flow- RTL implementation in SystemVerilog -> Simulation in VCS  

Date of Completion- 20th April 2025 

 

Graph 3: Execution time vs No. of PIM units for a given matrix size 

Tool flow- RTL implementation in SystemVerilog -> Simulation in VCS (PIM), Gem5 Simulation (normal CPU)  

Date of Completion- 1st May 2025 

 
