-- small functional 2d-array operation library for lua
local Matrices = {}

function Matrices.getShape(matrix)
	local nrows = 0
	for i, _ in pairs(matrix) do
		nrows += 1
	end
	local ncols = 0
	for j, _ in pairs(matrix[1]) do
		ncols += 1
	end
	return nrows, ncols
end

function Matrices.rotateLeft(matrix)
	local height, length = Matrices.getShape(matrix)
	local result = Matrices.fill(height, height, nil)
	local sh = (height + 1) / 2
	local sl = (height + 1) / 2

	for y = 1, height do
		for x = 1, height do
			-- shift origin
			local si = y - sh
			local sj = x - sl
			si, sj = -sj, si
			-- shift back
			si = math.floor(si + sh)
			sj = math.floor(sj + sl)
			result[si][sj] = matrix[y][x]
		end
	end
	return result
end

function Matrices.rotateRight(matrix)
	local height, length = Matrices.getShape(matrix)
	local result = Matrices.fill(height, height, nil)
	local sh = (height + 1) / 2
	local sl = (height + 1) / 2

	for y = 1, height do
		for x = 1, height do
			-- shift origin
			local si = y - sh
			local sj = x - sl
			si, sj = sj, -si
			-- shift back
			si = math.floor(si + sh)
			sj = math.floor(sj + sl)
			result[si][sj] = matrix[y][x]
		end
	end
	return result
end

function Matrices.fill(height, width, value)
	local result = {}
	for i = 1, height do
		result[i] = {}
		for j = 1, width do
			result[i][j] = value
		end
	end
	return result
end

function Matrices.clone(a)
	local result = {}
	for i, row in pairs(a) do
		result[i] = {}
		for j, cell in pairs(row) do
			result[i][j] = cell
		end
	end
	return result
end

function Matrices.merge(a, b, merger, offset: Vector2)
	offset = offset or Vector2.new(0, 0)
	local result = Matrices.clone(b)
	for i = 1, #a do
		result[i] = {}
		for j = 1, #a[i] do
			result[i][j] = merger(a[i][j], b[i + offset.X][j + offset.Y])
		end
	end
	return result
end

-- is merge, but ignores out-of-bounds positions
function Matrices.mergeInBounds(a, b, merger, offset: Vector2)
	offset = offset or Vector2.new(0, 0)
	local result = Matrices.clone(b)
	for i = 1, #a do
		result[i + offset.X] = {}
		if i + offset.X < 1 or i + offset.X > #b then
			continue
		end
		for j = 1, #a[i] do
			if j + offset.Y < 1 or j + offset.Y > #b[i + offset.X] then
				continue
			end
			result[i + offset.X][j + offset.Y] = merger(a[i][j], b[i + offset.X][j + offset.Y])
		end
	end
	return result
end

return Matrices
