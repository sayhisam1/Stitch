local Matrices = require(script.Parent.Matrices)
local Tetrimino = {}

local _ = nil
Tetrimino.TEMPLATES = {}
Tetrimino.TEMPLATES.I = {
	{ _, _, 1, _ },
	{ _, _, 1, _ },
	{ _, _, 1, _ },
	{ _, _, 1, _ },
}
Tetrimino.TEMPLATES.J = {
	{ _, _, 1, _ },
	{ _, _, 1, _ },
	{ _, 1, 1, _ },
	{ _, _, _, _ },
}
Tetrimino.TEMPLATES.T = {
	{ _, 1, 1, 1 },
	{ _, _, 1, _ },
	{ _, _, _, _ },
	{ _, _, _, _ },
}
Tetrimino.COLORS = {
	Color3.new(1, 0, 0),
	Color3.new(0, 1, 0),
	Color3.new(0, 0, 1),
	Color3.new(1, 1, 0),
	Color3.new(1, 0, 1),
	Color3.new(0, 1, 1),
}

function Tetrimino.createRandom()
	local templates = {}
	for _, v in pairs(Tetrimino.TEMPLATES) do
		table.insert(templates, v)
	end

	return Tetrimino.new(templates[math.random(1, #templates)], Vector2.new(0,0), Tetrimino.COLORS[math.random(1, #Tetrimino.COLORS)])
end

function Tetrimino.new(template, offset: Vector2, color: Color3)
	local tetrimino = {
		template = template,
		offset = offset or Vector2.new(0, 0),
		height = #template,
		width = #template[1],
		color = color,
	}

	return tetrimino
end

function Tetrimino.rotate(tetrimino, direction: number)
	direction = direction or 0
	if direction == 0 then
		return tetrimino
	end
	if direction == -1 then
		return Tetrimino.new(Matrices.rotateLeft(tetrimino.template), tetrimino.offset, tetrimino.color)
	end
	if direction == 1 then
		return Tetrimino.new(Matrices.rotateRight(tetrimino.template), tetrimino.offset, tetrimino.color)
	end
	error(("tried to rotate invalid direction %s"):format(direction))
end

function Tetrimino.move(tetrimino, direction: Vector2)
	return Tetrimino.new(tetrimino.template, tetrimino.offset + direction, tetrimino.color)
end

return Tetrimino
