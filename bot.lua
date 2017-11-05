require('logic')

function botTurn(myHand,totalDice,currentBet)
  local estimates = estimateBoard(myHand,totalDice)
  local mostConfidentBet = {face=0,count=0}
  local bets = {}
  for i=2,6 do
    local face=i
    local count=estimates[i]
    if isValidBet(currentBet,{face=i,count=estimates[i]}) then
      bets[#bets+1] = {count = count, face = face}
    end
  end

  if #bets == 0 then
    return {command = 'call'}
  end

  if #bets == 1 then
    return {command='raise',bet = bets[1]}
  end

  for i = 1, #bets do
    bets[i].count = bets[i].count - (love.math.random(2)-1)
    if bets[i].count < currentBet.count then
      bets[i].count = currentBet.count
    end
    if bets[i].count == currentBet.count and bets[i].face < currentBet.face then
      bets[i].count = bets[i].count + 1
    end
    if bets[i].count == currentBet.count and bets[i].face == currentBet.face then
      bets[i].count = bets[i].count + 1
    end
  end

  local bet = bets[love.math.random(#bets)]

  -- sanity check!!
  if not isValidBet(currentBet,bet) then
    print (bets.count .. ' ' ..bets.face)
    print ('Bot tried to bet above. This is an invalid bet!')
    return nil
  end

  return {
    command = 'raise',
    bet = bet
  }
end
