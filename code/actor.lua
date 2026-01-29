
-- require
HealthBar = require ("code/healthbar")

PlayerRef = {}

-- Object
local Actor = {}
Actor.__index = Actor

Actor.actorWidth = 64
Actor.actorHeight = 64

local invincibleTime = 0.25

local frictionFactor = 0.8
local accelTime = 0.35
local maxSpeed = 3.5
local minSpeed = 0.9

local repulseFactor = 25
local reuplseVelocityDamping = -0.35
local wallThickness = 32
local enemySpritePath = "assets/enemy.png"
local playerSpritePath = "assets/player_spritesheet.png"

Inputs = {
  {
    action = "MOVE_LEFT",
    facing = "left",
    mapping = "a",
    pressed = false,
    heldTime = 0,
    delegate = "moveLeft",
    stopDelegate = "stopHorizontal"
  },
  {
    action = "MOVE_RIGHT",
    facing = "right",
    mapping = "d",
    pressed = false,
    heldTime = 0,
    delegate = "moveRight",
    stopDelegate = "stopHorizontal"
  },
  {
    action = "MOVE_DOWN",
    facing = "down",
    mapping = "s",
    pressed = false,
    heldTime = 0,
    delegate = "moveDown",
    stopDelegate = "stopVertical"
  },
  {
    action = "MOVE_UP",
    facing = "up",
    mapping = "w",
    pressed = false,
    heldTime = 0,
    delegate = "moveUp",
    stopDelegate = "stopVertical"
  }

}

function Actor.new(params)
  local self = setmetatable({}, Actor)
  if params == nil then
    params = {}
  end

  -- display
  self.spritePath = params.spritePath or ""
  self.loadedSprite = nil
  self.xFrames = 0
  self.yFrames = 0
  self.shouldDraw = true
  -- position
  self.x = params.x or 0
  self.right = self.x + Actor.actorWidth
  self.y = params.y or 0
  self.bottom = self.y + Actor.actorHeight
  self.facing = "down"
  self.moveTime = { x = 0, y = 0 }
  self.velocity = { x = 0, y = 0 }
  self.collided = false
  -- gameplay
  self.hpMax = params.hp or 100
  self.hp = self.hpMax
  self.type = params.type or "enemy"
  self.active = true
  self.damaged = false
  self.receivesInputs = false
  self.isInvincible = false
  self.invincibleTimer = 0
  -- widgets
  self.healthBar = HealthBar.new()
  return self
end

function Actor:setIsEnemy()
  self.spritePath = enemySpritePath
  self.type = "enemy"
  self:loadSprite(self.spritePath)
end

function Actor:setIsPlayer()
  self.spritePath = playerSpritePath
  self.type = "player"
  self.receivesInputs = true
  self:loadSprite(self.spritePath)
  PlayerRef = self
end

function Actor:loadSprite(path)
  self.loadedSprite = love.graphics.newImage(self.spritePath)
  self.xFrames = math.floor(self.loadedSprite:getWidth() / Actor.actorWidth)
  self.yFrames = math.floor(self.loadedSprite:getHeight() / Actor.actorHeight)
end



function love.keypressed(key)
  if PlayerRef.receivesInputs == false then
    return
  end
  for __, input in ipairs(Inputs) do
    if key == input.mapping then
      if input.pressed == false then
        input.pressed = true
        input.heldTime = 0
      end
    end
  end
end

function love:keyreleased(key)
  if PlayerRef.receivesInputs == false then
    return
  end
  for __, input in ipairs(Inputs) do
    if key == input.mapping then
      input.pressed = false
      input.heldTime = 0
      PlayerRef[input.stopDelegate](PlayerRef)
    end
  end
end

function Actor:processInput(dt)
  for __, input in ipairs(Inputs) do
    if input.pressed then
      input.heldTime = input.heldTime + dt
      self[input.delegate](self, dt)
    end
  end
end




function Actor:moveLeft(dt)
  self.facing = "left"
  self.moveTime.x = self.moveTime.x + dt

  local t = self.moveTime.x / accelTime
  local trueMax = maxSpeed * 0.4
  if self.type == "player" then
    trueMax = maxSpeed
  end

  t = math.min(t, 1)
  self.velocity.x = -(minSpeed + ((trueMax - minSpeed) * (t * t)))
end

function Actor:moveRight(dt)
  self.facing = "right"
  self.moveTime.x = self.moveTime.x + dt

  local t = self.moveTime.x / accelTime
  local trueMax = maxSpeed * 0.2
  if self.type == "player" then
    trueMax = maxSpeed
  end

  t = math.min(t, 1)
  self.velocity.x = minSpeed + ((trueMax - minSpeed) * (t * t))
end

function Actor:moveUp(dt)
  self.facing = "up"
  self.moveTime.y = self.moveTime.y + dt

  local t = self.moveTime.y / accelTime
  local trueMax = maxSpeed * 0.2
  if self.type == "player" then
    trueMax = maxSpeed
  end

  t = math.min(t, 1)
  self.velocity.y = -(minSpeed + ((trueMax - minSpeed) * (t * t)))
end

function Actor:moveDown(dt)
  self.facing = "down"
  self.moveTime.y = self.moveTime.y + dt

  local t = self.moveTime.y / accelTime
  local trueMax = maxSpeed * 0.08
  if self.type == "player" then
    trueMax = maxSpeed
  end

  t = math.min(t, 1)
  self.velocity.y = minSpeed + ((trueMax - minSpeed) * (t * t))
end

function Actor:stopHorizontal()
  self.moveTime.x = 0
end

function Actor:stopVertical()
  self.moveTime.y = 0
end



function Actor:checkCollision(otherActor)
  if (otherActor == self) then
    return false
  end
  if (self.active == false or otherActor.active == false) then
    return false
  end
  self.collided = false

  if self.right > otherActor.x and self.x < otherActor.right then
    if self.bottom > otherActor.y and self.y < otherActor.bottom then
      self.collided = true
      self.x = self.x - self.velocity.x * 2
      self.y = self.y - self.velocity.y * 2
      self.repulse(self)
      otherActor:repulse(self)
    end
  end
end

function Actor:repulse(otherActor)
  self:damage(20)

  local trueRepulse = repulseFactor
  if self.type == "enemy" then
    trueRepulse = repulseFactor * 0.75
    self:rollNewDirection(love.timer.getDelta())
  end

  self.x = self.x - (self.velocity.x * trueRepulse)
  self.y = self.y - (self.velocity.y * trueRepulse)
  self.velocity.x = self.velocity.x * reuplseVelocityDamping
  self.velocity.y = self.velocity.y * reuplseVelocityDamping
  self.moveTime.x = 0.01
  self.moveTime.y = 0.01
  self:draw()
end

function Actor:damage(damageAmount)
  if self.isInvincible then
    return
  end
  self.damaged = true
  self.hp = self.hp - damageAmount
  DebugText.addText(self.hp)
  if (self.hp <= 0) then
    self.shouldDraw = false
    self.active = false
  else
    self:setInvincible()
  end
end

function Actor:setInvincible()
  self.isInvincible = true
  self.invincibleTimer = invincibleTime
end

function Actor:endInvincible()
  self.isInvincible = false
  self.invincibleTimer = -1
end

function Actor:update(dt)
  if self.receivesInputs == true then
    self:processInput(dt)
  else
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

  self.invincibleTimer = self.invincibleTimer - dt
  if self.invincibleTimer <= 0 then
    self:endInvincible()
  end

  self.velocity.x = self.velocity.x * frictionFactor
  self.velocity.y = self.velocity.y * frictionFactor

  self.x = self.x + self.velocity.x
  self.y = self.y + self.velocity.y
  if self.x < wallThickness then
    self.x = wallThickness
    self.velocity.x = 0
    self.collided = true
  elseif self.x + Actor.actorWidth + wallThickness > love.graphics:getWidth() then
    self.x = love.graphics:getWidth() - Actor.actorWidth - wallThickness
    self.velocity.y = 0
    self.collided = true
  end

  if self.y < wallThickness then
    self.y = wallThickness
    self.velocity.x = 0
    self.collided = true
  elseif self.y + Actor.actorHeight + wallThickness > love.graphics:getHeight() then
    self.y = love.graphics:getHeight() - Actor.actorHeight - wallThickness
    self.velocity.y = 0
    self.collided = true
  end

  if self.collided then
    self:rollNewDirection(dt)
  end
  self.right = self.x + Actor.actorWidth
  self.bottom = self.y + Actor.actorHeight
end


function Actor:rollNewDirection(dt)
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

function Actor:draw()
  if self.shouldDraw == false then
    return
  end

  if self.healthBar ~= nil and self.type == "player" then
    self.healthBar:setPercent(self.hp / self.hpMax)
    self.healthBar:draw()
  end

  if self.collided then
    love.graphics.setColor(255, 0, 0)
  else
    love.graphics.setColor(255, 255, 255)
  end
  love.graphics.rectangle("line", self.x, self.y, Actor.actorWidth, Actor.actorHeight)
  love.graphics.setColor(255, 255, 255)

  if self.yFrames > 1 then
    local subx, suby = 0, 0

    if self.facing == "down" then
      suby = 0
    elseif self.facing == "up" then
      suby = Actor.actorHeight * 3
    elseif self.facing == "left" then
      suby = Actor.actorHeight * 2
    elseif self.facing == "right" then
      suby = Actor.actorHeight
    end
    
    local subFrame = love.graphics.newQuad(subx, suby, Actor.actorWidth, Actor.actorHeight, self.loadedSprite:getWidth(), self.loadedSprite:getHeight())
    
    if self.damaged then
      love.graphics.setColor(255, 0, 0)
      if self.invincibleTimer < (invincibleTime - 0.02) then
        self.damaged = false
      end
    elseif self.isInvincible then
      love.graphics.setColor(255, 255, 255, 0.3)
    end
    love.graphics.draw(self.loadedSprite, subFrame, self.x, self.y)
    love.graphics.setColor(255, 255, 255)
  elseif self.loadedSprite ~= nil then
    love.graphics.setColor(255, 0, 0)
    if self.damaged then
      if self.invincibleTimer < (invincibleTime - 0.02) then
        self.damaged = false
      end
    elseif self.isInvincible then
      love.graphics.setColor(255, 255, 255, 0.3)
    else
      love.graphics.setColor(255, 255, 255)

    end
    love.graphics.draw(self.loadedSprite, self.x, self.y)
    love.graphics.setColor(255, 255, 255)
  end
end


return Actor