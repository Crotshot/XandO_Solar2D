local ai = { }

local rng = require("rng")
local mylib = require("mylib")

WON = 100
TIE = 0

--Maximum Search Depth
ai.maxDepth = 9

ai.eval = function(board)
    return 0
end

local debug = false
function ai.search(board, players, player, depth)
    depth = depth or 1
    local indent = string.rep("  ", depth)

    if debug then print(indent .. "SEARCHING at depth "..depth .." as PLAYER "..players[player].name) end

    local bestMove = 1
    local bestScore = -math.huge

    -- check if win
    if mylib.isWin(board) then
        return WON
    end
 
    -- check if tie
    if mylib.isTie(board) then
        return TIE
    end
    
    -- check if search reached max depth
    if depth > ai.maxDepth then
        return 0
    end

    -- iterate over all possible move
    for k = 1, 9 do
        if board[k] == 0 then
            --Make a move
            board[k] = players[player].value
            --Go deeper
            local score, _ = ai.search(board, players, player%2+1, depth + 1)
            --Revert move
            board[k] = 0
            if score > bestScore then --And if the score is better use that move
                 bestScore = score
                 bestMove = k
            end
        end
    end
    if debug then print(indent .. "OPTIMAL MOVE "..bestMove .. " with score " ..bestScore) end
    -- return best score and best 
    return -bestScore, bestMove
end


-- public interface to minimax search function
ai.move = function(board, players, player)

    local _, move = ai.search(board, players, player)

    return move
end

return ai
