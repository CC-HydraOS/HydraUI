---@class HydraUI.WindowComponentCreators.Text
local lib = {}
---@class HydraUI.WindowComponent.Checkbox: HydraUI.WindowComponent.Button
---@field active boolean
---@field func nil
---@field width nil
---@field text nil
local checkbox = {}

---@param screen HydraKernel.Screen
function checkbox.draw(self, screen, palette, parentX, parentY)
   local x, y = self.x, self.y
   local width = self.width

   screen:setCursorPos(parentX + x, parentY + y)
   if self.active then
      screen:blit("x", palette.text, palette.checkboxActivated)
   else
      screen:blit(" ", palette.text, palette.buttonBackground)
   end
end

local function positionInButtonBounds(btn, x, y)
   x = x - btn.x - btn.parent.x
   y = y - btn.y - btn.parent.y - 1

   return (x == 0) and (y == 0)
end

function checkbox.event(self, event, ...)
   local eventData = {...}

   if event == "mouse_click" and eventData[1] == 1 and positionInButtonBounds(self, eventData[2], eventData[3]) then
      self.active = not self.active
   end
end

---Creates a new checkbox
---@param x integer
---@param y integer
---@param active boolean?
---@return HydraUI.WindowComponent.Button
function lib.new(x, y, active)
   local new = setmetatable({x = x or 5, y = y or 5, active = active and true}, {
      __index = checkbox,
      __type = "HydraUI.WindowComponent.Button"
   })

   return new
end

return lib

