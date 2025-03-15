---@diagnostic disable undefined-global

local term = kernel.screen.get(0)

---@class HydraUI
ui = {}

local _require = require
local container = ...
local function require(modname)
   return _require(container .. "." .. modname)
end

local palette = require("palette")

local width, height = term:getSize()

local function clearTerminal()
   for y = 1, height do
      term:setCursorPos(1, y)
      term:blit((" "):rep(width), palette.text:rep(width), palette.background:rep(width))
   end
end

local windows = {
   require("windowComponents.window").new("Test Window", 16, 6, 5, 5),
   require("windowComponents.window").new("Test Window 2", 14, 8, 24, 5)
}
local tabs = {
   ["HydraUI"] = {
      draw = function() end,
      event = function() end
   }
}
local tabOrder = {"HydraUI"}

local function draw()
   clearTerminal()

   for k, v in pairs(windows) do
      v:draw(term, palette)
   end
end

ui.windows = windows
---Adds a window to the canvas
---@param window HydraUI.WindowComponent.Window
function ui.addWindow(window)
   windows[#windows + 1] = window
end

function ui.addTab(name, tab)
   tabs[name] = tab
   tabOrder[#tabOrder + 1] = name
end

local tab = "HydraUI"
local function drawTabs(event, button, x, y)
   term:setCursorPos(1, 1)
   term:blit((" "):rep(term:getWidth()), palette.text:rep(term:getWidth()), palette.windowTitleBackground:rep(term:getWidth()))
   term:setCursorPos(1, 1)

   local positions = {}

   for index, name in ipairs(tabOrder) do
      local color = palette.windowTitleBackground
      if name == tab then
         color = palette.darkWindowTitleBackground
      end

      positions[#positions + 1] = {
         term:getCursorPos(),
         term:getCursorPos() + #name - 1,
         type = "tab",
         value = name,
      }

      term:blit(name, palette.text:rep(#name), color:rep(#name))

      if name ~= "HydraUI" then
         positions[#positions + 1] = {
            term:getCursorPos(),
            term:getCursorPos(),
            type = "close",
            value = name,
            value2 = index
         }

         term:blit("X", palette.text, palette.closeButton)
      else
         term:blit("X", palette.text, palette.buttonBackground)
      end
   end

   if event == "mouse_click" and button == 1 and y == 1 then
      for _, v in pairs(positions) do
         if x >= v[1] and x <= v[2] then
            if v.type == "tab" then
               tab = v.value
            elseif v.type == "close" then
               tabs[v.value] = nil
               
               if tab == v.value then
                  tab = "HydraUI"
               end

               table.remove(tabOrder, v.value2)
            end
         end
      end
   end
end

-- Testing stuff
windows[1]:addComponent(require("windowComponents.text").new("BASIC COMPONENTS EXIST NOW!!!", 14, 1, 1))
windows[2]:addComponent(require("windowComponents.text").new("Clicker: ", 8, 1, 1))
windows[2]:addComponent(require("windowComponents.button").new("000", 3, 10, 1, function(self)
   self.text = string.format("%03i", tonumber(self.text) + 1)
end))

local prevEvents = {}
ui.addTab("Events", {
   draw = function()
      term:setBackgroundColor(0x8000)
      term:setTextColor(0x1)
      term:clear()
      for i, v in ipairs(prevEvents) do
         term:setCursorPos(1, 1 + i)
         local str = table.concat(v, " ")
         term:write(str, true)
      end
   end,
   event = function(self, ...)
      local prevEvent = table.pack(...)

      for i = 1, prevEvent.n do
         prevEvent[i] = tostring(prevEvent[i] ~= nil and prevEvent[i] or "")
      end

      if #prevEvents == term:getHeight() then
         table.remove(prevEvents, 1)
      end

      prevEvents[#prevEvents + 1] = prevEvent
   end
})
-- End testing stuff

draw()
drawTabs()
while true do
   local event, val1, val2, val3, val4, val5 = os.pullEvent()

   if tab == "HydraUI" then
      for k, v in pairs(windows) do
         local change = v:event(event, val1, val2, val3, val4, val5)

         if change == "DELETE" then
            windows[k] = nil
         end
      end
   
      draw()
   elseif tabs[tab] then
      tabs[tab]:event(event, val1, val2, val3, val4, val5)
      tabs[tab]:draw()
   end

   if #tabs > 0 then
      drawTabs(event, val1, val2, val3)
   end
end

