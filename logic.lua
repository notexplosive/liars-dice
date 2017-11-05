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
  if table == nil then print('you forgot to pass in table!') end
  if table.count == nil then
    return {count=table[1],face=table[2]}
  end
  return table
end
