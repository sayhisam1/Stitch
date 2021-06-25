local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Stitch = require(ReplicatedStorage.wizardProjectiles.shared.gameStitch)

for _, component in pairs(script.Parent.components:GetChildren()) do
	Stitch.entityManager:registerComponentTemplate(component)
end
for _, system in pairs(script.Parent.systems:GetChildren()) do
	Stitch:addSystem(system)
end

for i = 1, 100 do
	local totem = ReplicatedStorage.wizardProjectiles.shared.Totem:Clone()
	totem.Parent = Workspace
	totem:SetPrimaryPartCFrame(
		totem.PrimaryPart.CFrame + Vector3.new(math.random(-100, 100), 0, math.random(-100, 100))
	)

	Stitch.entityManager:addComponent("totem", totem)
end
