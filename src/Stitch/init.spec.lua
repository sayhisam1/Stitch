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
			stitch:on("patternRegistered", function()
				eventCount += 1
			end)
			stitch:registerPattern(patternDefinition)

			expect(eventCount).to.equal(1)
			expect(stitch._collection:resolvePattern(patternDefinition)).to.be.ok()
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

			expect(stitch:getPatternByRef("Test", testRef)).to.never.be.ok()

			local pattern = stitch:getOrCreatePatternByRef(patternDefinition, testRef)
			expect(stitch:getPatternByRef("Test", testRef)).to.be.ok()
			expect(stitch:getPatternByRef("Test", testRef)).to.equal(pattern)

			local uuid = stitch:getUuid(testRef)
			local patternData = stitch:lookupPatternByUuid(uuid)
			expect(patternData).to.be.ok()
			expect(stitch:getPatternByRef("Test", uuid)).to.be.ok()
			expect(stitch:getPatternByRef("Test", uuid)).to.equal(pattern)
		end)
	end)

	describe("Patterns", function()
		it("should set default data on pattern", function()
			local patternDefinition = {
				name = "Test",
			}

			stitch:registerPattern(patternDefinition)

			local testRef = game.Workspace.Baseplate
			local pattern = stitch:getOrCreatePatternByRef(patternDefinition, testRef, {
				variable = "1234",
			})

			expect(stitch:getPatternByRef("Test", testRef)).to.equal(pattern)
			expect(pattern:get("variable")).to.equal("1234")
		end)
		it("should update data on pattern", function()
			local patternDefinition = {
				name = "Test",
			}

			stitch:registerPattern(patternDefinition)

			local testRef = game.Workspace.Baseplate
			local pattern = stitch:getOrCreatePatternByRef(patternDefinition, testRef, {
				variable = "1234",
			})

			expect(stitch:getPatternByRef("Test", testRef)).to.equal(pattern)
			expect(pattern:get("variable")).to.equal("1234")

			pattern:set("variable", "spaghet")
			stitch:flushActions()
			expect(pattern:get("variable")).to.equal("spaghet")
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

			local test1 = stitch:getOrCreatePatternByRef(patternDefinition, testRef)
			local test2 = stitch:getOrCreatePatternByRef(patternDefinition2, testRef)
			local test2_child = stitch:getOrCreatePatternByRef(patternDefinition, test2)

			expect(stitch:getPatternByRef("Test", testRef)).to.be.ok()
			expect(stitch:getPatternByRef("Test2", testRef)).to.be.ok()
			expect(stitch:getPatternByRef("Test", test2)).to.be.ok()

			local deconstructedUuids = {}
			stitch:on("patternDeconstructed", function(uuid)
				table.insert(deconstructedUuids, uuid)
			end)

			stitch:deconstructPatternsWithRef(testRef)
			stitch:flushActions()

			expect(#deconstructedUuids).to.equal(4)

			for _, data in ipairs({ test1, test2, test2_child }) do
				expect(table.find(deconstructedUuids, data.uuid)).to.be.ok()
			end

			expect(stitch:getPatternByRef("Test", testRef)).to.never.be.ok()
			expect(stitch:getPatternByRef("Test2", testRef)).to.never.be.ok()
			expect(stitch:getPatternByRef("Test", test2)).to.never.be.ok()
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

	describe("stress test", function()
		SKIP()
		it("should be able to construct many patterns", function()
			local patternDefinition = {
				name = "Test",
			}

			stitch:registerPattern(patternDefinition)
			local instances = {}
			for i = 1, 8192, 1 do
				local part = Instance.new("Part")
				part.Anchored = true
				part.Parent = workspace
				table.insert(instances, part)
			end

			for i = 1, 1024, 1 do
				stitch:getOrCreatePatternByRef(patternDefinition, instances[i])
				stitch:deconstructPatternsWithRef(instances[i])
			end
			instances = {}
			for i = 1, 8192, 1 do
				local part = Instance.new("Part")
				part.Anchored = true
				part.Parent = workspace
				table.insert(instances, part)
			end

			for i = 1, 1024, 1 do
				stitch:getOrCreatePatternByRef(patternDefinition, instances[i])
				debug.profileend()
			end
		end)
	end)
end
