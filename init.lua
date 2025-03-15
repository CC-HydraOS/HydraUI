---@diagnostic disable undefined-global

local _require = require
local container = ...
local function require(modname)
   return _require(container .. "." .. modname)
end

local palette = require("palette")

local width, height = term.getSize()

local function clearTerminal()
   for y = 1, height do
      term.setCursorPos(1, y)
      term.blit((" "):rep(width), palette.text:rep(width), palette.background:rep(width))
   end
end

local windows = {
   require("windowComponents.window").new("Test Window", 16, 6, 5, 5),
   require("windowComponents.window").new("Test Window 2", 14, 8, 24, 5)
}

-- Testing stuff
windows[1]:addComponent(require("windowComponents.text").new("BASIC COMPONENTS EXIST NOW!!!", 14, 1, 1))
windows[2]:addComponent(require("windowComponents.text").new("Clicker: ", 8, 1, 1))
windows[2]:addComponent(require("windowComponents.button").new("000", 3, 10, 1, function(self)
   self.text = string.format("%03i", tonumber(self.text) + 1)
end))
-- End testing stuff

local function draw()
   clearTerminal()

   for k, v in pairs(windows) do
      v:draw(palette)
   end
end

draw()
while true do
   local event, val1, val2, val3, val4, val5 = os.pullEvent()

   for k, v in pairs(windows) do
      local change = v:event(event, val1, val2, val3, val4, val5)

      if change == "DELETE" then
         windows[k] = nil
      end
   end

   draw()
end

