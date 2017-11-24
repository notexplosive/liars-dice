require "net_server"
require "net_client"

local callSound = love.audio.newSource( 'sound/call.mp3','static' )

UI_ROOT = {x=700,y=400}

callButton = newButton(UI_ROOT.x,UI_ROOT.y,160,32,'Call!',function()
  callSound:play()
  local tbl = currentGame:call()
  previousRoundWinner = tbl[1]
  previousRoundLoser = tbl[2]
  clientBet.count = 1
  clientBet.face = 2
end)
betButton = newButton(UI_ROOT.x,UI_ROOT.y,160,32,'Bet!',function()
  local p = currentGame.currentPlayerIndex
  if currentGame:submitBet(clientBet) then
    history[#history+1] = {face=clientBet.face,count=clientBet.count,player=p}
  end
end)
countUpButton = newButton(UI_ROOT.x,UI_ROOT.y + 74,80,32,'-',function()
  clientBet.count = clientBet.count - 1
  if clientBet.count < 1 then
    clientBet.count = 1
  end
end)
countDownButton = newButton(UI_ROOT.x+80,UI_ROOT.y+74,80,32,'+',function()
  clientBet.count = clientBet.count + 1
  local totalDice = 0
  for i = 1, #currentGame.players do
    totalDice = totalDice + currentGame.players[i].health
  end
  if clientBet.count > totalDice then
    clientBet.count = totalDice
  end
end)
nextRoundButton = newButton(UI_ROOT.x,UI_ROOT.y,200,32,'Next round!',function()
  currentGame:setupRound(previousRoundWinner)
  playerHandTimers = {}
end)

twoButton = newButton(UI_ROOT.x,UI_ROOT.y+40, 32,32,'2',function()
  clientBet.face = 2
end)

threeButton = newButton(UI_ROOT.x+32,UI_ROOT.y+40, 32,32,'3',function()
  clientBet.face = 3
end)

fourButton = newButton(UI_ROOT.x+64,UI_ROOT.y+40, 32,32,'4',function()
  clientBet.face = 4
end)

fiveButton = newButton(UI_ROOT.x+96,UI_ROOT.y+40, 32,32,'5',function()
  clientBet.face = 5
end)

sixButton = newButton(UI_ROOT.x+128,UI_ROOT.y+40, 32,32,'6',function()
  clientBet.face = 6
end)

startGameButton = newButton(100,100,128,32,'Start Game', function()
  globalState = "GAME"

  if not online then
    currentGame = newGame()
    currentGame:setup(4,5)
  else
    local num_players = #Agents+1
    if not isClient then
      currentGame = newGame()
      currentGame:setup(num_players,5)
      clientIndex = 1
      for i=1,#Agents do
        sendToAgent(Agents[i],STARTGAME..num_players..' '..(i+1))
      end
    end
  end
end)

hostButton = newButton(100,148,128,32,'Host Multiplayer', function()
  setupServer()
end)

joinButton = newButton(100,180,128,32,'Join Multiplayer', function()
  setupClient()
end)

exitButton = newButton(600,472+64,128,32,'Exit to Menu', function()
  globalState = "MENU"
  currentGame = nil

  callButton.visible = false
  betButton.visible = false
  countUpButton.visible = false
  countDownButton.visible = false
  nextRoundButton.visible = false
  twoButton.visible = false
  threeButton.visible = false
  fourButton.visible = false
  fiveButton.visible = false
  sixButton.visible = false
end)


startGameButton.visible = true

callButton.visible = false
betButton.visible = false
countUpButton.visible = false
countDownButton.visible = false
nextRoundButton.visible = false
twoButton.visible = false
threeButton.visible = false
fourButton.visible = false
fiveButton.visible = false
sixButton.visible = false
