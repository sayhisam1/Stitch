local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local StitchLib = require(ReplicatedStorage.Packages.Stitch)
local Stitch = StitchLib.Stitch.new()
StitchLib.DefaultSystems.Replication(Stitch)
StitchLib.DefaultSystems.Roact(Stitch, Roact)

Stitch:registerPattern(script.Parent.patterns.tetrisBoard)

return Stitch
