
-- include libraries
Gamestate = require 'lib/gamestate'
anim8 = require 'lib/anim8'
require 'lib/timer'

require 'game'
require 'candidates/candidate'
require 'events/events'
require 'zones'

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function love.load(arg)
  math.randomseed(os.time()) -- seed love.math.rand() using os time
  love.graphics.setDefaultFilter("nearest", "nearest") -- set nearest pixel distance

  candidate:load() -- load candidate
  event:load() -- and events

  Gamestate.registerEvents()
  Gamestate.switch(game) -- swtich to game screen
end
