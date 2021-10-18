local TetrisLib = {}

function TetrisLib.createLayer(width, height)
	local layer = {}
	for i = 1, width do
		layer[i] = {}
		for j = 1, height do
			layer[i][j] = Color3.new(0, 0, 0)
		end
	end
	return layer
end

function TetrisLib.mergeColors(color1, color2)
    if color1 == Color3.new(0,0,0) then
        return color2
    end
    if color2 ~= Color3.new(0,0,0) then
        return nil
    end
    return color1
end

function TetrisLib.composeLayers(layer1, layer2)
	local width = #layer1
	local height = #layer1[1]
    local composedLayer = TetrisLib.createLayer(width, height)
	for i = 1, width do
		for j = 1, height do
			local nextColor = TetrisLib.mergeColors(layer1[i][j], layer2[i][j]) 
            if nextColor == nil then
                return nil
            end
            composedLayer[i][j] = nextColor
		end
	end
	return composedLayer
end


function TetrisLib.step(layer, direction:Vector2)
    local width = #layer
    local height = #layer[1]
    local newLayer = TetrisLib.createLayer(width, height)
    for i = 1, width do
        for j = 1, height do
            if layer[i][j] ~= Color3.new(0, 0, 0) then
                local newX = i + direction.X
                local newY = j + direction.Y
                if newX >= 1 and newX <= width and newY >= 1 and newY <= height then
                    newLayer[newX][newY] = layer[i][j]
                else
                    return nil
                end
            end
        end
    end
    return newLayer
end

TetrisLib.Tetromino = {}
TetrisLib.Tetromino.I = {
    {1},
    {1},
    {1},
    {1},
}
TetrisLib.Tetromino.J = {
    {0,1},
    {0,1},
    {1,1},
}
TetrisLib.Tetromino.T = {
    {1,1,1},
    {0,1,0},
}

TetrisLib.Colors = {
    Color3.new(1, 0, 0),
    Color3.new(0, 1, 0),
    Color3.new(0, 0, 1),
    Color3.new(1, 1, 0),
    Color3.new(1, 0, 1),
    Color3.new(0, 1, 1),
}
function TetrisLib.createTetriminoLayer(tetrimino, width, height)
    local layer = TetrisLib.createLayer(width, height)
    local tetriminoHeight = #tetrimino
    local tetriminoWidth = #tetrimino[1]
    local color = TetrisLib.Colors[math.random(1, #TetrisLib.Colors)]
    local mp = math.floor(width / 2)
    for i = 1, tetriminoHeight do
        for j = 1, tetriminoWidth do
            if tetrimino[i][j] == 1 then
                layer[mp+j-1][height-i+1] = color
            end
        end
    end
    return layer
end
function TetrisLib.createRandomTetriminoLayer(width, height)
    local tetriminos = {}
    for _, v in pairs(TetrisLib.Tetromino) do
        table.insert(tetriminos, v)
    end

    local tetrimino = tetriminos[math.random(1, #tetriminos)]
    return TetrisLib.createTetriminoLayer(tetrimino, width, height)
end
return TetrisLib
