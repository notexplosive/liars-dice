-- load namespace
require("button")
local socket = require("socket")
server = nil
isClient = nil
PORT = 25566

serverButton = newButton(400,300,160,32,'Server',function()
  setupServer()
end)
clientButton = newButton(400,400,160,32,'Client',function()
  setupClient()
end)

function setupServer()
  server = socket.udp()
  print(server:setsockname("0.0.0.0",25566))
  print(server:setpeername("0.0.0.0",25566))
  server:settimeout(1)--1/120)
  print(server)
  isClient = false
end

function setupClient()
  server = socket.udp()
  print(server:setpeername("0.0.0.0",25566))
  print(server)
  isClient = true
end

function love.load(arg)

end

function love.draw()
  for i = 1, #Buttons do
    Buttons[i]:draw()
  end

  if server ~= nil then
    if isClient then
      love.graphics.print("Is Client")
    else
      love.graphics.print("Is Server")
    end
  end
end

function love.quit()
  if server then
    server:close()
  end
end

  -- loop forever waiting for clients
function love.update(dt)
  if server ~= nil then
    if isClient then
      --print(server:send("Hello!"))
    else
      print(server:getsockname())
      local recv = server:receive()
      print(recv)
    end
  end
end
