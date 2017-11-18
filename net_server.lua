require("net_tags")
local socket = require("socket")

server = nil
isClient = nil
PORT = 25566
Agents = {}

-- This will not be needed
local client = socket.connect( "www.google.com", 80 )
myip, myport = client:getsockname()
client:close()

function setupServer()
  online = true
  server = socket.udp()
  server:setsockname("0.0.0.0",PORT)
  Agents = {}
  server:settimeout(1/120)
  isClient = false
end

function getIndexOfAgent(id)
  for i=1,#Agents do
    if Agents[i].ID == id then
      return i
    end
  end
  return nil
end

function serverCommandHandler()
  local recv,ip,port = server:receivefrom()
  if recv then
    if recv == ESTABLISH_REQ then
      local agent = {ID=ip..':'..port,ttk=5}
      Agents[#Agents + 1] = agent
      server:sendto(ESTABLISH_YES,ip,port)
      print("Establish attempted read")
    end
    if recv == BEAT then
      Agents[getIndexOfAgent(ip..':'..port)].ttk = 5

      -- update them on all the latest info
      server:sendto(SYNC..TheNumber,ip,port)
    end
    if recv == EXIT then
      flaggedForDelete = getIndexOfAgent(ip..':'..port)
    end
    if recv == ITERATE then
      TheNumber = TheNumber + 1
    end
    if flaggedForDelete then
      table.remove(Agents,flaggedForDelete)
    end
  end
end

function networkUpdate(dt)
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
