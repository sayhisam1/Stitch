local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Promise = require(script.Parent.Parent.Parent.Parent.Parent.Promise)

local StitchLib = require(script.Parent.Parent.Parent.Parent)

return function()
	if not RunService:IsClient() then
		return
	end
	local stitch
	local testComponent = {
		name = "replicationSystemTest",
		replicated = true,
		defaults = {},
	}
	local replicatedFolderName = ("%s:replicated"):format(testComponent.name)
	beforeEach(function()
		stitch = StitchLib.Stitch.new("test")
	end)
	afterEach(function()
		stitch:destroy()
	end)

	describe("Component added", function()
		it("should read replicate folder on client", function()
			stitch:addSystem(StitchLib.Systems.ReplicationSystem)
			stitch.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("ReplicationSystemTestInstance")
			stitch.entityManager:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(stitch.entityManager:getComponent(testComponent, instance).foo).to.equal("bar")
		end)
		it("should read replicate folder update on client", function()
			stitch:addSystem(StitchLib.Systems.ReplicationSystem)
			stitch.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("ReplicationSystemTestInstance")
			stitch.entityManager:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(stitch.entityManager:getComponent(testComponent, instance).foo).to.equal("baz")
			expect(stitch.entityManager:getComponent(testComponent, instance).momma).to.equal("mia")
		end)
	end)
end
