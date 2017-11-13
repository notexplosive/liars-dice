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

-- This will not be needed
local client = socket.connect( "www.google.com", 80 )
local myip, port = client:getsockname()
print(myip)
client:close()

function setupServer()
  server = socket.udp()
  print(server:setsockname("0.0.0.0",25566))
  server:settimeout(1/120)
  print(server)
  isClient = false
end

function setupClient()
  server = socket.udp()
  print(server:setpeername(myip,25566))
  server:settimeout(1/120)
  print(server)
  isClient = true
end

function love.load(arg)

end

output = ""

function love.draw()
  for i = 1, #Buttons do
    Buttons[i]:draw()
  end

  love.graphics.print(output)
end

function love.quit()
  if server then
    if isClient then
      server:send("EXIT")
    end
    server:close()
  end
end


Agents = {}
AgentsByID = {}
established = false
interval = 0
TheNumber = 1337

function getIndexOfAgent(id)
  for i=1,#Agents do
    if Agents[i].ID == id then
      return i
    end
  end

  return nil
end


  -- loop forever waiting for clients
function love.update(dt)
  output = ""
  output = output .. myip .. '\n'

  if server ~= nil then
    if isClient then
      output = output .. "Is Client\n"

      interval = interval + dt
      if interval > 1 then
        interval = 0
        if established then
          -- Poke the server, remind it we're still around
          server:send("beat")
        end
      end

      if math.random(100) < 2 then
        server:send("RAISE")
      end

      if not established then
        server:send("ESTABLISH")
      end

      -- Listening back
      local recv = server:receive()
      if recv then
        if recv == "ID confirmed" then
          output = output .. "Confirmed\n"
          established = true
        end

        if recv:match("NUM.*") then
          TheNumber = recv:match("NUM.*"):sub(recv:find(' ')+1,recv:len())
        end
      end

      output = output .. TheNumber .. "\n"
    else
      output = output .. "Is Server\n"
      output = output .. "Clients on board:\n"

      local flaggedForDelete = nil
      for i=1,#Agents do
        -- tick down time to kill
        Agents[i].ttk = Agents[i].ttk - dt
        output = output .. Agents[i].ID .. '\n'
        output = output .. '\t' .. Agents[i].ttk .. '\n'

        if Agents[i].ttk < 0 then
          flaggedForDelete = i
        end
      end

      output = output .. "------"

      output = output .. '\n'
      local recv,ip,port = server:receivefrom()
      if recv then
        output = output .. recv .. '\n'
        if recv == "ESTABLISH" then
          local agent = {ID=ip..':'..port,ttk=5}

          Agents[#Agents + 1] = agent
          server:sendto("ID confirmed",ip,port)
        end
        if recv == "beat" then
          Agents[getIndexOfAgent(ip..':'..port)].ttk = 5
          -- update them on all the latest info
          server:sendto("NUM "..TheNumber,ip,port)
        end
        if recv == "EXIT" then
          flaggedForDelete = getIndexOfAgent(ip..':'..port)
        end
        if recv == "RAISE" then
          TheNumber = TheNumber + 1
        end
        if flaggedForDelete then
          table.remove(Agents,flaggedForDelete)
        end
      end
    end
  end
end
