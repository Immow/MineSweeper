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
					elseif self.cells[y+i][x+j].bombCount > 0 and not self.cells[y+i][x+j].revealed then
						self.cells[y+i][x+j].revealed = true
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
			self.cells[y][x].flag = false
		end
	end
	print("Game Over!")
end

function Board:gameWin()
	for y, rows in ipairs (self.cells) do
		for x, cell in ipairs(rows) do
			if self.cells[y][x].bomb and not self.cells[y][x].flag or not self.cells[y][x].bomb and not self.cells[y][x].revealed then
				return false
			end
		end
	end
	for y, rows in ipairs (self.cells) do
		for x, cell in ipairs(rows) do
			self.cells[y][x].revealed = true
			self.cells[y][x].flag = false
		end
	end
	print("You Win!")
	return true
end

local function containsPoint(mx, my)
	if mx >= BOARD_OFFSET_X and mx <= BOARD_OFFSET_X + CELL_WIDTH * BOARD_SIZE_X and my >= BOARD_OFFSET_Y and my <= BOARD_OFFSET_Y + CELL_HEIGHT * BOARD_SIZE_Y then
		return true
	end
end

function Board:mousepressed(mx, my, mouseButton)
	if containsPoint(mx, my) then
		local x = math.floor((mx - BOARD_OFFSET_X) / CELL_WIDTH) + 1
		local y = math.floor((my - BOARD_OFFSET_Y) / CELL_HEIGHT) + 1
		local cell = self.cells[y][x]
		cell:mousepressed(mx, my, mouseButton)
		if mouseButton == 1 then
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

function Board:mousereleased(x,y,button,istouch,presses)

	self:gameWin()
end

function Board:draw()
	for _, rows in ipairs(self.cells) do
		for _, cell in ipairs(rows) do
			cell:draw()
		end
	end
end

function Board:update(dt)

end

return Board