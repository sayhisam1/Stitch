local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stitch = require(ReplicatedStorage.Stitch)

local world = Stitch.World.new()
world:addSystem(Stitch.DefaultSystems.ReplicationSystem)
world:addSystem(Stitch.DefaultSystems.TagSystem)

for _, component in pairs(script.Parent.components:GetChildren()) do
    world:registerComponent(component)
end

-- in this example we don't have shared services, but we could add them here if we did
-- for _, system in pairs(script.Parent.systems:GetChildren()) do
--     world:addSystem(system)
-- end

return world
