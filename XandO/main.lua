-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local rng = require("rng")
local colors = require("colorsRGB")
local mylib = require("mylib")
local ai =
    --require("first_space_player")
    --require("random_impact_player")
    require("minimax_player")

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local board = {} -- logic representation of game board
local mainSquares = {} -- game board buttons to deal with UI

local subBoards = {}
local subSquares = {}
local lastSubMove = nil

local players = {
    {name="X", human=true, value=1, wins=0},
    {name="O", human=true, value=-1, wins=0},
}
local player = 1
local gameCount = 0
local state -- 'waiting', 'thinking' 'over'

local gap = 6 -- gap between cells and margins
local size = (math.min(display.contentWidth, display.contentHeight) - 4*gap) / 3

-- place background and center it
local bg = display.newImageRect(backGroup,"assets/images/background.png", 444, 794)
bg.x = display.contentCenterX
bg.y = display.contentCenterY

-- screen elements
local turnText -- display name of current player
local titleText --
local statsText
local gameOverBackground, gameOverText
local resetBoard, move, checkMove

-----------------------------------------------------------------------------------------
-- audio setup
-----------------------------------------------------------------------------------------
local tapSound, winSound, buttonSound

audio.reserveChannels( 3 )

-- Reduce the overall volume of the channel
local bgMusic = audio.loadStream( "assets/audio/bgMusic.mp3" )

audio.setVolume( 0, { channel=1 } )
audio.setVolume( 0, { channel=2 } )
audio.setVolume( 0, { channel=3 } )
-- audio.play( bgMusic, { channel=1, loops=-1 } )

-----------------------------------------------------------------------------------------
-- game ui and playing functions
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

-- function to draw a line from (x1,y2) to (x2,y2) using center as origin
-- with color `color` (default black) and line width `width` (default 8)
local function drawLine(x1, y1, x2, y2, color, width)
    print("Line from (".. x1..","..y1..") to (".. x2..","..y2..")")
	local line = display.newLine(backGroup, 
		display.contentCenterX + x1*size,  display.contentCenterY + y1*size, 
		display.contentCenterX + x2*size,  display.contentCenterY + y2*size 
	)

    color = color or "black"
	line:setStrokeColor(colors.RGB(color))

    width = width or 8
    line.strokeWidth = width
end


local function displayMessage(message)
	gameOverBackground = display.newRect(mainGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
    gameOverBackground.x = display.contentCenterX
    gameOverBackground.y = display.contentCenterY
    gameOverBackground:setFillColor(0)
    gameOverBackground.alpha = 0.5

    gameOverText = display.newText(mainGroup, message, 100, 200, "assets/fonts/Bangers.ttf", 40)
    gameOverText.x = display.contentCenterX
    gameOverText.y = display.contentCenterY - size
    gameOverText:setFillColor(colors.RGB("white"))
    timer.performWithDelay( 2500, resetBoard )
end


local function nextPlayer(value)

    player = value or (player%2 + 1)

    turnText.text = players[player].name .. "'s Turn"
    turnText.x = display.contentCenterX + (player*2-3)*size

    state = players[player].human and 'waiting' or 'thinking'

    if state == 'thinking' then
        local result = ai.move(board, players, player)
        move(result)
    end
end


move = function(k)
    -- get square linked to current event
    local square = mainSquares[k]

    local filename = "assets/images/"..players[player].name..".png"
    local symbol = display.newImageRect(mainGroup, filename, size-4*gap, size-4*gap)
    symbol.x = square.rect.x
    symbol.y = square.rect.y
    square.symbol = symbol
    board[k] = players[player].value

    if mylib.isWin(board) then
        state = "over"
        gameCount = gameCount + 1
        players[player].wins = players[player].wins + 1
        displayMessage("Player "..players[player].name.." Wins")
        audio.play( winSound, { channel=3} )
    elseif mylib.isTie(board) then
        state = "over"
        gameCount = gameCount + 1
        displayMessage("Game Tied")
    else
        nextPlayer()
    end
end

subMove = function(k)
    -- get square linked to current event
    local square = subSquares[k]

    local filename = "assets/images/"..players[player].name..".png"
    local symbol = display.newImageRect(mainGroup, filename, (size/3)-1*gap, (size/3)-1*gap)
    symbol.x = square.rect.x
    symbol.y = square.rect.y
    square.symbol = symbol
    subBoards[k] = players[player].value

    if mylib.isSubWin(subBoards, k) then --Magic Numbers -> {1, 4, 7, 28, 31, 34, 55, 58, 61} if x =< & < x + 3 or x + 9 =< & < x + 11 or x + 18 <= & < x + 21
        print("Winner winner")
        -- state = "over"
        -- gameCount = gameCount + 1
        -- players[player].wins = players[player].wins + 1
        -- displayMessage("Player "..players[player].name.." Wins")
        -- audio.play( winSound, { channel=3} )
    elseif mylib.isSubTie(subBoards, k) then
        print("A tie tie")
        -- state = "over"
        -- gameCount = gameCount + 1
        -- displayMessage("Game Tied")
    else
        nextPlayer()
    end
end

checkMove = function(event)

    print(players[player].name .."'s move at square " .. event.target.k)
    -- return if current square is not-empty
    if board[event.target.k] ~= 0 then
        print("\t cannot move to non-empty square")
        return false
    end

    -- return if current player is non-human
    if state ~= 'waiting' then
        print("\t computer playing")
        return
    end

    audio.play( tapSound, { channel=2})

    -- place valid move
    move(event.target.k)

end

checkSubMove = function(event)

    print(players[player].name .."'s sub move at sub square " .. event.target.k)
    -- return if current square is not-empty
    if subBoards[event.target.k] ~= 0 then
        print("\t cannot move to non-empty square")
        return false
    end

    -- return if current player is non-human
    if state ~= 'waiting' then
        print("\t computer playing")
        return
    end

    audio.play( tapSound, { channel=2})

    -- place valid move
    subMove(event.target.k)

end


resetBoard = function()
    if gameOverBackground~=nil then
        display.remove(gameOverBackground)
        gameOverText.text = ""
        for _,square in ipairs(mainSquares) do
            display.remove(square.symbol)
            square.symbol = nil
        end
    end

    local tieCount = gameCount - players[1].wins - players[2].wins
    local message = string.format("Games: %3d    %s: %d    %s: %d    tie: %d", gameCount, players[1].name, players[1].wins, players[2].name, players[2].wins, tieCount)
    statsText.text = message

    -- logic representation of game
    board = {}
    for k = 1, 9 do
        board[k] = 0
    end
    subBoards = {}
    for k = 1, 81 do
        subBoards[k] = 0
    end
    nextPlayer(1)
end


local function createBoard()

    --Sub board lines
    for x = 1, 8 do
        drawLine(-1.5 + (x * 0.333),-3/2,-1.5 + (x * 0.333),3/2, "gray", 3)
    end
    for y = 1, 8 do
        drawLine(-3/2,-1.5 + (y * 0.333), 3/2,-1.5 + (y * 0.333), "gray", 3)
    end

    --Big board lines
    drawLine(-1/2, -3/2, -1/2,  3/2)
    drawLine( 1/2, -3/2,  1/2,  3/2)
    drawLine(-3/2, -1/2,  3/2, -1/2)
    drawLine(-3/2,  1/2,  3/2,  1/2)

    mainSquares = {}
    for k = 1, 9 do
        local row, col = mylib.k2rc(k)
        local x = display.contentCenterX + (col-4/2)*size
        local y = display.contentCenterY + (row-4/2)*size
        local rect = display.newRect( uiGroup, x, y, size - gap, size - gap)
        rect.k = k
        rect.alpha = 0.1
        --rect:addEventListener( "tap", checkMove )
        mainSquares[k] = {value=0, rect=rect}
    end

    subSquares = {}
    for k = 1, 81 do
        local row, col = mylib.k2rc3(k)
        local x = display.contentCenterX + (col-10/2)*(size/3)
        local y = display.contentCenterY + (row-10/2)*(size/3)
        local rect = display.newRect( uiGroup, x, y, size/3 - gap, size/3 - gap)
        rect.k = k
        rect.alpha = 0.3
        rect:addEventListener( "tap", checkSubMove )
        subSquares[k] = {value=0, rect=rect}
    end

    turnText = display.newText( mainGroup, "", 0, 0, "assets/fonts/Bangers.ttf", 24)
	turnText:setFillColor( 0, 0, 0 )
    turnText.x = display.contentCenterX - 90
    turnText.y = display.contentCenterY + 230

    titleText = display.newText( mainGroup, "X and O", 0, 0, "assets/fonts/Bangers.ttf", 40)
	titleText:setFillColor( 0, 0, 0 )
    titleText.x = display.contentCenterX
    titleText.y = 0

    statsText = display.newText( mainGroup, "", 0, 0, "assets/fonts/Bangers.ttf", 20)
	statsText:setFillColor( 0, 0, 0 )
    statsText.x = display.contentCenterX
    statsText.y = 0.5*size

    tapSound = audio.loadSound("assets/audio/tapSound.mp3")
    buttonSound = audio.loadSound("assets/audio/buttonSound.mp3")
    winSound = audio.loadSound("assets/audio/winSound.mp3")

    resetBoard()
end

createBoard()