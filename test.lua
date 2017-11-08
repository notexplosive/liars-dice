function testFunc(func, args, exp_output)
  local output = func( unpack(args) )
  if output == exp_output then
    print('[X] Passed!')
  else
    if #output == #exp_output then
      for i = 1, #output do
        if output[i] ~= exp_output[i] then
          print('[ ] Failed!')
          return
        end
      end
      print('[X] Passed!')
      return
    end
    print('[ ] Failed!')
    print( output )
  end
end

testGame = newGame()
print("TEST \'Game\'")
testGame:setup(5,5)

testFunc( testGame.isValidBet, {testGame, {count=1,face=2} }, true )
testFunc( testGame.isValidBet, {testGame, {1,2} }, true)
testFunc( testGame.isValidBet, {testGame, {2,2} }, true)

testFunc( testGame.submitBet,{testGame, {2,2} }, true )
testFunc( testGame.submitBet,{testGame, {2,2} }, false )

print("TEST \'Logic\'")
testFunc( evaluateBoard,{{1,2,3,4,5,6}}, {0,2,2,2,2,2} )

-- Test suite isn't smart enough for these yet.

-- testFunc(convertAnonymousToBet,{1,2},{face=1,count=2})
-- testFunc(convertAnonymousToBet,{face=1,count=2},{face=1,count=2})
-- testFunc(convertAnonymousToBet,nil,nil)
