local Concord = require 'concord'
local world = ".world"


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
  e.enabled = True
  e.defaultTextImg = love.graphics.newText(e.font, {defaultColor, e.text})
  e.selectedTextImg = love.graphics.newText(e.font, {selectedColor, e.text})
  e.clickedTextImg = love.graphics.newText(e.font, {clickedColor, e.text})
  e.disabledTextImg = love.graphics.newText(e.font, {{.2,.3,.3,.1}, e.text)
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

return prefabs
