-- zones.lua

zone = {
  x1 = 400,
  y1 = 300,
  x2 = 0,
  y2 = 0,
  x3 = 0,
  y3 = 0,
  name = nil,
  angle = nil,
  selected = false,
  index = nil,
  color = nil
}

zones = {}

center = {
  x = 400,
  y = 300
}

currentCircle = 360

function zone:new(x1, y1, x2, y2, x3, y3, name, index, color)
  newZone = copy(zone, newZone)

  newZone.x1, newZone.y1, newZone.x2, newZone.y2, newZone.x3, newZone.y3, newZone.name, newZone.index, newZone.color = x1, y1, x2, y2, x3, y3, name, index, color

  table.insert(zones, newZone)
end

baseColor = {242, 186, 186, 255}
red = 242
green = 168
blue = 186
function zone:generate(segment, names, mode)
  newColor = {}

  if segment == 1 then
    zone:new(625, 100, 425, 400, 825, 400, names[1], segment, baseColor)
    return true
  end

  if segment == 2 then -- 510, 130, 745, 480, 470, 415
    zone:new(510, 130, 470, 415, 745, 480, names[1], 1, baseColor) -- names[1], 1
    newColor = {red - 20, green - 20, blue - 20, 255}
    zone:new(510, 130, 795, 205, 745, 480, names[2], 2, newColor) --names[2], 2
    return true
  end

  local prevPoint = {x = nil, y = nil}
  local angleSize = 360 / segment
  local radAngle = angleSize * (math.pi/180)

  local prioritySet = false

  for i=1, segment do
    x1, y1 = 625, 300 -- center

    if prevPoint.x == nil and prevPoint.y == nil then
      x2, y2 = 400, 300
    else
      x2, y2 = prevPoint.x, prevPoint.y
    end

    while math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 ) < 230 do
      x2, y2 = love.math.random(450, 800), love.math.random(125, 480)
    end

    local d = math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )

    x3 = math.cos(radAngle) * (x2 - x1) - math.sin(radAngle) * (y2 - y1) + x1
    y3 = math.sin(radAngle) * (x2 - x1) + math.cos(radAngle) * (y2 - y1) + y1

    prevPoint.x, prevPoint.y = x3, y3

    if i == segment and mode == "random" then
      if prioritySet == false then
        zone:new(x1, y1, x2, y2, x3, y3, names[1], i, baseColor)

        return true
      end
    end

    if mode == "random" then
      local j = love.math.random(1, #names)
      zoneName = names[j]
      if zoneName == names[1] then prioritySet = true end

      newColor = {red - 20 * j, green - 20 * j, blue - 20 * j, 255}

    else
      zoneName = names[i]
      if i > 1 then
        newColor = {red - 20 * i, green - 20 * i, blue - 20 * i, fade}
      else
        newColor = baseColor
      end
    end

    zone:new(x1, y1, x2, y2, x3, y3, zoneName, i, newColor)
  end
end

function zoneCheck(spinner)
  local v1 = {x = 0, y = 0}
  local v2 = {x = 0, y = 0}

  for _, triangle in ipairs(zones) do
    -- bool b0 = (Vector(P.x - A.x, P.y - A.y) * Vector(A.y - B.y, B.x - A.x) > 0);
    v1.x, v1.y = spinner.x - triangle.x1, spinner.y - triangle.y1
    v2.x, v2.y = triangle.y1 - triangle.y2, triangle.x2 - triangle.x1

    b0 = v1.x * v2.x + v1.y * v2.y
    b0 = b0 > 0

    -- bool b1 = (Vector(P.x - B.x, P.y - B.y) * Vector(B.y - C.y, C.x - B.x) > 0);
    v1.x, v1.y = spinner.x - triangle.x2, spinner.y - triangle.y2
    v2.x, v2.y = triangle.y2 - triangle.y3, triangle.x3 - triangle.x2

    b1 = v1.x * v2.x + v1.y * v2.y
    b1 = b1 > 0

    -- bool b2 = (Vector(P.x - C.x, P.y - C.y) * Vector(C.y - A.y, A.x - C.x) > 0);
    v1.x, v1.y = spinner.x - triangle.x3, spinner.y - triangle.y3
    v2.x, v2.y = triangle.y3 - triangle.y1, triangle.x1 - triangle.x3

    b2 = v1.x * v2.x + v1.y * v2.y
    b2 = b2 > 0

    --return (b0 == b1 and b1 == b2);
    if b0 == b1 and b1 == b2 then
      triangle.selected = true
      if spinner.clicked == true then
        spinner.zone = triangle.name
        spinner.index = triangle.index
      end
    else
      triangle.selected = false
    end
  end
end

function zone:deleteAll()
  zones = {}
end

function zone:update(spinner)
  zoneCheck(spinner)
end

function zone:draw()
  for _, newZone in ipairs(zones) do

    if newZone.selected == true then
      love.graphics.setLineWidth(3)
    end

    love.graphics.setColor(newZone.color)
    love.graphics.polygon("fill", newZone.x1, newZone.y1, newZone.x2, newZone.y2, newZone.x3, newZone.y3)
    love.graphics.setColor(255, 255, 255, fade)

    -- for debugging:
    -- first line
    --love.graphics.line(newZone.x1, newZone.y1, newZone.x2, newZone.y2)

    -- second line
    --love.graphics.line(newZone.x2, newZone.y2, newZone.x3, newZone.y3)

    -- third line
    --love.graphics.line(newZone.x3, newZone.y3, newZone.x1, newZone.y1)

    -- print name
    local midX = (newZone.x1 + newZone.x2 + newZone.x3) / 3
    local midY = (newZone.y1 + newZone.y2 + newZone.y3) / 3

    local deltaX = newZone.x3 - newZone.x2
    local deltaY = newZone.y3 - newZone.y2

    local angle = math.atan(midY- newZone.y1, midX - newZone.x1) * 180 / math.pi

    love.graphics.printf(newZone.name, midX - 50, midY, 100, "center")

    love.graphics.setLineWidth(1)
  end
end
