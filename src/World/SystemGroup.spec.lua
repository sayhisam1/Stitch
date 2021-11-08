local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local SystemGroup = require(script.Parent.SystemGroup)

return function()
	local bindableEvent
	local systemGroup
	beforeEach(function()
		bindableEvent = Instance.new("BindableEvent")
		systemGroup = SystemGroup.new(bindableEvent.Event)
	end)

	afterEach(function()
		systemGroup:destroy()
		bindableEvent:destroy()
	end)

	describe("SystemGroup.new", function()
		it("should return an SystemGroup with a valid event listener", function()
			expect(systemGroup).to.be.ok()
			expect(systemGroup._listener).to.be.ok()
		end)
	end)

	describe("SystemGroup:addSystem", function()
		it("should add a system", function()
			local system = {
				name = "test",
				priority = 10,
				destroy = function() end,
			}
			systemGroup:addSystem(system)
		end)
		it("should call system create", function()
			local created = false
			local system = {
				name = "test",
				priority = 10,
				destroy = function() end,
				create = function()
					created = true
				end,
			}
			systemGroup:addSystem(system)
			local promise = Promise.fromEvent(bindableEvent.Event)
			bindableEvent:Fire()
			promise:await()
			expect(created).to.equal(true)
		end)
		it("should respect priorities", function()
			local systemct = nil
			local system2ct = nil
			local counter = 1
			local system = {
				name = "test",
				priority = 10,
				update = function()
					systemct = counter
					counter += 1
				end,
				destroy = function() end,
			}
			local system2 = {
				name = "test2",
				priority = 9,
				update = function()
					system2ct = counter
					counter += 1
				end,
				destroy = function() end,
			}
			systemGroup:addSystem(system)
			systemGroup:addSystem(system2)
			systemGroup:updateSystems()
			expect(systemct).to.equal(2)
			expect(system2ct).to.equal(1)
		end)
	end)
	describe("SystemGroup:update", function()
		it("should properly update all systems", function()
			local updated = false
			local system = {
				name = "test",
				priority = 10,
				destroy = function() end,
				update = function()
					updated = true
				end,
			}
			systemGroup:addSystem(system)
			systemGroup:updateSystems()
			expect(updated).to.equal(true)
		end)
		it("should pass fired with args to systems", function()
			local received = nil
			local system = {
				name = "test",
				priority = 10,
				destroy = function() end,
				update = function(self, ...)
					received = {...}
				end,
			}
			systemGroup:addSystem(system)
			local promise = Promise.fromEvent(bindableEvent.Event)
			bindableEvent:Fire("foo")
			promise:await()
			expect(#received).to.equal(2)
			expect(received[1]).to.equal(nil) -- no world in this case
			expect(received[2]).to.equal("foo")
		end)
		it("should update on event fire", function()
			local updated = false
			local system = {
				name = "test",
				priority = 10,
				destroy = function() end,
				update = function()
					updated = true
				end,
			}
			systemGroup:addSystem(system)
			local promise = Promise.fromEvent(bindableEvent.Event)
			bindableEvent:Fire()
			promise:await()
			expect(updated).to.equal(true)
		end)
	end)
end
