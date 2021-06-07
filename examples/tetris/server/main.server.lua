local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stitch = require(ReplicatedStorage.tetris.shared.gameStitch)
local TetrisSystem = require(script.Parent.systems.TetrisSystem)
TetrisSystem(Stitch)

Stitch:getOrCreatePatternByRef("tetrisBoard", workspace)
