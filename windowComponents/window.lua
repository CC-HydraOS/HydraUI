---@class HydraUI.WindowComponentCreators.Window
local lib = {}
---@class HydraUI.WindowComponent.Window: HydraUI.WindowComponent
---@field children HydraUI.WindowComponent[]
---@field closed boolean
---@field title string
---@field _dragOffsetX integer
---@field _dragOffsetY integer
---@field dragging boolean?
local window = {}

function window.addComponent(self, component)
   component.parent = self
   self.children[#self.children + 1] = component
end

---@param screen HydraKernel.Screen
function window.draw(self, screen, palette)
   local width, height = self.width, self.height
   local x, y = self.x, self.y
   local title = self.title

   local titleSpaceCount = (width - #title) / 2
   if titleSpaceCount < 0 then titleSpaceCount = 0 end

   local titleStr = (" "):rep(math.floor(titleSpaceCount)) .. title .. (" "):rep(math.ceil(titleSpaceCount))

   screen:setCursorPos(x, y)
   screen:blit(titleStr, palette.text:rep(#titleStr), palette.windowTitleBackground:rep(#titleStr))

   screen:setCursorPos(x + width - 1, y)
   screen:blit("X", palette.text, palette.closeButton)

   for cy = y + 1, y + height - 1 do
      screen:setCursorPos(x, cy)
      screen:blit((" "):rep(width), palette.text:rep(width), palette.windowBackground:rep(width))
   end

   for _, v in pairs(self.children) do
      v:draw(screen, palette, self.x, self.y + 1)
   end
end

local function positionOnTitleBar(x, y, width)
   return (y == 0) and
      (x < width) and
      (x >= 0)
end

function window.event(self, event, ...)
   local eventData = {...}

   if event == "mouse_click" and eventData[1] == 1 then
      local x, y = eventData[2], eventData[3]

      if (x - self.x == (self.width - 1)) and (y - self.y == 0) then
         self.closed = true
         return "DELETE"
      elseif positionOnTitleBar(x - self.x, y - self.y, self.width) then
         self.dragging = true
         self._dragOffsetX = self.x - x
         self._dragOffsetY = self.y - y
      end
   elseif event == "mouse_drag" and self.dragging then
      self.x = eventData[2] + self._dragOffsetX
      self.y = eventData[3] + self._dragOffsetY
   elseif event == "mouse_up" and eventData[1] == 1 then
      self.dragging = false
   end

   for _, v in pairs(self.children) do
      v:event(event, ...)
   end
end

function lib.new(title, width, height, x, y)
   local new = setmetatable({title=title, width=width, height=height, x = x or 5, y = y or 5, children = {}}, {
      __index = window,
      __type = "HydraUI.WindowComponent.Window"
   })

   return new
end

return lib

