module Core2048Game
    


using Random
#using BenchmarkTools

export MBoard, init_board, add_tile!, up!, down!, left!, right!, move!, show, rand_move, is_game_over, play_game, DIRS

# Set up board mutable struct to have a 4X4 grid filled with 0s and an unsigned 64 bit integer that will used to keep the score

# Define the struct

DIRS = ["u", "d", "l", "r"]
mutable struct MBoard
    board :: Matrix{Int64}
    score :: Int
    game_over :: Bool
    
    # Constructor to initialize the matrix as a 4x4 zeros matrix
    function MBoard(matrix::Matrix{Int64}=zeros(Int, 4, 4), score::Int=0, game_over::Bool=false)
        @assert size(matrix) == (4, 4) "Matrix must be 4x4"
        board = matrix
        new(board, score, game_over)
    end
end



# display(board)

# b.board = [2 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]

# display(board)

# b.board[2,2] = 2

# display(board)

# Function to add a new tile to the board

function add_tile!(board::MBoard, tile::Int=2)
    empty_cells = []
    for i in 1:4
        for j in 1:4
            if board.board[i, j] == 0
                push!(empty_cells, (i, j))
            end
        end
    end
    if length(empty_cells) == 0
        return board
    end
    cell = empty_cells[rand(1:length(empty_cells))]
   # board.board[cell[1], cell[2]] = tile
    add_tile!(board, [cell[1], cell[2]], tile)
    return board
end


function add_tile!(board::MBoard, selected_empty_cell::Array{Int}, tile::Int=2)
    board.board[selected_empty_cell[1], selected_empty_cell[2]] = tile
    return board
end

function add_tile!(board::MBoard)
    add_tile!(board, rand() < 0.1 ? 4 : 2)
    return board
end

function add_tile!(board::MBoard, selected_empty_cell::Array{Int})

    add_tile!(board, selected_empty_cell, rand() < 0.1 ? 4 : 2)
 
    return board
    
end

function init_board()
    board = MBoard()
    add_tile!(board, 2)
    add_tile!(board, 2)
    return board
end



#Move and merge tiles up, down, left, and right

function up!(board::MBoard)
    for j in 1:4
        col = board.board[:, j]
        col = col[col .!= 0]
        for i in 1:length(col)-1
            if col[i] == col[i+1]
                col[i] *= 2
                col[i+1] = 0
                board.score += col[i]
            end
        end
        col = col[col .!= 0]
        board.board[:, j] = vcat(col, zeros(4-length(col)))
    end
    return board
end

function down!(board::MBoard)
    for j in 1:4
        col = reverse(board.board[:, j])
        col = col[col .!= 0]
        for i in 1:length(col)-1
            if col[i] == col[i+1]
                col[i] *= 2
                col[i+1] = 0
                board.score += col[i]
            end
        end
        col = col[col .!= 0]
        board.board[:, j] = vcat(zeros(4-length(col)), reverse(col))
    end
    return board
end

function left!(board::MBoard)
    for i in 1:4
        row = board.board[i, :]
        row = row[row .!= 0]  # Filter out zeros
        # Merge tiles
        for j in 1:(length(row) - 1)
            if row[j] == row[j + 1]
                row[j] *= 2
                row[j + 1] = 0
                board.score += row[j]
            end
        end
        row = row[row .!= 0]  # Filter out zeros again after merging

        # Fill row with trailing zeros to maintain length 4
        padded_row = vcat(row, zeros(Int, 4 - length(row)))
        board.board[i, :] = padded_row
    end
    return board
end

function right!(board::MBoard)
    for i in 1:4
        row = board.board[i, :]
        row = reverse(row[row .!= 0])  # Filter out zeros and reverse
        
        # Merge tiles
        for j in 1:(length(row) - 1)
            if row[j] == row[j + 1]
                row[j] *= 2
                row[j + 1] = 0
                board.score += row[j]
            end
        end
        row = reverse(row[row .!= 0])  # Filter out zeros again after merging and reverse back

        # Fill row with leading zeros to maintain length 4
        padded_row = vcat(zeros(Int, 4 - length(row)), row)
        board.board[i, :] = padded_row
    end
    return board
end

function move!(board::MBoard, direction::String)
    if direction == "u"
        return up!(board)
    elseif direction == "d"
        return down!(board)
    elseif direction == "l"
        return left!(board)
    elseif direction == "r"
        return right!(board)
    else
        return board
    end
end

function show(board::MBoard)
    println("Score: ", board.score)
    for i in 1:4
        println(board.board[i, :])
    end
end

function rand_move(board::MBoard)
    directions = ["u", "d", "l", "r"]
    move!(board, directions[rand(1:4)])
end

function is_game_over(board::MBoard)
    
    for direction in DIRS
        new_board = deepcopy(board)
        move!(new_board, direction)
        if new_board.board != board.board
            return false
        end
    end
    board.game_over = true
    return true
end

function play_game()
    board = init_board()
    show(board)
    while true
        if is_game_over(board)
            show(board)
            println("Game Over!")
            break
        end
        board = rand_move(board)
        add_tile!(board)
    end
end

end