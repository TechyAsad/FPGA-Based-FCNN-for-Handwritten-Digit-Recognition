import mnist_loader
import network2
import json

training_data, validation_data, test_data = mnist_loader.load_data_wrapper()#loading the database and splitting it into training,test and validation data
net = network2.Network([784,30,30,10,10])# Number of neurons in each layer
validation_data = list(validation_data)
training_data = list(training_data)
net.SGD(training_data,30,10,0.1,lmbda=5.0,evaluation_data=validation_data,monitor_evaluation_accuracy=True)#Order: training_data, epochs, mini_batch_size, eta,lmbda
net.save("WeightsandBiases.txt")
#Inside WeightsandBiases.txt: 
#There's an array which specifies number of neurons in each layer
#There's an array for weights of each one.
#There's another array which specifies biases for each one 