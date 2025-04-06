module memory{
    input clk,
    input rst,
    input logic [LEN-1:0]matrix_A,
    input logic [LEN-1:0]matrix_B,
    input logic [LEN-1:0]dest_addr,
    input logic [2:0]matrix_size,
    //input logic [2:0]no_of_pims,

    input write_en  //needed?? I think it's needed because the reading to send to PIM and writing to dest will happen in parallel. so we need a control signal. 
    //we should probably send write_en low and then high from the test bench after a certain number of clock cycles
};

  // LEN must be equal to $clog2(MEM_ELEMENTS)

logic [WIDTH-1:0] mem[MEM_ELEMENTS-1:0];
logic [WIDTH-1:0] result[matrix_size**2-1:0];

logic [WIDTH-1:0] matrix_A[matrix_size**2-1:0];
logic [WIDTH-1:0] matrix_B[matrix_size**2-1:0];


logic result_ready;

//Address- should getting this be combinational or sequential? First thought it should be combinational because it is coming to memory independent of clock
//ChatGPT says memory accesses should be done on clock edge, which makes a lot of sense

/******************READ/RESET*************************/
always_ff(posedge clk) begin
    if(rst) begin
        for (int i = 0; i < MEM_ELEMENTS- 1; i++) begin
            mem[i] <= i;
        end
    end
        
    else begin
        if(!write_en) begin
            for (int i = 0; i < matrix_size**2 - 1; i++) begin
                matrix_A[i] <= mem[source_addr[0] + i];
                matrix_B[i] <= mem[source_addr[1] + i];
            end 
        end
    end

end

//note- how about we call PIMs in here? do we need a PIM controller? we can insert PIM-C logic and get result as a local variable.

//do we need any control signals? is there any point where memory is not ready that it needs to send a signal to the PIM-C? 
//the job of memory in this design is only to get addresses and put result in destination memory. so i don't think meory neeeds a ready signal
//will PIM-C need it? if it is not ready, then it shouldn't accept the new address. i can add the pim-c control signal as a local variable and give it as an output of pim-c.
//then internal to pim-c, 

pim_controller
(
               .clk(clk), //clock synchronization ensured. so I don't think modules need to be called within an always_ff (i don't think that's valid either)
               .rst(rst), 
               .matrix_A(matrix_A), 
               .matrix_B(matrix_B), 
               //.no_of_pims(no_of_pims),
               .result(result),
               .result_ready(result_ready)//output from PIM-C-- but does it need to communicate with memory? might need another wrapper here 
);


/*
PIM-C would look like:
for(i=0, i<no_of_pims,i++) begin
    pim_c #(.ID(i))(.inputs(inputs), .outputs(outputs))
end 

*/

/*******************WRITE*************************/
always_ff(posedge clk) begin

    if(write_en && result_ready) begin   //do we need this???
        for (int i = 0; i < matrix_size**2 - 1; i++) begin
            mem[dest_addr + i] <= result[i];
        end
    end

end
/*************************************************/

endmodule




