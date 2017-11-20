require("net_tags")


-- Syncronized number value for debugging
TheNumber = 0
clientData = {
  playerno = nil
}

established = false
interval = 0

function setupClient()
  online = true
  notHost = true
  server = socket.udp()
  server:setpeername(myip,PORT)
  server:settimeout(1/120)
  print(server)
  isClient = true
end

function love.quit()
  if server then
    if isClient then
      server:send(EXIT)
    end
    server:close()
  end
end

function clientUpdate(dt)
  interval = interval + dt
  if interval > 1 then
    interval = 0
    if established then
      -- Poke the server, remind it we're still around
      server:send(BEAT)
    end
  end

  if not established then
    server:send(ESTABLISH_REQ)
    --print("I'm trying to establish")
  end

  if established then
    if math.random(100) < 2 then
      server:send(ITERATE)
      server:send(TABLE_REQ..'ID')
    end
  end

  -- Listening back
  clientListenBack()
end

function clientListenBack()
  local recv = server:receive()
  if recv then
    print(recv)
    if recv == ESTABLISH_YES then
      established = true
      server:send(TABLE_REQ..'playerno')
    end

    local newNum = getArgFrom(recv,SYNC)
    local tableField = getArgFrom(recv,TABLE_SET)
    local startGame = getArgFrom(recv,STARTGAME)
    if startGame then
      currentGame = newGame()
      currentGame:setup(startGame[2],5)
      clientIndex = startGame[3]
      print("CLIENT INDEX = " .. startGame[3])
    end
    if newNum then
      TheNumber = newNum
    end
    if tableField then
      clientData[tableField[2]] = tableField[3]
    end
  end
end
