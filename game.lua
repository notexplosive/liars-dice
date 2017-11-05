require('logic')

function newPlayer()
  return {
    -- list of dice
    hand = {},
    -- number of dice allowed in hand
    health = 1,
    -- name, makes it easier to tell players apart
    name = "Unnamed Player",
  }
end

function newGame()
  return {
    -- list of players
    players = {},
    -- index of player who's current turn it is
    currentPlayerIndex = 1,
    -- Current Bet on the table
    currentBet = {count=1,face=2},
    -- index of most recent guess submitter
    currentSubmitter = 0,
    -- winner is nil until the game ends, then it's the index of winner
    winner=nil,
    -- state == {'round_start','round_over','round_mid','game_over'}
    state = 'round_start',

    -- iterate players
    nextTurn = function(self)
      self.currentPlayerIndex = self.currentPlayerIndex + 1
      if self.currentPlayerIndex > #self.players then
        self.currentPlayerIndex = 1
      end
      if self.players[self.currentPlayerIndex].health == 0 then
        self:nextTurn()
      end
    end,
    -- tests if submitted Bet is acceptable
    isValidBet = function(self,newBet)
      return isValidBet(self.currentBet,newBet)
    end,
    -- reassigns current Bet
    submitBet = function(self,newBet)
      newBet = convertAnonymousToBet(newBet)
      if self:isValidBet(newBet) then
        self.currentBet.face = newBet.face
        self.currentBet.count = newBet.count
        self.currentSubmitter = self.currentPlayerIndex
      else
        return false
      end
      self:changeState('round_mid')
      self:nextTurn()
      return true
    end,
    -- set up a brand new game
    setup = function(self, numberOfPlayers, numberOfDicePerPlayer)
      self.players = {}
      self.currentPlayerIndex = love.math.random(numberOfPlayers)
      self.currentBet = {count=0,face=0}
      self:changeState('round_start')
      for player_number=1,numberOfPlayers do
        self.players[player_number] = newPlayer()
        self.players[player_number].name = 'Player ' .. player_number
        self.players[player_number].health = numberOfDicePerPlayer
        for di_number=1,self.players[player_number].health do
          self.players[player_number].hand[#self.players[player_number].hand + 1] = rollDi()
        end
      end
    end,
    -- sets up next round; also evaluates if player is last one standing
    setupRound = function(self,playerGoingFirst)
      if playerGoingFirst == nil then print('Need to know who is going first!') return end
      self.currentPlayerIndex = playerGoingFirst
      self.currentBet = {count=0,face=0}
      self:changeState('round_start')
      local numberOfPlayersStillIn = 0
      for player_number=1,#self.players do
        self.players[player_number].hand = {}
        if self.players[player_number].health > 0 then
          numberOfPlayersStillIn = numberOfPlayersStillIn + 1
        end
        for di_number=1,self.players[player_number].health do
          self.players[player_number].hand[#self.players[player_number].hand + 1] = rollDi()
        end
      end

      if numberOfPlayersStillIn == 1 then
        self.winner = playerGoingFirst
        self:changeState('game_over')
      end
    end,
    -- helper function to read the current board state
    printBoard = function(self)
      for i=1, #self.players do
        if i == self.currentPlayerIndex then
          print('** ' .. self.players[i].name)
        else
          print(self.players[i].name)
        end
        local hand = ''
        for x=1, self.players[i].health do
          hand = hand .. self.players[i].hand[x] .. ','
        end
        print(hand)
      end
      print('current bet on the board: ' .. self.currentBet.count .. ' ' .. self.currentBet.face .. 's')
      if self.currentSubmitter ~= nil then
        print('bet was submitted by ' .. self.currentSubmitter)
      end
    end,
    -- End of round; Compares current bet to the actual board state, returns
    -- TRUE if the bet is accurate
    -- ie: FALSE means the caller loses
    evaluate = function(self)
      self:changeState('round_over')
      if self.currentBet.face == 0 then return nil end
      local diceList = {}
      diceList[1] = 0
      diceList[2] = 0
      diceList[3] = 0
      diceList[4] = 0
      diceList[5] = 0
      diceList[6] = 0
      for player_number = 1, #self.players do
        for hand_index = 1, self.players[player_number].health do
          diceList[#diceList + 1] = self.players[player_number].hand[hand_index]
        end
      end
      local truth = evaluateBoard(diceList)

     return truth[self.currentBet.face] >= self.currentBet.count
   end,
   -- ends round; returns winner
   call = function(self)
     local caller_lost = self:evaluate()
     if caller_lost == nil then return end
     local loser = 0
     local winner = 0
     if caller_lost then
       loser = self.currentPlayerIndex
       winner = self.currentSubmitter
     else
       loser = self.currentSubmitter
       winner = self.currentPlayerIndex
     end
     self.players[loser].health = self.players[loser].health - 1
     return winner
   end,

   totalDice = function(self)
     local total = 0
     for i = 1, #self.players do
       total = total + self.players[i].health
     end
     return total
   end,

   changeState = function(self,targetState)
     local allowed = false
     if self.state == 'round_mid' then
       if targetState == 'round_over' then
         allowed = true
       end
     end
     if targetState == 'game_over' and self.state == 'round_start' then
       allowed = true
     end
     if targetState == 'round_start' then
       if self.state == 'round_over' then
         allowed = true
       end
     end
     if targetState == 'round_mid' then
       if self.state == 'round_start' then
         allowed = true
       end
     end

     if allowed then
       self.state = targetState
     else
       if self.state ~= targetState then
         print('illegal state change attempted: ' .. self.state .. ' -> '..targetState)
       end
     end
     return allowed
   end,
 }
end
