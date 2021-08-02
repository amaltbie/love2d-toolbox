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

function _math.fract(x)
  return x - math.floor(x)
end

function _math.vec2(x, y)
  if y == nil then
    y = x
  end
  t = {x=x,y=y}
  mt = {
    __add = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec2(b.x+a,b.y+a)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec2(b+a.x,b+a.y)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec2(a.x+b.x,a.y+b.y)
      end
    end,
    __sub = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec2(a-b.x,a-b.y)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec2(a.x-b,a.y-b)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec2(a.x-b.x,a.y-b.y)
      end
    end,
    __mul = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec2(b.x*a,b.y*a)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec2(b*a.x,b*a.y)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec2(a.x*b.x,a.y*b.y)
      end
    end,
    __div = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec2(a/b.x,a/b.y)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec2(a.x/b,a.y/b)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec2(a.x/b.x,a.y/b.y)
      end
    end
  }
  setmetatable(t,mt)

  function t:max(o)
    if type(o) == "number" then
      return _math.vec2(math.max(self.x,o),math.max(self.y,o))
    else
      return _math.vec2(math.max(self.x,o.x),math.max(self.y,o.y))
    end
  end

  function t:dot(o)
    return self.x * o.x + self.y * o.y
  end

  function t:sin()
    return _math.vec2(math.sin(self.x),math.sin(self.y))
  end

  function t:fract()
    return _math.vec2(_math.fract(self.x),_math.fract(self.y))
  end

  function t:floor()
    return _math.vec2(math.floor(self.x),math.floor(self.y))
  end

  return t
end

function _math.vec3(x, y, z)
  if y == nil then
    y = x
    z = x
  elseif z == nil and type(x) == "table" then
    x = x.x
    y = x.y
    z = y
  end
  t = {x=x,y=y,z=z}
  mt = {
    __add = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec3(b.x+a,b.y+a,b.z+a)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec3(b+a.x,b+a.y,b+a.z)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec3(a.x+b.x,a.y+b.y,a.z+b.z)
      end
    end,
    __sub = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec3(a-b.x,a-b.y,a-b.z)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec3(a.x-b,a.y-b,a.z-b)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec3(a.x-b.x,a.y-b.y,a.z-b.z)
      end
    end,
    __mul = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec3(b.x*a,b.y*a,b.z*a)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec3(b*a.x,b*a.y,b*a.z)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec3(a.x*b.x,a.y*b.y,a.z*b.z)
      end
    end,
    __div = function(a, b)
      if type(a) == "number" and type(b) == "table" then
        return _math.vec3(a/b.x,a/b.y,a/b.z)
      elseif type(a) == "table" and type(b) == "number" then
        return _math.vec3(a.x/b,a.y/b,a.z/b)
      elseif type(a) == "table" and type(b) == "table" then
        return _math.vec3(a.x/b.x,a.y/b.y,a.z/b.z)
      end
    end
  }
  setmetatable(t,mt)

  function t:max(o)
    if type(o) == "number" then
      return _math.vec3(math.max(self.x,o),math.max(self.y,o),math.max(self.z,o))
    else
      return _math.vec3(math.max(self.x,o.x),math.max(self.y,o.y),math.max(self.z,o.z))
    end
  end

  function t:dot(o)
    return self.x * o.x + self.y * o.y + self.z * o.z
  end

  return t
end

function _math.hash22(p) -- in _math.vec2, out _math.vec2
  p = _math.vec2(p:dot(_math.vec2(127.1,311.7)), p:dot(_math.vec2(269.5,183.3)))
  return -1.0 + 2.0*(p:sin()*43758.5453123):fract()
end

-- simplex _math.noise from internet
-- https://www.shadertoy.com/view/4tdSWr
function _math.noise(p)
  K1 = 0.366025404 -- (sqrt(3)-1)/2;
  K2 = 0.211324865 -- (3-sqrt(3))/6;
  i = (p + (p.x+p.y)*K1):floor()
  a = p - i + (i.x+i.y)*K2
  if a.x>a.y then o = _math.vec2(1.0,0.0) else o = _math.vec2(0.0,1.0) end -- _math.vec2 of = 0.5 + 0.5*_math.vec2(sign(a.x-a.y), sign(a.y-a.x));
  b = a - o + K2
  c = a - 1.0 + 2.0*K2
  soup = _math.vec3(a:dot(a), b:dot(b), c:dot(c))
  -- print("soup.x: "..tostring(soup.x))
  h = (0.5-soup):max(0.0)
  -- print("h: "..tostring(h.x))
  n = h*h*h*h*_math.vec3(a:dot(_math.hash22(i+0.0)), b:dot(_math.hash22(i+o)), c:dot(_math.hash22(i+1.0)))
  return n:dot(_math.vec3(70.0))
end

-- fbm from internet
-- https://www.shadertoy.com/view/4tdSWr
function _math.fbm(n, amplitude)
  total = 0.0
  for i = 0,6 do
          total = total + _math.noise(n) * amplitude
          n = m * n
          amplitude = amplitude * 0.4
  end
  return total
end

return _math