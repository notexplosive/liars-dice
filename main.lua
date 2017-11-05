love.math.setRandomSeed( os.time() )

require('logic')
require('game')
require('test')
require('render')
require('button')

mainFont = love.graphics.newFont(12)

currentGame = newGame()
currentGame:setup(4,5)

clientBet = {face=2,count=1}
history = {}

callButton = newButton(400,360,200,32,'Call!',function()
  local caller_lost = currentGame:evaluate()
  if caller_lost == nil then return end
  local loser = 0
  local winner = 0
  if caller_lost then
    loser = currentGame.currentPlayerIndex
    winner = currentGame.currentSubmitter
  else
    loser = currentGame.currentSubmitter
    winner = currentGame.currentPlayerIndex
  end
  currentGame.players[loser].health = currentGame.players[loser].health - 1
  clientBet.count = 1
  clientBet.face = 2
  currentGame:setupRound(winner)
end)
betButton = newButton(400,400,200,32,'Place Bet!',function()
  local p = currentGame.currentPlayerIndex
  if currentGame:submitBet(clientBet) then
    history[#history+1] = {face=clientBet.face,count=clientBet.count,player=p}
  end
end)
faceUpButton = newButton(400,440, 90,32,'- Face',function()
  clientBet.face = clientBet.face - 1
  if clientBet.face < 2 then
    clientBet.face = 6
  end
end)
faceDownButton = newButton(510,440,90,32,'+ Face',function()
  clientBet.face = clientBet.face + 1
  if clientBet.face > 6 then
    clientBet.face = 2
  end
end)
countUpButton = newButton(400,480,90,32,'- Count',function()
  clientBet.count = clientBet.count - 1
  if clientBet.count < 1 then
    clientBet.count = 1
  end
end)
countDownButton = newButton(510,480,90,32,'+ Count',function()
  clientBet.count = clientBet.count + 1
  local totalDice = 0
  for i = 1, #currentGame.players do
    totalDice = totalDice + currentGame.players[i].health
  end
  if clientBet.count > totalDice then
    clientBet.count = totalDice
  end
end)

function love.draw()
  local y = 0
  love.graphics.setColor(255,255,255)
  love.graphics.setFont( mainFont )

  for i = 1, #Buttons do
    Buttons[i]:draw()
  end

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

  drawBet(clientBet,400,200)
  drawBet(currentGame.currentBet,400,10)
end
