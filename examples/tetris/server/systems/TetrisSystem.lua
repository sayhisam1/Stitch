return function(stitch)
	local boards = {}
	stitch:on("patternConstructed", function(uuid)
		local pattern = stitch:lookupPatternByUuid(uuid)
		if pattern.patternName == "tetrisBoard" then
			boards[uuid] = uuid
		end
	end)

	stitch.remoteEvent.OnServerEvent:Connect(function(player: Player, systemName: string, uuid: string, command: string, direction: string)
		if systemName == "TetrisSystem" then
			local board = stitch:lookupPatternByUuid(uuid)
			local next_offset = direction == "left" and Vector2.new(-1, 0) or Vector2.new(1, 0)
			board:set("next_offset", next_offset)
		end
	end)

	local running = true
	coroutine.wrap(function()
		while wait(0.1) and running do
			for _, uuid in pairs(boards) do
				local board = stitch:lookupPatternByUuid(uuid)
				local boardState = board:get("boardState")

				local newBoardState = table.create(#boardState)
				for i = 1, #boardState, 1 do
					newBoardState[i] = table.create(#boardState[i])
					for j = 1, #boardState[i], 1 do
						newBoardState[i][j] = boardState[i][j]
					end
				end

				local activeSquare = board:get("activeSquare")
				if activeSquare == nil then
					activeSquare = Vector2.new(10, 20)
					newBoardState[20][10] = Color3.new(1, 0, 0)
				else
					local next_offset = board:get("next_offset")
					local nextActiveSquare = activeSquare - Vector2.new(0, 1)
					if next_offset then
						nextActiveSquare = Vector2.new(
							math.clamp(nextActiveSquare.X + next_offset.X, 1, 10),
							nextActiveSquare.Y
						)
					end
					if
						board.inBounds(nextActiveSquare)
						and newBoardState[nextActiveSquare.Y][nextActiveSquare.X] == Color3.new(0, 0, 0)
					then
						newBoardState[activeSquare.Y][activeSquare.X] = Color3.new(0, 0, 0)
						newBoardState[nextActiveSquare.Y][nextActiveSquare.X] = Color3.new(1, 0, 0)
						activeSquare = nextActiveSquare
					else
						activeSquare = Vector2.new(10, 20)
						newBoardState[20][10] = Color3.new(1, 0, 0)
					end
				end

				board:set("boardState", newBoardState)
				board:set("activeSquare", activeSquare)
				board:set("next_offset", nil)
			end
		end
	end)()
	stitch:on("destroyed", function()
		running = false
	end)
end
