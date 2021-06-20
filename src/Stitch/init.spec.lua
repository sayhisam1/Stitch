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
			local uuid = stitch:register(instance)
			expect(uuid).to.be.a("string")
			instance:Destroy()
		end)
		it("shouldn't allow registering the same instance multiple times", function()
			local instance = Instance.new("Folder")
			instance.Parent = Workspace
			local uuid = stitch:register(instance)
			expect(function()
				stitch:register(instance)
			end).to.throw()
			instance:Destroy()
		end)
	end)
end
