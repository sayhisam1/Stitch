local World = require(script.Parent)
local EntityQuery = require(script.Parent.EntityQuery)

return function()
	local world
	local testInstance
	local testInstance2
	local testInstance3
	local testInstance4
	local testComponent = {
		name = "test",
	}
	local testComponent2 = {
		name = "test2",
	}
	local testComponent3 = {
		name = "test3",
	}
	local testComponent4 = {
		name = "test4",
	}
	beforeEach(function()
		world = World.new("test")
		world:registerComponent(testComponent)
		world:registerComponent(testComponent2)
		world:registerComponent(testComponent3)
		world:registerComponent(testComponent4)
		testInstance = Instance.new("Part")
		testInstance2 = Instance.new("Part")
		testInstance3 = Instance.new("Part")
		testInstance4 = Instance.new("Part")
	end)

	afterEach(function()
		world:destroy()
		testInstance:Destroy()
		testInstance2:Destroy()
		testInstance3:Destroy()
		testInstance4:Destroy()
	end)

	describe("EntityQuery.new", function()
		it("should create a new query", function()
			local query = EntityQuery.new(world)
			expect(query).to.be.ok()
			expect(query.withComponents).to.be.ok()
			expect(query.withoutComponents).to.be.ok()
		end)
	end)
	describe("EntityQuery:get", function()
		it("should get entities with same components", function()
			world:addComponent(testComponent, testInstance)
			world:addComponent(testComponent, testInstance2)
			world:addComponent(testComponent, testInstance3)
			world:addComponent(testComponent, testInstance4)
			local query = EntityQuery.new(world):all(testComponent)
			local gotEntities = query:get()
			expect(#gotEntities).to.equal(4)
			expect(table.find(gotEntities, testInstance)).to.be.ok()
			expect(table.find(gotEntities, testInstance2)).to.be.ok()
			expect(table.find(gotEntities, testInstance3)).to.be.ok()
			expect(table.find(gotEntities, testInstance4)).to.be.ok()
		end)
		it("should get entities with all of same components", function()
			world:addComponent(testComponent, testInstance)
			world:addComponent(testComponent, testInstance2)
			world:addComponent(testComponent, testInstance3)
			world:addComponent(testComponent, testInstance4)
			world:addComponent(testComponent2, testInstance)
			world:addComponent(testComponent2, testInstance2)
			local query = EntityQuery.new(world):all(testComponent, testComponent2)
			local gotEntities = query:get()
			expect(#gotEntities).to.equal(2)
			expect(table.find(gotEntities, testInstance)).to.be.ok()
			expect(table.find(gotEntities, testInstance2)).to.be.ok()
			expect(table.find(gotEntities, testInstance3)).to.never.be.ok()
			expect(table.find(gotEntities, testInstance4)).to.never.be.ok()
		end)
		it("should get entities without all of same components", function()
			world:addComponent(testComponent, testInstance)
			world:addComponent(testComponent, testInstance2)
			world:addComponent(testComponent, testInstance3)
			world:addComponent(testComponent, testInstance4)
			world:addComponent(testComponent2, testInstance)
			world:addComponent(testComponent2, testInstance2)
			world:addComponent(testComponent3, testInstance3)
			world:addComponent(testComponent4, testInstance4)
			local query = EntityQuery.new(world):all(testComponent):except(testComponent2)
			local gotEntities = query:get()
			expect(#gotEntities).to.equal(2)
			expect(table.find(gotEntities, testInstance)).to.never.be.ok()
			expect(table.find(gotEntities, testInstance2)).to.never.be.ok()
			expect(table.find(gotEntities, testInstance3)).to.be.ok()
			expect(table.find(gotEntities, testInstance4)).to.be.ok()
		end)
	end)
	describe("EntityQuery:forEach", function()
		it("should pass all components to callback", function()
			world:addComponent(testComponent, testInstance, {
				foo = "bar"
			})
			world:addComponent(testComponent2, testInstance, {
				baz="qux"
			})

			local valid = nil
			EntityQuery.new(world):all(testComponent, testComponent2):forEach(function(entity, c1, c2)
				valid = (entity==testInstance) and (c1.foo == "bar") and (c2.baz == "qux")
			end)
			expect(valid).to.be.ok()
		end)
	end)
end
