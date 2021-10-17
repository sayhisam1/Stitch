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
	local invokeClientTest = require(ReplicatedStorage.StitchTests.invokeClientTest)
	local world
	local instance
	local testComponent = {
		name = "tagSystemTest",
		tagged = true,
	}
	beforeEach(function()
		world = StitchLib.World.new("test")
		instance = Instance.new("Folder")
		instance.Name = "TagSystemTestInstance"
		instance.Parent = Workspace
	end)

	describe("Tag added", function()
		it("should add component on entity tag", function()
			world:addSystem(StitchLib.Systems.TagSystem)
			world.entityManager:registerComponent(testComponent)
			local promise = Promise.fromEvent(CollectionService:GetInstanceAddedSignal("tagSystemTest"))
			CollectionService:AddTag(instance, "tagSystemTest")
			promise:await()
			expect(world.entityManager:getComponent(testComponent, instance)).to.be.ok()
		end)
		it("should add component on existing instance tag", function()
			world.entityManager:registerComponent(testComponent)
			local promise = Promise.fromEvent(CollectionService:GetInstanceAddedSignal("tagSystemTest"))
			CollectionService:AddTag(instance, "tagSystemTest")
			promise:await()
			world:addSystem(StitchLib.Systems.TagSystem)
			expect(world.entityManager:getComponent(testComponent, instance)).to.be.ok()
		end)
	end)
	describe("Tag removed", function()
		it("should remove component on entity tag removal", function()
			world:addSystem(StitchLib.Systems.TagSystem)
			world.entityManager:registerComponent(testComponent)
			CollectionService:AddTag(instance, "tagSystemTest")
			local promise = Promise.fromEvent(CollectionService:GetInstanceRemovedSignal("tagSystemTest"))
			CollectionService:RemoveTag(instance, "tagSystemTest")
			promise:await()
			expect(world.entityManager:getComponent(testComponent, instance)).to.never.be.ok()
		end)
	end)
	if clientTestsEnabled then
		describe("client tests", function()
			it("should add component on entity on client", function()
				world:addSystem(StitchLib.Systems.TagSystem)
				world.entityManager:registerComponent(testComponent)
				local promise = Promise.fromEvent(CollectionService:GetInstanceAddedSignal("tagSystemTest"))
				CollectionService:AddTag(instance, "tagSystemTest")
				promise:await()
				expect(world.entityManager:getComponent(testComponent, instance)).to.be.ok()
				invokeClientTest(
					{ script.Parent["TagSystem.client.spec"] },
					nil,
					{ testNamePattern = "should add component on entity on client" }
				)
			end)
			it("should remove component on tag removal on client", function()
				world:addSystem(StitchLib.Systems.TagSystem)
				world.entityManager:registerComponent(testComponent)
				CollectionService:AddTag(instance, "tagSystemTest")
				local promise = Promise.fromEvent(CollectionService:GetInstanceRemovedSignal("tagSystemTest"))
				CollectionService:RemoveTag(instance, "tagSystemTest")
				promise:await()
				expect(world.entityManager:getComponent(testComponent, instance)).to.never.be.ok()
				invokeClientTest(
					{ script.Parent["TagSystem.client.spec"] },
					nil,
					{ testNamePattern = "should remove component on tag removal on client" }
				)
			end)
		end)
	end
	afterEach(function()
		world:destroy()
		instance:destroy()
	end)
end
