local mylib = {}

mylib.k2rc = function(k)
    row = 1 + math.floor((k - 1) /3)
    col = 1 + (k-1) % 3
    return row, col
end

mylib.rc2k = function (row, col)
    return (row-1)*3 + (col-1) + 1
end

return mylib