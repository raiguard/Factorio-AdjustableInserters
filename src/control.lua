local area = require("__flib__.area")
local event = require("__flib__.event")
local math = require("__flib__.math")

--- Snap the position to the nearest third-tile
--- @param pos MapPosition
local function snap_position(pos)
  return {
    x = math.floor(pos.x * 3) / 3 + (1 / 6),
    y = math.floor(pos.y * 3) / 3 + (1 / 6),
  }
end

--- @param player_index number
--- @param text LocalisedString
local function error_text(player_index, text)
  local player = game.get_player(player_index)
  player.create_local_flying_text({
    text = text,
    create_at_cursor = true,
  })
  player.play_sound({ path = "utility/cannot_build" })
end

--- @param player_index number
local function end_session(player_index)
  local session = global.sessions[player_index]
  if session then
    rendering.destroy(session.area_obj)
    rendering.destroy(session.drop_obj)
    rendering.destroy(session.pickup_obj)
    global.sessions[player_index] = nil
  end
end

event.on_init(function()
  --- @type table<number, Session>
  global.sessions = {}
end)

event.on_player_rotated_entity(function(e)
  local entity = e.entity
  for _, session in pairs(global.sessions) do
    if session.entity == entity then
      rendering.set_target(session.drop_obj, entity.drop_position)
      rendering.set_target(session.pickup_obj, entity.pickup_position)
    end
  end
end)

event.register({
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
  defines.events.on_entity_died,
  defines.events.script_raised_destroy,
}, function(e)
  local entity = e.entity
  for player_index, session in pairs(global.sessions) do
    if session.entity == entity then
      end_session(player_index)
    end
  end
end)

event.register("ains-adjust", function(e)
  local player = game.get_player(e.player_index)
  local selected = player.selected
  if selected and selected.valid then
    local session = global.sessions[e.player_index]
    if not session then
      --- @type BoundingBox
      local Area = area.from_dimensions({ height = 7, width = 7 }, selected.position):ceil()
      --- @class Session
      global.sessions[e.player_index] = {
        area = Area,
        area_obj = rendering.draw_rectangle({
          color = { g = 0.3, b = 0.3, a = 0.3 },
          filled = true,
          left_top = Area.left_top,
          right_bottom = Area.right_bottom,
          surface = selected.surface,
          players = { e.player_index },
          draw_on_ground = true,
        }),
        entity = selected,
        drop_obj = rendering.draw_circle({
          color = { r = 1 },
          radius = 0.15,
          filled = true,
          target = selected.drop_position,
          surface = selected.surface,
          players = { e.player_index },
        }),
        pickup_obj = rendering.draw_circle({
          color = { g = 1 },
          radius = 0.15,
          filled = true,
          target = selected.pickup_position,
          surface = selected.surface,
          players = { e.player_index },
        }),
      }
    end
  end
end)

event.register({ "ains-linked-build", "ains-linked-mine" }, function(e)
  local session = global.sessions[e.player_index]
  if session then
    if session.area:contains_position(e.cursor_position) then
      local pos = snap_position(e.cursor_position)
      local key = string.find(e.input_name, "build") and "drop" or "pickup"
      session.entity[key .. "_position"] = pos
      rendering.set_target(session[key .. "_obj"], pos)
    else
      error_text(e.player_index, { "message.ains-out-of-range" })
    end
  end
end)

event.register("ains-linked-smart-pipette", function(e)
  end_session(e.player_index)
end)

event.on_permission_group_added(function(e)
  log(e.group.name)
end)

-- TODO: Handle inserter teleportation while editing (there is no event)

-- PERMISSIONS:
-- Build
-- Open GUI
-- Begin mining
