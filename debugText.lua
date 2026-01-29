DebugText = {}

local displayText = ""

function DebugText.Test()
  displayText = "1"
end

function DebugText.setText(newText)
  displayText = newText
end

function DebugText.addText(newText)
  displayText = displayText .. "\n" .. newText
end

function DebugText.clearText()
  displayText = ""
end


function DebugText.drawText()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(displayText, 40, 20, 0, 1, 1)
end

return DebugText