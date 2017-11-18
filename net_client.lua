require("net_tags")


-- Syncronized number value for debugging
TheNumber = 0
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

function clientListenBack()
  local recv = server:receive()
  if recv then
    print(recv)
    if recv == ESTABLISH_YES then
      established = true
      print("I got a reply!")
    end

    newNum = getArgFrom(recv,SYNC)
    if newNum then
      TheNumber = newNum
    end
  end
end

function love.quit()
  if server then
    if isClient then
      server:send(EXIT)
    end
    server:close()
  end
end
