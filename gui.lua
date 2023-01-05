local Gui = {w = love.graphics.getDimensions(), h = CELL_HEIGHT, time = 0}

local Board = require("board")
local offset = CELL_HEIGHT / 2 - GUI_FONT:getHeight() / 2
local smile = love.graphics.newImage("assets/img/smile.png")
local sad = love.graphics.newImage("assets/img/sad.png")

function Gui:load()
	self.time = 0
end

function Gui:update(dt)
	if State.getGameState() == "playing" then
		self.time = self.time + 1 * dt
	end
end

function Gui:drawBombCount()
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(GUI_FONT)
	love.graphics.print(tostring(BOMBCOUNT), offset, offset)
end

function Gui:drawTime()
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(GUI_FONT)
	love.graphics.printf(tostring(math.floor(self.time)), 0, offset, WINDOW_WIDTH - offset, "right")
end

function Gui:drawBackground()
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("fill", 0, 0, self.w, self.h)
end

function Gui:drawSmile()
	local w, h = smile:getDimensions()
	love.graphics.setColor(0,0,0)
	if State.getGameState() ~= "game over" then
		love.graphics.draw(smile, WINDOW_WIDTH / 2 - w / 2, CELL_HEIGHT / 2 - h / 2)
	else
		love.graphics.draw(sad, WINDOW_WIDTH / 2 - w / 2, CELL_HEIGHT / 2 - h / 2)
	end
end

local function containsPoint(x, y)
	local w, h = smile:getDimensions()
	if x >= WINDOW_WIDTH / 2 - w / 2 and x <= WINDOW_WIDTH / 2 + w / 2 and y >= CELL_HEIGHT / 2 - h / 2 and y <= CELL_HEIGHT / 2 + h / 2 then
		return true
	end
end

function Gui:mousepressed(mx, my, button, istouch, presses)
	if containsPoint(mx, my) then
		State.setGameState("paused")
		Board:load()
		Gui:load()
	end
end

function Gui:draw()
	self:drawBackground()
	self:drawBombCount()
	self:drawTime()
	self:drawSmile()
end

return Gui