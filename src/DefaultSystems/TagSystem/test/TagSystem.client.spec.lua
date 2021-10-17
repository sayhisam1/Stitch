local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Promise = require(script.Parent.Parent.Parent.Parent.Parent.Promise)

local StitchLib = require(script.Parent.Parent.Parent.Parent)

return function()
	if not RunService:IsClient() then
		return
	end
	local world
	local testComponent = {
		name = "tagSystemTest",
		tag = true,
	}
	beforeEach(function()
		world = StitchLib.World.new("test")
	end)
	afterEach(function()
		world:destroy()
	end)

	describe("Tag added", function()
		it("should add component on entity on client", function()
			world:addSystem(StitchLib.DefaultSystems.TagSystem)
			world.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("TagSystemTestInstance", 5)
			expect(instance).to.be.ok()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world.entityManager:getComponent(testComponent, instance)).to.be.ok()
		end)
	end)
	describe("Tag removed", function()
		it("should remove component on tag removal on client", function()
			world:addSystem(StitchLib.DefaultSystems.TagSystem)
			world.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("TagSystemTestInstance", 5)
			expect(instance).to.be.ok()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world.entityManager:getComponent(testComponent, instance)).to.never.be.ok()
		end)
	end)
end
