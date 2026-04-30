//reg [31:0] myreg [255:0]; Each element is 32 bits wide , there are 256 such elements   

`include "include.v"

module Weight_Memory #(parameter numWeight = 3, neuronNo=5,layerNo=1,addressWidth=10,dataWidth=16,weightFile="w_1_15.mif")
      (
	  input clk,
	  input wen,
	  input ren,
	  input [addressWidth-1:0] wadd,
	  input [addressWidth-1:0] radd,
	  input [dataWidth-1:0] win,
	  output reg [dataWidth-1:0] wout);
	  
	  reg [dataWidth-1:0] mem [numWeight-1:0];//memory - datawidth-> width of memory , numWeight -> depth of memory , which is same as number of weights as well as number of inputs
	  
	  //Writing part ( either RAM or ROM): ROM-> Read only , RAM -> Dynamic, both read and write
	  
	  `ifdef pretrained // due to defined as pretrained , it'll act as ROM , else it'll act like RAM
	      initial
		  begin
		      $readmemb(weightFile, mem);// used for initializing memory in verilog , readmemb-> .mif file's content must be in binary format , readmemh -> in hexadecimal format
		  end                            // mem is the 2D memory and we need to store 
	  `else                              // It will read from the weightfile and will initialize this memory, .mif(memory initialization file)
	      always @(posedge clk)    // if not pretrained then the values will be stored in some external circuitry which is like RAM
		  begin
		      if (wen)             //wen ->valid signal , whenever valid signal(wen) is coming , whatever input(win) is coming we'll store it in memory and increment it( incrementing will be done by the external circuitry)        
			  begin
			      mem[wadd] <= win;// wadd-> write address ( address bus) win -> input coming
			  end
		  end
	  `endif
	  
	  //Reading part is RAM , irrespective of `include:
	  
	  always @(posedge clk)
	  begin
	    if (ren)                    // If ren(read enable) is active , it'll just take that value( radd-> read address) and give it out in wout(write out)
        begin
              wout <= mem[radd];
        end			  
	  end  // As it's a sequential circuit we have one clock read latency , weight (wout)value will come only after one clock cycle.
	  // But we trying to infer block RAM , for that we must use sequential modeling .
	  
	  /*
	  // if we use combinational modeling it'll always infer distributed RAM , not block RAM
	  // The modelling will look like:
	  
	  always @(*)
	  begin
	  if(ren)
	  wout = mem[radd];
	  else
	  wout = 0; // TO avoid infered latch
	  end  
	  
	  */
 endmodule

	  
/* Block RAM vs Distributed RAM :

Block RAM (BRAM):
Dedicated on-chip memory blocks inside FPGA fabric
Physically separate from logic (LUTs)
Fixed sizes (e.g., 18Kb, 36Kb blocks depending on FPGA)
Optimized for:
Large storage
High speed
Dual-port access

Intuition : "pre-built memory hardware"

Distributed RAM
Built using LUTs (Look-Up Tables)
No dedicated memory block used
Scattered (“distributed”) across logic fabric

Like: "memory made out of logic gates"

*/
	  
	  