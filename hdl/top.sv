module memory{
    input clk,
    input rst,
    input logic [LEN-1:0]source_addr[1:0],
    input logic [LEN-1:0]dest_addr,
    input logic [2:0]size,
    input logic [2:0]no_of_pims,

    input write_en  //needed?? I think it's needed because the reading to send to PIM and writing to dest will happen in parallel. so we need a control signal. 
    //we should probably send write_en low and then high from the test bench after a certain number of clock cycles
};

  // LEN must be equal to $clog2(MEM_SIZE)

logic [WIDTH-1:0] mem[MEM_SIZE-1:0];
logic [WIDTH-1:0] result[size-1:0];

logic [2*size-1:0][WIDTH-1:0] pimc_in[1:0];

logic [WIDTH-1:0] result[size-1:0];

logic pimc_ready;

//Address- should getting this be combinational or sequential? First thought it should be combinational because it is coming to memory independent of clock
//ChatGPT says memory accesses should be done on clock edge, which makes a lot of sense

always_ff(posedge clk) begin
    if(rst)
        //reset logic- I don't think there's anything to be done here
    else begin
        if(!write_en) begin
            for(int j=0;j<1;j++) begin
                for (int i = 0; i < 2*size - 1; i++) begin
                    pimc_in[j] = mem[source_addr[j] + i];
                end 
            end
        end
    end

end

//note- how about we call PIMs in here? do we need a PIM controller? we can insert PIM-C logic and get result as a local variable.

//do we need any control signals? is there any point where memory is not ready that it needs to send a signal to the PIM-C? 
//the job of memory in this design is only to get addresses and put result in destination memory. so i don't think meory neeeds a ready signal
//will PIM-C need it? if it is not ready, then it shouldn't accept the new address. i can add the pim-c control signal as a local variable and give it as an output of pim-c.
//then internal to pim-c, 

pim_controller(
               .clk(clk), //clock synchronization ensured. so I don't think modules need to be called within an always_ff (i don't think that's valid either)
               .rst(rst), 
               .pimc_in(pimc_in), //contains both inputs
               .no_of_pims(no_of_pims),
               .result(result)
               .ready(pimc_ready)//output from PIM-C-- but does it need to communicate with memory? might need another wrapper here 
);
 
//result_aggregator must be inside PIM-C. PIM-C sends inputs to PIM, which sends inouts to result_aggr, which should send them out to memory via PIM_C. 
//(because result_aggr cannot take inputs from one module and output to another module unless they are all caled and embedded)
PIM-C would look like:
for(i=0, i<no_of_pims,i++) begin
    pim_c #(.ID(i))(.inputs(inputs), .outputs(outputs))
end 

/*result_aggr(.clk(clk),
            .rst(rst),
            .input_from_pim_c,
            .result(result)); */


always_ff(posedge clk) begin

    if(write_en) begin   //do we need this???
        for (int i = 0; i < size - 1; i++) begin
            mem[dest_addr + i]= result[i];
        end
    end
end

endmodule




