using Game2048Core

using Game2048Core: initbboard, add_tile, move, left, right, up, down, randmove, simulate_bb, Bitboard, DIRS, move_and_reward
import Game2048Core as g

# obtain a new board with 2 tiles populated
board = initbboard()

# you can move left right up or down
old_board = board
new_board = move(board, g.left)

if board != old_board
    # this will add a new tile on the board
    board = add_tile(new_board)
end

result = move_and_reward(new_board, g.left)

println(typeof(result))
#ranmove(board)

# function simulat_bb(bitboard::Bitboard=initbboard())
#     while true
#         # Destructure the returned tuple into `new_bitboard` and `reward`
#         new_bitboard, reward = move_and_reward(bitboard, rand([g.left, g.right, g.up, g.down]))
        
#         if new_bitboard != bitboard
#             bitboard = add_tile(new_bitboard)
#             @assert bitboard != new_bitboard
#         else
#             # lost if no move can be made
#             return bitboard, reward
#         end
#     end
# end

# # simulate the game til the end using purely random moves
# simulat_bb(board)