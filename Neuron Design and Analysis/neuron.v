
//Flow of code:
//1. Each weight is processed using weightMemory
//2. Each input(myinput) is multipled by corresponding weight
//3. Multiply and accumulate operation then bias addition at end
//4. Activation Function
	
	
	
`include "include.v"

module neuron #(parameter layerNo=0, neuronNo=0,numWeight=784, dataWidth=16, sigmoidSize=10, weightIntWidth=4,actType="sigmoid",biasFile="b_1_0.mif",weightFile="w_1_0.mif")(
    input           clk,
    input           rst,
    input [dataWidth-1:0]   myinput,
    input          myinputValid,
    input 	       weightValid, //Input weight is a valid weight
	input          biasValid,
	input [31:0]   weightValue, //THe values which will get stored in neuron
	input [31:0]   biasValue,
	input [31:0]   config_layer_num,
	input [31:0]   config_neuron_num,
    output [dataWidth-1:0]   out,
	output  reg      outvalid
	);
	
	//dataWidth -> It is the width of the data which is coming to each neuron and it is the width of the data which is going out of each neuron also okay so we have defined it to be 16 here but we can change it 
	//weight as well as input data will be represented using 16 bit
	//weightIntWidth -> Out of this datawidth (16 bit) how many bits are representing the integer part of the weight 
	//Here weightIntWidth=1(dummy value) so one bit for integer part and this is a signed representation and that automatically says that it is always a positive number so it has to be always 0 
	//If we put weightIntWidth=4 there , that means 1 bit for sign and 3 bits for actual magnitude for the weight
	
	//how many bits for integer how many bits for fractional part can be different for the inputs and the weights
	parameter addressWidth = $clog2(numWeight); //addressWidth is Log base2 of (number of weights) 
	
	reg         wen;
	wire        ren;
	reg [addressWidth-1:0] w_addr;
	reg [addressWidth:0] r_addr;//read address has to reach until numWeight hence width is 1 bit more

	reg [dataWidth-1:0] w_in;
	wire [dataWidth-1:0] w_out;
	
	reg [2*dataWidth-1:0] mul;
	reg [2*dataWidth-1:0] sum;
	reg [2*dataWidth-1:0] bias;
	
	reg [31:0]    biasReg[0:0];
	reg          weight_valid;
	reg          mult_valid;
	wire         mux_valid;
	reg          sigValid;
	
	wire [2*dataWidth:0] comboAdd;
	wire [2*dataWidth:0] BiasAdd;
	reg  [dataWidth-1:0] myinputd;
	
	reg muxValid_d;
	reg muxValid_f;
	reg addr=0;
	
	//Loading weight values into the Memory
	
	//Each neuron will be uniquely identified by 2 parameters, configured  at top:
	//1.layerNo = The layer in which this neuron is present , first layer, 2nd layer etc.
	//2.neuronNo = What is the particular number of this neuron in that layer
	
	always @(posedge clk)
	begin
	   if(rst)
	   begin
	       w_addr <= {addressWidth{1'b1}}; //replication operator, which repeats what's inside{}, addressWidth times, here if adressWidth=4, we get w_addr=4'b1111(4 times)
		   wen <= 0;                       // if rst , w_addr initialised with all 1's , because in below we start with w_addr<= w_addr +1 , so so make it zero in start we have to initialize with all 1
	   end
	   else if(weightValid & (config_layer_num==layerNo) & (config_neuron_num==neuronNo))
	   begin  //This weight bus is a shared bus, among all the neurons , all of them get the same weight value and werightvalid signals but based on config_layer_num and config_neuron_num , a particular neuron is addressed
	      w_in <= weightValue;// Thus after identifying the neuron ; 1.weight value is assigned to it(win) , which further goes to weightMemory(instantiated below)
		  w_addr <= w_addr + 1; //2. write address will be incremented by 1 , { it will start from 0 , as we discussed above}
		  wen <= 1; //3.weightenable will become 1
	   end
	   else
	         wen <= 0;
	end
	// After this is processed by weightmemory(instantiated below), we get the output from weightmemory , that is w_out
	
	
	assign mux_valid = mult_valid;
	assign comboAdd = mul + sum;
	assign BiasAdd  = bias + sum;
	assign ren = myinputValid;
	
	`ifdef pretrained
	   initial
	   begin
	      $readmemb(biasFile,biasReg);
	   end
	   always @(posedge clk)
	   begin
	       bias <= {biasReg[addr][dataWidth-1:0],{dataWidth{1'b0}}};
	   end
	`else
	   always @(posedge clk)
	   begin
		  if(biasValid & (config_layer_num==layerNo) & (config_neuron_num==neuronNo))
		  begin
			  bias <= {biasValue[dataWidth-1:0],{dataWidth{1'b0}}};
		  end
	   end
	`endif
	
	
	always @(posedge clk)
	begin
	    if(rst|outvalid)
		    r_addr <= 0;
	    else if(myinputValid)
		    r_addr <= r_addr + 1;
	end
	
	always @(posedge clk)
	begin
	   mul <= $signed(myinputd) * $signed(w_out); // Now every output of weight memory(w_out) is multiplied by corresponding myinputd(myinput delayed by one clock)
	end // $signed -> For 2's complement signed multiplication
	
	// This is the multiply and accumulate block:
	always @(posedge clk)
	begin
	   //Part1: Reset or outvalid
	   if(rst|outvalid) // Whenever reset comes or whenever this neuron keys out the final ouput for activation
	   sum <=0; // Then this sum will be reset to zero
	   
	   //Part3:Adding bias after all multiplication is done
	   // In the last case when we have done all multiplication and accumulation with the weight , we need to add with the bias value
	   else if((r_addr == numWeight) & muxValid_f) // r_addr(read address) which is the address going to theweight memory , if it's numWeight(max value) and the muxValid_f is falling in same logic( to see later)
	   begin
	       //Case3.1: Checking for overflow
	       if(!bias[2*dataWidth-1] & !sum[2*dataWidth-1] & BiasAdd[2*dataWidth-1]) //If bias and sum are positive and after adding bias to sum, if sign bit becomes 1(negative), overflow
		   begin
		      sum[2*dataWidth-1] <= 1'b0;
			  sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
		   end
		   //Case 3.2: Checking for underflow
		   else if(bias[2*dataWidth-1] & sum[2*dataWidth-1] & !BiasAdd[2*dataWidth-1])//If bias and sum are negative and after addition if sign bit is 0, saturate
		   begin
		      sum[2*dataWidth-1] <= 1'b1;
			  sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}} ;
		   end
		   //Case 3.3: No overflow or undewrflow:
		   else
		       sum <= BiasAdd; // Simply assign the BiasAdd(BiasAdd  = bias + sum; , written above) to sum
	    end
		
	   //Part 2: This is what happens in case of normal multiplication:
	   //one possiblity is that when we do this multiplication and then addition , overflow may happen , or sometimes underflow may happen
	   //comboAdd stores the (current multiplication result added with the previous sum)
		else if(mux_valid)
		begin
		    //Case2.1: Checking for overflow:
		    if(!mul[2*dataWidth-1] & !sum[2*dataWidth-1] & comboAdd[2*dataWidth-1]) //mul[2*dataWidth-1] -> This represents the leftmost bit of mul , if that's zero ( which is the sign bit , remember we're using 2's complement signed rep.) , thus current multiplication mul is +ve , and previous sum has the same notation , so previous sum is also positive 
			begin //comboAdd which represents the current addition b/w this current multiplication and this previous sum ,it' sign bit is 1 ,ie. it is negative , thus we have added 2 positive numbers but the result is coming out to be negative , thus we are having an overflow(the output value is coming greater than what can be represented by this many bits)
			   sum[2*dataWidth-1] <= 1'b0; // So in this case we have to truncate the value of sum , so we are making the sign bit zero ( making it positive)
			   sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};// And making all the remaining bits 1 , so assigning the highest positive value we can assign(remember there was an overflow), so this is the best way we have
			end
			//Case2.2: Checking for underflow:
			else if(mul[2*dataWidth-1] & sum[2*dataWidth-1] & !comboAdd[2*dataWidth-1]) // We are adding two negative numbers and the result is coming out to be positive , this is the case of underflow ( the output number is so small that it can't be represented using this many bits, so we have to lash this to the smallest value
			begin
			     sum[2*dataWidth-1] <= 1'b1; // Making sign bit 1 , ie. making the sum negative
				 sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};// And making all the remaining bits 0 , so assigning the smallest value we can assign(remember there was an underflow), so this is the best way we have
			end
			//Case2.3: No overflow or undewrflow:
			else
			     sum <= comboAdd; // Simply assign the comboAdd(comboAdd = mul + sum; , written above) to sum
        end
    end
    
    always @(posedge clk) //Written with sequential logic, so one clock latency(delay) 
    begin
	    myinputd <= myinput;// So this input is also delayed by one clock
		weight_valid <= myinputValid;
		mult_valid <= weight_valid;
		sigValid  <= ((r_addr == numWeight) & muxValid_f) ? 1'b1 : 1'b0;
        outvalid  <= sigValid;
        muxValid_d <= mux_valid;
        muxValid_f <= !mux_valid & muxValid_d;
    end	
	
	
	Weight_Memory #(.numWeight(numWeight),.neuronNo(neuronNo), .layerNo(layerNo), .addressWidth(addressWidth), .dataWidth(dataWidth), .weightFile(weightFile))
	 WM(
	      .clk(clk),
		  .wen(wen),
		  .ren(ren),
		  .wadd(w_addr),
		  .radd(r_addr),
		  .win(w_in),
		  .wout(w_out)
		  );
		  
		generate //We use generate statement when we have to instantiate the same module multiple times using a for loop but that for loop can only be written inside the generate statement
		// But here we are using the generate statement to selectively instantiate either sigmoid or ReLU
		    if(actType == "sigmoid")// instantiating the sigmoid activation function using sigmoid.v
			begin:siginst
			//Instantiation of ROM for sigmoid
			//We'll be using a look up table to instantiate sigmoid values
			//sigmoid is implemented as a memory and we can define what is the depth of that memory , the deeper it is the better precision i will have , but more resources it will utilise
			// in this code ,at the top we have sigmoidSize=5 , thus we'll have size of sigmloid memory as 2^5= 32 same number of values will be there in the mif file
			   Sig_ROM #(.inWidth(sigmoidSize), .dataWidth(dataWidth)) s1(
                .clk(clk),
                .x(sum[2*dataWidth-1-:sigmoidSize]),// The sum output is going as input to this ROM , We're sending only a part of upper bits here , that is maximumwidth(2*dataWidth-1) - sigmoidSize(whatever is the size of sigmoid) , as according to the depth of sigmoid memory , we'll send that many uppermost bits only
                .out(out) //Output from the ROM will directly represent the sigmoid value for that particular input(mac output added with bias value)
            );
            end
            else
            begin:ReLUinst // instantiating the ReLU activation function using relu.v
               ReLU #(.dataWidth(dataWidth), .weightIntWidth(weightIntWidth)) s1 (
                .clk(clk),
                .x(sum),//We are implementing ReLU using BRAM , so we are feeding the whole of sum into x , as we don't have the issue of lookup table
                .out(out)
            );
            end
        endgenerate

        `ifdef DEBUG
        always @(posedge clk)
        begin
            if(outvalid)
                $display(neuronNo,,,,"%b",out);
        end
        `endif
    endmodule		

//reg [31:0] myreg [255:0]; Each element is 32 bits wide , there are 256 such elements   
			   
			   
/*
main takeaway is irrespective of number of input we make them, sequential we send them only one by one for getting better timing performance as well as to reduce the resource utilization.

2nd Takeaway:For the weight values we generally use a distributed bus the shared bus so that all the neurons are hooked up to the same bus
and by controlling the configuration layer number and neuron number I can address a particular neuron to send the weight value to that particular neuron

whenever we write memory we use the output in sequential format so that it will get implemented using block RAM instead of distributed ram here we can see they're not using sequential we are
using assign statement for this so called the sigmoid ROM which stores a sigmoid value and because of this, this sigmoid memory won't be implemented in block Ram but in distributed RAM but
the size of the sigmoid memory will be quite small 32 bit deep or 64 bit deep so it is actually better to use distributed RAM because in block Ram the smallest block Ram is 18 kilobit so even if we
are not using 18 kilobit the remaining part becomes unused so it is better to use distributed RAM for this activation function but for weight values it is better to use block RAM

now the minor control signals most of them are to manage the pipeline delay because we have one pipeline delay here(w_out) then one pipeline delay here(mul) one pipeline delay(sum) 
here so our valid signal has to be delayed accordingly so that's what most of this logic is doing 
*/

/*
number1  m int  n frac (m+n) bits
number2  k int  j frac (k+j) bits

number1 * number2 result will be the sum of total number of bits (m+n+k+j)

both are in signed representation

2 bit sign will be there 
(m-1) + (k-1) -> integer part
n+j -> fractional part

We can have only one bit of sign as well , then the result will have (m+n+k+j-1) bits in total

That's why we have results of multiplication as 2*datawidth-1 (m+n+k+j-1) {here, (m+n)=(k+j)=datawidth }


And for the sum we'll have:
1 bit sign
sizeof(int part of input) + sizeof(int part of weight) + 1 ->integer part
sizeof(frac part of input) + sizeof(frac part of weight) -> frac part
As a whole this will amount to 2*dataWidth-1


For dataWidth=16 bits , sum will be 32 bits 
Depth of LUT for sigmoid if we are directly feeding the sum there ,will be 2^32
Each entry in the sigmoid , because output of the sigmoid is going as input to next neuron
As far as next neuron is concerned the input is coming from the precious neuron , so the size(width) of the value coming out of this LUT should be my datawidth which is 16 bits
So the size of the memory which we need toward the sigmoid value will be something like (2^32)*16bits which is 4G*2 Bytes for one neuron , which is not a practical thing
We can't do any adjustment to the 16 bits part as it is going as input to the next neuron (datwidth is fixed)
But the depth of the LUT for storing these values can't be this much(2^32) , so we won't be able to directly fit this sum to the activation fxn
instead of that we will take only some most significant bits from this(2^32) and we'll feed it to the activation function , that's what the sigmoidSize is doing above
*/