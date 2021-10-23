local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Promise = require(ReplicatedStorage.Packages.Promise)

local Stitch = require(script.Parent.Parent.Parent.Parent)

return function()
	if not RunService:IsClient() or not RunService:IsRunning() or not Players.LocalPlayer then
		return
	end
	local world
	local testComponent = {
		name = "tagSystemTest",
		tag = true,
	}
	beforeEach(function()
		world = Stitch.World.new("test")
	end)
	afterEach(function()
		world:destroy()
	end)

	describe("Tag added", function()
		it("should add component on entity on client", function()
			world:addSystem(Stitch.DefaultSystems.TagSystem)
			world:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("TagSystemTestInstance", 5)
			expect(instance).to.be.ok()
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world:getComponent(testComponent, instance)).to.be.ok()
		end)
	end)
	describe("Tag removed", function()
		it("should remove component on tag removal on client", function()
			world:addSystem(Stitch.DefaultSystems.TagSystem)
			world:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("TagSystemTestInstance", 5)
			expect(instance).to.be.ok()
			Promise.fromEvent(RunService.Heartbeat):await()
			Promise.fromEvent(RunService.Heartbeat):await()
			expect(world:getComponent(testComponent, instance)).to.never.be.ok()
		end)
	end)
end
