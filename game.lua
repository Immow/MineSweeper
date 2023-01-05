local Game = {}

local Board = require("board")
local Gui = require("gui")

function Game:load()
	Board:load()
end

function Game:mousepressed(mx, my, mouseButton)
	Board:mousepressed(mx, my, mouseButton)
	Gui:mousepressed(mx, my, mouseButton)
end

function Game:mousereleased(x,y,button,istouch,presses)
	Board:mousereleased(x,y,button,istouch,presses)
end

function Game:keypressed(key,scancode,isrepeat)
	if scancode == "space" then
		State.setGameState("paused")
		Board:load()
		Gui:load()
	end
end

function Game:draw()
	Board:draw()
	Gui:draw()
end

function Game:update(dt)
	Board:update(dt)
	Gui:update(dt)
end

return Game