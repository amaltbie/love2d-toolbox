---
-- @module toolbox.prefabs

local _math = {}

function _math.bbRectangle(tlx, tly, brx, bry)
  x = tlx
  y = tly
  w = math.abs(tlx - brx)
  h = math.abs(tly - bry)
  return x, y, w, h
end

return _math