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
		tag = true
	}
	beforeEach(function()
		world = StitchLib.World.new("test")
		instance = Instance.new("Folder")
		instance.Name = "TagSystemTestInstance"
		instance.Parent = Workspace
	end)

	describe("Tag added", function()
		it("should add component on entity tag", function()
			world:addSystem(StitchLib.DefaultSystems.TagSystem)

			Promise.fromEvent(RunService.Heartbeat):await()
			world:registerComponent(testComponent)
			CollectionService:AddTag(instance, "tagSystemTest")
			Promise.fromEvent(RunService.Heartbeat):await()

			expect(CollectionService:HasTag(instance, "tagSystemTest")).to.be.ok()
			expect(world:getComponent(testComponent, instance)).to.be.ok()
		end)
		it("should add component on existing instance tag", function()
			world:registerComponent(testComponent)
			CollectionService:AddTag(instance, "tagSystemTest")

			Promise.fromEvent(RunService.Heartbeat):await()
			world:addSystem(StitchLib.DefaultSystems.TagSystem)
			Promise.fromEvent(RunService.Heartbeat):await()

			expect(world:getComponent(testComponent, instance)).to.be.ok()
		end)
	end)
	describe("Tag removed", function()
		it("should remove component on entity tag removal", function()
			world:addSystem(StitchLib.DefaultSystems.TagSystem)
			world:registerComponent(testComponent)

			CollectionService:AddTag(instance, "tagSystemTest")
			Promise.fromEvent(RunService.Heartbeat):await()
			
			CollectionService:RemoveTag(instance, "tagSystemTest")
			Promise.fromEvent(RunService.Heartbeat):await()

			expect(world:getComponent(testComponent, instance)).to.never.be.ok()
		end)
	end)
	if clientTestsEnabled then
		describe("client tests", function()
			it("should add component on entity on client", function()
				world:addSystem(StitchLib.DefaultSystems.TagSystem)
				world:registerComponent(testComponent)
				CollectionService:AddTag(instance, "tagSystemTest")
				Promise.fromEvent(RunService.Heartbeat):await()

				expect(world:getComponent(testComponent, instance)).to.be.ok()
				invokeClientTest(
					{ script.Parent["TagSystem.client.spec"] },
					{ testNamePattern = "should add component on entity on client" }
				)
			end)
			it("should remove component on tag removal on client", function()
				world:addSystem(StitchLib.DefaultSystems.TagSystem)
				world:registerComponent(testComponent)
				CollectionService:AddTag(instance, "tagSystemTest")
				Promise.fromEvent(RunService.Heartbeat):await()

				CollectionService:RemoveTag(instance, "tagSystemTest")
				Promise.fromEvent(RunService.Heartbeat):await()

				expect(world:getComponent(testComponent, instance)).to.never.be.ok()

				invokeClientTest(
					{ script.Parent["TagSystem.client.spec"] },
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
