require("tags")

established = false
interval = 0

function setupClient()
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
