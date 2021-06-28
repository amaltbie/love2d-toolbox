---
-- @module toolbox.world


-- local Concord = require 'concord'

local Concord = require 'concord'


-- Initialize world object
local world = Concord.world()

-- Position in world
Concord.component("position", function(c, x, y, z)
  c.x = x or 0
  c.y = y or 0
  c.z = z or 0
end)

function z_compare(e1, e2)
  return e1.position.z < e2.position.z
end

-- Generic graphics component for custome draw callback
Concord.component("graphics", function(c, _render)
  c.render = _render
end)

local DrawSystem = Concord.system({
  pool = {"graphics","position"}
})

function DrawSystem:draw()
  local sorted_pool = {unpack(self.pool)}
  table.sort(sorted_pool, function(e1,e2)
    return e1.position.z < e2.position.z
  end)
  for _, e in ipairs(sorted_pool) do
    e.graphics.render(e)
    love.graphics.reset()
  end
end

world:addSystems(DrawSystem)

local cleanUpSystem = Concord.system({
  pool = {"position"}
})

function cleanUpSystem:clean()
  for _, e in ipairs(self.pool) do
    if e.physics.body:getX() < 0 or
        e.physics.body:getY() < 0 or
        e.physics.body:getX() > love.graphics.getWidth() or
        e.physics.body:getY() > love.graphics.getY() then
          print("clean")
          world:removeEntity(e)
    end
  end
end


-- Update system to be tied into love.update
Concord.component("update", function(c, _run)
  c.run = _run
end)

world.UpdateSystem = Concord.system({
  pool = {"update"}
})

world.game_over = false

function world.UpdateSystem:update(dt)
    for _, e in ipairs(self.pool) do
      e.update.run(e, dt)
    end
end

world:addSystems(world.UpdateSystem)


-- Physics component
local physics_scale = 64
local world_gravity = 627.84 -- 9.81 * 64
love.physics.setMeter(physics_scale)
local physics_world = love.physics.newWorld(0, world_gravity, false)

Concord.component("physics", function(c, e, x, y, shape, body_type, sensor)
  body_type = body_type or "static"
  c.shape = shape
  c.body = love.physics.newBody(physics_world, x, y, body_type)
  c.body:setSleepingAllowed(false)
  c.fixture = love.physics.newFixture(c.body, c.shape, 1)
  c.fixture:setUserData(e)
  c.fixture:setSensor(false)
  if sensor then
    c.fixture:setSensor(true)
  end
end)

local PhysicsSystem = Concord.system({
  pool = {"physics"}
})

function PhysicsSystem:physics_update(dt)
  physics_world:update(dt)
end

physCallbackInit = function(c, _callback)
  c.callback = _callback
end

Concord.component("beginContactCallback", physCallbackInit)
Concord.component("endContactCallback", physCallbackInit)
Concord.component("preSolveCallback", physCallbackInit)
Concord.component("postSolveCallback", physCallbackInit)

function entityCallback(e, o, coll, cb_comp_class)
  if e and e:has(cb_comp_class) then
    return e:get(cb_comp_class).callback(e, o, coll)
  end
  return nil
end

function genericPhysicsCallback(cb_comp_class)
  return function(a, b, coll, normalimpulse, tangentimpulse)
    local entity_a,entity_b = a:getUserData(), b:getUserData()
    entityCallback(entity_a, entity_b, coll, cb_comp_class)
    entityCallback(entity_b, entity_a, coll, cb_comp_class)
  end
end

physics_world:setCallbacks(
  genericPhysicsCallback("beginContactCallback"),
  genericPhysicsCallback("endContactCallback"),
  genericPhysicsCallback("preSolveCallback"),
  genericPhysicsCallback("postSolveCallback")
)

world:addSystems(PhysicsSystem)

return world
