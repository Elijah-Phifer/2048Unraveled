using ReinforcementLearning
using ReinforcementLearningTrajectories

env = RandomWalk1D()

S = collect(state_space(env))

A = collect(action_space(env))

NS = length(S)
NA = length(A)

policy = QBasedPolicy(
           learner = TDLearner(
                   TabularQApproximator(
                       n_state = NS,
                       n_action = NA,
                   ),
                   :SARS
               ),
           explorer = EpsilonGreedyExplorer(0.1)
       )


trajectory = Trajectory(
    ElasticArraySARTSTraces(;
        state = Int64 => (),
        action = Int64 => (),
        reward = Float64 => (),
        terminal = Bool => (),
    ),
    DummySampler(),
    InsertSampleRatioController(),
)

agent = Agent(policy = policy, trajectory = trajectory)

r = run(agent, env, StopAfterNEpisodes(1000), TotalRewardPerEpisode())