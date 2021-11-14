local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matrices = require(ReplicatedStorage.tetris.shared.lib.Matrices)
local Tetris = require(ReplicatedStorage.tetris.shared.lib.Tetris)

local BoardRenderSystem = {}
BoardRenderSystem.stateComponent = {
	name = "boardRenderState",
	defaults = {
		renderedParts = {},
	},
	destructor = function(entity, data)
		for _, col in pairs(data.renderedParts) do
			for _, part in pairs(col) do
				part:Destroy()
			end
		end
	end,
}
BoardRenderSystem.priority = 2

local TETRIS_CELL = Instance.new("Part")
TETRIS_CELL.Anchored = true
local texture = Instance.new("Decal")
texture.Texture = "rbxassetid://7769732202"
for _, face in ipairs({
	Enum.NormalId.Top,
	Enum.NormalId.Bottom,
	Enum.NormalId.Left,
	Enum.NormalId.Right,
	Enum.NormalId.Front,
	Enum.NormalId.Back,
}) do
	local t = texture:Clone()
	t.Face = face
	t.Parent = TETRIS_CELL
end

function BoardRenderSystem.onUpdate(world)
	world:createQuery():all("tetris"):except("boardRenderState"):forEach(function(entity, tetris)
		if tetris.isRunning and tetris.board then
			local renderedParts = Matrices.fill(tetris.board.height, tetris.board.width, nil)
			for y = 1, tetris.board.height, 1 do
				for x = 1, tetris.board.width, 1 do
					local newCell = TETRIS_CELL:Clone()
					newCell.Size = Vector3.new(5, 5, 5)
					newCell.CFrame = CFrame.new(5 * (x - 1), 5 * (tetris.board.height - y), 0) + entity.Position
					newCell.Color = tetris.board.gridColor
					newCell.Parent = entity
					renderedParts[y][x] = newCell
				end
			end
			print("ADDED BOARD RENDER STATE")
			world:addComponent("boardRenderState", entity, {
				renderedParts = renderedParts,
			})
		end
	end)

	world:createQuery():all("tetris", "boardRenderState"):forEach(function(entity, tetris, renderState)
		if not tetris.isRunning then
			print("REMOVED BOARD RENDER STATE")
			world:removeComponent("boardRenderState", entity)
			return
		end

		local grid = tetris.board.grid
		if tetris.tetrimino then
			grid = Tetris.placeTetrimino(tetris.board, tetris.tetrimino).grid
		end
		for y = 1, tetris.board.height do
			for x = 1, tetris.board.width do
				local cell = grid[y][x]
				if tetris.board.grid[y][x] and not cell then
					print("ERROR CELL", y, x, tetris.board.grid[y][x], cell, #grid, #grid[y])
				end
				renderState.renderedParts[y][x].Color = cell or tetris.board.gridColor
			end
		end
	end)
end

return BoardRenderSystem
