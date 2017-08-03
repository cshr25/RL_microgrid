# RL microgrid project
This is a project I am working recently. 
The background of the project is that a small group of communication base stations could interconnect with each other and form a microgrid so that they could share load, stored energy (from batteries) and power generation. At the same time, they need to control their load considering the future load and power output so that they would not run out of sotred energy and forced to be shut off.

We proposed a game setting-- that the whole load control process is modeled as a multiple player game, so that each controller could use some conclusions from game theory to come up with a resonable solution without communication. By doing so, we hope to achive a reasonable overall system performance and increase the microgird's robustness.

# Materials
This repository includes codes and simulation models of a communication network microgrid. 
To see the test, one need to download the whole repository in a folder and run the main function in Matlab.

## Main functon:
bytest_adaptive_game_add.m
This is the main function runs the numerical simulation. In this function a simple load-power consumption summation is calculated based on every simulated hour. The outputs are load shaping factors found by controllers and overall battery SoC(stored energy). 

## Load and power generation functions：
Right now they are embeded in main function. Two individual functions describing how they worked were created: solar.m and load2.m

## Mixed game solving function:
gamesolver.m and linearprograming.m
linearprograming function is called during the main fucntion to solve for the mixed game.

The self learning function is added in the main function. I will create an individual learning function so that different RL methods could be applided.

