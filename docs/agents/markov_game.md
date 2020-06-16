## Markov Game

A Markov Game is represented as follows:

Num actions
 - int
An action is represented by
 - An ID (index) (0 < a <= num actions)
 - A String label
Action label
 - String
Num states
 - int
Num features
 - int
Set of states
A state is represented by
 - An ID (index) (0 < a <= num states)
 - A set of features (List<int>)
 - Number of actions available to each player (int)
Start states
 - A number of start states
 - List<int> IDs of the start states
Goal states
 - A number of goal states
 - List<int> IDs of the goal states
Set of transitions
A Transition is represented by
 - A start state (int - ID)
 - Player 1 action (int - ID)
 - Player 2 action (int - ID)
 - Next state (int - ID)
 - Player 1 reward (double)
 - Player 2 reward (double)
 - Number of times that unique transition occurs in the game tree
 