-- These are the types of messages the client and server both know about
ESTABLISH_YES = "id confirmed"
ESTABLISH_REQ = "est"
EXIT = "exit"
BEAT = "beat"
ITERATE = "iterate_num"
SYNC = "NUM " -- space is important!
TABLE_REQ = "TABLEREQ "
TABLE_SET = "TABLESET "
STARTGAME = "START "

-- Example:
-- getArgFrom("NUM 5","NUM") --> '5'
-- getArgFrom("NUM 5","TABLEREQ") --> nil
-- getArgFrom("TABLESET foo bar","TABLESET") --> "TABLESET" "foo" "bar"
function getArgFrom(recv,command)
  local val = {}

  if recv:match(command..".*") then
    val = stringSplit(recv)
  end

  if #val == 0 then
    return nil
  end

  if #val == 2 then
    return val[2]
  end

  return val
end

function stringSplit(str)
  words = {}
  for word in str:gmatch("%w+") do
    table.insert(words, word)
  end
  return words
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
