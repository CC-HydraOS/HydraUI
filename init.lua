---@diagnostic disable undefined-global

local term = kernel.screen.get(0)
term:setCursorBlinking(false)

---@class HydraUI
_G.ui = {}

local palette = require("HydraUI.palette")

local width, height = term:getSize()

local function clearTerminal()
   for y = 1, height do
      term:setCursorBlinking(false)
      term:setCursorPos(1, y)
      term:blit((" "):rep(width), palette.text:rep(width), palette.background:rep(width))
   end
end

local windows = {}
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
local prevEvents = {}
ui.addTab("Events", {
   draw = function()
      term:setBackgroundColor(0x8000)
      term:setTextColor(0x1)
      term:clear()
      term:setCursorPos(1, 2)
      for i, v in ipairs(prevEvents) do
         local str = table.concat(v, " ")
         print(str)
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
   local event, val1, val2, val3, val4, val5 = kernel.events.awaitEvent()
   if tab == "HydraUI" then
      for k, v in pairs(windows) do
         local change = v:event(event, val1, val2, val3, val4, val5)

         if change == "DELETE" then
            windows[k] = nil
         elseif change == "FINISH" then
            goto tabs
         end
      end
   
      ::tabs::
      draw()
   elseif tabs[tab] then
      tabs[tab]:event(event, val1, val2, val3, val4, val5)
      tabs[tab]:draw()
   end

   drawTabs(event, val1, val2, val3)
end

return ui

