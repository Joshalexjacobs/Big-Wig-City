game = {} -- create game gamestate

-- objects:
phase = "start"

turnNum = 0 -- current turn number
maxTurns = 14 -- 1 turn == 1 week

goal = 0 -- end revenue after 14 turns

dailyHireCount = 0 -- max is 2
dailyRejectCount = 0 -- max is 5

spinner = { -- declare our spinner object
  x = 600,
  y = 150,
  w = 10,
  h = 10,
  dx = 0,
  dy = 0,
  speed = 0.2,
  angle = 1.57,
  zone = "none",
  index = nil,
  clicked = false,
}

circle = { -- the invisible circle that holds our zones
  x = 625,
  y = 300,
  w = 1250,
  h = 600,
  r = 175
}

timers = {}

curCandidate = nil -- the current candidate being interviewed

employees = {} -- all of our employees
employeeNames = {}

maxCubes = 24 -- max number of cubicles

employeeCubes = { -- the draw location for each cubicle
  -- first row
  {x = 90, y = 530, occupied = false},
  {x = 220, y = 530, occupied = false},
  {x = 350, y = 530, occupied = false},

  {x = 90, y = 466, occupied = false},
  {x = 220, y = 466, occupied = false},
  {x = 350, y = 466, occupied = false},

  -- second row
  {x = 90, y = 402, occupied = false},
  {x = 220, y = 402, occupied = false},
  {x = 350, y = 402, occupied = false},

  {x = 90, y = 338, occupied = false},
  {x = 220, y = 338, occupied = false},
  {x = 350, y = 338, occupied = false},

  -- third row
  {x = 90, y = 274, occupied = false},
  {x = 220, y = 274, occupied = false},
  {x = 350, y = 274, occupied = false},

  {x = 90, y = 210, occupied = false},
  {x = 220, y = 210, occupied = false},
  {x = 350, y = 210, occupied = false},

  -- fourth row
  {x = 90, y = 146, occupied = false},
  {x = 220, y = 146, occupied = false},
  {x = 350, y = 146, occupied = false},

  {x = 90, y = 82, occupied = false},
  {x = 220, y = 82, occupied = false},
  {x = 350, y = 82, occupied = false},
}

curEvent = {}
curEventCost = 0

actionCards = { -- our starting hand contains 1 of each card
  "Skip",
  "Fire",
  "Promote"
}

business = {
  money = 0,
  earnings = 0, -- per turn
}

map = nil -- the game's backdrop

titleAlpha = 255
alphaDir = 0

fade = 255
fadeOut = false
fadeIn = false

employeeSprite = nil
employeeGrid = nil
employeeAnims = {}
employeeAnim = 1

function game:enter()
  -- upon entering the game gamestate we load everything needed
  -- load all images
  map = love.graphics.newImage("img/map.png")
  title = love.graphics.newImage("img/big wig textBIG.png")
  window1 = love.graphics.newImage("img/big wigdow1.png")
  window2 = love.graphics.newImage("img/big wigdow2.png")
  window3 = love.graphics.newImage("img/big wigdow3.png")
  window4 = love.graphics.newImage("img/big wigdow4.png")

  sad = love.graphics.newImage("img/sad.png")
  neutral = love.graphics.newImage("img/neutral.png")
  happy = love.graphics.newImage("img/happy.png")

  employeeSprite = love.graphics.newImage("img/employeesXBIG.png")
  employeeGrid = anim8.newGrid(96, 144, 960, 1152, 0, 0, 0)

  col = 1
  row = 1

  -- insert our employee animations
  for i = 1, 73 do
    table.insert(employeeAnims, anim8.newAnimation(employeeGrid(col, row), 0.1))
    col = col + 1

    if col > 10 then
      row = row + 1
      col = 1
    end
  end

  -- load fonts
  smallFont = love.graphics.newFont("lib/kenpixel_mini.ttf", 14)
  medFont = love.graphics.newFont("lib/kenpixel_mini.ttf", 25)
  bigFont = love.graphics.newFont("lib/kenpixel_mini.ttf", 40)
  love.graphics.setFont(bigFont)

  -- load audio
  music = love.audio.newSource("sfx/bg.ogg", stream)
  music:setVolume(0.4)
  goodThing = love.audio.newSource("sfx/coin1.wav", static)
  badThing = love.audio.newSource("sfx/coin10.wav", static)
end

function game:keypressed(key, code)
    if key =='escape' then -- quit on escape
      love.event.quit()
    elseif key == 'space' then -- stop spinner on space
      spinner.speed = 0
      spinner.clicked = true
      goodThing:setPitch(love.math.random(5, 15) * 0.1)
      love.audio.play(goodThing)
    end
end

function game:addCurCandidate() -- if spinner landed on "hire" and the player hasn't already hired 2 candidates this turn
  if dailyHireCount < 2 then

    -- insert our new candidate into their new cubicle
    for i = 1, #employeeCubes do
      if employeeCubes[i].occupied == false then
        curCandidate.x, curCandidate.y = employeeCubes[i].x, employeeCubes[i].y
        employeeCubes[i].occupied = true
        curCandidate.cubeNum = i
        break
      end
    end

    table.insert(employees, curCandidate)
    table.insert(employeeNames, curCandidate.name)
    business.earnings = business.earnings + curCandidate.profit

    dailyHireCount = dailyHireCount + 1
  end

  -- reset spinner.clicked
  spinner.clicked = false

  -- if the player is still in the interview phase, reset the spinner
  if phase == "interview" then
    zone:deleteAll()
    local seg = love.math.random(2, 10)
    zone:generate(seg, {"Hire", "Reject"}, "random")
  end
end

function game:spin() -- handles our spinner movement
  spinner.x = circle.w/2 + math.cos(spinner.angle) * circle.r / 2
  spinner.y = circle.h/2 + math.sin(spinner.angle) * circle.r / 2

  spinner.angle = spinner.angle + spinner.speed

  zone:update(spinner)

  if spinner.angle >= 6.28 or spinner.angle <= -6.28 then spinner.angle = 0 end
end

function game:update(dt)
  if music:isPlaying() == false then
    love.audio.play(music)
  end

  -- START PHASE --
  if phase == "start" then -- display the menu title and "press space" text
    if checkTimer("title", timers) == false then
      zone:generate(1, {"Continue"})
      addTimer(dt, "title", timers)
    end

    if alphaDir == 0 then -- going down
      titleAlpha = titleAlpha - 200 * dt
    elseif alphaDir == 1 then -- going up
      titleAlpha = titleAlpha + 200 * dt
    end

    if titleAlpha >= 255 and alphaDir == 1 then
      alphaDir = 0
    elseif titleAlpha < 100 and alphaDir == 0 then
      alphaDir = 1
    end

    game:spin() -- the player won't see the spinner, but spin it anyway

    if spinner.speed == 0 and spinner.zone == "Continue" and updateTimer(dt, "title", timers) == true then
      fadeOut = true
      addTimer(2.0, "title fadeOut", timers)
    end

    if updateTimer(dt, "title fadeOut", timers) then
      phase = "first run"
      fadeOut = false
      fadeIn = true
      fade = 0
    end
  end

  -- FIRST TURN --
  if turnNum == 0 and phase~="start" then
    goal = 50000

    firstEmployee = candidate:new() -- each player starts with 1 random employee
    firstEmployee.x, firstEmployee.y = employeeCubes[#employees + 1].x, employeeCubes[#employees + 1].y
    employeeCubes[#employees + 1].occupied = true
    firstEmployee.cubeNum = 1

    table.insert(employees, firstEmployee)
    table.insert(employeeNames, firstEmployee.name)
    business.earnings = business.earnings + firstEmployee.profit

    turnNum = 1

    love.graphics.setFont(smallFont)
    zone:deleteAll()

    phase = "interview" -- start the interview phase
  end

  if checkTimer("start", timers) == false and phase == "interview" then
    spinner.clicked = false

    curCandidate = candidate:new()
    employeeAnim = love.math.random(1, 73)
    local seg = love.math.random(2, 10)

    local speed = love.math.random(1, 22) * 0.01
    spinner.speed = speed--love.math.random(0.15, 0.22)

    addTimer(0.0, "start", timers)
    zone:generate(seg, {"Hire", "Reject"}, "random")
  end

  -- INTERVIEW PHASE --
  if phase == "interview" then
    if #employees == 24 then
      phase = "event"
    end

    game:spin()

    if spinner.speed == 0 and spinner.zone == "Hire" and checkTimer("newCand", timers) == false then
      game:addCurCandidate()

      if dailyHireCount >= 2 then
        addTimer(0.0, "endInterview", timers)
      end

      addTimer(0.3, "newCand", timers)
    elseif spinner.speed == 0 and spinner.zone == "Reject" and checkTimer("newCand", timers) == false then
      dailyRejectCount = dailyRejectCount + 1

      zone:deleteAll()
      local seg = love.math.random(2, 10)
      zone:generate(seg, {"Hire", "Reject"}, "random")

      if dailyRejectCount >= 5 then
        addTimer(0.0, "endInterview", timers)
      end

      addTimer(0.3, "newCand", timers)
    end

    if updateTimer(dt, "endInterview", timers) then
      -- reset for next interview phase
      dailyHireCount = 0
      dailyRejectCount = 0

      -- move to event phase
      phase = "event"
      curEvent = eventNew()


      if curEvent.type == "good" then
        curEventCost = love.math.random(curEvent.min, curEvent.max)
        business.money = business.money + curEventCost
        table.insert(actionCards, "Promote")

        badThing:setPitch(1.5)
        love.audio.play(badThing)
      elseif curEvent.type == "bad" then
        curEventCost = love.math.random(curEvent.min, curEvent.max)
        business.money = business.money - curEventCost
        table.insert(actionCards, "Fire")

        badThing:setPitch(0.10)
        love.audio.play(badThing)
      else
        curEventCost = 0
        badThing:setPitch(1)
        love.audio.play(badThing)
      end

      deleteTimer("endInterview", timers)
    elseif updateTimer(dt, "newCand", timers) then
      curCandidate = candidate:new()
      employeeAnim = love.math.random(1, 73)
      local speed = love.math.random(1, 22) * 0.01
      spinner.speed = speed --0.2
      deleteTimer("newCand", timers)
    end

  -- EVENT PHASE --
  elseif phase == "event" then
    if checkTimer("newEvent", timers) == false then
      spinner.clicked = false
      local speed = love.math.random(10, 20) * 0.01
      spinner.speed = speed -- 0.1
      zone:deleteAll()
      zone:generate(1, {"Continue"})
      --curEvent = eventNew()
      addTimer(0.0, "newEvent", timers)
    end

    game:spin()

    if spinner.speed == 0 and spinner.zone == "Continue" and updateTimer(dt, "newEvent", timers) == true then
      if #actionCards > 1 then
        phase = "action"
      else
        phase = "report"
      end
    end

  -- ACTION PHASE --
  elseif phase == "action" then
    if checkTimer("newAction", timers) == false then
      spinner.clicked = false
      local speed = love.math.random(10, 20) * 0.01
      spinner.speed = speed --0.1
      zone:deleteAll()
      zone:generate(#actionCards, actionCards, "set")
      addTimer(0.0, "newAction", timers)
    end

    game:spin()

    if spinner.speed == 0 and spinner.zone == "Skip" and updateTimer(dt, "newAction", timers) == true then
      phase = "report"
    elseif spinner.speed == 0 and spinner.zone == "Promote" and updateTimer(dt, "newAction", timers) == true then
      phase = "promote"
      table.remove(actionCards, spinner.index)
    elseif spinner.speed == 0 and spinner.zone == "Fire" and updateTimer(dt, "newAction", timers) == true then
      phase = "fire"
      table.remove(actionCards, spinner.index)
    end

  -- PROMOTE PHASE --
  elseif phase == "promote" then
    if checkTimer("promote", timers) == false then
      spinner.clicked = false
      local speed = love.math.random(10, 20) * 0.01
      spinner.speed = speed --0.1
      zone:deleteAll()
      zone:generate(#employeeNames, employeeNames, "set")
      addTimer(0.0, "promote", timers)
    end

    game:spin()

    if spinner.speed == 0 and spinner.clicked == true and updateTimer(dt, "promote", timers) then
      local increaseInIncome = love.math.random(100, 700)

      employees[spinner.index].profit = employees[spinner.index].profit + increaseInIncome
      business.earnings = business.earnings + increaseInIncome
      phase = "report"
    end

  -- FIRE PHASE --
  elseif phase == "fire" then
    if checkTimer("fire", timers) == false then


      spinner.clicked = false
      local speed = love.math.random(10, 20) * 0.01
      spinner.speed = speed -- 0.1
      zone:deleteAll()
      zone:generate(#employeeNames, employeeNames, "set")
      addTimer(0.0, "fire", timers)
    end

    game:spin()

    if spinner.speed == 0 and spinner.clicked == true and updateTimer(dt, "fire", timers) then

      employeeCubes[employees[spinner.index].cubeNum].occupied = false
      table.remove(employees, spinner.index)
      table.remove(employeeNames, spinner.index)

      phase = "report"
    end

  -- WEEKLY REPORT PHASE --
  elseif phase == "report" then
    if checkTimer("report", timers) == false then
      spinner.clicked = false
      local speed = love.math.random(10, 20) * 0.01
      spinner.speed = speed --0.1
      zone:deleteAll()
      zone:generate(1, {"Continue"}, "set")
      addTimer(0.0, "report", timers)

      business.money = business.money + business.earnings
    end

    game:spin()

    if spinner.speed == 0 and spinner.zone == "Continue" and updateTimer(dt, "report", timers) == true then

      if turnNum < maxTurns then
        phase = "interview"
        timers = {}
        zone:deleteAll()

        turnNum = turnNum + 1
      else
        phase = "end"
      end
    end

  elseif phase == "end" then
    if checkTimer("end", timers) == false then
      spinner.clicked = false
      local speed = love.math.random(10, 20) * 0.01
      spinner.speed = speed

      zone:deleteAll()
      zone:generate(1, {"Continue"}, "set")
      addTimer(0.0, "end", timers)
    end

    game:spin()

    if spinner.speed == 0 and spinner.zone == "Continue" and updateTimer(dt, "report", timers) == true then
      love.event.quit()
    end
  end

  if fadeOut then
    fade = fade - 150 * dt
  elseif fadeIn then
    fade = fade + 150 * dt
  end

  for _, cand in ipairs(employees) do
    cand.update(dt, cand)
  end

end

function game:draw()
  love.graphics.draw(map, 0, 0)

  if phase == "start" then -- draws our title screen
    if fadeOut then
      love.graphics.setColor(255, 255, 255, fade)
    end

    love.graphics.draw(title, 80, 100)

    if fadeOut == false then
      love.graphics.setColor(255, 255, 255, titleAlpha)
    end

    love.graphics.printf("--- Press Space ---", 210, 400, 1000)
    love.graphics.setColor(255, 255, 255, 255)

  else
    love.graphics.setColor(255, 255, 255, fade)

    love.graphics.draw(window1, 0, 0)
    love.graphics.draw(window2, 0, 0)
    love.graphics.draw(window3, 0, 0)
    love.graphics.draw(window4, 0, 0)

    zone:draw() -- draw our zones

    for _, cand in ipairs(employees) do -- draw employees
      cand.draw(cand)
    end

    -- basic spinner
    love.graphics.circle("fill", spinner.x, spinner.y, 4)
    love.graphics.line(spinner.x, spinner.y, 625, 300)

    if phase == "interview" then -- draws interview text and windows
      love.graphics.setColor(0, 0, 0, fade)
      love.graphics.rectangle("fill", 80, 100, 300, 375)

      love.graphics.setColor(242, 186, 186, fade)
      love.graphics.rectangle("line", 85, 105, 290, 365)

      love.graphics.setFont(medFont)
      love.graphics.printf("Interview", 165, 110, 280)
      love.graphics.setFont(smallFont)

      love.graphics.printf("Positions to Fill: " .. maxCubes - #employees, 90, 140, 280)
      love.graphics.printf(curCandidate.name, 90, 180, 280, "center")

      love.graphics.printf(curCandidate.question, 90, 350, 280, "center")
      love.graphics.printf(curCandidate.answer, 90, 420, 280, "center")

      love.graphics.rectangle("fill", 105, 200, 250, 150)

      love.graphics.setColor(0, 0, 0, fade)
      love.graphics.rectangle("line", 110, 205, 240, 140)

      love.graphics.setColor(255, 255, 255, fade)
      employeeAnims[employeeAnim]:draw(employeeSprite, 180, 205, 0, 1, 1, 0, 0)

      love.graphics.printf("Potential Revenue: $ " .. curCandidate.profit, 90, 450, 280)


      love.graphics.setColor(255, 255, 255, fade)

    elseif phase == "event" then -- draws event and event windows
      love.graphics.setColor(0, 0, 0, fade)
      love.graphics.rectangle("fill", 80, 100, 300, 375)

      love.graphics.setColor(242, 186, 186, fade)
      love.graphics.rectangle("line", 85, 105, 290, 365)

      love.graphics.setFont(medFont)

      if curEvent.type == "bad" then
        love.graphics.printf("- $ " .. curEventCost, 90, 420, 280, "center")
        love.graphics.draw(sad, 170, 280)
      elseif curEvent.type == "good" then
        love.graphics.printf("+ $ " .. curEventCost, 90, 420, 280, "center")
        love.graphics.draw(happy, 170, 280)
      else
        love.graphics.draw(neutral, 170, 280)
        love.graphics.printf("+ $ " .. curEventCost, 90, 420, 280, "center")
      end

      love.graphics.printf(curEvent.name, 90, 110, 280, "center")

      love.graphics.setFont(smallFont)
      love.graphics.printf(curEvent.desc, 90, 140, 280, "center")

      if curEvent.type == "bad" then
        love.graphics.printf("1 Fire card added!", 90, 450, 280, "center")
      elseif curEvent.type == "good" then
        love.graphics.printf("1 Promotion card added!", 90, 450, 280, "center")
      end


      love.graphics.setColor(255, 255, 255, fade)
    elseif phase == "report" then
      love.graphics.setColor(0, 0, 0, fade)
      love.graphics.rectangle("fill", 80, 100, 300, 375)

      love.graphics.setColor(242, 186, 186, fade)
      love.graphics.rectangle("line", 85, 105, 290, 365)

      love.graphics.setFont(medFont)
      love.graphics.printf("Employee's" .. " ( " .. #employees .. " )", 90, 237, 280, "left")
      love.graphics.printf("Weekly Progress Report", 90, 110, 280, "center")
      love.graphics.printf("----------------------", 90, 160, 280, "center")
      love.graphics.setFont(smallFont)
      love.graphics.printf("Week: " .. turnNum, 90, 180, 280, "left")
      love.graphics.printf("Weeks Remaining: " .. maxTurns - turnNum, 90, 195, 280, "left")
      love.graphics.printf("Current Revenue: $ " .. business.money .. " / 50000", 90, 210, 280, "left")
      love.graphics.printf("Current Weekly Earnings: $ " .. business.earnings, 90, 225, 280, "left")

      for i, cand in ipairs(employees) do -- draws a list of our employee's names
        local j = i - 13

        if i <= 13 then
          love.graphics.printf(cand.name, 90, i * 15 + 250, 140, "left")
          love.graphics.printf(cand.profit, 90, i * 15 + 250, 135, "right")
        else
          love.graphics.printf(cand.name, 230, j * 15 + 250, 140, "left")
          love.graphics.printf(cand.profit, 230, j * 15 + 250, 135, "right")
        end
      end

    elseif phase == "end" then -- if the game is over draw results
      love.graphics.setColor(0, 0, 0, fade)
      love.graphics.rectangle("fill", 80, 100, 300, 375)

      love.graphics.setColor(242, 186, 186, fade)
      love.graphics.rectangle("line", 85, 105, 290, 365)

      if business.money > goal then
        love.graphics.setFont(medFont)
        love.graphics.printf("Congratulations", 90, 110, 280, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("You somehow managed to raise $50,000 in 14 weeks! The company is saved thanks to you! ", 90, 140, 280, "center")
        love.graphics.printf("-- Press Escape to Exit -- ", 90, 420, 280, "center")
      else
        love.graphics.setFont(medFont)
        love.graphics.printf("Gameover", 90, 110, 280, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Unfortunately you were unable to reach your goal of $50,000 and went bankrupt. Not only did you let yourself down, but also all of your employees which by the way are now unemployed. Good luck breaking the news!", 90, 140, 280, "center")
        love.graphics.printf("-- Press Escape to Exit -- ", 90, 420, 280, "center")
      end
    end

    love.graphics.setColor(255, 255, 255, 255)
  end
end
