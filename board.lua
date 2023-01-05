local cell = require("classes.cell")

local Board = {cells = {}}
local firstClick
local isDown = false

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
	BOMBCOUNT = 0
	self:generateCells(BOARD_SIZE_X, BOARD_SIZE_Y)
	self:findBombNeighbours()
	firstClick = false
end

function Board:floodFill(x, y)
	if not cell.bomb then
		for i = -1, 1 do
			for j = -1, 1 do
				if x+j >= 1 and x+j <= BOARD_SIZE_X and y+i >= 1 and y+i <= BOARD_SIZE_Y then
					local cell = self.cells[y+i][x+j]
					if not cell.bomb and not cell.revealed and cell.bombCount == 0 then
						cell.revealed = true
						if cell.flag then
							cell.flag = false
							BOMBCOUNT = BOMBCOUNT + 1
						end
						self:floodFill(x+j, y+i)
					elseif cell.bombCount >= 0 and not cell.revealed then
						cell.revealed = true
						if cell.flag then
							cell.flag = false
							BOMBCOUNT = BOMBCOUNT + 1
						end
					end
				end
			end
		end
	end
end

function Board:reavealNeighbours(x, y)
	for i = -1, 1 do
		for j = -1, 1 do
			if x+j >= 1 and x+j <= BOARD_SIZE_X and y+i >= 1 and y+i <= BOARD_SIZE_Y then
				local cell = self.cells[y+i][x+j]

				if cell.bomb and not cell.flag then
					self:gameOver()
					return
				end

				if cell.bombCount == 0 and not cell.revealed and not cell.flag and not cell.bomb then
					self:floodFill(x+j, y+i)
				end

				if not cell.revealed and not cell.flag then
					cell.revealed = true
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
	State.setGameState("game over")
end

function Board:gameWin()
	for y, rows in ipairs (self.cells) do
		for x, cell in ipairs(rows) do
			if cell.bombCount >= 0 and not cell.bomb and not cell.revealed then
				return false
			end
		end
	end
	State.setGameState("win")
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

local function containsPoint(x, y)
	if x >= BOARD_OFFSET_X and x <= BOARD_OFFSET_X + CELL_WIDTH * BOARD_SIZE_X and y >= BOARD_OFFSET_Y and y <= BOARD_OFFSET_Y + CELL_HEIGHT * BOARD_SIZE_Y then
		return true
	end
end

function Board:mousepressed(mx, my, mouseButton)
	if firstClick then
		if containsPoint(mx, my) then
			local x = math.floor((mx - BOARD_OFFSET_X) / CELL_WIDTH) + 1
			local y = math.floor((my - BOARD_OFFSET_Y) / CELL_HEIGHT) + 1
			local cell = self.cells[y][x]
			if State.getGameState() == "playing" then
				cell:mousepressed(mx, my, mouseButton)
			end
			if mouseButton == 1 then
				if cell.bomb and not cell.flag then
					self:gameOver()
				elseif cell.bombCount > 0 and not cell.flag then
					cell.revealed = true
				elseif not cell.flag then
					self:floodFill(x, y)
				end
			end
		end
	else
		firstClick = true
		self:revealStartArea()
		State.setGameState("playing")
	end
end

function Board:mousereleased(x,y,button,istouch,presses)
	self:gameWin()
end

function Board:drawGameWin()
	local w, h = 400, 100
	if State.getGameState() == "win" then
		love.graphics.setColor(0.1,0.1,0.1)
		love.graphics.rectangle("fill", WINDOW_WIDTH / 2 - w / 2, WINDOW_HEIGHT / 2 - h / 2, w, h)
		love.graphics.setColor(1,1,1)
		love.graphics.printf("You Win!", 0, WINDOW_HEIGHT / 2 - FONT:getHeight() / 2, WINDOW_WIDTH, "center")
	end
end

function Board:drawGameOver()
	local w, h = 200, 50
	if State.getGameState() == "game over" then
		love.graphics.setColor(0.1,0.1,0.1, 0.5)
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
	local mx, my = love.mouse.getPosition()

	if love.mouse.isDown(1) and love.mouse.isDown(2) then
		if containsPoint(mx, my) then
			local x = math.floor((mx - BOARD_OFFSET_X) / CELL_WIDTH) + 1
			local y = math.floor((my - BOARD_OFFSET_Y) / CELL_HEIGHT) + 1
			local cell = self.cells[y][x]
			if not isDown and cell.bombCount > 0 and cell.revealed then
				self:reavealNeighbours(x, y)
				isDown = true
			end
		end
	else
		isDown = false
	end
end

return Board