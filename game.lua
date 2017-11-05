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

    -- iterate players
    nextTurn = function(self)
      self.currentPlayerIndex = self.currentPlayerIndex+1
      if self.currentPlayerIndex > #self.players then
        self.currentPlayerIndex = 1
      end
    end,
    -- tests if submitted Bet is acceptable
    isValidBet = function(self,newBet)
      newBet = convertAnonymousToBet(newBet)
      if newBet.count < self.currentBet.count or newBet.face < 2 or newBet.face > 6 then
        return false
      end

      if newBet.count > self.currentBet.count then
        return true
      end

      if newBet.count == self.currentBet.count then
        if newBet.face > self.currentBet.face then
          return true
        end
      end
      return false
    end,
    -- reassigns current Bet
    submitBet = function(self,newBet)
      newBet = convertAnonymousToBet(newBet)
      if self:isValidBet(newBet) then
        self.currentBet = newBet
        self.currentSubmitter = self.currentPlayerIndex
      else
        return false
      end
      self:nextTurn()
      return true
    end,
    -- set up a brand new game
    setup = function(self, numberOfPlayers, numberOfDicePerPlayer)
      self.players = {}
      self.currentPlayerIndex = love.math.random(numberOfPlayers)
      self.currentBet = {count=1,face=2}
      for player_number=1,numberOfPlayers do
        self.players[player_number] = newPlayer()
        self.players[player_number].name = 'Player ' .. player_number
        self.players[player_number].health = numberOfDicePerPlayer
        for di_number=1,numberOfDicePerPlayer do
          self.players[player_number].hand[#self.players[player_number].hand + 1] = rollDi()
        end
      end
    end,
    --
    setupRound = function(self)
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
    end
  }
end
