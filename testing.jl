module main
include("Core2048Game/src/board.jl")
using .Core2048Game: MBoard, init_board, add_tile!, show, up!, down!, left!, right!

function run()
    board = init_board()
    show(board)
end
end

main.run()