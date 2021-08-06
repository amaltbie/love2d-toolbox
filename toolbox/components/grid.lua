---
-- @module toolbox.components

local Concord = require 'concord'

local grid = {}

Concord.component("grid", function(c, args)
  c.width = args.width
  c.height = args.height
  c.cell_size = args.cell_size
  c.traversable = args.traversable or function(self, x, y) return true end
  c.data = {}
  -- initialize first dimension, so data can be accessed as 2d
  for x=1,c.width do
    c.data[x] = {}
  end
  function c:map(mapFunc)
    for x=1,self.width do
      for y=1,self.height do
        mapFunc(c,x,y)
      end
    end
  end
  function c:get(x, y)
    if x < 1 or
       x > c.width or
       y < 1 or
       y > c.height then
         error('coordinates ('..x..','..'y'..') are out of bounds')
    end
    return self.data[x][y]
  end
  function c:set(x, y, value)
    if x < 1 or
       x > c.width or
       y < 1 or
       y > c.height then
         error('coordinates ('..x..','..'y'..') are out of bounds')
    end
    self.data[x][y] = value
  end
  function c:toPixelCoord(n)
    return (n - 1) * self.cell_size
  end
  function c:toGridCoord(n)
    return math.ceil(n/self.cell_size)
  end
  function c:loadCSV(filename)
    local tx, ty = 1, 1
    for row in io.lines(filename) do
      tx = 1
      for val in string.gmatch(row,"[^,]+") do
        self:set(tx,ty,val)
        tx = tx + 1
      end
      ty = ty + 1
    end
  end
end)

Concord.component("tileset",function(c,data_module_name)
  c.tiles = {}
  local tileset_data = require(data_module_name)
  c.img = love.graphics.newImage(tileset_data.image)
  local rows = tileset_data.tilecount / tileset_data.columns
  for i,tileinfo in ipairs(tileset_data.tiles) do
    local id = i - 1
    local tx = id % tileset_data.columns
    local ty = math.floor(id/tileset_data.columns)
    c.tiles[id] = {
      quad = love.graphics.newQuad(
        tx * tileset_data.tilewidth,
        ty * tileset_data.tileheight,
        tileset_data.tilewidth,
        tileset_data.tilewidth,
        c.img:getDimensions()),
      data = tileinfo
    }
  end
end)

return grid
