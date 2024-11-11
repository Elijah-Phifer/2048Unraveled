using ReinforcementLearning
include("board.jl")

using .Core2048Game: MBoard, init_board, add_tile!, show, up!, down!, left!, right!, play_game, is_game_over, move!, DIRS

mutable struct Env2048 <: AbstractEnv
    board::MBoard
    current_score::Int
    previous_score::Int
    reward::Int
end

function Env2048()
    board = init_board()
    current_score = board.score
    previous_score = 0  # Initialize previous score as 0 for the first game
    reward = 0
    Env2048(board, current_score, previous_score, reward)
end

function RLBase.reset!(env::Env2048)
    env.board = init_board()
    env.previous_score = env.current_score  # Set previous score to the final score of the last game
    env.current_score = env.board.score
    env.reward = 0  # Reset reward for the new game
end

RLBase.state(env::Env2048) = env.board.board

RLBase.state_space(::Env2048) = ArrayProductDomain(fill(0:2^16, 4, 4))

RLBase.action_space(::Env2048) = Base.OneTo(4)  # Corresponding to "u", "d", "l", "r"

RLBase.legal_action_space(env::Env2048) = Base.OneTo(4)  # All actions are legal in this setup

RLBase.is_terminated(env::Env2048) = is_game_over(env.board)

RLBase.reward(env::Env2048) = env.reward  # Return the reward

function RLBase.act!(env::Env2048, action::Int)
    direction = DIRS[action]
    move!(env.board, direction)
    add_tile!(env.board)
    
    # Update the current score after the move
    env.current_score = env.board.score
    
    # If the game is over, assign the reward based on the score comparison
    if is_game_over(env.board)
        if env.current_score > env.previous_score
            env.reward = 1
        elseif env.current_score == env.previous_score
            env.reward = 0
        else
            env.reward = -1
        end
    end
end
