local World = require(script.Parent)

return function()
	local bindableEvent
	local world
	local testInstance

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
	describe("World:registerComponent", function()
		it("should properly register a component", function()
			local component = {
				name = "testComponent",
			}
			world:registerComponent(component)
		end)
	end)

	describe("World:addComponent", function()
		it("should add components to an entity", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)
			local component2 = {
				name = "testComponent2",
				defaults = {
					foo = "bar",
				},
			}
			world:registerComponent(component2)

			local data = world:addComponent("testComponent", testInstance, {
				baz = "qux",
			})
			local data2 = world:addComponent("testComponent2", testInstance, {
				duck = "quack",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
			expect(data2.foo).to.equal("bar")
			expect(data2.duck).to.equal("quack")
		end)
	end)

	describe("World:removeComponent", function()
		it("should remove a component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)

			local data = world:addComponent("testComponent", testInstance)
			world:removeComponent("testComponent", testInstance)
		end)
	end)

	describe("World:getComponent", function()
		it("should get an existing component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)

			local data = world:addComponent("testComponent", testInstance)
			expect(world:getComponent("testComponent", testInstance)).to.equal(data)
		end)
		it("should return nil for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)

			expect(world:getComponent("testComponent", testInstance)).to.never.be.ok()
		end)
	end)

	describe("World:getEntitiesWith", function()
		it("should get entities with a component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)
			local data = world:addComponent("testComponent", testInstance)
			local testEntity = {}
			local data = world:addComponent("testComponent", testEntity)
			expect(table.find(world:getEntitiesWith("testComponent"), testInstance)).to.be.ok()
			expect(table.find(world:getEntitiesWith("testComponent"), testEntity)).to.be.ok()
			expect(#world:getEntitiesWith("testComponent")).to.equal(2)
		end)
		it("should return nil for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)

			expect(next(world:getEntitiesWith("testComponent"))).to.never.be.ok()
		end)
	end)
	describe("World:setComponent", function()
		it("should set data on an existing component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)

			local data = world:addComponent("testComponent", testInstance)
			world:setComponent("testComponent", testInstance, {
				foo = "baz",
			})
			expect(world:getComponent("testComponent", testInstance).foo).to.equal("baz")
		end)
		it("should return error for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)
			expect(function()
				world:setComponent("testComponent", testInstance, {
					foo = "baz",
				})
			end).to.throw()
		end)
	end)

	describe("World:updateComponent", function()
		it("should update data on an existing component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)

			local data = world:addComponent("testComponent", testInstance)
			world:updateComponent("testComponent", testInstance, {
				baz = "qux",
			})
			expect(world:getComponent("testComponent", testInstance).foo).to.equal("bar")
			expect(world:getComponent("testComponent", testInstance).baz).to.equal("qux")
		end)
		it("should return error for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			world:registerComponent(component)
			expect(function()
				world:updateComponent("testComponent", testInstance, {
					foo = "baz",
				})
			end).to.throw()
		end)
	end)
end
