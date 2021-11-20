local World = require(script.Parent)

return function()
	local bindableEvent
	local world
	local testInstance
	SKIP()
	beforeEach(function()
		bindableEvent = Instance.new("BindableEvent")
		world = World.new("test")
		testInstance = Instance.new("Part")
	end)

	afterEach(function()
		world:destroy()
		bindableEvent:destroy()
		testInstance:destroy()
	end)

	describe("stress test huge", function()
		it("should profile component ops", function()
			local testComponent = {
				name = "testcomponent",
			}
			world:registerComponent(testComponent)
			local parts = {}
			for i = 1, 1000 do
				parts[#parts + 1] = Instance.new("Part")
			end
			
			wait(2)
			local t_start = os.clock()
			for i = 1, 1000 do
				world:addComponent(testComponent, parts[i])
			end
			local t_end = os.clock()
			print("TOTAL TIME ADD:", t_end - t_start)

			t_start = os.clock()
			for i = 1, 1000 do
				world:setComponent(testComponent, parts[i], {
					test = "test",
				})
			end
			t_end = os.clock()
			print("TOTAL TIME SET:", t_end - t_start)

		end)
	end)
end
