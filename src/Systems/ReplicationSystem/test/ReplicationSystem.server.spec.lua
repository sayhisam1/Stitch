local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Promise = require(script.Parent.Parent.Parent.Parent.Parent.Promise)

local StitchLib = require(script.Parent.Parent.Parent.Parent)

return function()
	if not RunService:IsServer() then
		return
	end
	-- skip test if no players
	wait(1)
	local clientTestsEnabled = false
	if #Players:GetPlayers() >= 1 then
		clientTestsEnabled = true
	end
	local invokeClientTest = require(ReplicatedStorage.StitchTests.invokeClientTest)
	local stitch
	local instance
	local testComponent = {
		name = "replicationSystemTest",
		replicated = true,
		defaults = {
			foo = "bar",
		},
	}
	local replicatedFolderName = ("%s:replicated"):format(testComponent.name)
	beforeEach(function()
		stitch = StitchLib.Stitch.new("test")
		instance = Instance.new("Folder")
		instance.Name = "ReplicationSystemTestInstance"
		instance.Parent = Workspace
	end)
	afterEach(function()
		stitch:destroy()
		instance:destroy()
	end)

	describe("Component added", function()
		it("should add replicate folder", function()
			stitch:addSystem(StitchLib.Systems.ReplicationSystem)
			stitch.entityManager:registerComponent(testComponent)
			stitch.entityManager:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName)).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo").Value).to.equal("bar")
		end)
		it("should add replicate on existing folder", function()
			stitch.entityManager:registerComponent(testComponent)
			stitch.entityManager:addComponent(testComponent, instance)
			stitch:addSystem(StitchLib.Systems.ReplicationSystem)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName)).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo").Value).to.equal("bar")
		end)
		it("should update replicate on component update", function()
			stitch:addSystem(StitchLib.Systems.ReplicationSystem)
			stitch.entityManager:registerComponent(testComponent)
			stitch.entityManager:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName)).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo").Value).to.equal("bar")
			local foo = instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")
			stitch.entityManager:updateComponent(testComponent, instance, {
				foo = "baz",
				momma = "mia",
			})
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo").Value).to.equal("baz")
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")).to.equal(foo)
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("momma").Value).to.equal("mia")
			stitch.entityManager:setComponent(testComponent, instance, {})
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")).to.never.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("momma")).to.never.be.ok()
		end)
	end)
	describe("Component removed", function()
		it("should remove replicate folder", function()
			stitch:addSystem(StitchLib.Systems.ReplicationSystem)
			stitch.entityManager:registerComponent(testComponent)
			stitch.entityManager:addComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName)).to.be.ok()
			stitch.entityManager:removeComponent(testComponent, instance)
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.never.be.ok()
			expect(instance:FindFirstChild(replicatedFolderName)).to.never.be.ok()
		end)
	end)
	if clientTestsEnabled then
		describe("client tests", function()
			it("should read replicate folder on client", function()
				stitch:addSystem(StitchLib.Systems.ReplicationSystem)
				stitch.entityManager:registerComponent(testComponent)
				stitch.entityManager:addComponent(testComponent, instance)
				Promise.fromEvent(RunService.Heartbeat):await()
				Promise.fromEvent(RunService.Heartbeat):await()
				expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
				expect(instance:FindFirstChild(replicatedFolderName)).to.be.ok()
				expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")).to.be.ok()
				expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo").Value).to.equal("bar")
				invokeClientTest(
					{ script.Parent["ReplicationSystem.client.spec"] },
					nil,
					{ testNamePattern = "should read replicate folder on client" }
				)
			end)
			it("should read replicate folder update on client", function()
				stitch:addSystem(StitchLib.Systems.ReplicationSystem)
				stitch.entityManager:registerComponent(testComponent)
				stitch.entityManager:addComponent(testComponent, instance)
				Promise.fromEvent(RunService.Heartbeat):await()
				Promise.fromEvent(RunService.Heartbeat):await()
				expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
				expect(instance:FindFirstChild(replicatedFolderName)).to.be.ok()
				expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo")).to.be.ok()
				expect(instance:FindFirstChild(replicatedFolderName):FindFirstChild("foo").Value).to.equal("bar")
				stitch.entityManager:updateComponent(testComponent, instance, {
					foo = "baz",
					momma = "mia",
				})
				Promise.fromEvent(RunService.Heartbeat):await()
				Promise.fromEvent(RunService.Heartbeat):await()
				invokeClientTest(
					{ script.Parent["ReplicationSystem.client.spec"] },
					nil,
					{ testNamePattern = "should read replicate folder update on client" }
				)
			end)
		end)
	end
end
