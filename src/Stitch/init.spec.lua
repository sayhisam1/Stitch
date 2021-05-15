local Stitch = require(script.Parent)

return function()
	local stitch
	beforeEach(function()
		stitch = Stitch.new("test")
	end)
	afterEach(function()
		stitch:Destroy()
		stitch = nil
	end)
	describe("Stitch.new", function()
		it("should return a stitch", function()
			expect(stitch.namespace).to.equal("test")
		end)
	end)

	describe("Stitch:registerPattern", function()
		it("should register patterns", function()
			local patternDefinition = {
				name = "Test",
			}

			local eventCount = 0
			local registered = nil
			stitch:on("patternRegistered", function(pattern)
				eventCount += 1
				registered = pattern
			end)
			stitch:registerPattern(patternDefinition)

			expect(eventCount).to.equal(1)
			expect(registered).to.equal(patternDefinition)
		end)

		it("shouldn't register duplicate patterns", function()
			local patternDefinition = {
				name = "Test",
			}

			stitch:registerPattern(patternDefinition)

			local patternDefinition2 = {
				name = "Test",
			}
			local stat, err = pcall(function()
				stitch:registerPattern(patternDefinition2)
			end)

			expect(stat).to.equal(false)
		end)
	end)

	describe("Stitch:getPatternByRef and Stitch:getOrCreateWorkingByRef", function()
		it("should create and get a pattern on ref", function()
			local patternDefinition = {
				name = "Test",
			}

			stitch:registerPattern(patternDefinition)

			local testRef = game.Workspace.Baseplate

			expect(stitch:getWorkingByRef("Test", testRef)).to.never.be.ok()

			stitch:getOrCreateWorkingByRef(patternDefinition, testRef)
			expect(stitch:getWorkingByRef("Test", testRef)).to.be.ok()
			local instanceUUID = stitch._collection:getInstanceUUID(testRef)
			expect(instanceUUID).to.be.ok()
			expect(stitch._collection._store:getState()["UUIDToInstance"][instanceUUID]).to.be.ok()
		end)
	end)

	describe("Stitch:removeAllPatternsWithRef", function()
		it("should remove all patterns with a ref", function()
			local patternDefinition = {
				name = "Test",
			}
			local patternDefinition2 = {
				name = "Test2",
			}

			stitch:registerPattern(patternDefinition)
			stitch:registerPattern(patternDefinition2)

			local testRef = game.Workspace.Baseplate

			stitch:getOrCreateWorkingByRef(patternDefinition, testRef)
			stitch:getOrCreateWorkingByRef(patternDefinition2, testRef)

			expect(stitch:getWorkingByRef("Test", testRef)).to.be.ok()
			expect(stitch:getWorkingByRef("Test2", testRef)).to.be.ok()

			stitch:removeAllWorkingsWithRef(testRef)

			expect(stitch:getWorkingByRef("Test", testRef)).to.never.be.ok()
			expect(stitch:getWorkingByRef("Test2", testRef)).to.never.be.ok()
		end)
	end)

	describe("Stitch:fire and Stitch:on", function()
		it("should fire events", function()
			local callCount = 0
			stitch:on("testEvent", function()
				callCount += 1
			end)

			expect(callCount).to.equal(0)

			stitch:fire("testEvent")

			expect(callCount).to.equal(1)

			stitch:fire("doesn't exist")

			expect(callCount).to.equal(1)
		end)
	end)
end
