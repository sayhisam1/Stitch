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
		replicate = true,
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
			world:addSystem(StitchLib.DefaultSystems.ReplicationSystem)
			world:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("ReplicationSystemTestInstance")
			world:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world:getComponent(testComponent, instance)).to.be.ok()
			expect(world:getComponent(testComponent, instance).foo).to.equal("bar")
		end)
		it("should read replicate folder update on client", function()
			world:addSystem(StitchLib.DefaultSystems.ReplicationSystem)
			world:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("ReplicationSystemTestInstance")
			world:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world:getComponent(testComponent, instance)).to.be.ok()
			expect(world:getComponent(testComponent, instance).foo).to.equal("baz")
			expect(world:getComponent(testComponent, instance).momma).to.equal("mia")
		end)
	end)
end
