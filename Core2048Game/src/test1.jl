using ReinforcementLearning
using Flux  # Import Flux for neural network components
using Flux.Optimisers  # Import the optimizers module
include("board.jl")

using .Core2048Game: MBoard, init_board, add_tile!, show, up!, down!, left!, right!, play_game, is_game_over, move!, DIRS

# Define environment
mutable struct Env2048 <: AbstractEnv
    board::MBoard
    current_score::Int
    previous_score::Int
    reward::Int
end

function Env2048()
    board = init_board()
    current_score = board.score
    previous_score = 0
    reward = 0
    Env2048(board, current_score, previous_score, reward)
end

function RLBase.reset!(env::Env2048)
    env.board = init_board()
    env.previous_score = env.current_score
    env.current_score = env.board.score
    env.reward = 0
end

RLBase.state(env::Env2048) = env.board.board
RLBase.state_space(::Env2048) = ArrayProductDomain(fill(0:2^11, 4, 4))
RLBase.action_space(::Env2048) = Base.OneTo(4)  # 1: up, 2: down, 3: left, 4: right
RLBase.legal_action_space(env::Env2048) = Base.OneTo(4)
RLBase.is_terminated(env::Env2048) = is_game_over(env.board)
RLBase.reward(env::Env2048) = env.reward

# Act function with reward shaping
function RLBase.act!(env::Env2048, action::Int)
    direction = DIRS[action]
    previous_score = env.current_score
    move!(env.board, direction)
    add_tile!(env.board)
    
    # Update the current score and calculate reward based on score improvement
    env.current_score = env.board.score
    if is_game_over(env.board)
        env.reward = -1  # Penalize if game is over
    else
        env.reward = env.current_score - previous_score  # Reward score improvements
    end
end

env = Env2048()

n_states = (2^11 + 1)^(4 * 4)

approximator = TabularQApproximator(
    ;n_state = n_states, #length(state_space(env))
    n_action = length(action_space(env)),
)

policy = QBasedPolicy(
learner = MonteCarloLearner(;
approximator=approximator,
kind=EVERY_VISIT,
),
explorer = EpsilonGreedyExplorer(0.01,  warmup_steps=10000, step=1)
)

agent = Agent(
policy = policy,
trajectory = VectorSARTTrajectory(; state=Int, action=Union{Int64,NoOp}, reward=Int, terminal=Bool)
)
# Training Setup

hook = TotalRewardPerEpisode()
runner = run(agent, env, StopAfterEpisode(1000), hook)

# # Training loop
# for _ in 1:5000  # Number of episodes
#     total_reward = 0
#     reset!(env)
#     while !is_terminated(env)
#         action = agent(env)  # Select action using DQN
#         act!(env, action)
#         observe!(agent, env)
#         total_reward += reward(env)
#     end
#     println("Episode reward: ", total_reward)
# end
