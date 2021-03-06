local game = ...

local map_name_builder = require("scripts/hud/map_name")
-- local current_arrow_builder = require("scripts/hud/bow_arrow_type")
local minimap_dungeon_builder = require("scripts/hud/minimap")
local plunging_bar_builder = require("scripts/hud/plunging_bar")
local hints_builder = require("scripts/hud/hints")


function game:initialize_hud()

  -- Set up the HUD.
  local bars_builder = require("scripts/hud/cutscene_bars")
  local clock_builder = require("scripts/hud/clock")
  local floor_builder = require("scripts/hud/floor")
  local rupees_builder = require("scripts/hud/rupees")
  local hearts_builder = require("scripts/hud/hearts")
  local item_icon_builder = require("scripts/hud/item_icon")
  local magic_bar_builder = require("scripts/hud/magic_bar")
  local small_keys_builder = require("scripts/hud/small_keys")
  local attack_icon_builder = require("scripts/hud/attack_icon")
  local action_icon_builder = require("scripts/hud/action_icon")
  local boss_life_builder = require("scripts/hud/boss_life")
  local horse_stamina = require("scripts/hud/horse_stamina")
  
  self.bars = {}
  self.clock = {}
  
  self.hud = {  -- Array for the hud elements, table for other hud info.
    showing_dialog = false,
    top_left_opacity = 255,
    custom_command_effects = {},
  }
  
  local clock_day_night = clock_builder:new(self)
  self.clock[#self.clock + 1] = clock_day_night
  
  local map_name = map_name_builder:new(self)
  map_name:set_dst_position(0,0)
  self.clock[#self.clock + 1] = map_name

  local bars = bars_builder:new(self)
  self.bars[#self.bars + 1] = bars
  
  local hints = hints_builder:new(self)
  self.bars[#self.bars + 1] = hints
  
  local menu = hearts_builder:new(self)
  menu:set_dst_position(15,12)
  self.hud[#self.hud + 1] = menu
  
  local menu = minimap_dungeon_builder:new(self)
  self.hud[#self.hud + 1] = menu

  local menu = magic_bar_builder:new(self)
  menu:set_dst_position(15,31)
  self.hud[#self.hud + 1] = menu
  
  local menu = plunging_bar_builder:new(self)
  menu:set_dst_position(15,38)
  self.hud[#self.hud + 1] = menu


  local menu = rupees_builder:new(self)
  menu:set_dst_position(15, -20)
  self.hud[#self.hud + 1] = menu
  
  -- local menu = horse_stamina:new(self)
  -- menu:set_dst_position(15, -20)
  -- self.hud[#self.hud + 1] = menu

  local menu = small_keys_builder:new(self)
  menu:set_dst_position(15, -33)
  self.hud[#self.hud + 1] = menu

  local menu = floor_builder:new(self)
  menu:set_dst_position(5, 70)
  self.hud[#self.hud + 1] = menu

  local menu = item_icon_builder:new(self, 1)
  menu:set_dst_position(232, 12)
  self.hud[#self.hud + 1] = menu
  self.hud.item_icon_1 = menu

  local menu = item_icon_builder:new(self, 2)
  menu:set_dst_position(276,12)
  self.hud[#self.hud + 1] = menu
  self.hud.item_icon_2 = menu

  local menu = attack_icon_builder:new(self)
  menu:set_dst_position(230,30)
  self.hud[#self.hud + 1] = menu
  self.hud.attack_icon = menu

  local menu = action_icon_builder:new(self)
  menu:set_dst_position(186,30)
  self.hud[#self.hud + 1] = menu
  self.hud.action_icon = menu
  
  local menu = boss_life_builder:new(self)
  menu:set_dst_position(110, 220)
  self.hud[#self.hud + 1] = menu
  self.hud.boss_life = menu  
  
  -- local menu = current_arrow_builder:new(self)
  -- menu:set_dst_position(164, 11)
  -- self.hud[#self.hud + 1] = menu
  -- self.hud.current_arrow_builder = menu  
  
  for _, bars in ipairs(self.bars) do
    sol.menu.start(self, bars, false)
  end

  self:set_hud_enabled(true)
  self:set_clock_enabled(true)
  self:check_hud()
end

function game:quit_hud()
  if self:is_hud_enabled() then
    -- Stop all HUD menus.
    self:set_hud_enabled(false)
  end
  self.hud = nil
  self.bars = nil
  self.clock = nil
end

function game:check_hud()
  local map = self:get_map()
  if map ~= nil then
    -- If the hero is below the top-left icons, make them semi-transparent.
    local hero = self:get_hero()
    local hero_x, hero_y = hero:get_position()
    local camera_x, camera_y = map:get_camera_position()
    local x = hero_x - camera_x
    local y = hero_y - camera_y
    local opacity = nil

    if self.hud.top_left_opacity == 255
        and not self:is_suspended()
        and x > 225
        and y < 70 then
      opacity = 96
    elseif self.hud.top_left_opacity == 96
        and (self:is_suspended()
        or x <= 225
        or y >= 70) then
      opacity = 255
    end

    if opacity ~= nil then
      self.hud.top_left_opacity = opacity
      self.hud.item_icon_1.surface:set_opacity(opacity)
      self.hud.item_icon_2.surface:set_opacity(opacity)
      self.hud.attack_icon.surface:set_opacity(opacity)
      self.hud.action_icon.surface:set_opacity(opacity)
    end
  end

  sol.timer.start(self, 50, function()
    self:check_hud()
  end)
end

function game:show_hint(key, seconds)
  hints_builder:display_hint(key, seconds)
end

function game:set_dungeon_minimap_index(index)
  minimap_dungeon_builder:set_dungeon_map(index)
end

function game:hud_on_map_changed(map)  
  if self:is_hud_enabled() then
    for _, menu in ipairs(self.hud) do
      if menu.on_map_changed ~= nil then
        menu:on_map_changed(map)
      end
    end
  end
end

-- Display Cutscene Bars
function game:show_cutscene_bars(boolean)
  local script = self.bars[1]
  local active = script:is_active()

  if boolean then
    if not active then
      script:show_bars()
	end
  else
    if active then
	  script:hide_bars()
	end
  end
end

function game:is_cutscene_bars_enabled()
  local active = self.bars[1]:is_active()
  return active
end

function game:hud_on_paused()
  if self:is_hud_enabled() then
    for _, menu in ipairs(self.hud) do
      if menu.on_paused ~= nil then
        menu:on_paused()
      end
    end
	
	for _, menu in ipairs(self.bars) do
      if menu.on_paused ~= nil then
        menu:on_paused()
      end
    end
	
	for _, menu in ipairs(self.clock) do
      if menu.on_paused ~= nil then
        menu:on_paused()
      end
    end
  end
end

function game:hud_on_unpaused()
  if self:is_hud_enabled() then
    for _, menu in ipairs(self.hud) do
      if menu.on_unpaused ~= nil then
        menu:on_unpaused()
      end
    end
	for _, menu in ipairs(self.clock) do
      if menu.on_unpaused ~= nil then
        menu:on_unpaused()
      end
    end
	for _, menu in ipairs(self.bars) do
      if menu.on_unpaused ~= nil then
        menu:on_unpaused()
      end
    end
  end
end

function game:is_hud_enabled()
  return self.hud_enabled
end

function game:set_clock_enabled(enabled)
  if enabled then
    for _, clocks in ipairs(self.clock) do
         sol.menu.start(self, clocks, true)
    end
	self.clock_was_enabled = true
  else
    for _, clocks in ipairs(self.clock) do
         sol.menu.stop(clocks)
    end
	self.clock_was_enabled = false
  end
end

function game:was_clock_enabled()
  return self.clock_was_enabled
end

function game:set_hud_enabled(hud_enabled)
  if hud_enabled ~= self.hud_enabled then
    game.hud_enabled = hud_enabled
    for _, menu in ipairs(self.hud) do
      if hud_enabled then
        sol.menu.start(self, menu)
      else
        sol.menu.stop(menu)
      end
    end
  end
end

function game:show_map_name(map_name, display_extra)
  map_name_builder:show_name(map_name, display_extra or nil)
end

function game:clear_map_name()
  map_name_builder:clear()
end

-- function game:change_arrow_type()
  -- current_arrow_builder:select_next_arrow()
-- end

function game:get_custom_command_effect(command)
  return self.hud.custom_command_effects[command]
end

-- Make the action (or attack) icon of the HUD show something else than the
-- built-in effect or the action (or attack) command.
-- You are responsible to override the command if you don't want the built-in
-- effect to be performed.
-- Set the effect to nil to show the built-in effect again.
function game:set_custom_command_effect(command, effect)
  if self.hud ~= nil then
    self.hud.custom_command_effects[command] = effect
  end
end