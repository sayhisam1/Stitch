local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TetrisLib = require(ReplicatedStorage.tetris.shared.lib.TetrisLib)

local TetrisSystem = {}
TetrisSystem.priority = 1

function TetrisSystem:onUpdate(world)
	world:createQuery():all("board"):forEach(function(entity, boardData)
		if not boardData.isRunning then
			return
		end
		local inputAppliedLayer = boardData.layer2
		if boardData.stepCounter % 4 == 0 then
			local inputDirection = world:getComponent("boardInput", entity).direction
			inputAppliedLayer = TetrisLib.step(boardData.layer2, Vector2.new(inputDirection, 0))
			if not inputAppliedLayer or not TetrisLib.composeLayers(boardData.layer1, inputAppliedLayer) then
				inputAppliedLayer = boardData.layer2
			end
			world:removeComponent("boardInput", entity)
		end

		if boardData.stepCounter == 0 then
			inputAppliedLayer = TetrisLib.step(boardData.layer2, Vector2.new(0, -1))
			if not inputAppliedLayer or not TetrisLib.composeLayers(boardData.layer1, inputAppliedLayer) then
				-- merge down layer 2 into 1
				world:updateComponent("board", entity, {
					layer1 = TetrisLib.composeLayers(boardData.layer1, boardData.layer2),
				})
				inputAppliedLayer = TetrisLib.createRandomTetriminoLayer(#boardData.layer1, #boardData.layer1[1])
			end
		end
		world:updateComponent("board", entity, {
			stepCounter = (boardData.stepCounter + 1) % 10,
			layer2= inputAppliedLayer
		})
	end)
end

return TetrisSystem
