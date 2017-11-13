love.math.setRandomSeed( os.time() )

require('logic')
require('game')
require('test')
require('drawdice')
require('button')
require('bot')
require('ui')

mainFont = love.graphics.newFont(12)

currentGame = nil -- newGame()
--currentGame:setup(4,5)

clientIndex = 1
clientBet = {face=2,count=1}
history = {}
previousRoundWinner = 0
previousRoundLoser = 0
globalState = "MENU"

local prev_state = ''
local timeAccumulate = 0
local rustleSound = love.audio.newSource( 'sound/rustle_dice.mp3','static' )
local callSound = love.audio.newSource( 'sound/call.mp3','static' )
local saySounds = {
  love.audio.newSource( 'sound/say1.mp3','static' ),
  love.audio.newSource( 'sound/say2.mp3','static' ),
  love.audio.newSource( 'sound/say3.mp3','static' ),
  love.audio.newSource( 'sound/say4.mp3','static' ),
  love.audio.newSource( 'sound/say5.mp3','static' )
}

love.graphics.setBackgroundColor(38, 43, 68)

function love.update(dt)
  if currentGame then
    if prev_state ~= currentGame.state then
      prev_state = currentGame.state
    end

    if currentGame.state == 'game_over' then
      currentGame = nil
      globalState = "MENU"
    end

    if currentGame.state ~= 'game_over' then
      if currentGame.currentPlayerIndex ~= clientIndex and currentGame.state ~= 'round_over' then

        local estimate = estimateBoard(
          currentGame.players[
            currentGame.currentPlayerIndex]
              .hand,
                currentGame:totalDice())
        timeAccumulate = timeAccumulate + dt
        if timeAccumulate > love.math.random(3)/2 then
          saySounds[love.math.random(5)]:play()
          local output = botTurn(currentGame.players[currentGame.currentPlayerIndex].hand,currentGame:totalDice(),currentGame.currentBet)
          if output.command == 'call' then
            callSound:stop()
            callSound:play()
            local tbl = currentGame:call()
            previousRoundWinner = tbl[1]
            previousRoundLoser = tbl[2]
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
end

playerHandTimers = {}

function love.draw()
  startGameButton.visible = globalState == "MENU"
  hostButton.visible = globalState == "MENU"
  joinButton.visible = globalState == "MENU"

  love.graphics.setColor(255,255,255)
  love.graphics.setFont( mainFont )

  for i = 1, #Buttons do
    Buttons[i]:draw()
  end

  if currentGame then
    local x = 16
    local y = 16

    if currentGame.state ~= 'game_over' then
      if #history > 3 then
        table.remove(history,1)
      end

      drawHistory(0,500)

      local clientsTurn = clientIndex == currentGame.currentPlayerIndex
      local roundStart = currentGame.state == 'round_start'
      local roundMid = currentGame.state == 'round_mid'
      local roundEnd = currentGame.state == 'round_over'

      callButton.visible = clientsTurn and not roundStart and not roundEnd and not isValidBet(currentGame.currentBet,clientBet)
      nextRoundButton.visible = roundEnd
      betButton.visible = clientsTurn and not roundEnd and isValidBet(currentGame.currentBet,clientBet)
      countUpButton.visible = clientsTurn and not roundEnd
      countDownButton.visible = clientsTurn and not roundEnd
      twoButton.visible = clientsTurn and not roundEnd
      threeButton.visible = clientsTurn and not roundEnd
      fourButton.visible = clientsTurn and not roundEnd
      fiveButton.visible = clientsTurn and not roundEnd
      sixButton.visible = clientsTurn and not roundEnd

      if clientsTurn and (roundMid or roundStart) then
        drawBet(clientBet,400,200)
      end

      for i = 1, #currentGame.players do
        local name = currentGame.players[i].name
        if i == currentGame.currentPlayerIndex then
          name = name .. '*'
        end

        local highlightFace = nil
        if currentGame.state == 'round_over' then
          highlightFace = currentGame.currentBet.face
          if previousRoundWinner == i then
            name = name .. ' winner!'
          end
          if previousRoundLoser == i then
            name = name .. ' loser!'
          end
        end

        love.graphics.setFont(mainFont)
        love.graphics.setColor(255,255,255)
        love.graphics.print(name,x,y)
        y = y+love.graphics.getFont():getHeight()

        if i == clientIndex then
          drawHand(currentGame.players[i],x,y,32,highlightFace,playerHandTimers)
        else
          if currentGame.state == 'round_over' then
            drawHand(currentGame.players[i],x,y,32,highlightFace)
          else
            drawHiddenHand(currentGame.players[i],x,y,32)
          end
        end
        love.graphics.setColor(255,255,255)
        y = y + 46
      end

      drawBet(currentGame.currentBet,400,10)
    end
  end
end
