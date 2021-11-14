local UserInputService = game:GetService("UserInputService")

local BoardInputSystem = {}
BoardInputSystem.priority = 0

function BoardInputSystem.onUpdate(world)
	local isLeft = UserInputService:IsKeyDown(Enum.KeyCode.Left) or UserInputService:IsKeyDown(Enum.KeyCode.A)
	local isRight = UserInputService:IsKeyDown(Enum.KeyCode.Right) or UserInputService:IsKeyDown(Enum.KeyCode.D)
	local direction = (isLeft and -1 or 0) + (isRight and 1 or 0)

	local rotateLeft = UserInputService:IsKeyDown(Enum.KeyCode.Q)
	local rotateRight = UserInputService:IsKeyDown(Enum.KeyCode.E)
	local rotation = (rotateLeft and -1 or 0) + (rotateRight and 1 or 0)

	local shouldReset = UserInputService:IsKeyDown(Enum.KeyCode.R)
	local shouldStart = UserInputService:IsKeyDown(Enum.KeyCode.Space)

	local shouldAdvance = UserInputService:IsKeyDown(Enum.KeyCode.S)

	world:createQuery():all("tetris"):forEach(function(entity, tetris)
		if shouldReset then
			world:removeComponent("tetris", entity)
			world:addComponent("tetris", entity, {
				isRunning = false,
			})
		end
		if shouldStart and not tetris.isRunning then
			world:updateComponent("tetris", entity, {
				isRunning = true,
			})
		end
		if not world:getComponent("boardInput", entity) then
			world:addComponent("boardInput", entity, {
				direction = direction,
				rotation = rotation,
				shouldAdvance = shouldAdvance,
			})
			return
		end
		world:setComponent(
			"boardInput",
			entity,
			{ direction = direction, rotation = rotation, shouldAdvance = shouldAdvance }
		)
	end)
end

return BoardInputSystem
