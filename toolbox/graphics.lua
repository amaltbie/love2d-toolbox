---
-- @module toolbox.graphics

local Concord = require 'concord'

local graphics = {}

Concord.component("animation",function(c,filename,width,height,rotate,speed,scale)
   c.image = love.graphics.newImage(filename)
   c.frame_count = c.image:getWidth() / width
   c.current_frame_index = 0
   c.framequads = {}
   c.rotate = rotate
   c.speed = speed
   c.scale = scale
   for i=0,c.frame_count - 1 do
      c.framequads[i] = love.graphics.newQuad(
         i*width,
         0,
         width,
         height,
         c.image)
   end
   c.draw = function(this)
      love.graphics.draw(
         this.animation.image,
         this.animation.framequads[math.floor(this.animation.current_frame_index)],
         this.position.x,
         this.position.y,
         this.animation.rotate - math.pi/2,
         this.animation.scale,
         this.animation.scale)
      this.animation.current_frame_index = (this.animation.current_frame_index + this.animation.speed) % this.animation.frame_count
   end
end)

Concord.component("rotatable",function(c,r)
   c.r = r
end)

function graphics.AnimationAsmbl(e,filename,width,height,rotate,speed)
   e
   :give("animation",filename,width,height,rotate,speed)
   :give("graphics", function(this)
      this.animation.draw(this)
   end)
end

return graphics