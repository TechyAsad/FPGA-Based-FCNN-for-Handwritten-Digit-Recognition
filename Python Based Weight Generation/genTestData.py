#Taking mnist.pkl.gz as input and generating those test images in text format
import sys

outputPath = "./testData/"
headerFilePath = "./testData/"

try:
    import cPickle as pickle
except:
    import pickle
import gzip
import numpy as np

dataWidth = 16                    #specify the number of bits in test data
IntSize = 1 #Number of bits of integer portion including sign bit

try:
    testDataNum = int(sys.argv[1])
except:
    testDataNum = 3

def DtoB(num,dataWidth,fracBits):                        #funtion for converting into two's complement format
    if num >= 0:
        num = num * (2**fracBits)
        d = int(num)
    else:
        num = -num
        num = num * (2**fracBits)        #number of fractional bits
        num = int(num)
        if num == 0:
            d = 0
        else:
            d = 2**dataWidth - num
    return d


def load_data():
    f = gzip.open('mnist.pkl.gz', 'rb')         #change this location to the resiprositry where MNIST dataset sits
    try:
        training_data, validation_data, test_data = pickle.load(f,encoding='latin1')
    except:
        training_data, validation_data, test_data = pickle.load(f)
    f.close()
    return (training_data, validation_data, test_data)

def genTestData(dataWidth,IntSize,testDataNum):#if we want to generate file for a particular input we will call this fxn
    dataHeaderFile = open(headerFilePath+"dataValues.h","w")
    dataHeaderFile.write("int dataValues[]={")
    tr_d, va_d, te_d = load_data()
    test_inputs = [np.reshape(x, (1, 784)) for x in te_d[0]]
    x = len(test_inputs[0][0])
    d=dataWidth-IntSize
    count = 0
    fileName = 'test_data.txt'
    f = open(outputPath+fileName,'w')
    fileName = 'visual_data'+str(te_d[1][testDataNum])+'.txt'
    g = open(outputPath+fileName,'w')
    k = open('testData.txt','w')
    for i in range(0,x):
        k.write(str(test_inputs[testDataNum][0][i])+',')
        dInDec = DtoB(test_inputs[testDataNum][0][i],dataWidth,d)
        myData = bin(dInDec)[2:]
        dataHeaderFile.write(str(dInDec)+',')
        f.write(myData+'\n')
        if test_inputs[testDataNum][0][i]>0:
            g.write(str(1)+' ')
        else:
            g.write(str(0)+' ')
        count += 1
        if count%28 == 0:
            g.write('\n')
    k.close()
    g.close()
    f.close()
    dataHeaderFile.write('0};\n')
    dataHeaderFile.write('int result='+str(te_d[1][testDataNum])+';\n')
    dataHeaderFile.close()
        
        
def genAllTestData(dataWidth,IntSize):# IF we want to generate all those 10,000 we will just call this function
    tr_d, va_d, te_d = load_data()
    test_inputs = [np.reshape(x, (1, 784)) for x in te_d[0]]
    x = len(test_inputs[0][0])
    d=dataWidth-IntSize
    for i in range(len(test_inputs)):
        if i < 10:
            ext = "000"+str(i)
        elif i < 100:
            ext = "00"+str(i)
        elif i < 1000:
            ext = "0"+str(i)
        else:
            ext = str(i)
        fileName = 'test_data_'+ext+'.txt'
        f = open(outputPath+fileName,'w')
        for j in range(0,x):
            dInDec = DtoB(test_inputs[i][0][j],dataWidth,d)
            myData = bin(dInDec)[2:]
            f.write(myData+'\n')
        f.write(bin(DtoB((te_d[1][i]),dataWidth,0))[2:]) #This line writes the number at the end to compare wrt our detection in the neural network
        f.close()



if __name__ == "__main__":
    #genTestData(dataWidth,IntSize,testDataNum=0)  #Calling genTestData to generate file for a particular input , testDataNum to specify which test image you want to use, we can give any number b/w 0 to 9999. 
    genAllTestData(dataWidth,IntSize)              #Calling genAllTestData to generate for all those 10,000, this is what we actually need to do
