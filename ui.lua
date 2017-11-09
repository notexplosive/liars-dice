local callSound = love.audio.newSource( 'sound/call.mp3','static' )

callButton = newButton(400,360,200,32,'Call!',function()
  callSound:play()
  previousRoundWinner = currentGame:call()
  clientBet.count = 1
  clientBet.face = 2
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
nextRoundButton = newButton(400,400,200,32,'Next round!',function()
  currentGame:setupRound(previousRoundWinner)
end)
