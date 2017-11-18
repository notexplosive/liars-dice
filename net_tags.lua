-- These are the types of messages the client and server both know about
ESTABLISH_YES = "id confirmed"
ESTABLISH_REQ = "est"
EXIT = "exit"
BEAT = "beat"
ITERATE = "iterate_num"
SYNC = "NUM " -- space is important!

-- Example:
-- getArgFrom("NUM 5","NUM") --> '5'
function getArgFrom(recv,command)
  local val = nil
  if recv:match(command..".*") then
    val = recv:match(command..".*"):sub(recv:find(' ')+1,recv:len())
  end

  return val
end

function constructOutput()
  local output = ""
  output = output .. myip .. ':' .. PORT .. '\n'

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
