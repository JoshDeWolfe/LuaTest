-- Required
HealthBarView = require ("code/ui/healthbarView")

-- Object
local HealthBarViewModel = {}
HealthBarViewModel.__index = HealthBarViewModel

function HealthBarViewModel.new(actor)
  local self = setmetatable({}, HealthBarViewModel)
  self.percent = 1
  self.shouldDraw = true
  self.view = HealthBarView.new()
  self.actorModel = actor.actorModel
  actor:bindOnDamage(self)
  return self
end

function HealthBarViewModel:onDamageEvent(model)
  self.percent = model.hp / model.hpMax
  self.view:setPercent(self.percent)
  self.shouldDraw = model.actor.shouldDraw
end

function HealthBarViewModel:draw()
  if self.shouldDraw then
    self.view:draw()
  end
end

return HealthBarViewModel