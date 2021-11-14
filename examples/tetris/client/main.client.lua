local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local world = require(ReplicatedStorage.tetris.shared.world)

for _, system in pairs(ReplicatedStorage.tetris.client.systems:GetChildren()) do
    world:addSystem(system)
end

local board = Instance.new("Part")
board.Anchored = true
board.CanCollide = false
board.Transparency = 1
board.Name = "TetrisBoard"
board.Parent = Workspace

world:addComponent("tetris", board, {

})

