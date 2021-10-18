local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TetrisLib = require(ReplicatedStorage.tetris.shared.lib.TetrisLib)
local world = require(ReplicatedStorage.tetris.shared.world)

for _, system in pairs(ReplicatedStorage.tetris.client.systems:GetChildren()) do
    world:addSystem(system)
end

local board = Instance.new("Folder")
board.Name = "TetrisBoard"
board.Parent = Workspace

world:addComponent("board", board, {
    layer1 = TetrisLib.createLayer(10, 22),
    layer2 = TetrisLib.createLayer(10, 22),
})

