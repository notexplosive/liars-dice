love.math.setRandomSeed( os.time() )

require('logic')
require('game')
require('test')
require('render')
require('button')
require('bot')
require('ui')

mainFont = love.graphics.newFont(12)

currentGame = newGame()
currentGame:setup(4,5)

clientIndex = 1
clientBet = {face=2,count=1}
history = {}
previousRoundWinner = 0

local prev_state = ''
local timeAccumulate = 0

function love.update(dt)
  if prev_state ~= currentGame.state then
    prev_state = currentGame.state
    print(currentGame.state)
  end

  if currentGame.state ~= 'game_over' then
    if currentGame.currentPlayerIndex ~= clientIndex and currentGame.state ~= 'round_over' then
      local estimate = estimateBoard(currentGame.players[currentGame.currentPlayerIndex].hand,currentGame:totalDice())
      timeAccumulate = timeAccumulate + dt
      if timeAccumulate > love.math.random(3)/10 then
        local output = botTurn(currentGame.players[currentGame.currentPlayerIndex].hand,currentGame:totalDice(),currentGame.currentBet)
        if output.command == 'call' then
          previousRoundWinner = currentGame:call()
        else
          local bet = output.bet
          local p = currentGame.currentPlayerIndex
          if currentGame:submitBet(bet) then
            history[#history+1] = {face=bet.face,count=bet.count,player=p}
          end
        end
        timeAccumulate = 0
      end
      clientBet.face = currentGame.currentBet.face
      clientBet.count = currentGame.currentBet.count
    end
  end
end

function love.draw()
  local y = 0
  love.graphics.setColor(255,255,255)
  love.graphics.setFont( mainFont )

  if currentGame.state ~= 'game_over' then
    for i = 1, #Buttons do
      Buttons[i]:draw()
    end

    if #history > 3 then
      table.remove(history,4)
    end

    drawHistory(0,500)

    -- REFACTOR!
    if clientIndex == currentGame.currentPlayerIndex then
      if currentGame.state == 'round_mid' or currentGame.state == 'round_start' then
        callButton.hide = false
        betButton.hide = false
        faceUpButton.hide = false
        faceDownButton.hide = false
        countUpButton.hide = false
        countDownButton.hide = false
        drawBet(clientBet,400,200)
      end

      if currentGame.state == 'round_over' then
        callButton.hide = true
        betButton.hide = true
        faceUpButton.hide = true
        faceDownButton.hide = true
        countUpButton.hide = true
        countDownButton.hide = true
      end
    else
      callButton.hide = true
      betButton.hide = true
      faceUpButton.hide = true
      faceDownButton.hide = true
      countUpButton.hide = true
      countDownButton.hide = true
    end

    nextRoundButton.hide = currentGame.state ~= 'round_over'

    for i = 1, #currentGame.players do
      local name = currentGame.players[i].name
      if i == currentGame.currentPlayerIndex then
        name = name .. '*'
      end
      love.graphics.setFont(mainFont)
      love.graphics.setColor(255,255,255)
      love.graphics.print(name,0,y)
      y = y+love.graphics.getFont():getHeight()
      local highlightFace = nil
      if currentGame.state == 'round_over' then
        highlightFace = currentGame.currentBet.face
      end

      if i == clientIndex then
        drawHand(currentGame.players[i],0,y,32,highlightFace)
      else
        if currentGame.state == 'round_over' then
          drawHand(currentGame.players[i],0,y,32,highlightFace)
        else
          drawHiddenHand(currentGame.players[i],0,y,32)
        end
      end
      love.graphics.setColor(255,255,255)
      y = y + 46
    end

    drawBet(currentGame.currentBet,400,10)
  end
end
