-- Required


-- Object
local HealthBarView = {}
HealthBarView.__index = HealthBarView

function HealthBarView.new(model)
  local self = setmetatable({}, HealthBarView)
  self.displayPercent = 1
  self.model = model
  return self
end

function HealthBarView:setPercent(newPercent)
  self.displayPercent = newPercent
end

function HealthBarView:draw()
  if self.shouldDraw == false then
    return
  end
  local padding = 4
  if (self.percent == nil) then
    self.percent = 1
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle ("fill", 48, love.graphics.getHeight() - 100, 300, 50)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle ("fill", 48 + padding, love.graphics.getHeight() - 100 + padding, 300 - (padding * 2), 50 - (padding * 2))
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle ("fill", 48 + padding, love.graphics.getHeight() - 100 + padding, self.displayPercent * (300 - (padding * 2)), 50 - (padding * 2))
end

return HealthBarView