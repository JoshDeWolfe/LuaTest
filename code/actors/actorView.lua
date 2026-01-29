-- Required



-- Object
ActorView = {}
ActorView.__index = ActorView


local enemySpritePath = "assets/enemy.png"
local playerSpritePath = "assets/player_spritesheet.png"

function ActorView.new(model)
  local self = setmetatable({}, ActorView)

  self.model = model
  -- display
  self.spritePath = ""
  self.loadedSprite = nil
  self.xFrames = 0
  self.yFrames = 0

  return self
end

function ActorView:setWidth(newSize)
  self.width = newSize
  self.halfWidth = self.width * 0.5
end

function ActorView:setHeight(newHeight)
  self.height = newHeight
  self.halfHeight = self.height * 0.5
end

function ActorView:setSize(newWidth, newHeight)
  self:setWidth(newWidth)
  self:setHeight(newHeight)
end


function ActorView:setIsEnemy()
  self.spritePath = enemySpritePath
  self:loadSprite(self.spritePath)
end

function ActorView:setIsPlayer()
  self.spritePath = playerSpritePath
  self:loadSprite(self.spritePath)
end

function ActorView:loadSprite(path)
  self.loadedSprite = love.graphics.newImage(self.spritePath)
  self.xFrames = math.floor(self.loadedSprite:getWidth() / self.width)
  self.yFrames = math.floor(self.loadedSprite:getHeight() / self.height)
end

function ActorView:drawHitbox()
  if self.collided then
    love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(255, 255, 255)
  end
  love.graphics.rectangle("line", self.model.x, self.model.y, self.width, self.height)
  love.graphics.setColor(255, 255, 255)
end

function ActorView:draw(actorModel)
  if self.healthBar ~= nil and self.type == "player" then
    self.healthBar:setPercent(self.hp / self.hpMax)
    self.healthBar:draw()
  end

  self:drawHitbox()
  -- draw sprite:
  -- white normally, transparent if invincible, red if took damage
  if self.model.damaged then
    love.graphics.setColor(255, 0, 0)
  elseif self.model.isInvincible then
    love.graphics.setColor(255, 255, 255, 0.3)
  end
  if self.yFrames > 1 then
    -- if we need a subframe within the spritesheet
    local subx, suby = 0, 0
    if self.model.facing == "down" then
      suby = 0
    elseif self.model.facing == "up" then
      suby = self.height * 3
    elseif self.model.facing == "left" then
      suby = self.height * 2
    elseif self.model.facing == "right" then
      suby = self.height
    end
    local subFrame = love.graphics.newQuad(subx, suby, self.width, self.height, self.loadedSprite:getWidth(), self.loadedSprite:getHeight())
    love.graphics.draw(self.loadedSprite, subFrame, self.model.x, self.model.y)
  elseif self.loadedSprite ~= nil then
    love.graphics.draw(self.loadedSprite, self.model.x, self.model.y)
  end
  love.graphics.setColor(255, 255, 255)
end

return ActorView