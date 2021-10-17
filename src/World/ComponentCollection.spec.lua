local ComponentCollection = require(script.Parent.ComponentCollection)
local Promise = require(script.Parent.Parent.Parent.Promise)

return function()
	local componentCollection
	beforeEach(function()
		componentCollection = ComponentCollection.new()
	end)

	afterEach(function()
		componentCollection:destroy()
	end)

	describe("ComponentCollection.new", function()
		it("should return a ComponentCollection", function()
			expect(componentCollection).to.be.ok()
		end)
	end)
	describe("ComponentCollection:register", function()
		it("should register a new component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			componentCollection:register(component)
		end)
		it("shouldn't register duplicate components", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			componentCollection:register(component)
			expect(function()
				componentCollection:register(component)
			end).to.throw()
		end)
		it("should should fire registered signal", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			local registered = nil
			local promise = Promise.fromEvent(componentCollection:getComponentRegisteredSignal()):andThen(
				function(registeredComponent)
					registered = registeredComponent.name
				end
			)
			componentCollection:register(component)
			promise:await()
			expect(registered).to.equal("testComponent")
		end)
	end)
	describe("ComponentCollection:unregister", function()
		it("should unregister a component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			componentCollection:register(component)
			componentCollection:unregister(component)
			expect(componentCollection:resolve(component)).to.never.be.ok()
		end)
		it("should should fire unregistered signal", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			local unregistered = nil
			local promise = Promise.fromEvent(componentCollection:getComponentUnregisteredSignal()):andThen(
				function(unregisteredComponent)
					unregistered = unregisteredComponent.name
				end
			)
			componentCollection:register(component)
			componentCollection:unregister(component)
			promise:await()
			expect(unregistered).to.equal("testComponent")
		end)
	end)
	describe("ComponentCollection:resolve", function()
		it("should resolve a component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			componentCollection:register(component)
			expect(componentCollection:resolve(component)).to.be.ok()
		end)
	end)
	describe("ComponentCollection:resolveOrError", function()
		it("should resolve a component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			componentCollection:register(component)
			expect(componentCollection:resolveOrError(component)).to.be.ok()
		end)
		it("should properly throw on resolve fail", function()
			expect(function()
				componentCollection:resolveOrError("testComponent")
			end).to.throw()
		end)
	end)
	describe("ComponentCollection:getAll", function()
		it("should get all registered components", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			componentCollection:register(component)
			local allComponents = componentCollection:getAll()
			local len = 0
			for k, v in pairs(allComponents) do
				len += 1
			end
			expect(len).to.equal(1)
			expect(allComponents[component.name]).to.be.ok()
		end)
	end)
end
