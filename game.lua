local Game = {}

local Board = require("board")

function Game:load()
	Board:load()
end

function Game:mousepressed(mx, my, mouseButton)
	Board:mousepressed(mx, my, mouseButton)
end

function Game:mousereleased(x,y,button,istouch,presses)
	Board:mousereleased(x,y,button,istouch,presses)
end

function Game:draw()
	Board:draw()
end

function Game:update(dt)
	Board:update(dt)
end

return Game