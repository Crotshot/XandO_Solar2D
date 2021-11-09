local mylib = require("mylib")
local rng = require("rng")
local colors = require("colorsRGB")
--ai1 = require("first_space_player")
--ai2 = require("rule_based_player")
--ai3 = require("minimax_player")

------------------------------------------------------------------
local backGroup = display.newGroup();
local mainGroup = display.newGroup();
local uiGroup = display.newGroup();

local board = {} -- 2D representation of game board
local squares = {} -- 1D representation of game board (ui, events)

local players = {
 {name = "X", human = true, value = 1, wins = 0},
 {name = "O", human = true, value = 1, wins = 0}
}

local player = 1 --Current player
local gameCount = 0
local state -- 'Waiting', 'Thinking', 'Over'

local gap = 6
local size = (math.min(display.contentWidth, display.contentHeight) - 4 * gap) / 3

local background = display.newImageRect(backGroup,"assets/images/background.png",444,794)
background.x = display.contentCenterX
background.y = display.contentCenterY

local titleText, statsText, gameOverText, turnText;
------------------------------------------------------------------
---------------------------Audio----------------------------------
------------------------------------------------------------------


------------------------------------------------------------------
---------------------------Logic----------------------------------
------------------------------------------------------------------

local function isRowWin()
    for r = 1, 3 do
        if board[r][1] ~= 0 and board[r][1] == board[r][2] and board[r][3] == board[r][2] then
            return r
        end
    end
    return 0;
end

local function isColWin()
    for c = 1, 3 do
        if board[1][c] ~= 0 and board[1][c] == board[2][c] and board[3][c] == board[2][c] then
            return c
        end
    end
    return 0;
end

local function isDiagonalWin()
    return board[1][1] ~= 0 and board[1][1] == board[2][2] and board[3][3] == board[2][2]
end

local function isAntiDiagonal()
    return board[1][3] ~= 0 and board[1][3] == board[2][2] and board[3][1] == board[2][2]
end

local function isWin()
    return isRowWin() > 0 or isColWin() > 0 or isDiagonalWin() or isAntiDiagonal()
end

local function isTie()
    for row = 1, 3 do
        for col = 1, 3 do
            if board[row][col] == 0 then return false end
        end
    end
    return true;
end

------------------------------------------------------------------
--------------------UI and Player Features------------------------
------------------------------------------------------------------
display.setStatusBar(display.HiddenStatusBar)

--Function to drawline relative to center screen with given color and width
local function drawLine(x1, y1, x2, y2, color, width)
    local line = display.newLine(backGroup,
    display.contentCenterX + x1, display.contentCenterY + y1,
    display.contentCenterX + x2, display.contentCenterY + y2)

    color = color or "black"
    line:setStrokeColor(colors.RGB(color))
    width = width or 8
    line.strokeWidth = width
end

--Display message for brief interval, dimming game board
--Before reseting level
local function displayMessage(message)

end

local function nextPlayer(value)
    player = value or (player%2) + 1

    state = players[player].human and "waiting" or "thinking"

end

--Carries out a valid move
local function move()

end