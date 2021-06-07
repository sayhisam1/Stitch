local HttpService = game:GetService("HttpService")

local HashMappedTrie = require(script.Parent.HashMappedTrie)
return function()
	describe("insertion", function()
		SKIP()
		it("should insert a single value", function()
			local trie = HashMappedTrie.new()
			local val = {}
			trie = HashMappedTrie.set(trie, "TESTINGABCD", val)
			expect(HashMappedTrie.get(trie, "TESTINGABCD")).to.equal(val)
		end)
		it("should insert multiple values", function()
			local trie = HashMappedTrie.new()
			local values = {
				AAAAAAA = {},
				BBBBBBB = {},
				CCCCCCC = {},
				DDDDDDD = {},
				EEEEEEE = {},
			}
			for k, v in pairs(values) do
				trie = HashMappedTrie.set(trie, k, v)
			end
			for k, v in pairs(values) do
				expect(HashMappedTrie.get(trie, k)).to.equal(v)
			end
		end)
		it("should resize hashmap", function()
			local trie = HashMappedTrie.new()
			local values = {}
			for i = 1, 1024, 1 do
				local key = HttpService:GenerateGUID(false)
				values[key] = {}
			end
			for k, v in pairs(values) do
				trie = HashMappedTrie.set(trie, k, v)
			end
			for k, v in pairs(values) do
				expect(HashMappedTrie.get(trie, k)).to.equal(v)
			end
		end)
		it("should get all key-value pairs", function()
			local trie = HashMappedTrie.new()
			local values = {}
			for i = 1, 128, 1 do
				local key = HttpService:GenerateGUID(false)
				values[key] = {}
			end
			for k, v in pairs(values) do
				trie = HashMappedTrie.set(trie, k, v)
			end
			for k, v in pairs(HashMappedTrie.getAllKeyValues(trie)) do
				expect(values[k]).to.equal(v)
				values[k] = nil
			end
			for k, v in pairs(values) do
				expect(false).to.equal(true)
			end
		end)
		it("should be immutable", function()
			local trie = HashMappedTrie.new()
			local values = {}
			for i = 1, 1024, 1 do
				local key = HttpService:GenerateGUID(false)
				values[key] = {}
			end
			local newtrie = trie
			for k, v in pairs(values) do
				local tmp = HashMappedTrie.set(trie, k, v)
				expect(HashMappedTrie.get(newtrie, k)).to.never.be.ok()
				newtrie = tmp
			end
			for k, v in pairs(values) do
				expect(HashMappedTrie.get(trie, k)).to.never.be.ok()
			end
		end)
	end)
end
