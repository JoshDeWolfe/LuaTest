-- Required


-- Object
GameStateViewModel = {}
GameStateViewModel.__index = GameStateViewModel

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
  local startX = (love.graphics.getWidth() * 0.5 - (Actor.actorWidth * (rowLength * 0.5) + (gapSize * 2)))
  pos.x = startX
  pos.y = love.graphics.getHeight() * 0.5 - (Actor.actorWidth * (-1 + numRows))  - (Actor.actorHeight * 4)

  for i = 1, #enemies, 1 do
    enemies[i].x = pos.x
    enemies[i].y = pos.y

    if i % rowLength == 0 then
      pos.x = startX
      pos.y = pos.y + Actor.actorHeight + gapSize
    else
      pos.x = pos.x + Actor.actorWidth + gapSize
    end
  end
end

function GameStateViewModel:setupPlayerStart(player)
  player.x = (love.graphics.getWidth() * 0.5) - Actor.actorWidth * 0.5
  player.y = ((love.graphics.getHeight() * 0.5) - Actor.actorHeight * 0.5) + love.graphics.getHeight() * 0.2
end

return GameStateViewModel