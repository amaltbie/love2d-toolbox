---
-- @module toolbox.world


-- local Concord = require 'concord'

local Concord = require 'concord'


-- Initialize world object
local world = Concord.world()


-- Component for an initialization function
Concord.component("init", function(c, _run)
  c.run = _run
end)

-- If entity has the init component then run its init function
function world:onEntityAdded(e)
  if e:has("init") then
    e.init.run(e)
  end
end

-- Position in world
Concord.component("position", function(c, x, y, z)
  c.x = x or 0
  c.y = y or 0
  c.z = z or 0
end)

function z_compare(e1, e2)
  return e1.position.z < e2.position.z
end

Concord.component("effect", function(c, shader_code, data)
  c.shader = love.graphics.newShader(shader_code)
  c.data = {}
  function c:setData(key, value)
    self.data[key] = value
    self.shader:send(key, value)
  end
  for k,v in pairs(data or {}) do
    c:setData(k, v)
  end
end)

-- Generic graphics component for custome draw callback
Concord.component("graphics", function(c, _render)
  c.render = _render
  c.visible = true
end)

local DrawSystem = Concord.system({
  pool = {"graphics","position"}
})

function DrawSystem:draw()
  local sorted_pool = {}
  for i,e in ipairs(self.pool) do sorted_pool[i] = e end
  table.sort(sorted_pool, function(e1,e2)
    return e1.position.z < e2.position.z
  end)
  for _, e in ipairs(sorted_pool) do
    if e.graphics.visible then
      if e:has("effect") then
        love.graphics.setShader(e.effect.shader) 
      end
      e.graphics.render(e)
      love.graphics.reset()
    end
  end
end

world:addSystems(DrawSystem)

-- callback for mousepressed event
for _, mouse_event_type in ipairs({"mousepressed","mousereleased","mouseclicked"}) do
  Concord.component(mouse_event_type, function(c, callback)
    c.callback = callback
  end)

  local mouse_event_system = Concord.system({
    pool = {mouse_event_type}
  })

  mouse_event_system[mouse_event_type] = function (self,x,y,button,istouch,presses)
    for _, e in ipairs(self.pool) do
      e[mouse_event_type].callback(e,x,y,button,istouch,presses)
    end
  end

  love[mouse_event_type] = function(x,y,button,istouch,presses)
    world:emit(mouse_event_type,x,y,button,istouch,presses)
  end

  world:addSystems(mouse_event_system)
end

Concord.component("mouseover",function(c,_callback)
  c.callback = _callback
end)

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
    if entity_a == world.mouse or entity_b == world.mouse then
      local other = entity_a == world.mouse and entity_b or entity_a
      if other:has("mouseover") then
        other.mouseover.callback(other)
      end
    end
  end
end

physics_world:setCallbacks(
  genericPhysicsCallback("beginContactCallback"),
  genericPhysicsCallback("endContactCallback"),
  genericPhysicsCallback("preSolveCallback"),
  genericPhysicsCallback("postSolveCallback")
)

world:addSystems(PhysicsSystem)

world.mouse = Concord.entity()
world.mouse.width = .5
world.mouse.height = .5
world.mouse.isDownImage = nil
world.mouse.isUpImage = nil

function world.mouse.setIsDownImage(image_filepath)
  world.mouse.isDownImage = love.mouse.newCursor(image_filepath)
end

function world.mouse.setIsUpImage(image_filepath)
  world.mouse.isUpImage = love.mouse.newCursor(image_filepath)
end

world.mouse:give("physics",
  world.mouse,
  love.mouse.getX(),
  love.mouse.getY(),
  love.physics.newRectangleShape(world.mouse.width, world.mouse.height),
  "dynamic",
  true)
world.mouse:give("update", function(this, dt)
  if love.mouse.isDown(1) then
    if world.mouse.isDownImage then
      love.mouse.setCursor(world.mouse.isDownImage)
    end
  else
    if world.mouse.isUpImage then
      love.mouse.setCursor(world.mouse.isUpImage)
    end
  end
  this.physics.body:setPosition(love.mouse.getX(),love.mouse.getY())
end)
world.mouse:give("position", love.mouse.getX(),love.mouse.getY(), 100)
-- world.mouse:give("graphics", function(this)
--   love.graphics.setColor(1,1,1,1)
--   love.graphics.rectangle("fill",this.physics.body:getX()-this.width/2,this.physics.body:getY()-this.height/2,this.width,this.height)
-- end)
world.mouse.id = "mouse"
world.mouse.physics.fixture:setSensor(true)
world.mouse.holding = false
world:addEntity(world.mouse)

return world
