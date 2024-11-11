using ReinforcementLearning

Base.@kwdef mutable struct LotteryEnv <: AbstractEnv
    reward::Union{Nothing, Int} = nothing
end


struct LotteryAction{a}
    function LotteryAction(a)
        new{a}()
    end
end

RLBase.action_space(env::LotteryEnv) = LotteryAction.([:PowerRich, :MegaHaul, nothing])

RLBase.reward(env::LotteryEnv) = env.reward

RLBase.state(env::LotteryEnv, ::Observation, ::DefaultPlayer) = !isnothing(env.reward)

RLBase.state_space(env::LotteryEnv) = [false, true]

RLBase.is_terminated(env::LotteryEnv) = !isnothing(env.reward)

RLBase.reset!(env::LotteryEnv) = env.reward = nothing

#game logic:

function RLBase.act!(x::LotteryEnv, action)
    if action == LotteryAction(:PowerRich)
        x.reward = rand() < 0.01 ? 100_000_000 : -10
    elseif action == LotteryAction(:MegaHaul)
        x.reward = rand() < 0.05 ? 1_000_000 : -10
    elseif action == LotteryAction(nothing)
        x.reward = 0
    else
        @error "unknown action of $action"
    end
end

env = LotteryEnv()

#RLBase.test_runnable!(env)


# n_episodes = 10
# for _ in 1:n_episodes
#     reset!(env)
#     while !is_terminated(env)
#         action = rand(action_space(env))
#         act!(env, action)
#         println("Action: $action, Reward: $(reward(env))")
#     end
# end




#RLCore.forward(p.learner.approximator, 1, 1) # Q(s, a)
#RLCore.forward(p.learner.approximator, 1) # Q(s, a) for all a

wrapped_env = ActionTransformedEnv(
           StateTransformedEnv(
               env;
               state_mapping=s -> s ? 1 : 2,
               state_space_mapping = _ -> Base.OneTo(2)
           );
           action_mapping = i -> action_space(env)[i],
           action_space_mapping = _ -> Base.OneTo(3),
       )

# LotteryEnv |> StateTransformedEnv |> ActionTransformedEnv


#plan!(p, env)



p = QBasedPolicy(
           learner = TDLearner(
               TabularQApproximator(
                   n_state = length(state_space(env)),
                   n_action = length(action_space(env)),
               ), :SARS
           ),
           explorer = EpsilonGreedyExplorer(0.1)
       )


#plan!(p, wrapped_env)

h = TotalRewardPerEpisode()

run(p, wrapped_env, StopAfterNEpisodes(1_000), h)

#using Plots

#plot(hook.rewards)
