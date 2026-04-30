module ReLU  #(parameter dataWidth=16,weightIntWidth=4) (
    input           clk,
    input   [2*dataWidth-1:0]   x,
    output  reg [dataWidth-1:0]  out
);
//We are implementing ReLU using BRAM , so we are feeding the whole of sum into x , as we don't have the issue of lookup table
//In ReLU there is no upperbound , but in hardware we have a limit
//Moreover x(sum) is 2*dataWidth in size , while out's size is dataWidth and we can't just assign the uppermost bits to out.
always @(posedge clk)
begin
    if($signed(x) >= 0)// Composition of x is in this order: signbit  weightIntWidth inputIntWidth weightFrac inputFract
    begin              //We have to make sure that output integer width is same as inputIntWidth(input Integer Width), when there is no overflow
	                   //If there are nonzero elements in this portion "signbit weightIntWidth" of output , there is a probablity of overflow, that is what we are checking below
        if(|x[2*dataWidth-1-:weightIntWidth+1]) //over flow to sign bit of integer part
            out <= {1'b0,{(dataWidth-1){1'b1}}}; //positive saturate(maximum positive value which can be stored
        else
            out <= x[2*dataWidth-1-weightIntWidth-:dataWidth];//If no overflow happens: We are storing only this part "inputIntWidth inputFract"
    end
    else 
        out <= 0;//If input is negative , output is zero.    
end

endmodule