---@class HydraUI.WindowComponent
---@field width integer
---@field height integer
---@field x integer
---@field y integer
---@field parentX integer
---@field parentY integer
---@field parent HydraUI.WindowComponent?
local window = {}

---Draws the window component
---@param self HydraUI.WindowComponent
---@param screen HydraKernel.Screen
---@param palette table
---@param parentX integer
---@param parentY integer
function window.draw(self, screen, palette, parentX, parentY)
end

---Passes an event to the window
---@param self HydraUI.WindowComponent
---@param event string
---@param ... any
---@return string?
function window.event(self, event, ...)
end

