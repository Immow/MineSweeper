local cell = require("classes.cell")

local Board = {cells = {}}

function Board:generateCells(x, y)
	for i = 1, y do
		self.cells[i] = {}
		for j = 1, x do
			self.cells[i][j] = cell.new({
				index = {x = j, y = i}
			})
		end
	end
end

function Board:findBombNeighbours()
	for y, rows in ipairs (self.cells) do
		for x, cell in ipairs(rows) do
			if cell.bomb then
				for i = -1, 1 do
					for j = -1, 1 do
						if x+j >= 1 and x+j <= BOARD_SIZE_X and y+i >= 1 and y+i <= BOARD_SIZE_Y then
							if not self.cells[y+i][x+j].bomb then
								self.cells[y+i][x+j].bombCount = self.cells[y+i][x+j].bombCount + 1
							end
						end
					end
				end
			end
		end
	end
end

function Board:load()
	self:generateCells(BOARD_SIZE_X, BOARD_SIZE_Y)
	self:findBombNeighbours()
end

function Board:floodFill(x, y)
	if not cell.bomb then
		for i = -1, 1 do
			for j = -1, 1 do
				if x+j >= 1 and x+j <= BOARD_SIZE_X and y+i >= 1 and y+i <= BOARD_SIZE_Y then
					if not self.cells[y+i][x+j].bomb and not self.cells[y+i][x+j].revealed and self.cells[y+i][x+j].bombCount == 0 then
						self.cells[y+i][x+j].revealed = true
						self:floodFill(x+j, y+i)
					end
				end
			end
		end
	end
end

function Board:gameOver()
	for y, rows in ipairs (self.cells) do
		for x, cell in ipairs(rows) do
			self.cells[y][x].revealed = true
		end
	end
end

function Board:mousepressed(mx, my, mouseButton)
	for _, rows in ipairs(self.cells) do
		for _, cell in ipairs(rows) do
			cell:mousepressed(mx, my, mouseButton)
			if cell:containsPoint(mx, my) and mouseButton == 1 then
				if cell.bomb then
					self:gameOver()
				elseif cell.bombCount > 0 then
					cell.revealed = true
				else
					self:floodFill(cell.index.x, cell.index.y)
				end
			end
		end
	end
end

function Board:draw()
	for _, rows in ipairs(self.cells) do
		for _, cell in ipairs(rows) do
			cell:draw()
		end
	end
end

function Board:update(dt)
	-- self.cells:update(dt)
end

return Board