local mylib = {}

-- math.floor(k-1 / 3) + 1

-----------------------------------------------------------------------------------------
-- coordinate translation functions
-----------------------------------------------------------------------------------------


mylib.k2rc = function (k)
   local row = 1 + math.floor((k-1)/3)
   local col = 1 + (k - 1) % 3

   return row, col
end

mylib.rc2k = function (row, col)
   return (row - 1) * 3 + (col - 1) + 1     
end

mylib.k2rc3 = function (k)
   local row = 1 + math.floor((k-1)/9)
   local col = 1 + (k - 1) % 9

   return row, col
end


-----------------------------------------------------------------------------------------
-- logic functions
-----------------------------------------------------------------------------------------

local function isRowWin(board)
   for r  = 0, 2 do
       if board[r*3+1] ~= 0 and board[r*3+1] == board[r*3+2] and board[r*3+2] == board[r*3+3]  then
           return r + 1
       end
   end
   return 0
end
mylib.isRowWin = isRowWin


local function isColWin(board)
   for c  = 1, 3 do
       if board[c] ~= 0 and board[c] == board[c + 3] and board[c + 3] == board[c + 6]  then
           return c
       end
   end
   return 0
end
mylib.isColWin = isColWin

local function isDiagonalWin(board)
   return board[1] ~= 0 and board[1] == board[5] and board[5] == board[9]
end
mylib.isDiagonalWin = isDiagonalWin


local function isAntiDiagonalWin(board)
   return board[3] ~= 0 and board[3] == board[5] and board[5] == board[7]
end
mylib.isAntiDiagonalWin = isAntiDiagonalWin


local function isWin(board)
   return isRowWin(board) > 0 or isColWin(board) > 0 or isDiagonalWin(board) or isAntiDiagonalWin(board)
end
mylib.isWin = isWin


local function isTie(board)
   for k = 1, 9 do
      if board[k] == 0 then
         return false
      end
   end
   return true
end
mylib.isTie = isTie

local function calcSubBoard(subBoards, k)
   local subBoard = {}
   local magicNumbers = {1,4,7,28,31,34,55,58,61} --Top left position of each sub board
   for _,x in ipairs(magicNumbers) do
      if (x <= k and k < x + 3) or (x + 9 <= k and k < x + 12) or (x + 18 <= k and k < x + 21) then
         for z = 0, 2 do
            for y = 0, 2 do
               subBoard[#subBoard+1] = subBoards[x + y + (9 * z)]
            end
         end
         break
      end
   end
   return subBoard
end
mylib.calcSubBoard = calcSubBoard

local function isSubWin(subBoards, k)
   local subBoard = calcSubBoard(subBoards, k)
   return isRowWin(subBoard) > 0 or isColWin(subBoard) > 0 or isDiagonalWin(subBoard) or isAntiDiagonalWin(subBoard)
end
mylib.isSubWin = isSubWin

local function isSubTie(subBoards, k)
   local subBoard = calcSubBoard(subBoards, k)
   for x = 1, 9 do
      if subBoard[x] == 0 then
         return false
      end
   end
   return true
end
mylib.isSubTie = isSubTie

return mylib