function testFunc(func, args, exp_output)
  if func( unpack(args) ) == exp_output then
    print('[X] Passed!')
  else
    print('[ ] Failed!')
  end
end

testGame = newGame()
print("TEST \'Game\'")
testGame:setup(5,5)

testFunc( testGame.isValidBet, {testGame, {count=1,face=2} }, false )
testFunc( testGame.isValidBet, {testGame, {1,2} }, false)
testFunc( testGame.isValidBet, {testGame, {2,2} }, true)

testFunc( testGame.submitBet,{testGame, {2,2} }, true )
testFunc( testGame.submitBet,{testGame, {2,2} }, false )
