local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tetris = require(ReplicatedStorage.tetris.shared.lib.Tetris)
local Tetrimino = require(ReplicatedStorage.tetris.shared.lib.Tetrimino)

local TetrisSystem = {}
TetrisSystem.priority = 1
TetrisSystem.systemStateComponent = {
	name = "RunningTetrisState",
}

local DEFAULT_HEIGHT = 22
local DEFAULT_WIDTH = 10

function TetrisSystem.onUpdate(world)
	world:createQuery():all("tetris"):forEach(function(entity, tetris)
		if not tetris.isRunning then
			return
		end

		local board = tetris.board
		if not board then
			board = Tetris.createBoard(DEFAULT_WIDTH, DEFAULT_HEIGHT)
		end

		local tetrimino = tetris.tetrimino
		if not tetrimino then
			print("CREATE NEW TETRIMINO!")
			tetrimino = Tetrimino.createRandom()
			tetrimino.offset = Vector2.new(math.floor(board.width / 2), 0)
			if not Tetris.isPlaceable(board, tetrimino) then
				print("GAME OVER!")
				world:removeComponent("tetris", entity)
				world:addComponent("tetris", entity, {
					isRunning = false,
				})
				return
			end
		end

		local stepCount = tetris.stepCount or 0

		-- move piece
		local boardInput = world:getComponent("boardInput", entity)
		if stepCount % 3 == 0 and boardInput then
			if boardInput.direction ~= 0 then
				local nextTetrimino = Tetrimino.move(tetrimino, Vector2.new(boardInput.direction, 0))
				if Tetris.isPlaceable(board, nextTetrimino) then
					tetrimino = nextTetrimino
				end
			end
		end

		-- rotate piece
		if stepCount % 4 == 0 and boardInput then
			if boardInput.rotation ~= 0 then
				local nextTetrimino = Tetrimino.rotate(tetrimino, boardInput.rotation)
				if Tetris.isPlaceable(board, nextTetrimino) then
					tetrimino = nextTetrimino
				end
			end
		end

		-- advance piece down
		if stepCount % 30 == 0 or (stepCount % 2 == 0 and boardInput and boardInput.shouldAdvance) then
			local nextTetrimino = Tetrimino.move(tetrimino, Vector2.new(0, 1))
			if Tetris.isPlaceable(board, nextTetrimino) then
				tetrimino = nextTetrimino
			else
				board = Tetris.placeTetrimino(board, tetrimino)
				tetrimino = world.NONE
			end
		end

		-- only clear rows if board has mutated
		if board ~= tetris.board then
			local nRemoved
			board, nRemoved = Tetris.clearRows(board)
			if nRemoved > 0 then
				print("Cleared", nRemoved, "rows!")
			end
		end

		world:updateComponent("tetris", entity, {
			board = board,
			tetrimino = tetrimino,
			stepCount = (stepCount + 1) % 60,
		})
	end)
end

return TetrisSystem
