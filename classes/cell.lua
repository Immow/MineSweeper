local Cell = {}
Cell.__index = Cell

local flag = love.graphics.newImage("assets/img/flag.png")
local bomb = love.graphics.newImage("assets/img/bomb.jpg")

local function random()
	local r = love.math.random(1, 10)
	if r > 1 then
		return false
	else
		return true
	end
end

function Cell.new(settings)
	local instance = setmetatable({}, Cell)
	instance.x         = (settings.index.x - 1) * CELL_WIDTH + BOARD_OFFSET_X
	instance.y         = (settings.index.y - 1) * CELL_HEIGHT + BOARD_OFFSET_Y
	instance.width     = settings.width or 50
	instance.height    = settings.height or 50
	instance.bomb     = random()
	instance.bombCount = 0
	instance.text      = 0
	instance.index     = settings.index
	instance.flag      = false
	instance.revealed  = false
	return instance
end

function Cell:containsPoint(x, y)
	return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

function Cell:placeFlag(button)
	if button == 2 then
		if self.flag then
			self.flag = false
		else
			self.flag = true
		end
	end
end

function Cell:mousepressed(x,y,button,istouch,presses)
	self:placeFlag(button)
end

function Cell:update(dt)
end

function Cell:CellGrid()
	if self.revealed then
		love.graphics.setColor(1,1,1)
	else
		love.graphics.setColor(0.9,0.9,0.9)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(0.2,0.2,0.2)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Cell:drawBomb()
	if self.bomb and self.revealed then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(bomb, self.x, self.y, 0, 0.09765625, 0.09765625)
	end
end

function Cell:drawFlag()
	if self.flag then
		love.graphics.setColor(1,1,1)
		local scale = 0.5
		love.graphics.draw(
			flag,
			self.x + CELL_WIDTH / 2 - (flag:getWidth() / 2) * scale,
			self.y + CELL_HEIGHT / 2 - (flag:getHeight() / 2) * scale,
			0,
			scale,
			scale
		)
	end
end

function Cell:drawBombCount()
	if self.revealed then
		local textBombCountWidth = tostring(self.bombCount)
		if self.bombCount > 0 then
			love.graphics.setColor(1,0,0)
			love.graphics.print(
				self.bombCount,
				self.x + CELL_WIDTH / 2 - FONT:getWidth(textBombCountWidth) / 2,
				self.y + CELL_HEIGHT / 2 - FONT:getHeight() / 2
			)
		end
	end
end

function Cell:draw()
	self:CellGrid()
	self:drawBomb()
	self:drawBombCount()
	self:drawFlag()
end

return Cell