module maxFinder #(parameter numInput=10,parameter inputWidth=16)(
input           i_clk,
input [(numInput*inputWidth)-1:0]   i_data,//maxFinder gets the data,inputWidth is 1D, we are multiplying the data width(inputWidth) with number of neurons(numInput) in the output layer.
input           i_valid,
output reg [31:0]o_data,
output  reg     o_data_valid
);

reg [inputWidth-1:0] maxValue;
reg [(numInput*inputWidth)-1:0] inDataBuffer;
integer counter;

always @(posedge i_clk) //It takes 10 clock cycles(number of neurons in output layer)  to find out the largest value, if we took one clock , the clock performance would have been horrible
begin
    o_data_valid <= 1'b0;                //On every clock it compares
    if(i_valid)
    begin
        maxValue <= i_data[inputWidth-1:0];
        counter <= 1;
        inDataBuffer <= i_data;
        o_data <= 0;
    end
    else if(counter == numInput)
    begin
        counter <= 0;
        o_data_valid <= 1'b1;
    end
    else if(counter != 0)
    begin
        counter <= counter + 1;
        if(inDataBuffer[counter*inputWidth+:inputWidth] > maxValue)
        begin
            maxValue <= inDataBuffer[counter*inputWidth+:inputWidth];
            o_data <= counter;
        end
    end
end

endmodule