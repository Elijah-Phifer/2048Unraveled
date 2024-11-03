# 2048Unraveled
Predicting Antecedent States in Single-Player Stochastic Puzzle Games

Single-Player Stocastic Puzzle Games offer a special challenge for the player. While the player is trying to solve the problem the puzzle itself is stochastically (randomly) changing. Games of this characteristic include tetris, mine sweeper, and 2048 (which will be the focus of our study). As a matter of fact, solving 2048 is an NP-hard problem due to the stochastic element making it hard to plan for future moves. While it is already known that it is difficult to get a high score in 2048 because of its constantly changing nature, predicting the anteceding state of the game leading to any given state has yet to be explored to my knowledge. 

Because of the properties of the game, it can be said that 2048 is either irreversible or very difficlut to reverse. Games that are "hard to reverse" typically have complex state spaces or randomness that makes it difficult to deduce previous moves or the initial setup. This sliding tile game is difficult to reverse because each move merges tiles in a non-reversible way and new tiles appear randomly, making it nearly impossible to deduce previous states with any certainty. "Non-reversible" in this context highlights that the game’s mechanics inherently lose information with each move, which prevents backtracking or reversing to an exact previous state. However, it could be possible to predict a state (any state) S~(n-1)~ that could have lead to any given current state S~n~.

This work was inspired by work done on reversing conway's game of life which is inherently deterministic -- removing a layer of complexity because the game is based on specific rules that, given the same starting conditions, should lead to predicible states. While reversing the game of life is not reversible, a genetic algorithm could be used to approximate prior states by evolving a population of candidate boards backward. You would define a fitness function based on the similarity between the evolved state and the target state and allow the algorithm to iteratively improve guesses. This method could reveal how closely one can approximate an inverse state by optimizing over generations, providing insight into the "distance" between possible states. Since the Game of Life rules are local, you can apply backtracking to explore configurations that could lead to the current state. By adding constraints (e.g., limiting cell state changes to certain neighborhoods), you can prune the search space. This approach could be highly memory-intensive.

