local GameState = require "code/gameState"
local DebugText = require ("debugText")
local currentState

-- Program start
function love:load()
    print("HI!")
  -- set up game state
  local params = {
  name = "Game State",
    isActive = false,
    bgPath = "assets/background.png"
  }

  local gs = GameState.new(params)
  gs:initialize()
  gs:activate()
  currentState = gs
end

function love.update(dt)
    if currentState ~= nil then
        currentState:update(dt)
    end
end

function love.draw()
    if currentState ~= nil then
        currentState:draw()
    end
   DebugText.drawText()
end