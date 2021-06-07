local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

return function(stitch)
	local function startGame(board)
		local camera = Workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		local boardPos = board:get("position")
		camera.CFrame = CFrame.new(boardPos + Vector3.new(2 * 5, 2 * 10, 40), boardPos + Vector3.new(2 * 5, 2 * 10, 0))

		local character = Players.LocalPlayer.Character
		character.PrimaryPart.Anchored = true

		-- listen to user input
		UserInputService.InputBegan:Connect(function(input: InputObject)
			local direction = nil
			if input.KeyCode == Enum.KeyCode.Left then
				direction = "left"
			elseif input.KeyCode == Enum.KeyCode.Right then
				direction = "right"
			end
			stitch.remoteEvent:FireServer("TetrisSystem", board.uuid, "move", direction)
		end)
	end

	stitch:on("patternConstructed", function(uuid)
		local pattern = stitch:lookupPatternByUuid(uuid)
		if pattern.patternName == "tetrisBoard" then
			startGame(pattern)
		end
	end)
end
