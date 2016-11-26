-- events

event = {
  bad = {},
  good = {},
  neutral = {}
}

eventObj = {
  type = nil,
  name = "nil",
  desc = "nil",
  min = 0,
  max = 0
}

function event:load()
  -- load bad events
  local file = io.open("events/bad.txt", "r")

  for i = 1, 16 do
    local newEvent = copy(eventObj, newEvent)
    newEvent.type = "bad"
    newEvent.name = file:read("*line")
    newEvent.desc = file:read("*line")
    newEvent.min = tonumber(file:read("*line"))
    newEvent.max = tonumber(file:read("*line"))
    table.insert(event.bad, newEvent)
  end

  io.close(file)

  -- load good events
  local gfile = io.open("events/good.txt", "r")

  for i = 1, 16 do
    local newEvent = copy(eventObj, newEvent)
    newEvent.type = "good"
    newEvent.name = gfile:read("*line")
    newEvent.desc = gfile:read("*line")
    newEvent.min = tonumber(gfile:read("*line"))
    newEvent.max = tonumber(gfile:read("*line"))

    table.insert(event.good, newEvent)
  end

  io.close(gfile)

  local nfile = io.open("events/neutral.txt")

  for i = 1, 3 do
    local newEvent = copy(eventObj, newEvent)
    newEvent.type = "neutral"
    newEvent.name = nfile:read("*line")
    newEvent.desc = nfile:read("*line")
    newEvent.min = tonumber(nfile:read("*line"))
    newEvent.max = tonumber(nfile:read("*line"))

    table.insert(event.neutral, newEvent)
  end

  io.close(nfile)
end

function eventNew()
  local chance = love.math.random(0, 2)

  if chance == 0 then -- odds are good
    return event.good[love.math.random(1,16)]
  elseif chance == 1 then -- odds are bad
    return event.bad[love.math.random(1,16)]
  elseif chance == 2 then
    return event.neutral[love.math.random(1,3)]
  end

end
