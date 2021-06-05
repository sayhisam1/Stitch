local Stitch = require(script.Parent.Parent)

local PATTERN_DEFINITION = {
	name = "Test",
}

return function()
	local stitch, store, testInstance, testInstanceUuid
	beforeEach(function()
		stitch = Stitch.new("test")
		store = stitch._store
		testInstance = Instance.new("Part")
		testInstance.Anchored = true
		testInstanceUuid = stitch:registerInstance(testInstance)
	end)
	afterEach(function()
		stitch:destroy()
		testInstance:destroy()
		testInstance = nil
		stitch = nil
		store = nil
	end)
	describe("construction", function()
		it("should construct a pattern", function()
			local pattern = stitch:registerPattern(PATTERN_DEFINITION)
			store:dispatch({
				type = "constructPattern",
				data = {
					variable = "1234",
				},
				refuuid = testInstanceUuid,
				uuid = "12345",
				pattern = pattern,
			})
			local created = store:lookup("12345")
			expect(created).to.be.ok()
			expect(created.data.variable).to.equal("1234")
		end)
	end)
end
