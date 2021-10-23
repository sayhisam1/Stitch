local ComponentRegistry = require(script.Parent.ComponentRegistry)

return function()
	local registry
	beforeEach(function()
		registry = ComponentRegistry.new()
	end)

	afterEach(function()
		registry:destroy()
	end)

	describe("ComponentRegistry.new", function()
		it("should return a ComponentRegistry", function()
			expect(registry).to.be.ok()
		end)
	end)
	describe("ComponentRegistry:register", function()
		it("should register a new component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			registry:register(component)
		end)
		it("shouldn't register duplicate components", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			registry:register(component)
			expect(function()
				registry:register(component)
			end).to.throw()
		end)
	end)
	describe("ComponentRegistry:unregister", function()
		it("should unregister a component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			registry:register(component)
			registry:unregister(component)
			expect(registry:resolve(component)).to.never.be.ok()
		end)
	end)
	describe("ComponentRegistry:resolve", function()
		it("should resolve a component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			registry:register(component)
			expect(registry:resolve(component)).to.be.ok()
		end)
	end)
	describe("ComponentRegistry:resolveOrError", function()
		it("should resolve a component", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			registry:register(component)
			expect(registry:resolveOrError(component)).to.be.ok()
		end)
		it("should properly throw on resolve fail", function()
			expect(function()
				registry:resolveOrError("testComponent")
			end).to.throw()
		end)
	end)
	describe("ComponentRegistry:getAll", function()
		it("should get all registered components", function()
			local component = {
				name = "testComponent",
				defaults = {},
			}
			registry:register(component)
			local allComponents = registry:getAll()
			local len = 0
			for k, v in pairs(allComponents) do
				len += 1
			end
			expect(len).to.equal(1)
			expect(allComponents[component.name]).to.be.ok()
		end)
	end)
end
