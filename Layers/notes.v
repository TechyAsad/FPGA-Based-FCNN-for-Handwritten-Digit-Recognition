/*
NN - Number of neurons in particular layer
There is a big shift register staying between each layers and the output from the layer first gets stored in that shift register then after clock it gets shifted to next layer
For this logic to work, the number of neurons in the next layer should be either equal to or less than the number of neurons in previous layer
Before we shift up all the data here the previous layer will be giving new output and our logic will break
In case the number of neurons in next layer has to be less than the previous layer we'll have to modify this logic and add a backpressure like the ready signal from this state machine to the previous logic
In zynet.v , axidataready , in case of backpressure we have to add the logic here, in case of the state machine, this data (axidata) is directly going as input to first layer and axis_in_dat_valid is going as value to our first layer
Data coming out of the last layer (x4_out) , first it's getting latch in hold_data_4

w_1_0 -> 1-> layer number , 0-> neuron number



Without sobel:
Epoch 0: 8225 / 10000
Epoch 1: 8354 / 10000
Epoch 2: 8454 / 10000
Epoch 3: 9296 / 10000
Epoch 4: 9357 / 10000
Epoch 5: 9405 / 10000
Epoch 6: 9397 / 10000
Epoch 7: 9322 / 10000
Epoch 8: 9377 / 10000
Epoch 9: 9427 / 10000
Epoch 10: 9469 / 10000
Epoch 11: 9478 / 10000
Epoch 12: 9451 / 10000
Epoch 13: 9459 / 10000
Epoch 14: 9485 / 10000
Epoch 15: 9463 / 10000
Epoch 16: 9486 / 10000
Epoch 17: 9443 / 10000
Epoch 18: 9470 / 10000
Epoch 19: 9483 / 10000
Epoch 20: 9465 / 10000
Epoch 21: 9468 / 10000
Epoch 22: 9476 / 10000
Epoch 23: 9472 / 10000
Epoch 24: 9467 / 10000
Epoch 25: 9502 / 10000
Epoch 26: 9476 / 10000
Epoch 27: 9478 / 10000
Epoch 28: 9463 / 10000
Epoch 29: 9473 / 10000
Epoch 30: 9506 / 10000
Epoch 31: 9486 / 10000
Epoch 32: 9492 / 10000
Epoch 33: 9491 / 10000
Epoch 34: 9497 / 10000
Epoch 35: 9459 / 10000
Epoch 36: 9489 / 10000
Epoch 37: 9479 / 10000
Epoch 38: 9514 / 10000
Epoch 39: 9499 / 10000
Epoch 40: 9493 / 10000
Epoch 41: 9486 / 10000
Epoch 42: 9486 / 10000
Epoch 43: 9462 / 10000
Epoch 44: 9482 / 10000
Epoch 45: 9487 / 10000
Epoch 46: 9470 / 10000
Epoch 47: 9475 / 10000
Epoch 48: 9492 / 10000
Epoch 49: 9488 / 10000




WIth Sobel:

Epoch 0: 9024 / 10000
Epoch 1: 9200 / 10000
Epoch 2: 9275 / 10000
Epoch 3: 9331 / 10000
Epoch 4: 9382 / 10000
Epoch 5: 9413 / 10000
Epoch 6: 9405 / 10000
Epoch 7: 9416 / 10000
Epoch 8: 9421 / 10000
Epoch 9: 9408 / 10000
Epoch 10: 9445 / 10000
Epoch 11: 9435 / 10000
Epoch 12: 9451 / 10000
Epoch 13: 9470 / 10000
Epoch 14: 9465 / 10000
Epoch 15: 9467 / 10000
Epoch 16: 9462 / 10000
Epoch 17: 9479 / 10000
Epoch 18: 9478 / 10000
Epoch 19: 9479 / 10000
Epoch 20: 9445 / 10000
Epoch 21: 9486 / 10000
Epoch 22: 9457 / 10000
Epoch 23: 9496 / 10000
Epoch 24: 9474 / 10000
Epoch 25: 9493 / 10000
Epoch 26: 9495 / 10000
Epoch 27: 9494 / 10000
Epoch 28: 9502 / 10000
Epoch 29: 9491 / 10000
Epoch 30: 9486 / 10000
Epoch 31: 9495 / 10000
Epoch 32: 9478 / 10000
Epoch 33: 9483 / 10000
Epoch 34: 9504 / 10000
Epoch 35: 9485 / 10000
Epoch 36: 9498 / 10000
Epoch 37: 9480 / 10000
Epoch 38: 9491 / 10000
Epoch 39: 9477 / 10000
Epoch 40: 9503 / 10000
Epoch 41: 9490 / 10000
Epoch 42: 9489 / 10000
Epoch 43: 9489 / 10000
Epoch 44: 9516 / 10000
Epoch 45: 9508 / 10000
Epoch 46: 9488 / 10000
Epoch 47: 9482 / 10000
Epoch 48: 9491 / 10000
Epoch 49: 9497 / 10000


Combined Input(Sobel+RAW : 1568 inputs):

Epoch 0: 8094 / 10000
Epoch 1: 8293 / 10000
Epoch 2: 8353 / 10000
Epoch 3: 8442 / 10000
Epoch 4: 8466 / 10000
Epoch 5: 8460 / 10000
Epoch 6: 9365 / 10000
Epoch 7: 9393 / 10000
Epoch 8: 9411 / 10000
Epoch 9: 9405 / 10000
Epoch 10: 9445 / 10000
Epoch 11: 9428 / 10000
Epoch 12: 9457 / 10000
Epoch 13: 9445 / 10000
Epoch 14: 9437 / 10000
Epoch 15: 9458 / 10000
Epoch 16: 9438 / 10000
Epoch 17: 9453 / 10000
Epoch 18: 9454 / 10000
Epoch 19: 9448 / 10000
Epoch 20: 9437 / 10000
Epoch 21: 9462 / 10000
Epoch 22: 9487 / 10000
Epoch 23: 9465 / 10000
Epoch 24: 9437 / 10000
Epoch 25: 9469 / 10000
Epoch 26: 9464 / 10000
Epoch 27: 9464 / 10000
Epoch 28: 9488 / 10000
Epoch 29: 9499 / 10000
Epoch 30: 9478 / 10000
Epoch 31: 9484 / 10000
Epoch 32: 9478 / 10000
Epoch 33: 9485 / 10000
Epoch 34: 9473 / 10000
Epoch 35: 9495 / 10000
Epoch 36: 9483 / 10000
Epoch 37: 9511 / 10000
Epoch 38: 9500 / 10000
Epoch 39: 9495 / 10000
Epoch 40: 9511 / 10000
Epoch 41: 9494 / 10000
Epoch 42: 9468 / 10000
Epoch 43: 9514 / 10000
Epoch 44: 9522 / 10000
Epoch 45: 9501 / 10000
Epoch 46: 9509 / 10000
Epoch 47: 9505 / 10000
Epoch 48: 9507 / 10000
Epoch 49: 9486 / 10000


testdata .txt files -> 784 values with a 785th entry , which is representing which digit it is

Verilog Design:

1. Accuracy: 100.000000, Detected number: 7, Expected: 0007
2. Accuracy: 100.000000, Detected number: 2, Expected: 0002
3. Accuracy: 100.000000, Detected number: 1, Expected: 0001
4. Accuracy: 100.000000, Detected number: 0, Expected: 0000
5. Accuracy: 100.000000, Detected number: 4, Expected: 0004
6. Accuracy: 100.000000, Detected number: 1, Expected: 0001
7. Accuracy: 100.000000, Detected number: 4, Expected: 0004
8. Accuracy: 100.000000, Detected number: 9, Expected: 0009
9. Accuracy: 88.888889, Detected number: 6, Expected: 0005
10. Accuracy: 90.000000, Detected number: 9, Expected: 0009
11. Accuracy: 90.909091, Detected number: 0, Expected: 0000
12. Accuracy: 91.666667, Detected number: 6, Expected: 0006
13. Accuracy: 92.307692, Detected number: 9, Expected: 0009
14. Accuracy: 92.857143, Detected number: 0, Expected: 0000
15. Accuracy: 93.333333, Detected number: 1, Expected: 0001
16. Accuracy: 93.750000, Detected number: 5, Expected: 0005
17. Accuracy: 94.117647, Detected number: 9, Expected: 0009
18. Accuracy: 94.444444, Detected number: 7, Expected: 0007
19. Accuracy: 89.473684, Detected number: 8, Expected: 0003
20. Accuracy: 90.000000, Detected number: 4, Expected: 0004
21. Accuracy: 90.476190, Detected number: 9, Expected: 0009
22. Accuracy: 90.909091, Detected number: 6, Expected: 0006
23. Accuracy: 91.304348, Detected number: 6, Expected: 0006
24. Accuracy: 91.666667, Detected number: 5, Expected: 0005
25. Accuracy: 92.000000, Detected number: 4, Expected: 0004
26. Accuracy: 92.307692, Detected number: 0, Expected: 0000
27. Accuracy: 92.592593, Detected number: 7, Expected: 0007
28. Accuracy: 92.857143, Detected number: 4, Expected: 0004
29. Accuracy: 93.103448, Detected number: 0, Expected: 0000
30. Accuracy: 93.333333, Detected number: 1, Expected: 0001
31. Accuracy: 93.548387, Detected number: 3, Expected: 0003
32. Accuracy: 93.750000, Detected number: 1, Expected: 0001
33. Accuracy: 93.939394, Detected number: 3, Expected: 0003
34. Accuracy: 94.117647, Detected number: 4, Expected: 0004
35. Accuracy: 94.285714, Detected number: 7, Expected: 0007
36. Accuracy: 94.444444, Detected number: 2, Expected: 0002
37. Accuracy: 94.594595, Detected number: 7, Expected: 0007
38. Accuracy: 94.736842, Detected number: 1, Expected: 0001
39. Accuracy: 94.871795, Detected number: 2, Expected: 0002
40. Accuracy: 95.000000, Detected number: 1, Expected: 0001
41. Accuracy: 95.121951, Detected number: 1, Expected: 0001
42. Accuracy: 95.238095, Detected number: 7, Expected: 0007
43. Accuracy: 95.348837, Detected number: 4, Expected: 0004
44. Accuracy: 95.454545, Detected number: 2, Expected: 0002
45. Accuracy: 95.555556, Detected number: 3, Expected: 0003
46. Accuracy: 95.652174, Detected number: 5, Expected: 0005
47. Accuracy: 95.744681, Detected number: 1, Expected: 0001
48. Accuracy: 95.833333, Detected number: 2, Expected: 0002
49. Accuracy: 95.918367, Detected number: 4, Expected: 0004
50. Accuracy: 96.000000, Detected number: 4, Expected: 0004
51. Accuracy: 96.078431, Detected number: 6, Expected: 0006
52. Accuracy: 96.153846, Detected number: 3, Expected: 0003
53. Accuracy: 96.226415, Detected number: 5, Expected: 0005
54. Accuracy: 96.296296, Detected number: 5, Expected: 0005
55. Accuracy: 96.363636, Detected number: 6, Expected: 0006
56. Accuracy: 96.428571, Detected number: 0, Expected: 0000
57. Accuracy: 96.491228, Detected number: 4, Expected: 0004
58. Accuracy: 96.551724, Detected number: 1, Expected: 0001
59. Accuracy: 96.610169, Detected number: 9, Expected: 0009
60. Accuracy: 96.666667, Detected number: 5, Expected: 0005
61. Accuracy: 96.721311, Detected number: 7, Expected: 0007
62. Accuracy: 96.774194, Detected number: 8, Expected: 0008
63. Accuracy: 96.825397, Detected number: 9, Expected: 0009
64. Accuracy: 96.875000, Detected number: 3, Expected: 0003
65. Accuracy: 96.923077, Detected number: 7, Expected: 0007
66. Accuracy: 96.969697, Detected number: 4, Expected: 0004
67. Accuracy: 97.014925, Detected number: 6, Expected: 0006
68. Accuracy: 97.058824, Detected number: 4, Expected: 0004
69. Accuracy: 97.101449, Detected number: 3, Expected: 0003
70. Accuracy: 97.142857, Detected number: 0, Expected: 0000
71. Accuracy: 97.183099, Detected number: 7, Expected: 0007
72. Accuracy: 97.222222, Detected number: 0, Expected: 0000
73. Accuracy: 97.260274, Detected number: 2, Expected: 0002
74. Accuracy: 97.297297, Detected number: 9, Expected: 0009
75. Accuracy: 97.333333, Detected number: 1, Expected: 0001
76. Accuracy: 97.368421, Detected number: 7, Expected: 0007
77. Accuracy: 97.402597, Detected number: 3, Expected: 0003
78. Accuracy: 97.435897, Detected number: 2, Expected: 0002
79. Accuracy: 97.468354, Detected number: 9, Expected: 0009
80. Accuracy: 97.500000, Detected number: 7, Expected: 0007
81. Accuracy: 97.530864, Detected number: 7, Expected: 0007
82. Accuracy: 97.560976, Detected number: 6, Expected: 0006
83. Accuracy: 97.590361, Detected number: 2, Expected: 0002
84. Accuracy: 97.619048, Detected number: 7, Expected: 0007
85. Accuracy: 97.647059, Detected number: 8, Expected: 0008
86. Accuracy: 97.674419, Detected number: 4, Expected: 0004
87. Accuracy: 97.701149, Detected number: 7, Expected: 0007
88. Accuracy: 97.727273, Detected number: 3, Expected: 0003
89. Accuracy: 97.752809, Detected number: 6, Expected: 0006
90. Accuracy: 97.777778, Detected number: 1, Expected: 0001
91. Accuracy: 97.802198, Detected number: 3, Expected: 0003
92. Accuracy: 97.826087, Detected number: 6, Expected: 0006
93. Accuracy: 97.849462, Detected number: 9, Expected: 0009
94. Accuracy: 97.872340, Detected number: 3, Expected: 0003
95. Accuracy: 97.894737, Detected number: 1, Expected: 0001
96. Accuracy: 97.916667, Detected number: 4, Expected: 0004
97. Accuracy: 97.938144, Detected number: 1, Expected: 0001
98. Accuracy: 97.959184, Detected number: 7, Expected: 0007
99. Accuracy: 97.979798, Detected number: 6, Expected: 0006
100. Accuracy: 98.000000, Detected number: 9, Expected: 0009
Accuracy: 98.000000
run: Time (s): cpu = 00:00:03 ; elapsed = 00:00:17 . Memory (MB): peak = 813.652 ; gain = 21.164



*/