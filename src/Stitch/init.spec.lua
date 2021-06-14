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

	describe("atomic dispatches", function()
		it("should follow normal dispatch rules", function()
			local patternDefinition = {
				name = "Test",
			}
			stitch:registerPattern(patternDefinition)
			local pattern = stitch:getOrCreatePatternByRef("Test", game.Workspace)
			stitch:doAtomicTask(function()
				pattern:set("testval", "foo")
			end)
			expect(pattern:get("testval")).to.never.be.ok()
			stitch:flushActions()
			expect(pattern:get("testval")).to.equal("foo")
		end)
		it("should do actions atomically", function()
			local patternDefinition = {
				name = "Test",
			}
			stitch:registerPattern(patternDefinition)
			local pattern = stitch:getOrCreatePatternByRef("Test", game.Workspace)
			pcall(stitch.doAtomicTask, stitch, function()
				pattern:set("testval", "foo")
				stitch:deconstructPatternsWithRef(game.Workspace)
				error("somefailure")
			end)
			stitch:flushActions()
			pattern = stitch:getPatternByRef("Test", game.Workspace)
			expect(pattern).to.be.ok()
			expect(pattern:get("testval")).to.never.be.ok()

			stitch.debug = true
			stitch:doAtomicTask(function()
				pattern:set("testval", "foo")
				stitch:deconstructPatternsWithRef(game.Workspace)
				-- force an error by double-destroying the same ref
				stitch:deconstructPatternsWithRef(game.Workspace)
			end)
			stitch:flushActions()
			pattern = stitch:getPatternByRef("Test", game.Workspace)
			expect(pattern).to.be.ok()
			expect(pattern:get("testval")).to.never.be.ok()
		end)
		it("should do actions atomically between two patterns", function()
			-- simulate a player trade
			local playerPattern = {
				name = "playerData",
				data = {
					items = {},
				},
			}
			stitch:registerPattern(playerPattern)
			local pattern1 = stitch:getOrCreatePatternByRef("playerData", game.Workspace)
			local pattern2 = stitch:getOrCreatePatternByRef("playerData", game.Lighting)
			pattern1:set("items", { "foo" })
			pattern2:set("items", { "bar" })
			stitch:flushActions()
			stitch:doAtomicTask(function()
				pattern1:set("items", { "bar" })
				pattern2:set("items", { "foo" })
			end)
			stitch:flushActions()
			expect(function()
				local tbl = pattern1:get("items")
				assert(#tbl == 1, "invalid count")
				assert(tbl[1] == "bar", "invalid item")
			end).to.never.throw()

			expect(function()
				local tbl = pattern2:get("items")
				assert(#tbl == 1, "invalid count")
				assert(tbl[1] == "foo", "invalid item")
			end).to.never.throw()

			stitch:doAtomicTask(function()
				pattern1:set("items", { "foo" })
				pattern2:set("items", { "bar" })
				stitch:deconstructPatternsWithRef(game.Workspace)
				stitch:deconstructPatternsWithRef(game.Lighting)
			end)

			stitch:flushActions()

			local pattern1 = stitch:getPatternByRef("playerData", game.Workspace)
			local pattern2 = stitch:getPatternByRef("playerData", game.Lighting)
			expect(pattern1).to.never.be.ok()
			expect(pattern2).to.never.be.ok()
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
