-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--Refactor test conditions to win, change check to win, pass params
--move params to a lib

-- Your code here

local mylib = require("mylib")
local rng = require("rng")
local colors = require("colorsRGB")

local ai = require("first_space_player")
--local ai = require("random_impact_player")
--local ai = require("minimax_player")

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local board = {} -- 2D representation of game board (logic)
local squares = {} -- 1D representation of game board (ui, events)

local players = {
    {name = 'X', human = true, value = 1, wins = 0},
    {name = 'O', human = false, value = -1, wins = 0}
}

local player = 1 -- current player
local gameCount = 0
local state -- 'waiting', 'thinking', 'over'

local gap = 6
local size = (math.min(display.contentWidth, display.contentHeight) - 4 * gap) / 3

local background = display.newImageRect(backGroup, "assets/images/background.png", 444, 794)
background.x = display.contentCenterX
background.y = display.contentCenterY

local gameOverImage
local titleText, statsText, turnText, gameOverText


local resetBoard, move
-----------------------------------------------------------------------------------------
-- audio
-----------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------
-- UI and playing functions
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

-- function to draw line relative to center screen with given color and width
local function drawLine(x1, y1, x2, y2, color, width)
    local line = display.newLine(backGroup,
        display.contentCenterX + x1 * size, display.contentCenterY + y1 * size,
        display.contentCenterX + x2 * size, display.contentCenterY + y2 * size
    )

    color = color or "black"

    line:setStrokeColor(colors.RGB(color))
    
    width = width or 8
    line.strokeWidth = width

end

-- display end of game message for a brief interval, dimming game board
-- before resetting game
local function displayMessage(message)
    gameOverImage.alpha = 0.5
    gameOverText.text = message

    timer.performWithDelay(2500, resetBoard)

end

-- switch to next player by default (or to given value otherwise)
local function nextPlayer(value)
    player = value or (player % 2) + 1
    
    state = players[player].human and "waiting" or "thinking"

    if state == 'thinking' then
        local result = ai.move(board, players, player)
        move(result)
    end

end

-- carries out a valid move
move =  function (k)
    -- determine location of valid move
    local square = squares[k]

    -- update UIand logic representation of board
    local filename = "assets/images/" .. players[player].name .. ".png"
    local symbol = display.newImageRect(mainGroup, filename, size - 4 * gap, size - 4 * gap )
    symbol.x = square.rect.x
    symbol.y = square.rect.y
    square.symbol = symbol
    board[k] = players[player].value

    -- check if game win
    if mylib.isWin(board) then
        state = "over"
        gameCount = gameCount + 1
        players[player].wins = players[player].wins + 1
        displayMessage("Player " .. players[player].name .. " Wins!")

    elseif mylib.isTie(board) then
        state = "over"
        gameCount = gameCount + 1
        displayMessage("Game Tied")
    else
        nextPlayer()
    end

    -- else check if game ite
    -- else switch to next player
end

--processes a tap evemt on the board
-- return false if attempted move is invalid
local function checkMove( event )
    --determine location of tap evet on board
    print(players[player].name .. "'s move at square ".. event.target.k)

    -- current player must be human
    if state ~= "waiting" then
        print("\t not waiting for humna input - ignore my move")
        return false;
    end
    
    -- current square must be empty
    if board[event.target.k] ~= 0 then
        print("\t cannot move to non-empty space - ignore move")
        return false;
    end

    -- implement valid move
    move(event.target.k)
end

-- reset game state ( without unnessary destroying of UI element )
resetBoard = function ()
    -- tidy up UI elements
    gameOverImage.alpha = 0;
    gameOverText.text = ""
    for _, square in ipairs(squares) do
        display.remove(square.symbol)
        square.symbol = nil
    end

    local tieCount = gameCount - players[1].wins - players[2].wins
    local s = string.format("Games: %3d    %s: %d    %s: %d    ties: %d", gameCount, players[1].name, players[1].wins, players[2].name, players[2].wins, tieCount)
    statsText.text = s

    --reset game logic
    board = {}
    for k = 1, 9 do
        board[k] = 0
    end
    nextPlayer(1)
end

local function createBoard()
    -- ceneter board vetically and maxium width
    drawLine(-0.5, - 1.5, - 0.5, 1.5)
    drawLine(0.5, - 1.5,  0.5, 1.5)

    drawLine(-1.5, -0.5, 1.5, -0.5)
    drawLine(-1.5, 0.5, 1.5, 0.5)

    squares = {}

    for k = 1, 9 do
        local row, col = mylib.k2rc(k)
        local x = display.contentCenterX + (col - 4/2) * size
        local y = display.contentCenterY + (row - 4/2) * size
        local rect = display.newRect(uiGroup, x, y, size - gap, size - gap)
        rect.alpha = 0.05
        rect.k = k
        rect:addEventListener("tap", checkMove)
        squares[k] = {rect = rect}

    end

    titleText = display.newText(uiGroup, "X and O", 0, 0, "assets/fonts/Bangers.ttf", 30)
    titleText.x = display.contentCenterX
    titleText.y = display.contentCenterY - 3 * size
    titleText:setFillColor(colors.RGB("moccasin"))

    gameOverImage = display.newRect(mainGroup, 0,0, display.actualContentWidth, display.actualContentHeight)
    gameOverImage.x = display.contentCenterX
    gameOverImage.y = display.contentCenterY
    gameOverImage:setFillColor(colors.RGB("black"))
    gameOverImage.alpha = 0
    
    gameOverText = display.newText(uiGroup, "", 100, 200, "assets/fonts/Bangers.ttf", 50)
    gameOverText.x = display.contentCenterX
    gameOverText.y = display.contentCenterY - size
    gameOverText:setFillColor(colors.RGB("pink"))

    statsText = display.newText(uiGroup, "", 0, 0, "assets/fonts/Bangers.ttf", 25)
    statsText.x = display.contentCenterX
    statsText.y = display.contentCenterY - 2.5 * size
    statsText:setFillColor(colors.RGB("moccasin"))

    

    resetBoard()
end


createBoard()
