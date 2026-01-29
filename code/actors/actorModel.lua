-- Required



-- Object
ActorModel = {}
ActorModel.__index = ActorModel

local invincibleTime = 0.25
local flashTime = 0.02

local frictionFactor = 0.825
local accelTime = 0.35
local maxSpeed = 3.5
local maxSpeedEnemy = maxSpeed * 0.35
local minSpeed = 1.325

local repulseFactor = 25
local reuplseVelocityDamping = -0.35
local wallThickness = 32

function ActorModel.new(actorRef)
  local self = setmetatable({}, ActorModel)

  self.actor = actorRef
  -- size/position
  self.x = 0
  self.right = 0
  self.y = 0
  self.width = 0
  self.halfWidth = 0
  self.height = 0
  self.halfHeight = self.height * 0.5
  self.bottom = 0
  -- physics
  self.moveTime = { x = 0, y = 0 }
  self.velocity = { x = 0, y = 0 }
  self.collided = false
  -- gameplay
  self.facing = "down"
  self.hpMax = 100
  self.hp = self.hpMax
  self.damaged = false
  self.isInvincible = false
  self.invincibleTimer = 0
  return self
end

function ActorModel:hasTag(tag)
  return Has_Value(self.actor.tags, tag)
end

function ActorModel:setWidth(newSize)
  self.width = newSize
  self.halfWidth = self.width * 0.5
end

function ActorModel:setHeight(newHeight)
  self.height = newHeight
  self.halfHeight = self.height * 0.5
end

function ActorModel:setSize(newWidth, newHeight)
  self:setWidth(newWidth)
  self:setHeight(newHeight)
end


function ActorModel:setXPos(newX)
  if newX ~= nil then
    self.x = newX
  end
end

function ActorModel:setYPos(newY)
  if newY ~= nil then
    self.y = newY
  end
end

function ActorModel:setPos(newX, newY)
  if newX ~= nil then
    self:setXPos(newX)
  end
  if newY ~= nil then
    self:setYPos(newY)
  end
end


function ActorModel:moveLeft(dt)
  self.facing = "left"
  self.moveTime.x = self.moveTime.x + dt
  local trueSpeed = maxSpeed
  if self:hasTag("enemy") then trueSpeed = maxSpeedEnemy
  end
  local t = self.moveTime.x / accelTime
  t = math.min(t, 1)
  self.velocity.x = -(minSpeed + ((trueSpeed - minSpeed) * (t * t)))
end

function ActorModel:moveRight(dt)
  self.facing = "right"
  self.moveTime.x = self.moveTime.x + dt
  local trueSpeed = maxSpeed
  if self:hasTag("enemy") then trueSpeed = maxSpeedEnemy
  end
  local t = self.moveTime.x / accelTime
  t = math.min(t, 1)
  self.velocity.x = minSpeed + ((trueSpeed - minSpeed) * (t * t))
end

function ActorModel:moveUp(dt)
  self.facing = "up"
  self.moveTime.y = self.moveTime.y + dt
  local trueSpeed = maxSpeed
  if self:hasTag("enemy") then trueSpeed = maxSpeedEnemy
  end
  local t = self.moveTime.y / accelTime
  t = math.min(t, 1)
  self.velocity.y = -(minSpeed + ((trueSpeed - minSpeed) * (t * t)))
end

function ActorModel:moveDown(dt)
  self.facing = "down"
  self.moveTime.y = self.moveTime.y + dt
  local trueSpeed = maxSpeed
  if self:hasTag("enemy") then trueSpeed = maxSpeedEnemy
  end
  local t = self.moveTime.y / accelTime
  t = math.min(t, 1)
  self.velocity.y = minSpeed + ((trueSpeed - minSpeed) * (t * t))
end

function ActorModel:stopHorizontal()
  self.moveTime.x = 0
end

function ActorModel:stopVertical()
  self.moveTime.y = 0
end

function ActorModel:repulse(otherActor)
  self:damage(20)

  local trueRepulse = repulseFactor
  if self:hasTag("enemy") then
    trueRepulse = repulseFactor * 0.75
    self:rollNewDirection(love.timer.getDelta())
  end

  self.x = self.x - (self.velocity.x * trueRepulse)
  self.y = self.y - (self.velocity.y * trueRepulse)
  self.velocity.x = self.velocity.x * reuplseVelocityDamping
  self.velocity.y = self.velocity.y * reuplseVelocityDamping
  self.moveTime.x = 0.01
  self.moveTime.y = 0.01
end

function ActorModel:damage(damageAmount)
  if self.isInvincible then
    return
  end
  self.damaged = true
  self.hp = self.hp - damageAmount
  if (self.hp <= 0) then
    self:inflictDeath()
  else
    self:setInvincible()
  end
  self.actor:onDamage(self)
end

function ActorModel:inflictDeath()
  self.actor.shouldDraw = false
  self.actor.active = false
  self.actor:onDeath(self)
end

function ActorModel:rollNewDirection(dt)
  local roll = math.random()
  if roll < 0.25 then
    self:moveLeft(dt)
  elseif roll < 0.5 then
    self:moveRight(dt)
  elseif roll < 0.75 then
    self:moveUp(dt)
  else
    self:moveDown(dt)
  end
end

function ActorModel:setInvincible()
  self.isInvincible = true
  self.invincibleTimer = invincibleTime
end

function ActorModel:endInvincible()
  self.isInvincible = false
  self.invincibleTimer = -1
end

-- compares against another actor
function ActorModel:checkCollision(other)
  self.collided = false
  if (other.actorModel == self) then
    return false
  end
  if (self.actor.active == false or other.active == false) then
    return false
  end

  if self.right > other.actorModel.x and self.x < other.actorModel.right then
    if self.bottom > other.actorModel.y and self.y < other.actorModel.bottom then
      self.collided = true
      self.x = self.x - self.velocity.x * 2
      self.y = self.y - self.velocity.y * 2
      self.repulse(self)
      other.actorModel:repulse(self)
    end
  end
end

function ActorModel:enemyMovement(dt)
      local roll2 = math.random()
    if roll2 > 0.975 then
      local roll = math.random()
      self:rollNewDirection(dt)
    else
      if self.facing == "up" then self:moveUp(dt)
      elseif self.facing == "down" then self:moveDown(dt)
      elseif self.facing == "left" then self:moveLeft(dt)
      elseif self.facing == "right" then self:moveRight(dt)
      end
    end
end

function ActorModel:constrainToScreen()
  if self.x < wallThickness then
    self.x = wallThickness
    self.velocity.x = 0
    self.collided = true
  elseif self.x + self.width + wallThickness > love.graphics:getWidth() then
    self.x = love.graphics:getWidth() - self.width - wallThickness
    self.velocity.y = 0
    self.collided = true
  end
  if self.y < wallThickness then
    self.y = wallThickness
    self.velocity.x = 0
    self.collided = true
  elseif self.y + self.height + wallThickness > love.graphics:getHeight() then
    self.y = love.graphics:getHeight() - self.height - wallThickness
    self.velocity.y = 0
    self.collided = true
  end
end

function ActorModel:update(dt)
  if self:hasTag("enemy") then
    self:enemyMovement(dt)
  end

  self.invincibleTimer = self.invincibleTimer - dt
  if self.invincibleTimer <= (invincibleTime - flashTime) then
    self.damaged = false
  end
  if self.invincibleTimer <= 0 then
    self:endInvincible()
  end

  self.velocity.x = self.velocity.x * frictionFactor
  self.velocity.y = self.velocity.y * frictionFactor
  self.x = self.x + self.velocity.x
  self.y = self.y + self.velocity.y
  self:constrainToScreen()

  if self.collided and self:hasTag("enemy") then
    self:rollNewDirection(dt)
  end
  self.right = self.x + self.width
  self.bottom = self.y + self.height
end

return ActorModel