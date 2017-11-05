require('logic')
require('game')
require('test')

g_dice = {}

for x=1, 5 do
  --print("Player " .. x .. ": ")
  for i=1,5 do
    g_dice[#g_dice+1] = rollDi()
    --print( g_dice[#g_dice] )
  end
end

g_board = evaluateBoard(g_dice)

--print(unpack(g_board))
