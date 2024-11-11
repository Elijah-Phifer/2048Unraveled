using Game2048Core: initbboard, add_tile, move, left, right, up, down, randmove, simulate_bb, Bitboard
import Game2048Core as g

println("___________________________________________________")

# obtain a new board with 2 tiles populated
board = initbboard()

display(board)

print("\n")
# you can move left right up or down
old_board = board
new_board = move(board, g.left)

display(new_board)

new_board = move(new_board, g.right)

display(new_board)

new_board = move(new_board, g.up)

display(new_board)

new_board = move(new_board, g.down)

display(new_board)

if new_board != old_board
    # this will add a new tile on the board
    new_board = add_tile(new_board)
end

display(new_board)
# make a random move
# randmove(board)

# simulate the game til the end using purely random moves
# simulate_bb(board)