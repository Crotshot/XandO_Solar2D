local ai = { }

local rng = require("rng")
local mylib = require("mylib")

WON = 100
TIE = 0
subWIN = 50
subTIE = 20

--Maximum Search Depth
ai.maxDepth = 4

local debug = false
function ai.search(board, subBoards, players, player, depth, abv, boardLocks)
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

-- check if SUB win/tie
    if mylib.isSubWin(subBoards[abv]) then
        return subWIN
    end
    if mylib.isSubTie(subBoards[abv]) then
        return subTIE
    end

    -- check if search reached max depth
    if depth > ai.maxDepth then
        return 0
    end


    --Calculate all possible moves and loop though them
    --iterate over all possible move
    for k = 1, 81 do
        local grid, box = mylib.k2rc3(k)
        local gridChanged = false
        if subBoards[grid][box] == 0 and (abv == -1 or grid == abv) and not boardLocks[abv] then
            subBoards[grid][box] = players[player].value
            if mylib.isSubWin(subBoards[grid]) or mylib.isSubTie(subBoards[grid]) then
                boardLocks[grid] = true
                gridChanged = true
            end
            --Go deeper
            local score, _ = ai.search(board, subBoards, players, player%2+1, depth + 1, box, boardLocks)
            --Revert move
            subBoards[grid][box] = 0
            if gridChanged then
                boardLocks[grid] = false
            end
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
ai.move = function(board, subBoards, players, player, depth, activeBoardValue, boardLocks)

    local _, move = ai.search(board, subBoards, players, player, depth, activeBoardValue, boardLocks)

    return move
end

return ai