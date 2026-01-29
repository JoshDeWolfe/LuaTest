-- Required


-- Object
GameStateViewModel = {}
GameStateViewModel.__index = GameStateViewModel

local actorWidth = 64
local actorHeight = 64

function GameStateViewModel.new()
  local self = setmetatable({}, GameStateViewModel)
  return self
end

function GameStateViewModel:setupEnemyStart(enemies)
  local gapSize = 96
  local rowLength = 5
  local numRows = math.ceil(#enemies/rowLength)

  local pos = {}
  -- center horizontally based on rowLength
  -- offset from center vertically
  local startX = (love.graphics.getWidth() * 0.5 - (actorWidth * (rowLength * 0.5) + (gapSize * 2)))
  pos.x = startX
  pos.y = love.graphics.getHeight() * 0.5 - (actorHeight * (-1 + numRows))  - (actorHeight * 4)

  for i = 1, #enemies, 1 do
    enemies[i]:setPos(pos.x, pos.y)
    if i % rowLength == 0 then
      pos.x = startX
      pos.y = pos.y + actorHeight + gapSize
    else
      pos.x = pos.x + actorWidth + gapSize
    end
  end
end

function GameStateViewModel:setupPlayerStart(player)
  local pos = {}
  pos.x = (love.graphics.getWidth() * 0.5) - actorWidth * 0.5
  pos.y = ((love.graphics.getHeight() * 0.5) - actorHeight * 0.5) + love.graphics.getHeight() * 0.2
  player:setPos(pos.x, pos.y)
end


return GameStateViewModel