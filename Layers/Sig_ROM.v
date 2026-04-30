
module Sig_ROM #(parameter inWidth=10, dataWidth=16) (
    input            clk,
	input   [inWidth-1:0] x,
	output  [dataWidth-1:0] out
	);
	// inWidth -> Integer part of input data
	
	reg [dataWidth-1:0] mem [2**inWidth-1:0];
	reg [inWidth-1:0] y;
	
	initial
	begin
	    $readmemb("sigContent.mif",mem);//loading the precalculated values,sigmoidsize=10 , (2^10)(1024) weight values
	end
	
	always @(posedge clk)
	begin
	// x , the input coming here after all multiplication and summation that is again a signed number , but address to a memory is always a +ve number, we can't have -ve address
    //it's more significant bit is 1 so if you are directly feed it that is actually representing a higher address so instead of getting a smaller value out of sigmoid I'll be getting a larger value	  
	  if($signed(x) >= 0)//y is acting like index for reading 
		    y <= x+(2**(inWidth-1));//whenever positive numbers are coming we are adding (2^inwidth) minus 1 which is representing the address the middle address in my sigmoid row
		else                        //inWidth is depth of sigmoidmemory, if it is 10 , this will give 2^9 ,logic->if you represent a sign number using n bits the largest positive number will be 2 to the power of n minus 1
		    y <= x-(2**(inWidth-1));//whenever negative numbers are coming we are subtracting (2^inwidth) minus 1 (this is an unsigned subtraction), so the negative number is just a large number , thus after subtraction , it will be offseted to the beginning of the memory
	end
	
	assign out = mem[y];// We are using an assign statement but that doesn't gurantee it'll be implemented using DRAM(usually done in DRAM) , but final decision is subject to Vivado's optimization
	
endmodule