local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local Promise = require(script.Parent.Parent.Parent.Promise)
local EntityManager = require(script.Parent.EntityManager)

return function()
	local entityManager
	local testInstance
	beforeEach(function()
		entityManager = EntityManager.new("test")
		testInstance = Instance.new("Part")
	end)

	afterEach(function()
		entityManager:destroy()
		testInstance:Destroy()
	end)

	describe("EntityManager.new", function()
		it("should return an EntityManager", function()
			expect(entityManager).to.be.ok()
		end)
	end)

	describe("EntityManager:registerEntity", function()
		it("should register a table entity", function()
			local testEntity = {}
			entityManager:registerEntity(testEntity)
			expect(entityManager.entities[testEntity]).to.be.ok()
		end)
		it("should add tags to an instance", function()
			entityManager:registerEntity(testInstance)
			expect(CollectionService:HasTag(testInstance, entityManager.instanceTag)).to.be.ok()
			expect(entityManager.entities[testInstance]).to.be.ok()
		end)
	end)

	describe("EntityManager:unregisterEntity", function()
		it("should properly unregister a table entity", function()
			local testEntity = {}
			entityManager:registerEntity(testEntity)
			entityManager:unregisterEntity(testEntity)
			expect(entityManager.entities[testEntity]).to.never.be.ok()
		end)
		it("should properly unregister an instance", function()
			entityManager:registerEntity(testInstance)
			expect(CollectionService:HasTag(testInstance, entityManager.instanceTag)).to.equal(true)
			entityManager:unregisterEntity(testInstance)
			expect(CollectionService:HasTag(testInstance, entityManager.instanceTag)).to.equal(false)
			expect(entityManager.entities[testInstance]).to.never.be.ok()
		end)
		it("should properly unregister instances on destruction", function()
			local promise = Promise.fromEvent(CollectionService:GetInstanceRemovedSignal(entityManager.instanceTag))

			local newInstance = Instance.new("Folder")
			newInstance.Parent = Workspace
			entityManager:registerEntity(newInstance)

			newInstance:Destroy()
			promise:await()

			expect(entityManager.entities[newInstance]).to.never.be.ok()
		end)
	end)

	describe("EntityManager:registerComponent", function()
		it("should properly register a component", function()
			local component = {
				name = "testComponent",
			}
			entityManager:registerComponent(component)
		end)
	end)

	describe("EntityManager:addComponent", function()
		it("should add a component to an unregistered instance", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			local data = entityManager:addComponent("testComponent", testInstance, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
		end)
		it("should add a component to an unregistered table", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			local testEntity = {}
			local data = entityManager:addComponent("testComponent", testEntity, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
		end)
		it("should add a component to a registered instance", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerEntity(testInstance)
			entityManager:registerComponent(component)

			local data = entityManager:addComponent("testComponent", testInstance, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
			expect(entityManager.componentToEntity["testComponent"][testInstance]).to.be.ok()
		end)
		it("should add a component to a registered table", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}
			entityManager:registerComponent(component)

			local testEntity = {}
			entityManager:registerEntity(testEntity)

			local data = entityManager:addComponent("testComponent", testEntity, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
			expect(entityManager.componentToEntity["testComponent"][testEntity]).to.be.ok()
		end)
	end)

	describe("EntityManager:removeComponent", function()
		it("should remove a component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			local data = entityManager:addComponent("testComponent", testInstance)
			entityManager:removeComponent("testComponent", testInstance)
			expect(entityManager.componentToEntity["testComponent"][testInstance]).to.never.be.ok()
		end)
		it("should call destructor", function()
			local called = 0
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
				destructor = function()
					called += 1
				end,
			}

			entityManager:registerComponent(component)

			local data = entityManager:addComponent("testComponent", testInstance)
			entityManager:removeComponent("testComponent", testInstance)
			expect(called).to.equal(1)
		end)
		it("should clear references to an entity when all components are removed", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)
			local component2 = {
				name = "testComponent2",
				defaults = {
					foo = "bar",
				},
			}
			entityManager:registerComponent(component2)

			entityManager:addComponent("testComponent", testInstance)
			entityManager:addComponent("testComponent2", testInstance)
			entityManager:removeComponent("testComponent", testInstance)
			expect(entityManager.entities[testInstance]).to.be.ok()
			expect(entityManager.componentToEntity["testComponent"][testInstance]).to.never.be.ok()
			entityManager:removeComponent("testComponent2", testInstance)
			expect(entityManager.entities[testInstance]).to.never.be.ok()
			expect(entityManager.componentToEntity["testComponent2"][testInstance]).to.never.be.ok()
			entityManager:addComponent("testComponent", testInstance)
			expect(entityManager.entities[testInstance]).to.be.ok()
			expect(entityManager.componentToEntity["testComponent"][testInstance]).to.be.ok()
		end)
		it("shouldn't error for non-existant components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)
			entityManager:removeComponent("testComponent", testInstance)

			expect(entityManager:getComponent("testComponent", testInstance)).to.never.be.ok()
		end)
	end)

	describe("EntityManager:getComponent", function()
		it("should get an existing component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			local data = entityManager:addComponent("testComponent", testInstance)
			expect(entityManager:getComponent("testComponent", testInstance)).to.equal(data)
		end)
		it("should return nil for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			expect(entityManager:getComponent("testComponent", testInstance)).to.never.be.ok()
		end)
	end)

	describe("EntityManager:getEntitiesWith", function()
		it("should get entities with a component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)
			local data = entityManager:addComponent("testComponent", testInstance)
			local testEntity = {}
			local data = entityManager:addComponent("testComponent", testEntity)
			expect(table.find(entityManager:getEntitiesWith("testComponent"), testInstance)).to.be.ok()
			expect(table.find(entityManager:getEntitiesWith("testComponent"), testEntity)).to.be.ok()
			expect(#entityManager:getEntitiesWith("testComponent")).to.equal(2)
		end)
		it("should return nil for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			expect(next(entityManager:getEntitiesWith("testComponent"))).to.never.be.ok()
		end)
	end)
	describe("EntityManager:setComponent", function()
		it("should set data on an existing component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			local data = entityManager:addComponent("testComponent", testInstance)
			entityManager:setComponent("testComponent", testInstance, {
				foo = "baz",
			})
			expect(entityManager:getComponent("testComponent", testInstance).foo).to.equal("baz")
		end)
		it("should return error for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)
			expect(function()
				entityManager:setComponent("testComponent", testInstance, {
					foo = "baz",
				})
			end).to.throw()
		end)
	end)

	describe("EntityManager:updateComponent", function()
		it("should update data on an existing component", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)

			local data = entityManager:addComponent("testComponent", testInstance)
			entityManager:updateComponent("testComponent", testInstance, {
				baz = "qux",
			})
			expect(entityManager:getComponent("testComponent", testInstance).foo).to.equal("bar")
			expect(entityManager:getComponent("testComponent", testInstance).baz).to.equal("qux")
		end)
		it("should return error for non-existing components", function()
			local component = {
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}

			entityManager:registerComponent(component)
			expect(function()
				entityManager:updateComponent("testComponent", testInstance, {
					foo = "baz",
				})
			end).to.throw()
		end)
	end)
end