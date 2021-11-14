local Matrices = require(script.Parent.Matrices)

local Tetris = {}

function Tetris.createBoard(width, height)
	assert(width and width > 0, "width must be greater than 0")
	assert(height and height > 0, "height must be greater than 0")
	local board = {
		width = width,
		height = height,
		grid = Matrices.fill(height, width, nil),
		gridColor = Color3.new(0, 0, 0),
	}

	return board
end

function Tetris.isPlaceable(board, tetrimino)
	for y = 1, 4 do
		local yPos = tetrimino.offset.Y + y
		for x = 1, 4 do
			local cell = tetrimino.template[y][x]
			local xPos = tetrimino.offset.X + x
			if
				cell
				and (yPos < 1 or yPos > board.height or xPos < 1 or xPos > board.width or board.grid[yPos][xPos])
			then
				return false
			end
		end
	end
	return true
end

function Tetris.placeTetrimino(board, tetrimino)
	local newBoard = Tetris.createBoard(board.width, board.height)
	newBoard.grid = Matrices.clone(board.grid)
	for y = 1, 4 do
		local yPos = tetrimino.offset.Y + y
		for x = 1, 4 do
			local cell = tetrimino.template[y][x]
			local xPos = tetrimino.offset.X + x
			if cell then
				newBoard.grid[yPos][xPos] = tetrimino.color
			end
		end
	end
	return newBoard
end

function Tetris.clearRows(board)
	local newBoard = Tetris.createBoard(board.width, board.height)
	newBoard.grid = Matrices.clone(board.grid)
	local rowsCleared = 0
	for y = 1, board.height do
		local row = newBoard.grid[y]
		local isFull = true
		for x = 1, board.width do
			if not row[x] then
				isFull = false
				break
			end
		end
		if isFull then
			rowsCleared = rowsCleared + 1
			for y2 = y, 2, -1 do
				newBoard.grid[y2] = newBoard.grid[y2 - 1]
			end
			newBoard.grid[1] = {}
		end
	end
	return newBoard, rowsCleared
end

return Tetris
