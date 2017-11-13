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
