local World = require(script.Parent)

return function()
	local bindableEvent
	local world
	beforeEach(function()
		bindableEvent = Instance.new("BindableEvent")
		world = World.new("test")
	end)

	afterEach(function()
		world:destroy()
		bindableEvent:destroy()
	end)

	describe("World.new", function()
		it("should return an World", function()
			expect(world).to.be.ok()
		end)
	end)

	describe("World:addSystem", function()
		it("should add a system", function()
			local system = {
				priority = 10,
				updateEvent = bindableEvent.Event,
				name = "test",
				destroy = function() end,
			}
			world:addSystem(system)
		end)
	end)

	describe("World:removeSystem", function()
		it("should remove a system", function()
			local system = {
				priority = 10,
				updateEvent = bindableEvent.Event,
				name = "test",
				destroy = function() end,
			}
			world:addSystem(system)
			world:removeSystem(system)
		end)
	end)
end
