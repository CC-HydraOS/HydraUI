---@class HydraUI.WindowComponentCreators.Text
local lib = {}
---@class HydraUI.WindowComponent.Button: HydraUI.WindowComponent.Text
---@field func fun(self: HydraUI.WindowComponent.Button)
local button = {}

local function splitIntoChunks(txt, size)
   local split = {}

   for i = 1, #txt, size do
      split[#split + 1] = txt:sub(i, i + size - 1)
   end

   return split
end

---@param screen HydraKernel.Screen
function button.draw(self, screen, palette, parentX, parentY)
   local x, y = self.x, self.y - 1
   local width = self.width

   local split = splitIntoChunks(self.text, width)
   for k, v in pairs(split) do
      screen:setCursorPos(parentX + x, parentY + y + k)
      screen:blit(v, palette.text:rep(#v), palette.buttonBackground:rep(#v))
   end
end

local function positionInButtonBounds(btn, x, y)
   x = x - btn.x - btn.parent.x
   y = y - btn.y - btn.parent.y - 1

   return (x >= 0) and
      (y >= 0) and
      (y < math.ceil(#btn.text / btn.width)) and
      (x < btn.width)
end

function button.event(self, event, ...)
   local eventData = {...}

   if event == "mouse_click" and eventData[1] == 1 and positionInButtonBounds(self, eventData[2], eventData[3]) then
      self.func(self)
   end
end

---Creates a new button
---@param txt string
---@param width integer
---@param x integer
---@param y integer
---@param func fun(self: HydraUI.WindowComponent.Button)
---@return HydraUI.WindowComponent.Button
function lib.new(txt, width, x, y, func)
   local new = setmetatable({text = txt, width = width, x = x or 5, y = y or 5, func = func}, {
      __index = button,
      __type = "HydraUI.WindowComponent.Button"
   })

   return new
end

return lib

