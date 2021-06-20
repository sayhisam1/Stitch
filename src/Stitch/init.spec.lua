local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local Promise = require(script.Parent.Parent.Parent.Promise)
local Stitch = require(script.Parent)

return function()
	local stitch
	beforeEach(function()
		stitch = Stitch.new("test")
	end)

	afterEach(function()
		stitch:destroy()
		stitch = nil
	end)

	describe("Stitch.new", function()
		it("should return a stitch with correct namespace", function()
			expect(stitch.namespace).to.equal("test")
		end)
	end)

	describe("Stitch:register", function()
		it("should assign a uuid to an instance", function()
			local instance = Instance.new("Folder")
			instance.Parent = Workspace
			local entity = stitch:register(instance)
			expect(entity).to.be.a("string")
			instance:Destroy()
		end)

		it("shouldn't allow re-registering the same instance multiple times", function()
			local instance = Instance.new("Folder")
			instance.Parent = Workspace
			stitch:register(instance)

			expect(function()
				stitch:register(instance)
			end).to.throw()

			instance:Destroy()
		end)
	end)

	describe("Stitch:unregister", function()
		it("should remove all components", function()
			local instance = Instance.new("Folder")
			instance.Parent = Workspace
			local entity = stitch:register(instance)
			expect(entity).to.be.a("string")
			stitch:unregister(instance)
			instance:Destroy()
		end)
	end)

	describe("Stitch:addPattern", function()
		it("should properly add a new pattern", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)
		end)
	end)

	describe("Stitch:emplace", function()
		it("should create a pattern and attach to an existing entity", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local entity = stitch:register(instance)
			local test = stitch:emplace("test", entity, { foo = "bar" })

			expect(test).to.be.a("table")
			expect(test.foo).to.equal("bar")

			instance:Destroy()
		end)

		it("should create a pattern and attach to an existing entity when referenced by instance", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local entity = stitch:register(instance)
			local test = stitch:emplace("test", instance, { foo = "bar" })

			expect(test).to.be.a("table")
			expect(test.foo).to.equal("bar")

			instance:Destroy()
		end)
		it("should automatically register instances if needed", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local test = stitch:emplace("test", instance, { foo = "bar" })

			expect(test).to.be.a("table")
			expect(test.foo).to.equal("bar")

			instance:Destroy()
		end)
	end)

	describe("Stitch:get", function()
		it("should properly get created patterns", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			stitch:emplace("test", instance, {
				foo = "bar",
			})
			local test = stitch:get("test", instance)

			expect(test).to.be.ok()
			expect(test.foo).to.equal("bar")

			instance:Destroy()
		end)
		it("should return nil for patterns that aren't created", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			stitch:register(instance)
			local test = stitch:get("test", instance)

			expect(test).to.never.be.ok()

			instance:Destroy()
		end)
		it("should return nil for instances that aren't registered", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local test = stitch:get("test", instance)

			expect(test).to.never.be.ok()

			instance:Destroy()
		end)
	end)

	describe("Stitch:getOrEmplace", function()
		it("should create a pattern and attach to an existing entity", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local entity = stitch:register(instance)
			local test = stitch:getOrEmplace("test", entity, { foo = "bar" })

			expect(test).to.be.a("table")
			expect(test.foo).to.equal("bar")

			instance:Destroy()
		end)

		it("should use pattern if already exists", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			stitch:register(instance)
			stitch:emplace("test", instance, { foo = "bar" })
			local test = stitch:getOrEmplace("test", instance, {})
			expect(test.foo).to.equal("bar")

			instance:Destroy()
		end)
	end)

	describe("Stitch:replace", function()
		it("should immutably replace data for component", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			stitch:register(instance)
			stitch:emplace("test", instance, { foo = "bar" })
			local test1 = stitch:get("test", instance)
			expect(test1.foo).to.equal("bar")

			stitch:replace("test", instance, { foo = "baz" })
			local test2 = stitch:get("test", instance)
			expect(test2.foo).to.equal("baz")
			expect(test2 == test1).to.equal(false)

			instance:Destroy()
		end)
	end)

	describe("Stitch:onCreated", function()
		it("should fire when a pattern is created", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local recvInstance, recvPattern
			local promise = Promise.fromEvent(stitch:GetOnCreatedSignal(testPattern)):andThen(
				function(instance: Instance, pattern: table)
					recvInstance = instance
					recvPattern = pattern
				end
			)
			stitch:register(instance)
			stitch:emplace("test", instance, { foo = "bar" })
			promise:await()
			expect(recvInstance).to.equal(instance)
			expect(recvPattern.foo).to.equal("bar")
			expect(getmetatable(recvPattern)).to.be.ok()
			instance:Destroy()
		end)
	end)

	describe("Stitch:onUpdated", function()
		it("should fire when a pattern is updated", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local recvInstance, recvPattern
			local promise = Promise.fromEvent(stitch:GetOnUpdatedSignal(testPattern)):andThen(
				function(instance: Instance, pattern: table)
					recvInstance = instance
					recvPattern = pattern
				end
			)
			stitch:register(instance)
			stitch:emplace("test", instance, { foo = "bar" })
			stitch:replace("test", instance, { foo = "baz" })
			promise:await()
			expect(recvInstance).to.equal(instance)
			expect(recvPattern.foo).to.equal("baz")
			expect(getmetatable(recvPattern)).to.be.ok()
			instance:Destroy()
		end)
	end)

	describe("Stitch:onRemoved", function()
		it("should fire when a pattern is removed", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			local recvInstance, recvPattern
			local promise = Promise.fromEvent(stitch:GetOnRemovedSignal(testPattern)):andThen(
				function(instance: Instance, pattern: table)
					recvInstance = instance
					recvPattern = pattern
				end
			)
			stitch:register(instance)
			stitch:emplace("test", instance, { foo = "bar" })
			stitch:remove("test", instance)
			promise:await()
			expect(recvInstance).to.equal(instance)
			expect(recvPattern.foo).to.equal("bar")
			expect(getmetatable(recvPattern)).to.be.ok()
			expect(stitch:get("test", instance)).to.never.be.ok()
			instance:Destroy()
		end)
	end)
	describe("Stitch:remove", function()
		it("should remove the component from the entity", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			stitch:register(instance)
			stitch:emplace("test", instance, { foo = "bar" })
			local test1 = stitch:get("test", instance)
			expect(test1.foo).to.equal("bar")

			stitch:remove("test", instance)
			local test2 = stitch:get("test", instance)
			expect(test2).to.never.be.ok()

			instance:Destroy()
		end)
	end)

	describe("Stitch:emplaceOrReplace", function()
		it("should immutably replace data for component", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			stitch:register(instance)
			local test1 = stitch:emplaceOrReplace("test", instance, { foo = "bar" })
			expect(test1.foo).to.equal("bar")

			local test2 = stitch:emplaceOrReplace("test", instance, { foo = "baz" })
			expect(test2.foo).to.equal("baz")
			expect(test2 == test1).to.equal(false)

			instance:Destroy()
		end)
	end)

	describe("Stitch:patch", function()
		it("should immutably patch data for component", function()
			local testPattern = {
				name = "test",
			}
			stitch:addPattern(testPattern)

			local instance = Instance.new("Folder")
			instance.Parent = Workspace

			stitch:register(instance)
			local test1 = stitch:emplace("test", instance, { foo = "bar" })
			expect(test1.foo).to.equal("bar")

			local test2 = stitch:patch("test", instance, function(data)
				return {
					foo = "baz",
				}
			end)

			expect(test2.foo).to.equal("baz")
			expect(test2 == test1).to.equal(false)

			instance:Destroy()
		end)
	end)
end
