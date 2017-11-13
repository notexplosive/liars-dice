require("tags")

Agents = {}

function setupServer()
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
