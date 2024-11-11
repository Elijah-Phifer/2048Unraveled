using Random
using ReinforcementLearningBase

# Define the environment type
mutable struct Game2048Env <: AbstractEnv
    board::Core2048Game.MBoard
end

# Action space - Define possible actions for the environment
DIRS = ["u", "d", "l", "r"]

# Define the state (4x4 board matrix)
function RLBase.state(env::Game2048Env)
    return env.board.board
end

# Define the state space (a 4x4 matrix with tile values 0 to 2^11)
function RLBase.state_space(env::Game2048Env)
    return 0:(2^11)
end

# Define the action space (four directions)
function RLBase.action_space(env::Game2048Env)
    return DIRS
end

# Define the reward as the score after each move
function RLBase.reward(env::Game2048Env)
    return env.board.score
end

# Check if the game is terminated
function RLBase.is_terminated(env::Game2048Env)
    return Core2048Game.is_game_over(env.board)
end

# Reset the environment by initializing a new board
function RLBase.reset!(env::Game2048Env)
    env.board = Core2048Game.init_board()
    return env
end

# Apply an action (move) to the environment
function RLBase.act!(env::Game2048Env, action)
    Core2048Game.move!(env.board, action)
    Core2048Game.add_tile!(env.board)
    return env
end
