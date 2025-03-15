---@class HydraUI.WindowComponentCreators.Text
local lib = {}
---@class HydraUI.WindowComponent.Text: HydraUI.WindowComponent
---@field height nil
---@field text string
local text = {}

local function splitIntoChunks(txt, size)
   local split = {}

   for i = 1, #txt, size do
      split[#split + 1] = txt:sub(i, i + size - 1)
   end

   return split
end

function text.event() end

---@param screen HydraKernel.Screen
function text.draw(self, screen, palette, parentX, parentY)
   local x, y = self.x, self.y - 1
   local width = self.width

   local split = splitIntoChunks(self.text, width)
   for k, v in pairs(split) do
      screen:setCursorPos(parentX + x, parentY + y + k)
      screen:blit(v, palette.text:rep(#v), palette.windowBackground:rep(#v))
   end
end

---Creates a new text
---@param txt string
---@param width integer
---@param x integer
---@param y integer
---@return HydraUI.WindowComponent.Text
function lib.new(txt, width, x, y)
   local new = setmetatable({text = txt, width = width, x = x or 5, y = y or 5}, {
      __index = text,
      __type = "HydraUI.WindowComponent.Text"
   })

   return new
end

return lib

