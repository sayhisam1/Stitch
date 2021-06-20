local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Stitch = require(script.Parent.Parent.Stitch)
local StitchRoact = require(script.Parent)
local Roact = require(script.Parent.Parent.Parent.Roact)
local Promise = require(script.Parent.Parent.Parent.Promise)

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
					return e(self.stitch.roact.Portal, {
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
			local promise = Promise.new(function(resolve, reject, onCancel)
				heartbeat.Event:Wait()
				resolve()
			end):andThen(function()
				expect(workspace:FindFirstChild("TestPart")).to.be.ok()
			end)
			heartbeat:Fire()
			promise:await()
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
					debug.profilebegin("get target")
					local target = self:getRef():getInstance()
					debug.profileend()
					local ret = e(self.stitch.roact.Portal, {
						target = target,
					}, {
						TestPart = e("Part", {
							Anchored = true,
							CFrame = self:get("cframe"),
						}),
					})
					return ret
				end,
			}

			stitch:registerPattern(PatternDefinition)
			local refs = {}
			local patterns = {}
			for i = 1, 1000 do
				refs[i] = Instance.new("Folder")
				refs[i].Parent = Workspace
				table.insert(
					patterns,
					stitch:getOrCreatePatternByRef(PatternDefinition, refs[i], {
						cframe = CFrame.new(),
					})
				)
			end
			stitch:flushActions()
			for i = 1, 1000 do
				debug.profilebegin("stitch update loop")
				for _, p in pairs(patterns) do
					local newCf = p:get("cframe") * CFrame.new(math.random(), 0, math.random())
					p:set("cframe", newCf)
				end
				debug.profileend()
				heartbeat:Fire()
				RunService.Heartbeat:Wait()
			end
		end)
	end)
end
