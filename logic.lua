-- Functions used for evaluating board state

-- Utility function that returns a rand from 1-6
function rollDi()
  return love.math.random(6)
end

-- Returns a table of 2 through 6 with values of how many of each face is
-- present, factoring in ones.
function evaluateBoard(diceList)
  local board = {}
  board[1] = 0
  for n=2,6 do
    board[n] = 0
    for i=1,#diceList do
      if diceList[i] == n or diceList[i] == 1 then
        board[n] = board[n]+1
      end
    end
  end
  return board
end

function convertAnonymousToBet(table)
  if table == nil then print('you forgot to pass in table!') return nil end
  if table.count == nil then
    return {count=table[1],face=table[2]}
  end
  return table
end

function isValidBet(oldBet,newBet)
  oldBet = convertAnonymousToBet(oldBet)
  newBet = convertAnonymousToBet(newBet)
  return oldBet.count < newBet.count or (oldBet.count <= newBet.count and oldBet.face < newBet.face)
end


function estimateBoard(myHand,totalDice)
  probs = {0,0,0,0,0,0}
  local totalDiceOtherThanMine = totalDice - #myHand
  local onesInMyHand = 0

  for i = 1, #myHand do
    local face = myHand[i]
    probs[face] = probs[face] + 1/totalDice

    if face == 1 then
      onesInMyHand = onesInMyHand + 1
    end
  end

  for i = 1, 6 do
    probs[i] = probs[i] + totalDiceOtherThanMine / 6 / totalDice + probs[1] * .66
  end

  estimates = {}
  for i = 2, 6 do
    estimates[i] = math.floor(probs[i] * totalDice)
  end

  return estimates
end
