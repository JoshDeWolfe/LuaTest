


local HealthBar = {}
HealthBar.__index = HealthBar

function HealthBar.new()
  local self = setmetatable({}, HealthBar)
  self.percent = 100
  self.shouldDraw = true
  return self
end

function HealthBar:setPercent(newPercent)
  self.percent = newPercent
end

function HealthBar:draw()
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
  love.graphics.rectangle ("fill", 48 + padding, love.graphics.getHeight() - 100 + padding, self.percent * (300 - (padding * 2)), 50 - (padding * 2))
end

return HealthBar