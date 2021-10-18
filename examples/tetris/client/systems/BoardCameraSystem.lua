local Workspace = game:GetService("Workspace")

local BoardRenderSystem = {}
BoardRenderSystem.priority = -5

function BoardRenderSystem:onUpdate(world)
	world:createQuery():all("board"):forEach(function(entity, boardData)
		local camera = Workspace.CurrentCamera
		local width = #boardData.layer1
		local height = #boardData.layer1[1]
		local boardPos = boardData.position + Vector3.new(width / 2, height / 2, 0) * boardData.cellSize + Vector3.new(0,5,0)
		camera.CFrame = CFrame.lookAt(boardPos+Vector3.new(0,0,85), boardPos, Vector3.new(0,1,0))
		camera.CameraType = Enum.CameraType.Scriptable
	end)
end

return BoardRenderSystem
