local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TetrisLib = require(ReplicatedStorage.tetris.shared.lib.TetrisLib)

local BoardInputSystem = {}
BoardInputSystem.priority = 0

function BoardInputSystem:onUpdate(world)
    local isLeft = UserInputService:IsKeyDown(Enum.KeyCode.Left) or UserInputService:IsKeyDown(Enum.KeyCode.A)
    local isRight = UserInputService:IsKeyDown(Enum.KeyCode.Right) or UserInputService:IsKeyDown(Enum.KeyCode.D)
    local direction = (isLeft and -1 or 0) + (isRight and 1 or 0)
    local shouldReset = UserInputService:IsKeyDown(Enum.KeyCode.R)
    local shouldStart = UserInputService:IsKeyDown(Enum.KeyCode.Space)

    world:createQuery():all("board"):forEach(function(entity, boardData)
        if shouldReset then
            world:updateComponent("board", entity, {
                isRunning = false
            })
        end
        if shouldStart and not boardData.isRunning then
            world:updateComponent("board", entity, {
                isRunning = true,
                layer1 = TetrisLib.createLayer(#boardData.layer1, #boardData.layer1[1]),
                layer2 = TetrisLib.createRandomTetriminoLayer(#boardData.layer1, #boardData.layer1[1]),
            })
        end
        if not world:getComponent("boardInput", entity) then
            world:addComponent("boardInput", entity, {
                direction = direction
            })
            return
        end
        world:setComponent("boardInput", entity, {direction = direction})
        
    end)
end


return BoardInputSystem