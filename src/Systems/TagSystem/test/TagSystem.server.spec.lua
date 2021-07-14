local CollectionService = game:GetService("CollectionService")
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
	local invokeClientTest = require(ReplicatedStorage.StitchTest.invokeClientTest)
	local stitch
	local instance
	local testComponent = {
		name = "tagSystemTest",
		tagged = true,
	}
	beforeEach(function()
		stitch = StitchLib.Stitch.new("test")
		instance = Instance.new("Folder")
		instance.Name = "TagSystemTestInstance"
		instance.Parent = Workspace
	end)

	describe("Tag added", function()
		it("should add component on entity tag", function()
			stitch:addSystem(StitchLib.Systems.TagSystem)
			stitch.entityManager:registerComponent(testComponent)
			local promise = Promise.fromEvent(CollectionService:GetInstanceAddedSignal("tagSystemTest"))
			CollectionService:AddTag(instance, "tagSystemTest")
			promise:await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
		end)
		it("should add component on existing instance tag", function()
			stitch.entityManager:registerComponent(testComponent)
			local promise = Promise.fromEvent(CollectionService:GetInstanceAddedSignal("tagSystemTest"))
			CollectionService:AddTag(instance, "tagSystemTest")
			promise:await()
			stitch:addSystem(StitchLib.Systems.TagSystem)
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
		end)
	end)
	describe("Tag removed", function()
		it("should remove component on entity tag removal", function()
			stitch:addSystem(StitchLib.Systems.TagSystem)
			stitch.entityManager:registerComponent(testComponent)
			CollectionService:AddTag(instance, "tagSystemTest")
			local promise = Promise.fromEvent(CollectionService:GetInstanceRemovedSignal("tagSystemTest"))
			CollectionService:RemoveTag(instance, "tagSystemTest")
			promise:await()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.never.be.ok()
		end)
	end)
	if clientTestsEnabled then
		describe("client tests", function()
			it("should add component on entity on client", function()
				stitch:addSystem(StitchLib.Systems.TagSystem)
				stitch.entityManager:registerComponent(testComponent)
				local promise = Promise.fromEvent(CollectionService:GetInstanceAddedSignal("tagSystemTest"))
				CollectionService:AddTag(instance, "tagSystemTest")
				promise:await()
				expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
				invokeClientTest(
					{ script.Parent["TagSystem.client.spec"] },
					nil,
					{ testNamePattern = "should add component on entity on client" }
				)
			end)
			it("should remove component on tag removal on client", function()
				stitch:addSystem(StitchLib.Systems.TagSystem)
				stitch.entityManager:registerComponent(testComponent)
				CollectionService:AddTag(instance, "tagSystemTest")
				local promise = Promise.fromEvent(CollectionService:GetInstanceRemovedSignal("tagSystemTest"))
				CollectionService:RemoveTag(instance, "tagSystemTest")
				promise:await()
				expect(stitch.entityManager:getComponent(testComponent, instance)).to.never.be.ok()
				invokeClientTest(
					{ script.Parent["TagSystem.client.spec"] },
					nil,
					{ testNamePattern = "should remove component on tag removal on client" }
				)
			end)
		end)
	end
	afterEach(function()
		stitch:destroy()
		instance:destroy()
	end)
end
