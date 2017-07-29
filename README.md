# RL_microgrid
This project contains code and simulation models of a communication network microgrid. 
To run then, download the whole repository and run main function in Matlab.

Main functon:
bytest_adaptive_game_add.m

Load and power generation functions：
embeded in main function.

Mixed game solving function:
gamesolver_add(?)

The self learning function is in the main function. Next I will create an individual learning function so that different RL methods could be applided.

The objective function needs a lot of comments, working on it...


#### Bullet points:
1. Microgrid electric model muilding in python (simple load balance)
2. Base station controller logic module building and its interface port with different method. Make it universal.
3. RL method application and modeling. Need specify problem space and learning methid.
4. Add NN controller as comparison?
5. Test with different scenarios.
6. Keep or discard game approach? Performance comparison.

To do lists:
1. A folder containing electric model: base station, renewable power source, battery
2. A folder containing different load planning strategies: constant, global optial(require communicatioin), game approach, self_learning
3. Test environment folder: load and renewable power curve and distibution, stored energy requirement
