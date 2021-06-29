---
-- @module toolbox

local PATH = (...):gsub('%.init$', '')

local toolbox = {
   _VERSION     = "1.0",
   _DESCRIPTION = "Love2d Toolbox"
}

math.randomseed(os.time())

function toolbox.random()
  return math.random()
end

toolbox.graphics = require(PATH..".graphics")
toolbox.world = require(PATH..".world")
toolbox.resources = require(PATH..".resources")
toolbox.prefabs = require(PATH..".prefabs")
toolbox.math = require(PATH..".math")
require(PATH..".components")

return toolbox
