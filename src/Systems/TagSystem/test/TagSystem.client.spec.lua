local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local StitchLib = require(script.Parent.Parent.Parent.Parent)

return function()
	if not RunService:IsClient() then
		return
	end
	local stitch
	local testComponent = {
		name = "tagSystemTest",
		tagged = true,
	}
	beforeEach(function()
		stitch = StitchLib.Stitch.new("test")
	end)
	afterEach(function()
		stitch:destroy()
	end)

	describe("Tag added", function()
		it("should add component on entity on client", function()
			stitch:addSystem(StitchLib.Systems.TagSystem)
			stitch.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("TagSystemTestInstance", 5)
			expect(instance).to.be.ok()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.be.ok()
		end)
	end)
	describe("Tag removed", function()
		it("should remove component on tag removal on client", function()
			stitch:addSystem(StitchLib.Systems.TagSystem)
			stitch.entityManager:registerComponent(testComponent)
			local instance = Workspace:WaitForChild("TagSystemTestInstance", 5)
			expect(instance).to.be.ok()
			expect(stitch.entityManager:getComponent(testComponent, instance)).to.never.be.ok()
		end)
	end)
end
