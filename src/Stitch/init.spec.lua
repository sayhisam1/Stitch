local Promise = require(script.Parent.Parent.Parent.Promise)
local Stitch = require(script.Parent)

return function()
	local bindableEvent
	local stitch
	beforeEach(function()
		bindableEvent = Instance.new("BindableEvent")
		stitch = Stitch.new("test")
	end)

	afterEach(function()
		stitch:destroy()
		bindableEvent:destroy()
	end)

	describe("Stitch.new", function()
		it("should return an Stitch", function()
			expect(stitch).to.be.ok()
		end)
	end)

	describe("Stitch:addSystem", function()
		it("should add a system", function()
			local system = {
				priority = 10,
				updateEvent = bindableEvent.Event,
				name = "test",
				destroy = function() end,
			}
			stitch:addSystem(system)
		end)
	end)

	describe("Stitch:removeSystem", function()
		it("should remove a system", function()
			local system = {
				priority = 10,
				updateEvent = bindableEvent.Event,
				name = "test",
				destroy = function() end,
			}
			stitch:addSystem(system)
			stitch:removeSystem(system)
		end)
	end)
end
