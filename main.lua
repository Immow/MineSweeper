State = require("state")
require("constants")

function love.load()
	State.addScene("game")
	State.setScene("game")
	State:load()
end

function love.mousepressed(mx, my, mouseButton)
	State:mousepressed(mx, my, mouseButton)
end

function love.mousereleased(mx, my, mouseButton)
	State:mousereleased(mx, my, mouseButton)
end

function love.draw()
	State:draw()
end

function love.update(dt)
	State:update(dt)
end