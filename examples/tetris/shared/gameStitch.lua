local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local StitchLib = require(ReplicatedStorage.Packages.Stitch)
local Stitch = StitchLib.Stitch.new()
StitchLib.Systems.Replication(Stitch)
StitchLib.Systems.Roact(Stitch, Roact)

local pattern = require(script.Parent.patterns.tetrisBoard)
Stitch:registerPattern(pattern)

return Stitch
