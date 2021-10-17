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
		name = "replicationSystemTest",
		replicated = true,
		defaults = {},
	}
	beforeEach(function()
		world = StitchLib.World.new("test")
	end)
	afterEach(function()
		world:destroy()
	end)

	describe("Component added", function()
		it("should read replicate folder on client", function()
			world:addSystem(StitchLib.Systems.ReplicationSystem)
			world.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("ReplicationSystemTestInstance")
			world.entityManager:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(world.entityManager:getComponent(testComponent, instance).foo).to.equal("bar")
		end)
		it("should read replicate folder update on client", function()
			world:addSystem(StitchLib.Systems.ReplicationSystem)
			world.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("ReplicationSystemTestInstance")
			world.entityManager:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(world.entityManager:getComponent(testComponent, instance).foo).to.equal("baz")
			expect(world.entityManager:getComponent(testComponent, instance).momma).to.equal("mia")
		end)
	end)
end
