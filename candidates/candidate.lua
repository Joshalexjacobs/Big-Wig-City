-- candidate.lua --

candidate = {
  name = nil,
  profit = nil,
  cubeNum = nil,
  x = 0,
  y = 0,
  sprite = nil,
  grid = nil,
  animations = nil,
  curAnim = 1,
  draw = function (entity)
    entity.animations[entity.curAnim]:draw(entity.sprite, entity.x, entity.y, 0, 1, 1, 0, 0)
  end,
  update = function (dt, entity)
    entity.animations[entity.curAnim]:update(dt)
  end,
  fired = false,
  question = nil,
  answer = nil
}

previousName = nil

fNames = {}
questions = {}
answers = {}

function candidate:load()
  local file = io.open("candidates/fNames.txt", "r")

  for i = 1, 60 do
    local name = file:read("*line")
    table.insert(fNames, name)
  end

  io.close(file)

  file = io.open("candidates/q.txt", "r")

  for i = 1, 734 do
    local q = file:read("*line")
    local a = file:read("*line")

    table.insert(questions, q)
    table.insert(answers, a)
  end

  io.close(file)

  candidate.sprite = love.graphics.newImage("img/big wig.png")

  candidate.grid = anim8.newGrid(24, 42, 72, 84, 0, 0, 0)

  candidate.animations = {
    anim8.newAnimation(candidate.grid('1-3', '1-2'), 0.1, "pauseAtEnd"), -- 1 spawn
    anim8.newAnimation(candidate.grid('3-1', '2-1'), 0.1, "pauseAtEnd"), -- 2 despawn
  }

end

function candidate:new()
  potCandidate = copy(candidate, potCandidate)

  potCandidate.name = fNames[love.math.random(1, 60)]

  local qNum = love.math.random(1, 367)

  potCandidate.question = questions[qNum]
  potCandidate.answer = answers[qNum]

  potCandidate.profit = love.math.random(-1000, 1000)

  print(potCandidate.name, potCandidate.profit)

  return potCandidate
end
