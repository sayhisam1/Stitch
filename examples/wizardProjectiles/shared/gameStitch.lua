local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StitchLib = require(ReplicatedStorage.Packages.Stitch)
local Stitch = StitchLib.Stitch.new()

for _, component in pairs(script.Parent.components:GetChildren()) do
	Stitch.entityManager:registerComponentTemplate(component)
end
for _, system in pairs(script.Parent.systems:GetChildren()) do
	Stitch:addSystem(system)
end

return Stitch
