-- load namespace
require("button")
require("server")
require("client")
require("tags")
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

-- This will not be needed
local client = socket.connect( "www.google.com", 80 )
myip, myport = client:getsockname()
client:close()

function constructOutput()
  local output = ""
  output = output .. myip .. '\n'

  if server ~= nil then
    if isClient then
      output = output .. "Is Client\n"
      if established then
        output = output .. "Connected!\n"
      else
        output = output .. "Not Connected\n"
      end
      output = output .. TheNumber .. "\n"
    else
      output = output .. "Is Server\n"
      output = output .. "Clients on board:\n"

      for i=1,#Agents do
        output = output .. Agents[i].ID .. '\n'
        output = output .. '\t' .. Agents[i].ttk .. '\n'
      end
      output = output .. "------"
      output = output .. '\n'
    end
  end

  return output
end

function love.draw()
  for i = 1, #Buttons do
    Buttons[i]:draw()
  end

  love.graphics.print(constructOutput())
end

function love.quit()
  if server then
    if isClient then
      server:send(EXIT)
    end
    server:close()
  end
end

  -- loop forever waiting for clients
function love.update(dt)
  if server ~= nil then
    if isClient then
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

      if math.random(100) < 2 then
        server:send(ITERATE)
      end

      -- Listening back
      clientListenBack()
    else
      local flaggedForDelete = nil
      for i=1,#Agents do
        -- tick down time to kill
        Agents[i].ttk = Agents[i].ttk - dt

        if Agents[i].ttk < 0 then
          flaggedForDelete = i
        end
      end

      serverCommandHandler()
    end
  end
end
