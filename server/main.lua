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

local client = socket.connect( "www.google.com", 80 )
local myip, port = client:getsockname()
print(myip)
client:close()

function setupServer()
  server = socket.udp()
  print(server:setsockname("0.0.0.0",25566))
  server:settimeout(1)--1/120)
  print(server)
  isClient = false
end

function setupClient()
  server = socket.udp()
  print(server:setpeername(myip,25566))
  print(server)
  isClient = true
end

function love.load(arg)

end

function love.draw()
  local output = ""
  for i = 1, #Buttons do
    Buttons[i]:draw()
  end

  output = output .. myip

  if server ~= nil then
    if isClient then
      output = output .. "Is Client\n"
    else
      output = output .. "Is Server\n"
    end
  end

  love.graphics.print(output)
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
      server:send("Hello!")
    else
      local recv = server:receive()
      if recv then
        print(recv)
      end
    end
  end
end
