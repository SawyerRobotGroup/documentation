## Overview

Colored Trails is a cooperitive game used to test and study social interaction between players. We are using it to specifically study Human robot interaction.

The game is a 2-player game consisting of an n x m board of colored squares and a common goal square. Each player starts on one of the squares on the board and get a starting hand of k chips. These chips can be used to create a trail from the players starting position to the goal.

In our scenario n,m, and k all equal 4.

### Game Phases

- Set Up

- Exchange Proposal

- Counter Proposal

- Trade

- Score

#### Phase Explaination

##### Set Up

During the Set Up phase, the game board is generated and starting positions and goals are assigned. The hands are then delt and the whole scenario is tested for validity. If it is valid the round begines, otherwise a new scenario is generated.

Validity is determined by 2 criteria adapted from Gal et al. [^1].

- One of the players could reach the goal before or after trading
- Both players can not reach the goal before trading

##### Exchange Proposal and Counter Proposal

During the Exchange Proposal and the Counter Proposal phases, players will propose what chips that they would like to exchange with the other player and may deliberate with the other player.

This will keep going until the players either reach a consensus or one player says they will no longer negotiate.

##### Trade and Score

Once a deal is made, the players chips will be exchanged by the game, the best path is calculated and scores are assigned.

Scoreing is as follows:

- 20 pts for reaching the goal
- 5 less points for each square away from the goal if a player was not able to reach the goal

### Citations

[^1]: Gal, Ya'akov & Grosz, Barbara & Kraus, Sarit & Pfeffer, Avi & Shieber, Stuart. (2005). Colored Trails: A Formalism for Investigating Decision-making in Strategic Environments.
