-- Required
HealthBarViewModel = require ("code/ui/healthbarViewModel")

-- Object
local UIController = {}
UIController.__index = UIController

function UIController.new(gameState)
  local self = setmetatable({}, UIController)
  self.shouldDraw = true
  -- widgets
  self.healthBar = HealthBarViewModel.new(gameState.player)
  return self
end

function UIController:update(gameState)
  if self.healthBar ~= nil then
    --self.healthBar:setPercent(self.actorModel.hp / self.actorModel.hpMax)
  end
end

function UIController:draw()
  if self.shouldDraw == false then
    return
  end
  if self.healthBar ~= nil then
    self.healthBar:draw()
  end
end

return UIController