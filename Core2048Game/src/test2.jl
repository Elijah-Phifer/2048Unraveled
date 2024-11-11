using Random

# Define the GridWorld environment
mutable struct GridWorld
    grid_size::Tuple{Int, Int}
    current_state::Tuple{Int, Int}
    goal_state::Tuple{Int, Int}
    terminal_states::Vector{Tuple{Int, Int}}
end

# Initialize environment
function GridWorld()
    grid_size = (4, 4)
    goal_state = (4, 4)
    terminal_states = [(4, 4)]  # Goal state is terminal
    current_state = (1, 1)
    
    return GridWorld(grid_size, current_state, goal_state, terminal_states)
end

# Define possible actions
const ACTIONS = [(0, 1), (1, 0), (0, -1), (-1, 0)]  # right, down, left, up

# Check if state is valid
function is_valid_state(env::GridWorld, state::Tuple{Int, Int})
    return 1 <= state[1] <= env.grid_size[1] && 
           1 <= state[2] <= env.grid_size[2]
end

# Get next state and reward
function step!(env::GridWorld, action::Tuple{Int, Int})
    next_state = (env.current_state[1] + action[1], 
                 env.current_state[2] + action[2])
    
    # Check if next state is valid
    if !is_valid_state(env, next_state)
        next_state = env.current_state
    end
    
    # Update current state
    env.current_state = next_state
    
    # Calculate reward
    reward = -1  # Step penalty
    if next_state == env.goal_state
        reward = 100  # Goal reward
    end
    
    done = next_state in env.terminal_states
    
    return next_state, reward, done
end

# Reset environment
function reset!(env::GridWorld)
    env.current_state = (1, 1)
    return env.current_state
end

# Initialize Q-table
function initialize_q_table(env::GridWorld)
    states = [(i, j) for i in 1:env.grid_size[1], j in 1:env.grid_size[2]]
    q_table = Dict((s, a) => 0.0 for s in states for a in ACTIONS)
    return q_table
end

# Epsilon-greedy policy
function choose_action(q_table::Dict, state::Tuple{Int, Int}, epsilon::Float64)
    if rand() < epsilon
        return rand(ACTIONS)
    else
        return argmax(a -> get(q_table, (state, a), 0.0), ACTIONS)
    end
end

# Training loop
function train_agent(episodes::Int)
    # Hyperparameters
    α = 0.1  # Learning rate
    γ = 0.99  # Discount factor
    ϵ = 0.1  # Epsilon for exploration
    
    env = GridWorld()
    q_table = initialize_q_table(env)
    
    for episode in 1:episodes
        state = reset!(env)
        total_reward = 0
        
        while true
            action = choose_action(q_table, state, ϵ)
            next_state, reward, done = step!(env, action)
            total_reward += reward
            
            # Q-learning update
            best_next_value = maximum(get(q_table, (next_state, a), 0.0) for a in ACTIONS)
            q_table[(state, action)] = (1 - α) * q_table[(state, action)] + 
                                     α * (reward + γ * best_next_value)
            
            state = next_state
            
            if done
                break
            end
        end
        
        if episode % 100 == 0
            println("Episode: $episode, Total Reward: $total_reward")
        end
    end
    
    return q_table
end

# Run the experiment
q_table = train_agent(1000)

# Function to visualize the learned policy
function print_policy(q_table::Dict, env::GridWorld)
    println("\nLearned Policy:")
    for i in 1:env.grid_size[1]
        for j in 1:env.grid_size[2]
            state = (i, j)
            if state in env.terminal_states
                print("G ")  # Goal
                continue
            end
            best_action = argmax(a -> get(q_table, (state, a), 0.0), ACTIONS)
            symbol = if best_action == (0, 1)
                "→"
            elseif best_action == (1, 0)
                "↓"
            elseif best_action == (0, -1)
                "←"
            else
                "↑"
            end
            print("$symbol ")
        end
        println()
    end
end

# Print the learned policy
print_policy(q_table, GridWorld())