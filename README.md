# pim-matrix-multiplication

Processing-In-Memory (PIM) architecture for accelerating matrix multiplication, by distributing computation across multiple PIM units and aggregating results efficiently, using SystemVerilog. This project addresses the von Neumann bottleneck by reducing data movement between CPU and memory, and is challenging because we are implementing different chunking strategies for parallelism, and choosing the number of PIM units to be used dynamically. 


Graph 1: Execution time vs Type of Processor (Emulation for CPU Access and In-memory Access)
![Graph 1](https://github.com/shravnr/pim-matrix-multiplication/blob/master/Graphs/graph1.png)

Graph 2: Execution time vs PIM Unit Capacity (for matrix size 64- dense matrix)
![Graph 2](https://github.com/user-attachments/assets/9928bf25-74ce-4d33-9b4d-237f434af0e8)

Graph 3: Execution time vs Matrix Size
Specs- 2 PIM_UNIT_CAPACITY, 4 PIM units
![Graph 3](https://github.com/shravnr/pim-matrix-multiplication/blob/master/Graphs/graph3.png)

Graph 4: Execution Time- Dense vs Sparse
Specs- 16 x 16  matrices, 4 PIM units 
![Graph 4](https://github.com/user-attachments/assets/5dc6aceb-49b3-48bd-8164-0dad2ade1480)

Tool flow - RTL implementation in SystemVerilog -> Simulation in VCS  
