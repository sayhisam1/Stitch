local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stitch = require(ReplicatedStorage.wizardProjectiles.shared.gameStitch)

for _, component in pairs(script.Parent.components:GetChildren()) do
	Stitch.entityManager:registerComponentTemplate(component)
end
for _, system in pairs(script.Parent.systems:GetChildren()) do
	Stitch:addSystem(system)
end
