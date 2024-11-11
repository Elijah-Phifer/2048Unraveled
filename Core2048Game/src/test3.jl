# Import Core2048Game module
include("board.jl")
using .Core2048Game: MBoard, init_board, add_tile!, show, up!, down!, left!, right!, play_game, is_game_over, move!, DIRS
using CSV, DataFrames

# Define parameters
α = 0.1          # Learning rate
γ = 0.99         # Discount factor
ε_start = 0.1    # Initial exploration rate
ε_decay = 0.999  # Decay rate for ε
ε_min = 0.01     # Minimum exploration rate
num_episodes = 100000  # Extended training

# Q-table: Maps state-action pairs to Q-values
Q = Dict()

# Initialize state representation
function get_state(board::Core2048Game.MBoard)
    return deepcopy(board.board)
end

# Get Q-value for state-action pair, initializing if unseen
function get_q_value(state, action)
    return get(Q, (state, action), 0.1)  # Start with small positive value to encourage exploration
end

# Choose action using ε-greedy policy
function choose_action(state, ε)
    if rand() < ε
        # Exploration: Pick a random direction
        return Core2048Game.DIRS[rand(1:4)]
    else
        # Exploitation: Pick the best action based on Q-values
        q_values = [get_q_value(state, action) for action in Core2048Game.DIRS]
        max_q_value, max_index = findmax(q_values)
        return Core2048Game.DIRS[max_index]
    end
end

# Update Q-value for state-action pair
function update_q_value(state, action, reward, next_state)
    max_next_q = maximum([get_q_value(next_state, a) for a in Core2048Game.DIRS])
    Q[(state, action)] = get_q_value(state, action) + α * (reward + γ * max_next_q - get_q_value(state, action))
end

# Initialize CSV file with headers for progress tracking
CSV.write("2048_agent_results.csv", DataFrame(Episode=Int[], TotalReward=Float64[], Score=Int[]))

# Run training episodes
thousandth_scores = []
global highest_score = 0  # Declare `highest_score` as global
global ε = ε_start        # Declare `ε` as global

for episode in 1:num_episodes
    board = Core2048Game.init_board()
    state = get_state(board)
    total_reward = 0
    episode_high_score = 0

    while !Core2048Game.is_game_over(board)
        action = choose_action(state, ε)
        prev_score = board.score
        Core2048Game.move!(board, action)

        # Reward is based on improvement over the last highest episode score
        reward = max(0, board.score - episode_high_score)
        total_reward += reward
        episode_high_score = max(episode_high_score, board.score)

        next_state = get_state(board)
        update_q_value(state, action, reward, next_state)
        state = next_state

        Core2048Game.add_tile!(board)
    end

    # Decay epsilon over time
    global ε = max(ε_min, ε * ε_decay)  # Update the global `ε`

    # Track scores and rewards every 1000 episodes
    if episode % 1000 == 0
        push!(thousandth_scores, board.score)
        
        # Create a temporary DataFrame and append it to the CSV file
        temp_df = DataFrame(Episode=[episode], TotalReward=[total_reward], Score=[board.score])
        CSV.write("2048_agent_results.csv", temp_df, append=true)
    end
end

# Plot the end scores every 1000 episodes
using Plots
plot(1:1000:num_episodes, thousandth_scores, xlabel="Episode (x1000)", ylabel="End Score", title="Scores Every 1000 Episodes")
