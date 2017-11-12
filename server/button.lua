Buttons = {}

function newButton(xp,yp,w,h,name,func)
  if xp == nil then
    xp = 0
    yp = 0
    w = 100
    h = 100
  end

  if name == nil then
    name = 'Button'
  end

  if func == nil then
    func = function()
      print('no functionality for this button')
    end
  end

  local button = {
    x = xp,
    y = yp,
    width = w,
    height = h,
    name = name,
    visible = true,
    wasHoverLastFrame = true,

    hover = function(self)
      local mx,my = love.mouse.getX(),love.mouse.getY()
      return mx > self.x and
       my > self.y and
        mx < self.x + self.width and
         my < self.y + self.height
    end,

    draw = function(self)
      if not self.visible then return end
      local fill = 'line'
      if self:hover() then
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
        fill = 'fill'
      end
      love.graphics.setColor(100, 100, 255)

      if love.mouse.isDown(1) and self:hover() then
        love.graphics.setColor(120, 120, 255)
      end

      love.graphics.rectangle(fill, self.x, self.y, self.width, self.height)
      love.graphics.setColor(255,255,255)
      love.graphics.print(self.name,self.x+10,self.y+10)
      self.wasHoverLastFrame = self:hover()
    end,

    onClick = func
  }

  Buttons[#Buttons + 1] = button
  return button
end

function love.mousepressed(x, y, button, isTouch)
  if button == 1 then
    for i=1,#Buttons do
      local b = Buttons[i]
      if b:hover() and b.visible then
        b.onClick()
      end
    end
  end
end
