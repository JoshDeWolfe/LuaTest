-- Required
ActorModel = require ("code/actors/actorModel")
ActorView = require ("code/actors/actorView")

PlayerRef = {}

-- Object
local Actor = {}
Actor.__index = Actor

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
  -- components
  self.actorModel = ActorModel.new(self)
  self.actorView = ActorView.new(self.actorModel)
  -- fields
  self.active = true
  self.shouldDraw = true
  self.receivesInputs = false
  self.tags = { "" }
  self:setSize(params.width or 64, params.height or 64)
  -- listeners
  self.onDamageListeners = { }
  return self
end


function Has_Value (table, val)
    for __, value in ipairs(table) do
        if value == val then
            return true
        end
    end
    return false
end

function Actor:addTag(newTag)
  if Has_Value(self.tags, newTag) == false then
    table.insert(self.tags, newTag)
  end
  return self.tags
end

function Actor:removeTag(removeTag)
  while Has_Value(self.tags, removeTag) do
    for i = #self.tags, 1, -1 do
      if self.tags[i] == removeTag then
          table.remove(self.tags, i)
      end
    end
  end
  return self.tags
end

function Actor:hasTag(tag)
  return Has_Value(self.tags, tag)
end

function Actor:setWidth(newWidth)
  self.width = newWidth
  self.halfWidth = self.width * 0.5
  self.actorModel:setWidth(newWidth)
  self.actorView:setWidth(newWidth)
end

function Actor:setHeight(newHeight)
  self.height = newHeight
  self.halfHeight = self.height * 0.5
  self.actorModel:setHeight(newHeight)
  self.actorView:setHeight(newHeight)
end

function Actor:setSize(newWidth, newHeight)
  self:setWidth(newWidth)
  self:setHeight(newHeight)
end

function Actor:setXPos(newX)
  if newX ~= nil then
    self.actorModel:setXPos(newX)
  end
end

function Actor:setYPos(newY)
  if newY ~= nil then
    self.actorModel:setYPos(newY)
  end
end

function Actor:setPos(newX, newY)
  if newX ~= nil then
    self:setXPos(newX)
  end
  if newY ~= nil then
    self:setYPos(newY)
  end
end


function Actor:setIsEnemy()
  self:removeTag("player")
  self:addTag("enemy")
  self.actorView:setIsEnemy()
end

function Actor:setIsPlayer()
  self:removeTag("enemy")
  self:addTag("player")
  self.receivesInputs = true
  self.actorView:setIsPlayer()
  PlayerRef = self
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

function Actor:moveLeft(dt)
  self.actorModel:moveLeft(dt)
end

function Actor:moveRight(dt)
  self.actorModel:moveRight(dt)
end

function Actor:moveUp(dt)
  self.actorModel:moveUp(dt)
end

function Actor:moveDown(dt)
  self.actorModel:moveDown(dt)
end

function Actor:stopHorizontal()
  self.actorModel:stopHorizontal()
end

function Actor:stopVertical()
  self.actorModel:stopVertical()
end

function Actor:processInput(dt)
  for __, input in ipairs(Inputs) do
    if input.pressed then
      input.heldTime = input.heldTime + dt
      self[input.delegate](self, dt)
    end
  end
end



function Actor:checkCollision(otherActor)
  self.actorModel:checkCollision(otherActor)
end


function Actor:onDeath(actorModel)
  --self.healthBar.shouldDraw = false
end

function Actor:unbindOnDamage()
end

function Actor:bindOnDamage(newListener)
  table.insert(self.onDamageListeners, newListener)
end

function Actor:onDamage(actorModel)
  if self.onDamageListeners ~= nil and #self.onDamageListeners > 0 then
    for __, l in ipairs(self.onDamageListeners) do
      l:onDamageEvent(self.actorModel)
    end
  end
end


function Actor:update(dt)
  if self.active == false then
    return
  end
  if self.receivesInputs == true then
    self:processInput(dt)
  end
  self.actorModel:update(dt)
end


function Actor:draw()
  if self.shouldDraw then
    self.actorView:draw(self.actorModel)
  end
end

return Actor