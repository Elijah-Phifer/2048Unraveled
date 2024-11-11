using ReinforcementLearning
using ReinforcementLearningEnvironments

run(
                  RandomPolicy(),
                  CartPoleEnv(),
                  StopAfterNSteps(1_000),
                  TotalRewardPerEpisode()
              )