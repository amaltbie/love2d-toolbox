---
-- @module toolbox.components
-- All components get loaded into Concord

local PATH = (...):gsub('%.init$', '')

function splitlines(str) return str:gmatch('[^\n\r]+') end
local dirpath = PATH:gsub('%.','/')
list_output = io.popen('ls -1 '..dirpath..'/*.lua'):read'*a'
for filename in splitlines(list_output) do
    local module_path = filename:gsub('%.lua',''):gsub('/','.')
    if not module_path:find('%.init') then
        require(module_path)
    end
end