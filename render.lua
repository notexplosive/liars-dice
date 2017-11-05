function drawDi(face,x,y,size)
  love.graphics.setColor(200,200,200)
  love.graphics.rectangle('fill', x, y, size, size)
  love.graphics.setColor(0, 30, 0)

  local circle_radius = 5/64 * size
  if face % 2 == 1 then
    love.graphics.circle('fill', x+size/2, y+size/2, circle_radius, 10)
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
    love.graphics.circle('fill', x+size/4, y+size/4, circle_radius, 10)
    love.graphics.circle('fill', x+size/4+size/2, y+size/4+size/2, circle_radius, 10)
  end

  -- 4 5 6
  if face >= 4 then
    love.graphics.circle('fill', x+size/2+size/4, y+size/4, circle_radius, 10)
    love.graphics.circle('fill', x+size/4, y+size/2+size/4, circle_radius, 10)
  end

  -- 6
  if face == 6 then
    love.graphics.circle('fill', x+size/4, y+size/2, circle_radius, 10)
    love.graphics.circle('fill', x+size-size/4, y+size/2, circle_radius, 10)
  end

  love.graphics.setColor(0,0,0,50)
  love.graphics.circle('fill', x+size/2, y+size/2, size/2, 20)
end

function drawHand(player,x,y,scale)
  if x == nil then
    x = 0
    y = 0
  end
  if scale == nil then
    scale = 64
  end
  for i = 1, #player.hand do
    drawDi(player.hand[i],x+(scale+4)*(i-1),y,scale)
  end
end

function drawBet(bet,x,y)
  bet = convertAnonymousToBet(bet)
  for i = 1, clientBet.count do
    local margin = 4
    local size = 32
    local max_width = 5
    drawDi(clientBet.face, x+((i-1) % max_width )*(size+margin),y+(math.floor((i-1)/max_width)*(size+margin)), size)
  end
end
