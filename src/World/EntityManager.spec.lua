local ComponentDefinition = require(script.Parent.ComponentDefinition)
local EntityManager = require(script.Parent.EntityManager)
local Symbol = require(script.Parent.Parent.Shared.Symbol)
local Immutable = require(script.Parent.Parent.Shared.Immutable)
local NONE = Symbol.named("NONE")

return function()
	local entityManager
	local testInstance
	beforeEach(function()
		entityManager = EntityManager.new()
		testInstance = Instance.new("Part")
	end)

	afterEach(function()
		testInstance:Destroy()
		entityManager:destroy()
	end)

	describe("EntityManager.new", function()
		it("should return an EntityManager", function()
			expect(entityManager).to.be.ok()
		end)
	end)

	describe("EntityManager:register", function()
		it("should register a table entity", function()
			local testEntity = {}
			entityManager:register(testEntity)
			expect(entityManager.entityToComponent[testEntity]).to.be.ok()
		end)
		it("should register an instance entity", function()
			entityManager:register(testInstance)
			expect(entityManager.entityToComponent[testInstance]).to.be.ok()
		end)
	end)

	describe("EntityManager:unregister", function()
		it("should properly unregister a table entity", function()
			local testEntity = {}
			entityManager:register(testEntity)
			entityManager:unregister(testEntity)
			expect(entityManager.entityToComponent[testEntity]).to.never.be.ok()
		end)
	end)

	describe("EntityManager:addComponent", function()
		it("should add a component to an unregistered instance", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
		end)
		it("should remove NONE keys", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance, {
				baz = "qux",
				foo = NONE,
			})
			expect(data.foo).to.never.be.ok()
			expect(data.baz).to.equal("qux")
		end)
		it("should properly validate data", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
				validator = function(data)
					return data.foo == "bar"
				end,
			}, ComponentDefinition)

			expect(function()
				entityManager:addComponent(component, testInstance, {
					foo = "baz",
				})
			end).to.throw()
			entityManager:addComponent(component, testInstance)
			entityManager:addComponent(component, {}, {
				foo = "bar",
			})
		end)
		it("should add a component to an unregistered table", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local testEntity = {}
			local data = entityManager:addComponent(component, testEntity, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
		end)
		it("should add a component to a registered instance", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			entityManager:register(testInstance)

			local data = entityManager:addComponent(component, testInstance, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
			expect(entityManager.componentToEntity["testComponent"][testInstance]).to.be.ok()
		end)
		it("should add a component to a registered table", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local testEntity = {}
			entityManager:register(testEntity)

			local data = entityManager:addComponent(component, testEntity, {
				baz = "qux",
			})
			expect(data.foo).to.equal("bar")
			expect(data.baz).to.equal("qux")
			expect(entityManager.componentToEntity["testComponent"][testEntity]).to.be.ok()
		end)
	end)

	describe("EntityManager:getComponentAddedSignal", function()
		it("should fire signal on component set", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getComponentAddedSignal(testInstance)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			local data = entityManager:addComponent(component, testInstance)
			expect(args).to.be.ok()
			expect(#args).to.equal(2)
			expect(args[1]).to.equal("testComponent")
			expect(args[2]).to.equal(data)
		end)
		it("should clear signal on entity unregister", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getComponentAddedSignal(testInstance)

			entityManager:addComponent(component, testInstance)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			entityManager:unregister(testInstance)
			entityManager:addComponent(component, testInstance)
			expect(args).to.never.be.ok()
		end)
	end)

	describe("EntityManager:getEntityAddedSignal", function()
		it("should fire signal on component set", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getEntityAddedSignal(component)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			local data = entityManager:addComponent(component, testInstance)
			expect(args).to.be.ok()
			expect(#args).to.equal(2)
			expect(args[1]).to.equal(testInstance)
			expect(args[2]).to.equal(data)
		end)
	end)

	describe("EntityManager:removeComponent", function()
		it("should remove a component", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance)
			entityManager:removeComponent(component, testInstance)
			expect(entityManager.componentToEntity["testComponent"][testInstance]).to.never.be.ok()
		end)
		it("should call destructor", function()
			local called = 0
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
				destructor = function()
					called += 1
				end,
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance)
			entityManager:removeComponent(component, testInstance)
			expect(called).to.equal(1)
		end)
		it("should clear references to an entity when all components are removed", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local component2 = setmetatable({
				name = "testComponent2",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			entityManager:addComponent(component, testInstance)
			entityManager:addComponent(component2, testInstance)
			entityManager:removeComponent(component, testInstance)
			expect(entityManager.entityToComponent[testInstance]).to.be.ok()
			expect(entityManager.componentToEntity[component.name][testInstance]).to.never.be.ok()
			entityManager:removeComponent(component2, testInstance)
			expect(entityManager.componentToEntity[component2.name][testInstance]).to.never.be.ok()
			entityManager:addComponent(component, testInstance)
			expect(entityManager.entityToComponent[testInstance]).to.be.ok()
			expect(entityManager.componentToEntity[component.name][testInstance]).to.be.ok()
		end)
		it("shouldn't error for non-existant components", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			entityManager:removeComponent(component, testInstance)

			expect(entityManager:getComponent(component, testInstance)).to.never.be.ok()
		end)
	end)

	describe("EntityManager:getComponentRemovingSignal", function()
		it("should fire signal on component set", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getComponentRemovingSignal(testInstance)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			local prevData = entityManager:addComponent(component, testInstance)
			expect(args).to.never.be.ok()
			entityManager:removeComponent(component, testInstance)

			expect(args).to.be.ok()
			expect(#args).to.equal(2)
			expect(args[1]).to.equal("testComponent")
			expect(args[2]).to.equal(prevData)
		end)
		it("should clear signal on entity unregister", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getComponentRemovingSignal(testInstance)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			entityManager:addComponent(component, testInstance)
			entityManager:unregister(testInstance)
			entityManager:addComponent(component, testInstance)
			entityManager:removeComponent(component, testInstance)
			expect(args).to.never.be.ok()
		end)
	end)

	describe("EntityManager:getEntityRemovingSignal", function()
		it("should fire signal on component set", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getEntityRemovingSignal(component)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			local data = entityManager:addComponent(component, testInstance)
			expect(args).to.never.be.ok()
			entityManager:removeComponent(component, testInstance)
			expect(args).to.be.ok()
			expect(#args).to.equal(2)
			expect(args[1]).to.equal(testInstance)
			expect(args[2]).to.equal(data)
		end)
	end)

	describe("EntityManager:getComponent", function()
		it("should get an existing component", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance)
			expect(entityManager:getComponent(component, testInstance)).to.equal(data)
		end)
		it("should return nil for non-existing components", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			expect(entityManager:getComponent(component, testInstance)).to.never.be.ok()
		end)
	end)

	describe("EntityManager:getEntitiesWith", function()
		it("should get entities with a component", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance)
			local testEntity = {}
			local data = entityManager:addComponent(component, testEntity)

			expect(entityManager:getEntitiesWith(component)[testInstance]).to.be.ok()
			expect(entityManager:getEntitiesWith(component)[testEntity]).to.be.ok()
			expect(Immutable.count(entityManager:getEntitiesWith(component))).to.equal(2)
		end)
		it("should return nil for non-existing components", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			expect(next(entityManager:getEntitiesWith(component))).to.never.be.ok()
		end)
	end)

	describe("EntityManager:setComponent", function()
		it("should set data on an existing component", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance)
			entityManager:setComponent(component, testInstance, {
				foo = "baz",
			})
			expect(entityManager:getComponent(component, testInstance).foo).to.equal("baz")
		end)
		it("should properly validate data", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
				validator = function(data)
					return data.foo == "bar"
				end,
			}, ComponentDefinition)
			entityManager:addComponent(component, testInstance)

			expect(function()
				entityManager:setComponent(component, testInstance, {
					foo = "baz",
				})
			end).to.throw()
			entityManager:setComponent(component, testInstance, {
				foo = "bar",
			})
		end)
		it("should return error for non-existing components", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			expect(function()
				entityManager:setComponent(component, testInstance, {
					foo = "baz",
				})
			end).to.throw()
		end)
	end)

	describe("EntityManager:updateComponent", function()
		it("should update data on an existing component", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance)
			entityManager:updateComponent(component, testInstance, {
				baz = "qux",
			})
			expect(entityManager:getComponent(component, testInstance).foo).to.equal("bar")
			expect(entityManager:getComponent(component, testInstance).baz).to.equal("qux")
		end)
		it("should update NONE keys", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local data = entityManager:addComponent(component, testInstance)
			entityManager:updateComponent(component, testInstance, {
				baz = "qux",
				foo = NONE,
			})
			expect(entityManager:getComponent(component, testInstance).foo).to.never.be.ok()
			expect(entityManager:getComponent(component, testInstance).baz).to.equal("qux")
		end)
		it("should properly validate data", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
				validator = function(data)
					return data.foo == "bar"
				end,
			}, ComponentDefinition)
			entityManager:addComponent(component, testInstance)

			expect(function()
				entityManager:updateComponent(component, testInstance, {
					foo = "baz",
				})
			end).to.throw()

			entityManager:updateComponent(component, testInstance, {
				foo = "bar",
			})
		end)
		it("should return error for non-existing components", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			expect(function()
				entityManager:updateComponent(component, testInstance, {
					foo = "baz",
				})
			end).to.throw()
		end)
	end)

	describe("EntityManager:getComponents", function()
		it("should return all components of a given entity", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			entityManager:addComponent(component, testInstance)

			expect(entityManager:getComponents(testInstance)).to.be.ok()
			
			for _,componentName in ipairs(entityManager:getComponents(testInstance)) do
				expect(componentName).to.equal(component.name)
			end
		end)

		it("should return empty table for entities with no components", function()
			expect(#entityManager:getComponents(testInstance)).to.equal(0)
		end)
	end)

	describe("EntityManager:getComponentChangedSignal", function()
		it("should fire signal on component set", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getComponentChangedSignal(testInstance)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			local prevData = entityManager:addComponent(component, testInstance)
			expect(args).to.never.be.ok()
			local newData = entityManager:setComponent(component, testInstance, {
				foo = "baz",
			})
			expect(args).to.be.ok()
			expect(#args).to.equal(3)
			expect(args[1]).to.equal("testComponent")
			expect(args[2]).to.equal(newData)
			expect(args[3]).to.equal(prevData)
		end)
		it("should fire signal on component update", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getComponentChangedSignal(testInstance)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			local prevData = entityManager:addComponent(component, testInstance)
			expect(args).to.never.be.ok()
			local newData = entityManager:updateComponent(component, testInstance, {
				foo = "baz",
			})
			expect(args).to.be.ok()
			expect(#args).to.equal(3)
			expect(args[1]).to.equal("testComponent")
			expect(args[2]).to.equal(newData)
			expect(args[3]).to.equal(prevData)
		end)
		it("should clear signal on entity unregister", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getComponentChangedSignal(testInstance)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			entityManager:addComponent(component, testInstance)
			entityManager:unregister(testInstance)
			entityManager:addComponent(component, testInstance)
			entityManager:setComponent(component, testInstance, {
				foo = "baz",
			})
			expect(args).to.never.be.ok()
		end)
	end)

	describe("EntityManager:getEntityChangedSignal", function()
		it("should fire signal on component change", function()
			local component = setmetatable({
				name = "testComponent",
				defaults = {
					foo = "bar",
				},
			}, ComponentDefinition)

			local signal = entityManager:getEntityChangedSignal(component)
			local args
			signal:connect(function(...)
				args = { ... }
			end)
			local prevData = entityManager:addComponent(component, testInstance)
			expect(args).to.never.be.ok()
			local newData = entityManager:setComponent(component, testInstance, {
				foo = "baz",
			})
			expect(args).to.be.ok()
			expect(#args).to.equal(3)
			expect(args[1]).to.equal(testInstance)
			expect(args[2]).to.equal(newData)
			expect(args[3]).to.equal(prevData)
		end)
	end)
end
