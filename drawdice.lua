local rollSounds = {
  love.audio.newSource( 'sound/roll_1.mp3','static' ),
  love.audio.newSource( 'sound/roll_2.mp3','static' )
}

function drawDi(face,x,y,size,highlight,wireframe)
  if highlight == nil then highlight = false end

  if highlight then
    love.graphics.setColor(200,255,200)
  else
    love.graphics.setColor(200,200,200)
  end

  local fillType = 'fill'
  if wireframe then
    fillType = 'line'
  end

  love.graphics.rectangle(fillType, x, y, size, size)
  love.graphics.setColor(0, 30, 0)

  local circle_radius = 5/64 * size
  if face % 2 == 1 then
    love.graphics.circle(fillType, x+size/2, y+size/2, circle_radius, 10)
  end

  -- unknown face
  if face == 0 then
    local font = love.graphics.newFont(size)
    love.graphics.setFont( font )
    local width = font:getWidth('?')
    local height = font:getHeight('?')
    love.graphics.print('?', x+size/2-width/2, y+size/2-height/2)
  end

  -- 3 5 2 4 6
  if face > 1 then
    love.graphics.circle(fillType, x+size/4, y+size/4, circle_radius, 10)
    love.graphics.circle(fillType, x+size/4+size/2, y+size/4+size/2, circle_radius, 10)
  end

  -- 4 5 6
  if face >= 4 then
    love.graphics.circle(fillType, x+size/2+size/4, y+size/4, circle_radius, 10)
    love.graphics.circle(fillType, x+size/4, y+size/2+size/4, circle_radius, 10)
  end

  -- 6
  if face == 6 then
    love.graphics.circle(fillType, x+size/4, y+size/2, circle_radius, 10)
    love.graphics.circle(fillType, x+size-size/4, y+size/2, circle_radius, 10)
  end

  love.graphics.setColor(0,0,0,50)
  love.graphics.circle(fillType, x+size/2, y+size/2, size/2, 20)
end

function drawHand(player,x,y,scale,highlightFace,timers)
  if x == nil then
    x = 0
    y = 0
  end
  if scale == nil then
    scale = 64
  end
  if highlightFace == nil then
    highlightFace = 0
  end
  if timers == nil then
    timers = {}
    for i = 1, #player.hand do
      timers[i] = 0
    end
  end
  if #timers ~= #player.hand then
    rollSounds[love.math.random(2)]:play()
    for i = 1, #player.hand do
      timers[i] = 5*i
    end
  end
  for i = 1, #player.hand do
    wireframe = true
    if timers[i] > 0 then
      timers[i] = timers[i] - 1
      y = y - timers[i]
    else
      wireframe = false
    end
    drawDi(player.hand[i],x+(scale+4)*(i-1),y,scale,player.hand[i] == highlightFace or (player.hand[i] == 1 and highlightFace ~= 0),wireframe)
  end
end

function drawHiddenHand(player,x,y,scale)
  if x == nil then
    x = 0
    y = 0
  end
  if scale == nil then
    scale = 64
  end

  for i = 1, #player.hand do
    drawDi(0,x+(scale+4)*(i-1),y,scale)
  end
end

function drawBet(bet,x,y,scale)
  if scale == nil then scale = 1 end

  bet = convertAnonymousToBet(bet)
  for i = 1, bet.count do
    local margin = 4
    local size = 32*scale
    local max_width = 5
    drawDi(bet.face, x+((i-1) % max_width )*(size+margin),y+(math.floor((i-1)/max_width)*(size+margin)), size)
  end
end

function drawHistory(x,y)
  if currentGame.state == 'round_start' then
    history = {}
  end

  -- constants
  local margin = 18

  local historyOffset = 0
  for i=#history,1,-1 do
    numberOfRows = 0
    if i > 1 then
      numberOfRows = (math.floor(history[i-1].count / 5) + 1)
      if history[i-1].count == 5 then
        numberOfRows = 1
      end
    end

    drawBet(history[i],x+8,y+historyOffset,.5)
    love.graphics.setColor(255,255,255)
    love.graphics.print(history[i].player,x+120,y+historyOffset)
    historyOffset = historyOffset - margin * numberOfRows - 8
  end
end
