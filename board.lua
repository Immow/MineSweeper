local cell = require("classes.cell")

local Board = {cells = {}}
local firstClick
local state

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
	firstClick = false
	state = "playing"
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
			cell.revealed = true
			cell.flag = false
		end
	end
	state = "game over"
	print("Game Over!")
end

function Board:gameWin()
	for y, rows in ipairs (self.cells) do
		for x, cell in ipairs(rows) do
			if cell.bomb and not cell.flag or not cell.bomb and not cell.revealed then
				return false
			end
		end
	end
	for y, rows in ipairs (self.cells) do
		for x, cell in ipairs(rows) do
			cell.revealed = true
			cell.flag = false
		end
	end
	state = "win"
	print("You Win!")
	return true
end

function Board:revealStartArea()
	local x = love.math.random(1, BOARD_SIZE_X)
	local y = love.math.random(1, BOARD_SIZE_Y)
	if self.cells[y][x].bombCount == 0 and not self.cells[y][x].bomb then
		self:floodFill(x, y)
	else
		self:revealStartArea()
	end
end

local function containsPoint(mx, my)
	if mx >= BOARD_OFFSET_X and mx <= BOARD_OFFSET_X + CELL_WIDTH * BOARD_SIZE_X and my >= BOARD_OFFSET_Y and my <= BOARD_OFFSET_Y + CELL_HEIGHT * BOARD_SIZE_Y then
		return true
	end
end

function Board:mousepressed(mx, my, mouseButton)
	if firstClick then
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
					self:floodFill(x, y)
				end
			end
		end
	else
		firstClick = true
		self:revealStartArea()
	end
end

function Board:mousereleased(x,y,button,istouch,presses)
	self:gameWin()
end

function Board:drawGameWin()
	local w, h = 400, 100
	if state == "win" then
		love.graphics.setColor(0.1,0.1,0.1)
		love.graphics.rectangle("fill", WINDOW_WIDTH / 2 - w / 2, WINDOW_HEIGHT / 2 - h / 2, w, h)
		love.graphics.setColor(1,1,1)
		love.graphics.printf("You Win!", 0, WINDOW_HEIGHT / 2 - FONT:getHeight() / 2, WINDOW_WIDTH, "center")
	end
end

function Board:drawGameOver()
	local w, h = 400, 100
	if state == "game over" then
		love.graphics.setColor(0.1,0.1,0.1)
		love.graphics.rectangle("fill", WINDOW_WIDTH / 2 - w / 2, WINDOW_HEIGHT / 2 - h / 2, w, h)
		love.graphics.setColor(1,1,1)
		love.graphics.printf("Game Over!", 0, WINDOW_HEIGHT / 2 - FONT:getHeight() / 2, WINDOW_WIDTH, "center")
	end
end

function Board:draw()
	for _, rows in ipairs(self.cells) do
		for _, cell in ipairs(rows) do
			cell:draw()
		end
	end
	self:drawGameWin()
	self:drawGameOver()
end

function Board:update(dt)

end

return Board