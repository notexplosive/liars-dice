love.math.setRandomSeed( os.time() )

require('logic')
require('game')
require('test')
require('drawdice')
require('button')
require('bot')
require('ui')
require('net_server')

mainFont = love.graphics.newFont('font/Limelight-Regular.ttf',15)
bigFont = love.graphics.newFont('font/Limelight-Regular.ttf',128)

currentGame = nil

clientIndex = 1
clientBet = {face=2,count=1}
history = {}
previousRoundWinner = 0
previousRoundLoser = 0
globalState = "MENU"

-- Netcode related fields
online = false
notHost = false

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

function love.load(arg)
  love.window.setTitle("Liar's Dice by NotExplosive")
  love.window.setMode(1024, 576, {
    minwidth = 1024,
    minheight = 576,
    fullscreen = false,
    resizable = true
  })
end

love.graphics.setBackgroundColor(38, 43, 68)

function love.update(dt)
  --networkUpdate(dt)

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
  love.graphics.setColor(255,255,255)
  -- Debug scaffolding
  -- love.graphics.print(constructOutput())

  love.graphics.setColor(255,255,255,10)
  love.graphics.ellipse('fill', love.graphics.getWidth()/2, love.graphics.getHeight()/2, 500, 200)
  love.graphics.setFont( bigFont )
  love.graphics.print('Liar\'s Dice',love.graphics.getWidth()/2-love.graphics.getFont():getWidth('Liar\'s Dice')/2, love.graphics.getHeight()/2-64)
  love.graphics.setFont( mainFont )
  love.graphics.setColor(255,255,255,50)
  love.graphics.print('by NotExplosive',love.graphics.getWidth()/2-love.graphics.getFont():getWidth('Liar\'s Dice')/2, love.graphics.getHeight()/2+64)

  love.graphics.setColor(255,255,255)
  startGameButton.visible = globalState == "MENU" and not (online and notHost)
  --hostButton.visible = globalState == "MENU" and not online
  --joinButton.visible = globalState == "MENU" and not online
  exitButton.visible = globalState ~= "MENU"

  for i = 1, #Buttons do
    Buttons[i]:draw()
  end

  if currentGame then
    -- offset for hands UI
    -- TODO: change this whole architecture so each module has a root x,y
    local x = love.graphics.getWidth()/2
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
        drawBet(clientBet,UI_ROOT.x-108,UI_ROOT.y,.5)
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

        if i == clientIndex then
          drawHand(currentGame.players[i],UI_ROOT.x-8,UI_ROOT.y-46,32,highlightFace,playerHandTimers,false)
        else
          local angle = i/#currentGame.players * math.pi + math.pi/2 + math.pi/4
          local distance = 200
          local ax,ay = love.graphics.getWidth()/2+math.cos(angle)*distance*2,love.graphics.getHeight()/2+math.sin(angle)*distance
          if currentGame.state == 'round_over' then
            drawHand(currentGame.players[i],ax,ay,32,highlightFace)
          else
            drawHiddenHand(currentGame.players[i],ax,ay,32)
          end
        end
        love.graphics.setColor(255,255,255)
        y = y + 46
      end

      drawBet(currentGame.currentBet,love.graphics.getWidth()/2-32-64,love.graphics.getHeight()/2-64)
    end
  end
end
