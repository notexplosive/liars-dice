love.math.setRandomSeed( os.time() )

require('logic')
require('game')
require('test')
require('render')

mainFont = love.graphics.newFont(12)

currentGame = newGame()
currentGame:setup(4,5)

function love.update(dt)
  -- body...
end

function love.draw()
  local y = 0
  love.graphics.setColor(255,255,255)
  love.graphics.setFont( mainFont )

  for i = 1, #currentGame.players do
    local name = currentGame.players[i].name
    if i == currentGame.currentPlayerIndex then
      name = name .. '*'
    end
    love.graphics.print(name,0,y)
    y = y+love.graphics.getFont():getHeight()
    drawHand(currentGame.players[i],0,y,32)
    love.graphics.setColor(255,255,255)
    y = y + 46
  end
end
