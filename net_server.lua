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
      -- TODO: revise playerno
      local agent = {ID=ip..':'..port,ttk=5,playerno=#Agents+1,ip=ip,port=port}
      Agents[#Agents + 1] = agent
      server:sendto(ESTABLISH_YES,ip,port)
      print("Establish attempted read")
    end

    local currentAgent = Agents[getIndexOfAgent(ip..':'..port)]

    if recv == BEAT then
      currentAgent.ttk = 5
      -- update them on all the latest info
      sendToAgent(currentAgent,SYNC..TheNumber)
    end
    if recv == EXIT then
      flaggedForDelete = getIndexOfAgent(ip..':'..port)
    end
    if recv == ITERATE then
      TheNumber = TheNumber + 1
    end
    if getArgFrom(recv,TABLE_REQ) then
      print(TABLE_SET..getArgFrom(recv,TABLE_REQ))
      print(currentAgent[getArgFrom(recv,TABLE_REQ)])
      sendToAgent(currentAgent,TABLE_SET..getArgFrom(recv,TABLE_REQ)..' '..currentAgent[getArgFrom(recv,TABLE_REQ)])
    end
    if flaggedForDelete then
      table.remove(Agents,flaggedForDelete)
    end
  end
end

function sendToAgent(agent,data)
  server:sendto(data,agent.ip,agent.port)
end

function sendToAllAgents(data)
  for i=1,#Agents do
    agent = Agents[i]
    sendToAgent(agent,data)
  end
end

function serverUpdate(dt)
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

function networkUpdate(dt)
  if server ~= nil then
    print(clientIndex)
    if isClient then
      clientUpdate(dt)
    else
      serverUpdate(dt)
    end
  end
end
