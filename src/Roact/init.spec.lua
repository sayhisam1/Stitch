local RunService = game:GetService("RunService")

local Stitch = require(script.Parent.Parent.Stitch)
local StitchRoact = require(script.Parent)
local Roact = require(script.Parent.Parent.Parent.Roact)

return function()
	local stitch
	local heartbeat
	beforeEach(function()
		stitch = Stitch.new("test")
		heartbeat = Instance.new("BindableEvent")
		stitch.Heartbeat = heartbeat.Event
	end)
	afterEach(function()
		stitch:destroy()
		heartbeat:Destroy()
		stitch = nil
	end)
	describe("Roact", function()
		it("should load roact", function()
			StitchRoact(stitch, Roact)
		end)
		it("should render roact", function()
			StitchRoact(stitch, Roact)
			local PatternDefinition = {
				name = "test",
				render = function(self, e)
					return e(self.stitch.Roact.Portal, {
						target = workspace,
					}, {
						TestPart = e("Part", {
							Anchored = true,
						}),
					})
				end,
			}
			stitch:registerPattern(PatternDefinition)
			stitch:getOrCreatePatternByRef(PatternDefinition, workspace)
			stitch:flushActions()
			heartbeat:Fire()
			expect(workspace:FindFirstChild("TestPart")).to.be.ok()
		end)
	end)
	describe("stress test", function()
		SKIP()
		it("should render multiple things efficiently", function()
			StitchRoact(stitch, Roact)
			local targetFolder = Instance.new("Folder")
			targetFolder.Parent = workspace
			targetFolder.Name = "TestFolder"
			local PatternDefinition = {
				name = "test",
				render = function(self, e)
					debug.profilebegin("TestRender")
					local ret = e(self.stitch.Roact.Portal, {
						target = targetFolder,
					}, {
						TestPart = e("Part", {
							Anchored = true,
							CFrame = self:get("cframe"),
						}),
					})
					debug.profileend()
					return ret
				end,
			}

			stitch:registerPattern(PatternDefinition)

			local patterns = {}
			for i = 1, 1000 do
				table.insert(
					patterns,
					stitch:createRootPattern(PatternDefinition, nil, {
						cframe = CFrame.new(),
					})
				)
			end
			stitch:flushActions()
			for i = 1, 1000 do
				debug.profilebegin("renderloop")
				for _, p in pairs(patterns) do
					p:set("cframe", p:get("cframe") * CFrame.new(math.random(), 0, math.random()))
				end
				heartbeat:Fire()
				debug.profileend()
				RunService.Heartbeat:Wait()
			end
		end)
	end)
end
