local FRAMES_BETWEEN_ATTACKS = 120

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TotemSystemServer = {}

TotemSystemServer.name = "TotemSystemServer"

function TotemSystemServer:onCreate()
	self.frameCounter = -1
end

local function distance(totem: Model, player: Player)
	if not player.Character then
		return math.huge
	end
	return (totem:GetPivot().Position - player.Character:GetPivot().Position).Magnitude
end

function TotemSystemServer:onUpdate()
	self.frameCounter = (self.frameCounter + 1) % FRAMES_BETWEEN_ATTACKS
	if self.frameCounter ~= 0 then
		return
	end

	for _, entity: Model in pairs(self.stitch.entityManager:getEntitiesWith("totem")) do
		local totemData = self.stitch.entityManager:getComponent("totem", entity)
		local totemProjectileDamage = totemData.projectileDamage
		local players = Players:GetPlayers()
		local _, closest = next(players)
		for _, player in pairs(players) do
			if distance(entity, player) <= distance(entity, closest) then
				closest = player
			end
		end
		if closest and closest.Character then
			local vecToChar: Vector3 = closest.Character:GetPivot().Position - entity:GetPivot().Position
			local projectile = Instance.new("Part")
			Debris:AddItem(projectile, 10)
			projectile.CFrame = entity:GetPivot() + vecToChar.Unit * 1.5
			projectile.Size = Vector3.new(1, 1, 1)
			projectile.Parent = Workspace
			projectile:ApplyImpulse(vecToChar * 1.5)
			self.stitch.entityManager:addComponent("projectile", projectile, {
				ignoreTouchedList = { entity },
			})

			-- rotate totem to face player
			local cf = entity.PrimaryPart.CFrame
			local playerCf = closest.Character.PrimaryPart.CFrame
			local playerCfObjSpace = cf:ToObjectSpace(playerCf)
			playerCfObjSpace = playerCfObjSpace - Vector3.new(0, playerCfObjSpace.Y, 0)
			local newCf = CFrame.lookAt(cf.Position, cf:ToWorldSpace(playerCfObjSpace).Position, Vector3.new(0, 1, 0))
			entity:SetPrimaryPartCFrame(newCf)
		end
	end
end

function TotemSystemServer:onDestroy() end

return TotemSystemServer
