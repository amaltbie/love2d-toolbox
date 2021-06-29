---
-- @module toolbox.data

local PATH = (...):gsub('%.init$', '')

local data = {}

data.pqueue = require(PATH..".pqueue")

return data