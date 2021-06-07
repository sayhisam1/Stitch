local Queue = {}
Queue.__init = Queue

function Queue.new()
	local self = setmetatable({}, Queue)
	local left, right = 1, 1
	function self:enqueue(value: any)
		table.insert(self, right, value)

		right += 1
	end
	function self:dequeue()
		if left == right then
			return
		end
		local ret = self[left]
		self[left] = nil
		left += 1
		return ret
	end
	function self:peek()
		if left == right then
			return
		end
		return self[left]
	end
	return self
end

return Queue
