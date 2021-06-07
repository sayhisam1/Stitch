local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local BOARD_BLOCK_SIZE = 2
local default_boardstate = table.create(20)
for i = 1, 20 do
	default_boardstate[i] = table.create(10, Color3.fromRGB(0, 0, 0))
end
local tetrisBoard = {
	name = "tetrisBoard",
	replicated = true,
	data = {
		boardState = default_boardstate,
		position = Vector3.new(0, 0, 0),
	},
}

if RunService:IsClient() then
	function tetrisBoard:render(e)
		-- draw the board every time it is updated
		local boardState = self:get("boardState")
		local position = self:get("position")
		local elements = table.create(20 * 10)
		for i = 1, 20, 1 do
			for j = 1, 10, 1 do
				local unrolled_idx = (i - 1) * 10 + j
				elements[unrolled_idx] = e(self.stitch.roact.Portal, {
					target = Workspace,
				}, {
					part = e("Part", {
						Anchored = true,
						CanCollide = false,
						Size = Vector3.new(1, 1, 1) * BOARD_BLOCK_SIZE,
						Position = position + Vector3.new((j - 1), (i - 1), 0) * BOARD_BLOCK_SIZE,
						Color = boardState[i][j],
					}),
				})
			end
		end
		return self.stitch.roact.createFragment(elements)
	end
end

function tetrisBoard.inBounds(loc: Vector2)
	return loc.Y <= 20 and loc.Y >= 1 and loc.X <= 10 and loc.X >= 1
end

return tetrisBoard
