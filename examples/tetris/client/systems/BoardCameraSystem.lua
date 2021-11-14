local Workspace = game:GetService("Workspace")

local BoardRenderSystem = {}
BoardRenderSystem.priority = -5

function BoardRenderSystem.onUpdate(world)
	world:createQuery():all("tetris"):forEach(function(entity, tetris)
		if not tetris.board then
			return
		end
		local camera = Workspace.CurrentCamera
		local board = tetris.board
		local height, width = board.height, board.width

		local boardPos = entity.Position + Vector3.new(width / 2, height / 2, 0) * 5
		camera.CFrame = CFrame.lookAt(boardPos+Vector3.new(0,0,100), boardPos, Vector3.new(0,1,0))
		camera.CameraType = Enum.CameraType.Scriptable
	end)
end

return BoardRenderSystem
