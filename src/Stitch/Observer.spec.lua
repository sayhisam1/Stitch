local Promise = require(script.Parent.Parent.Parent.Promise)
local EntityManager = require(script.Parent.EntityManager)
local Observer = require(script.Parent.Observer)

return function()
	local entityManager
	local testInstance
	local testComponent = {
		name = "test",
	}
	beforeEach(function()
		entityManager = EntityManager.new("test")
		entityManager:registerComponentTemplate(testComponent)
		testInstance = Instance.new("Part")
	end)

	afterEach(function()
		entityManager:destroy()
		testInstance:Destroy()
	end)

	describe("Observer.new", function()
		it("should create a new observer", function()
			local observer = Observer.new(entityManager, testComponent)
			expect(observer).to.be.ok()
		end)
	end)
	describe("Observer:get", function()
		it("should return a list of existing entities", function()
			entityManager:addComponent(testComponent, testInstance)
			local observer = Observer.new(entityManager, testComponent)
			expect(next(observer:get())).to.equal(testInstance)
		end)
		it("should update when a new entity is added", function()
			local observer = Observer.new(entityManager, testComponent)
			entityManager:addComponent(testComponent, testInstance)
			expect(next(observer:get())).to.equal(testInstance)
		end)
		it("should update when an entity component is set", function()
			local observer = Observer.new(entityManager, testComponent)
			entityManager:addComponent(testComponent, testInstance)
			observer:clear()
			expect(next(observer:get())).to.never.be.ok()
			entityManager:setComponent(testComponent, testInstance, {})
			expect(next(observer:get())).to.equal(testInstance)
		end)
		it("should update when an entity component is updated", function()
			local observer = Observer.new(entityManager, testComponent)
			entityManager:addComponent(testComponent, testInstance)
			observer:clear()
			expect(next(observer:get())).to.never.be.ok()
			entityManager:updateComponent(testComponent, testInstance, {})
			expect(next(observer:get())).to.equal(testInstance)
		end)
		it("shouldn't return removed components", function()
			local observer = Observer.new(entityManager, testComponent)
			entityManager:addComponent(testComponent, testInstance)
			local testEntity = {}
			entityManager:addComponent(testComponent, testEntity)
			entityManager:removeComponent(testComponent, testInstance)
			expect(next(observer:get())).to.equal(testEntity)
			entityManager:removeComponent(testComponent, testEntity)
			expect(next(observer:get())).to.never.be.ok()
		end)
	end)
end
