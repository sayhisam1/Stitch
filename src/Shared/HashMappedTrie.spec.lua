local HttpService = game:GetService("HttpService")

local HashMappedTrie = require(script.Parent.HashMappedTrie)
return function()
	describe("insertion", function()
		it("should insert a single value", function()
			local trie = {}
			local val = {}
			trie = HashMappedTrie.set(trie, "TESTINGABCD", val)
			expect(HashMappedTrie.get(trie, "TESTINGABCD")).to.equal(val)
		end)
		it("should insert multiple values", function()
			local trie = {}
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
			local trie = {}
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
	end)
end
