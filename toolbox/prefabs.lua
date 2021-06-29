local Concord = require 'concord'
local PATH = (...):gsub('%.prefabs$', '')
local world = require(PATH..".world")
local resources = require(PATH..".resources")


-- Contains functions for prefab entity types
local prefabs = {}


function prefabs.Shape(x,y,z,p_shape,imageData,body_type)
  local body_type = body_type or "dynamic"

  local e = Concord.entity()
  :give("position", x, y, z)
  :give("graphics", function(this)
    love.graphics.draw(
      this.img,
      this.physics.body:getX(),
      this.physics.body:getY(),
      this.physics.body:getAngle(),
      this.width / this.img:getWidth(),
      this.height / this.img:getHeight(),
      this.img:getWidth()/2,
      this.img:getHeight()/2
    )
  end)
  :give("physics", e, x, y, p_shape, body_type)

  e.img = love.graphics.newImage(imageData)

  return e
end

function prefabs.Circle(x,y,z,color,body_type,radius)
  local color = color or {1,1,1,1}
  local radius = radius or 20

  local imageData = love.image.newImageData(radius*2, radius*2)
  imageData:mapPixel(function(x,y,r,g,b,a)
      x = x - radius
      y = y - radius
      if math.sqrt(math.pow(x, 2)+math.pow(y, 2)) <= radius then
        return color[1],color[2],color[3],color[4]
      else
        return 0,0,0,0
      end
  end)
  local img = love.graphics.newImage(imageData)
  local p_shape = love.physics.newCircleShape(radius)
  local e = prefabs.Shape(x,y,z,p_shape,imageData,body_type)
  e.radius = radius
  e.width = radius * 2
  e.height = radius * 2
  return e

end

function prefabs.rectImageData(width, height,color)
  local imageData = love.image.newImageData(width, height)
  imageData:mapPixel(function(x,y,r,g,b,a)
    return color[1],color[2],color[3],color[4]
  end)
  return imageData
end

-- Rectangular box
function prefabs.Box(x,y,z,color,body_type,width,height)
  local color = color or {1,1,1,1}
  local body_type = body_type or "dynamic"

  local width = width or 10
  local height = height or 10
  local imageData = prefabs.rectImageData(width, height, color)
  local img = love.graphics.newImage(imageData)
  local p_shape = love.physics.newRectangleShape(width, height)
  local e = prefabs.Shape(x,y,z,p_shape,imageData,body_type)

  e.width = width
  e.height = height
  e.angle = 0
  e.color = color

  return e
end

function prefabs.Button(x, y, text, font, defaultColor, selectedColor, clickedColor, onClick)
  local e = Concord.entity()
  e.selected = false
  e.clicked = false
  e.text = text
  e.font = font
  e.enabled = true
  e.defaultTextImg = love.graphics.newText(e.font, {defaultColor, e.text})
  e.selectedTextImg = love.graphics.newText(e.font, {selectedColor, e.text})
  e.clickedTextImg = love.graphics.newText(e.font, {clickedColor, e.text})
  e.disabledTextImg = love.graphics.newText(e.font, {{.2,.3,.3,.1}, e.text})
  e.textImg = e.defaultTextImg
  e.onClick = onClick
  e:give("physics",
    e,x,y,
    love.physics.newRectangleShape(e.textImg:getWidth(), e.textImg:getHeight()),
    "static",
    true
  )
  e:give("beginContactCallback",function(this, other, collision)
    if other == world.mouse and this.enabled then
      print(this.text.." selected")
      this.selected = true
      this.textImg = this.selectedTextImg
    end
  end)
  e:give("endContactCallback",function(this, other, collision)
    if other == world.mouse and this.enabled then
      print(this.text.." deselected")
      this.selected = false
      this.textImg = this.defaultTextImg
    end
  end)
  e:give("update",function(this, dt)
    if this.enabled then
      if love.mouse.isDown(1) then
        if this.selected then
          this.clicked = true
          this.textImg = this.clickedTextImg
        else
          this.textImg = this.defaultTextImg
          this.clicked = false
        end
      else
        if this.clicked then
          this.onClick(this)
          this.clicked = false
          this.textImg = this.defaultTextImg
        end
      end
    else
      this.textImg = this.disabledTextImg
    end
  end)
  e:give("position",x,y,100)
  e:give("graphics", function(this)
    love.graphics.draw(
      this.textImg,
      this.physics.body:getX()-this.textImg:getWidth()/2,
      this.physics.body:getY()-this.textImg:getHeight()/2
    )
  end)
  return e
end

-- Takes in a string of text possibly containing variables
-- and subsitutes them with data from the vars if possible
function template(text, vars)
  if text == nil then
    return ""
  end
  if type(text) == "function" then
    text = text(vars)
  end
  return (text:gsub(
    '(%b{})',
    function(var)
      word = var:sub(2,-2)
      local result = vars
      if string.find(word, '.') then
        for w in string.gmatch(word, "%w+") do
          if result[w] then
            result = result[w]
          else
            return "na"
          end
        end
      else
        result = vars[w]
      end
      return result
    end))
end

function prefabs.textbox(text,x,y,w,h)
  local e = Concord.entity()
  e.text = text
  e.original_text = text
  e.w = w
  e.h = h
  e.buffer_w = 20
  e.buffer_h = 10
  e.text_w = e.w - e.buffer_w * 2
  e.text_h = e.h - e.buffer_h * 2
  e.font = resources.fonts.basis33
  function e:update_text(data)
    self.text = template(self.original_text, data)
    self.max_lines = math.floor(e.text_h / e.font:getHeight())
    self.text_words = string.gmatch(e.text, '[^%s]+')
    self.text_parts = {}
    self.text_index = 1
    local idx = 1
    local line_length = 0
    for word in self.text_words do
      if self.text_parts[idx] ~= nil then
        line_width, lines = e.font:getWrap(e.text_parts[idx] .. ' ' .. word, self.text_w)
        if table.getn(lines) > self.max_lines then
          idx = idx + 1
        end
      end
      if self.text_parts[idx] == nil then
        self.text_parts[idx] = word
      else
        self.text_parts[idx] = self.text_parts[idx] .. ' ' .. word
      end
    end
  end
  e:update_text({})
  e:give("position",x,y,0)
  e:give("graphics",function(this)
    local width = love.graphics.getFont():getWidth(this.text)
    love.graphics.rectangle("line",this.position.x,this.position.y,this.w,this.h)
    love.graphics.setFont(this.font)
    love.graphics.printf(
      this.text_parts[e.text_index],
      this.position.x + this.buffer_w,
      this.position.y + this.buffer_h,
      this.text_w)
  end)

  e.button = prefabs.Button(
    x + e.w - e.buffer_w/2,
    y + e.h - e.buffer_h,
    ">",
    e.font,
    {1,1,1,1},
    {1,0,0,1},
    {1,0,0,1},
    function(this)
      e.text_index = e.text_index + 1
      if e.text_index > table.getn(e.text_parts) then
        e:destroy()
        this:destroy()
      end
    end
  )
  e:give("init",function(this)
    print(this.button.position.y)
    world:addEntity(this.button)
  end)

  return e
end

function prefabs.promptbox(prompt,choices,x,y,w,h)
  local e = Concord.entity()
  e.x = x
  e.y = y
  e.w = w
  e.h = h
  e.prompt = prompt
  e.original_prompt = prompt
  e.choices = choices
  e.buttons = {}
  e.font = resources.fonts.basis33
  function e:update_text(data)
    self.prompt = template(self.original_prompt, data)
  end
  e:give("init",function(this)
    e:update_text({})
    local center_x = e.x + e.w/2
    local center_y = e.y + e.h/2
    for i, choice in ipairs(choices) do
      local prompt_text_width = e.font:getWidth(choice.text)
      local button = prefabs.Button(
        center_x,
        center_y + 25 * (i - 1),
        choice.text,
        e.font,
        {1,1,1,1},
        {1,0,0,1},
        {1,0,0,1},
        function (this)
          choice.callback(this)
          if this.exit then
            this.box._destroy()
          end
        end)
      button.box = e
      button.exit = choice.exit == nil and true or choice.exit
      table.insert(e.buttons, button)
      world:addEntity(button)
    end
  end)
  e:give("position",x,y,0)
  e:give("graphics",function(this)
    love.graphics.rectangle("line",e.position.x,e.position.y,e.w,e.h)
    love.graphics.setFont(e.font)
    love.graphics.print(this.prompt,this.x+20,this.y+20)
  end)
  e._destroy = function()
    for _, button in ipairs(e.buttons) do
      button:destroy()
    end
    e:destroy()
  end
  return e
end

return prefabs
