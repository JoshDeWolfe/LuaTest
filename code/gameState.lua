Actor = require "code/actor"
ViewModel = require "code/gameStateViewModel"

-- Object
local GameState = {}
GameState.__index = GameState

function GameState.new(params)
  local self = setmetatable({}, GameState)

  -- basics
  self.name = params.name or "**Blank State**"
  self.isActive = params.isActive or false
  self.viewModel = ViewModel.new()
  -- background
  self.bgPath = params.bgPath or nil
  self.bgSprite = nil
  -- gameplay
  self.player = {}
  self.enemies = {}
  self.numEnemies = 10
  return self
end

function GameState:initialize()
  DebugText.addText("Initializing Game State")
  self:setupEnemies()
  self:setupPlayer()
end

function GameState:setupEnemies()
  -- Create the enemies
  self.enemies = {}
  for i = 1, self.numEnemies, 1 do
    self.enemies[i] = Actor.new()
    self.enemies[i]:setIsEnemy() 
  end
  -- Position enemies
  self.viewModel:setupEnemyStart(self.enemies)
end

function GameState:setupPlayer()
  -- Create player
  self.player = Actor.new()
  self.player:setIsPlayer()
  -- Position player
  self.viewModel:setupPlayerStart(self.player)
end

function GameState:activate()
  DebugText.addText("Activating Game State")

  self.isActive = true
  
  if self.bgPath ~= nil then
    self.bgSprite = love.graphics.newImage(self.bgPath)
  end
end

function GameState:deactivate()
  self.isActive = false
end

function GameState:update(dt)
  if self.player ~= nil then
    self.player:update(dt)
  end
  if self.enemies ~= nil then
    for i = 1, #self.enemies, 1 do
      self.enemies[i]:update(dt)
    end
    for i = 1, #self.enemies, 1 do
      self.player:checkCollision(self.enemies[i])
    end
    for i = 1, #self.enemies, 1 do
      for n = 1, #self.enemies, 1 do
        self.enemies[n]:checkCollision(self.enemies[i])
      end
    end
  end
end

function GameState:draw()
  if self.isActive == false then
    return
  end

  if self.bgSprite ~= nil then
    love.graphics.draw(self.bgSprite, 0, 0)
  end

  if self.player ~= nil then
    self.player:draw()
  end

  if self.enemies ~= nil then
    for i = 1, #self.enemies, 1 do
      self.enemies[i]:draw() 
    end
  end
end

return GameState