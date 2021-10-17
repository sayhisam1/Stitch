local EntityManager = require(script.Parent.EntityManager)
local EntityQuery = require(script.Parent.EntityQuery)

return function()
	local entityManager
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
		entityManager = EntityManager.new("test")
		entityManager:registerComponent(testComponent)
		entityManager:registerComponent(testComponent2)
		entityManager:registerComponent(testComponent3)
		entityManager:registerComponent(testComponent4)
		testInstance = Instance.new("Part")
		testInstance2 = Instance.new("Part")
		testInstance3 = Instance.new("Part")
		testInstance4 = Instance.new("Part")
	end)

	afterEach(function()
		entityManager:destroy()
		testInstance:Destroy()
		testInstance2:Destroy()
		testInstance3:Destroy()
		testInstance4:Destroy()
	end)

	describe("EntityQuery.new", function()
		it("should create a new query", function()
			local query = EntityQuery.new(entityManager)
			expect(query).to.be.ok()
			expect(query.withComponents).to.be.ok()
			expect(query.withoutComponents).to.be.ok()
		end)
	end)
	describe("EntityQuery:get", function()
		it("should get entities with same components", function()
			entityManager:addComponent(testComponent, testInstance)
			entityManager:addComponent(testComponent, testInstance2)
			entityManager:addComponent(testComponent, testInstance3)
			entityManager:addComponent(testComponent, testInstance4)
			local query = EntityQuery.new(entityManager):all(testComponent)
			local gotEntities = query:get()
			expect(#gotEntities).to.equal(4)
			expect(table.find(gotEntities, testInstance)).to.be.ok()
			expect(table.find(gotEntities, testInstance2)).to.be.ok()
			expect(table.find(gotEntities, testInstance3)).to.be.ok()
			expect(table.find(gotEntities, testInstance4)).to.be.ok()
		end)
		it("should get entities with all of same components", function()
			entityManager:addComponent(testComponent, testInstance)
			entityManager:addComponent(testComponent, testInstance2)
			entityManager:addComponent(testComponent, testInstance3)
			entityManager:addComponent(testComponent, testInstance4)
			entityManager:addComponent(testComponent2, testInstance)
			entityManager:addComponent(testComponent2, testInstance2)
			local query = EntityQuery.new(entityManager):all(testComponent, testComponent2)
			local gotEntities = query:get()
			expect(#gotEntities).to.equal(2)
			expect(table.find(gotEntities, testInstance)).to.be.ok()
			expect(table.find(gotEntities, testInstance2)).to.be.ok()
			expect(table.find(gotEntities, testInstance3)).to.never.be.ok()
			expect(table.find(gotEntities, testInstance4)).to.never.be.ok()
		end)
		it("should get entities without all of same components", function()
			entityManager:addComponent(testComponent, testInstance)
			entityManager:addComponent(testComponent, testInstance2)
			entityManager:addComponent(testComponent, testInstance3)
			entityManager:addComponent(testComponent, testInstance4)
			entityManager:addComponent(testComponent2, testInstance)
			entityManager:addComponent(testComponent2, testInstance2)
			entityManager:addComponent(testComponent3, testInstance3)
			entityManager:addComponent(testComponent4, testInstance4)
			local query = EntityQuery.new(entityManager):all(testComponent):except(testComponent2)
			local gotEntities = query:get()
			expect(#gotEntities).to.equal(2)
			expect(table.find(gotEntities, testInstance)).to.never.be.ok()
			expect(table.find(gotEntities, testInstance2)).to.never.be.ok()
			expect(table.find(gotEntities, testInstance3)).to.be.ok()
			expect(table.find(gotEntities, testInstance4)).to.be.ok()
		end)
	end)
end
