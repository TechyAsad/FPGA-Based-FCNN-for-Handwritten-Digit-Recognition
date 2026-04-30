import json

dataWidth = 16
dataIntWidth = 1#All inputs are +ve and we just need 1 bit to represent the sign:zero
weightIntWidth = 4# For knowing how many bits in the weightint part we have to know what is the largest weight value, we'll have to run another script for it.
inputFile = "WeightsandBiases.txt"
dataFracWidth = dataWidth-dataIntWidth
weightFracWidth = dataWidth-weightIntWidth
biasIntWidth = dataIntWidth+weightIntWidth# bias is added after multiplying and adding all the input and weight, so in that sum of product term,total number of bits representing the integer part will be the sum of integers representing weight and input, thats why the bias needs to have the same size.
biasFracWidth = dataWidth-biasIntWidth# As we need to keep total dataWidth as 16 only , so the fractional part of bias will be dataWidth(16 here)-biasIntWidth(calculated above)
outputPath = "./w_b/"#The directory where all mif output files are going to get stored.
headerPath = "./"#.h c files so that we may assign weights and biases from the processor to our AXI lite interface

def DtoB(num,dataWidth,fracBits):						#funtion for converting into two's complement format
	if num >= 0:
		num = num * (2**fracBits)
		num = int(num)
		d = num
	else:
		num = -num
		num = num * (2**fracBits)		#number of fractional bits
		num = int(num)
		if num == 0:
			d = 0
		else:
			d = 2**dataWidth - num
	return d

def genWaitAndBias(dataWidth,weightFracWidth,biasFracWidth,inputFile):#The main function
	weightIntWidth = dataWidth-weightFracWidth
	biasIntWidth = dataWidth-biasFracWidth
	myDataFile = open(inputFile,"r")
	weightHeaderFile = open(headerPath+"weightValues.h","w")
	myData = myDataFile.read()
	myDict = json.loads(myData)
	myWeights = myDict['weights']
	myBiases = myDict['biases']
	weightHeaderFile.write("int weightValues[]={")
	for layer in range(0,len(myWeights)):
		for neuron in range(0,len(myWeights[layer])):
			fi = 'w_'+str(layer+1)+'_'+str(neuron)+'.mif'
			f = open(outputPath+fi,'w')
			for weight in range(0,len(myWeights[layer][neuron])):
				if 'e' in str(myWeights[layer][neuron][weight]):
					p = '0'
				else:
					if myWeights[layer][neuron][weight] > 2**(weightIntWidth-1):
						myWeights[layer][neuron][weight] = 2**(weightIntWidth-1)-2**(-weightFracWidth)
					elif myWeights[layer][neuron][weight] < -2**(weightIntWidth-1):
						myWeights[layer][neuron][weight] = -2**(weightIntWidth-1)
					wInDec = DtoB(myWeights[layer][neuron][weight],dataWidth,weightFracWidth)
					p = bin(wInDec)[2:]
				f.write(p+'\n')
				weightHeaderFile.write(str(wInDec)+',')
			f.close()
	weightHeaderFile.write('0};\n')
	weightHeaderFile.close()
	
	biasHeaderFile = open(headerPath+"biasValues.h","w")
	biasHeaderFile.write("int biasValues[]={")
	for layer in range(0,len(myBiases)):
		for neuron in range(0,len(myBiases[layer])):
			fi = 'b_'+str(layer+1)+'_'+str(neuron)+'.mif'
			p = myBiases[layer][neuron][0]
			if 'e' in str(p): #To remove very small values with exponents
				res = '0'
			else:
				if p > 2**(biasIntWidth-1):
					p = 2**(biasIntWidth-1)-2**(-biasFracWidth)
				elif p < -2**(biasIntWidth-1):
					p = -2**(biasIntWidth-1)
				bInDec = DtoB(p,dataWidth,biasFracWidth)
				res = bin(bInDec)[2:]
			f = open(outputPath+fi,'w')
			f.write(res)
			biasHeaderFile.write(str(bInDec)+',')
			f.close()
	biasHeaderFile.write('0};\n')
	biasHeaderFile.close()
			
if __name__ == "__main__":
	genWaitAndBias(dataWidth,weightFracWidth,biasFracWidth,inputFile)