local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Immutable = require(ReplicatedStorage.tetris.shared.lib.Immutable)

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

function BoardRenderSystem:onUpdate(world)
	world:createQuery():all("board"):forEach(function(entity, boardData)
		local renderState = world:getComponent("boardRenderState", entity)
		if not boardData.isRunning then
			if renderState then
				world:removeComponent("boardRenderState", entity)
			end
			return
		end
		if not renderState then
			local parts = Immutable.full_construct(boardData.layer1, function(color)
				local cell = Instance.new("Part")
				cell.Size = boardData.cellSize
				cell.Anchored = true
				cell.Parent = entity
				cell.Color = color
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
					t.Parent = cell
				end
				return cell
			end)
			for x, partlist in pairs(parts) do
				for y, part in pairs(partlist) do
					local pos = Vector3.new(boardData.cellSize.X * x, boardData.cellSize.Y * y, 0)
					pos += Vector3.new(boardData.cellSize.X, boardData.cellSize.Y, 0) / 2
					pos += boardData.position
					part.CFrame = CFrame.new(pos)
				end
			end
			renderState = world:addComponent("boardRenderState", entity, {
				renderedParts = parts,
			})
		end

		local width = #boardData.layer1
		local height = #boardData.layer1[1]
		for x = 1, width do
			for y = 1, height do
				local part = renderState.renderedParts[x][y]
				local layer1Color = boardData.layer1[x][y]
				local layer2Color = boardData.layer2[x][y]
				local newColor = (layer1Color ~= Color3.new() and layer1Color) or layer2Color
				if newColor ~= part.Color then
					part.Color = newColor
				end
			end
		end
	end)
end

return BoardRenderSystem
