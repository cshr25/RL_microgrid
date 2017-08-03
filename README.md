# RL_microgrid
This repository includes code and simulation models of a communication network microgrid. 
To see the test, one need to download the whole repository in a folder and run the main function in Matlab.

##Main functon:
bytest_adaptive_game_add.m
This is the main function runs the numerical simulation. In this function a simple load-power consumption summation is calculated based on every simulated hour. The outputs are load shaping factors found by controllers and overall battery SoC(stored energy). 

##Load and power generation functions：
Right now they are embeded in main function. Two individual functions describing how they worked were created: solar.m and load2.m

##Mixed game solving function:
gamesolver.m and linearprograming.m
linearprograming function is called during the main fucntion to solve for the mixed game.

The self learning function is added in the main function. I will create an individual learning function so that different RL methods could be applided.

