local callSound = love.audio.newSource( 'sound/call.mp3','static' )

callButton = newButton(400,400,160,32,'Call!',function()
  callSound:play()
  local tbl = currentGame:call()
  previousRoundWinner = tbl[1]
  previousRoundLoser = tbl[2]
  clientBet.count = 1
  clientBet.face = 2
end)
betButton = newButton(400,400,160,32,'Bet!',function()
  local p = currentGame.currentPlayerIndex
  if currentGame:submitBet(clientBet) then
    history[#history+1] = {face=clientBet.face,count=clientBet.count,player=p}
  end
end)
countUpButton = newButton(400,474,80,32,'-',function()
  clientBet.count = clientBet.count - 1
  if clientBet.count < 1 then
    clientBet.count = 1
  end
end)
countDownButton = newButton(480,474,80,32,'+',function()
  clientBet.count = clientBet.count + 1
  local totalDice = 0
  for i = 1, #currentGame.players do
    totalDice = totalDice + currentGame.players[i].health
  end
  if clientBet.count > totalDice then
    clientBet.count = totalDice
  end
end)
nextRoundButton = newButton(400,400,200,32,'Next round!',function()
  currentGame:setupRound(previousRoundWinner)
  playerHandTimers = {}
end)

twoButton = newButton(400,440, 32,32,'2',function()
  clientBet.face = 2
end)

threeButton = newButton(432,440, 32,32,'3',function()
  clientBet.face = 3
end)

fourButton = newButton(464,440, 32,32,'4',function()
  clientBet.face = 4
end)

fiveButton = newButton(496,440, 32,32,'5',function()
  clientBet.face = 5
end)

sixButton = newButton(528,440, 32,32,'6',function()
  clientBet.face = 6
end)
