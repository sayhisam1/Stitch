local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Promise = require(ReplicatedStorage.Packages.Promise)

local Stitch = require(script.Parent.Parent.Parent.Parent)

return function()
	if not RunService:IsClient() or not RunService:IsRunning() or not Players.LocalPlayer then
		return
	end
	local world
	local testComponent = {
		name = "replicationSystemTest",
		replicate = true,
		defaults = {},
	}
	beforeEach(function()
		world = Stitch.World.new("test")
	end)
	afterEach(function()
		world:destroy()
	end)

	describe("Component added", function()
		it("should read replicate folder on client", function()
			world:addSystem(Stitch.DefaultSystems.ReplicationSystem)
			world:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("ReplicationSystemTestInstance")
			world:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world:getComponent(testComponent, instance)).to.be.ok()
			expect(world:getComponent(testComponent, instance).foo).to.equal("bar")
		end)
		it("should read replicate folder update on client", function()
			world:addSystem(Stitch.DefaultSystems.ReplicationSystem)
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
