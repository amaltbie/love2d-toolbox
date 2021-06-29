---
-- @module toolbox.resources

local resources = {}

fonts = {}
fonts.early_gameboy = love.graphics.newFont("Early GameBoy.ttf", 15)
fonts.basis33 = love.graphics.newFont("basis33.ttf", 20)

resources.fonts = fonts

return resources