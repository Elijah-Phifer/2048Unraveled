using ReinforcementLearning


Base.@kwdef mutable struct LotteryEnv <: AbstractEnv
           reward::Union{Nothing, Int} = nothing
       end

Main.LotteryEnv

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


