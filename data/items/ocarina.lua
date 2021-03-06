local item = ...
local game = item:get_game()

local item_name = "ocarina"
local sound_played_on_brandish = "/common/big_item"
local sound_played_when_picked = nil
local is_assignable = true
local sound_dir = "/items/"..item_name.."/"
local volume_bgm = game:get_value("old_volume")

sol.main.load_file("scripts/gameplay/hero/ocarina_controller")(game)

function item:on_created()
  self:set_savegame_variable("item_"..item_name.."_possession")
  self:set_assignable(is_assignable)
  self:set_sound_when_picked(sound_played_when_picked)
  self:set_sound_when_brandished(sound_played_on_brandish)
end

function item:on_obtained()
  sol.audio.set_music_volume(volume_bgm)
end

function item:transit_to_finish()
  if game:is_cutscene_bars_enabled() and not game:is_current_scene_cutscene() then game:show_cutscene_bars(false) end
  game:set_hud_enabled(true)
  self:set_finished()
  game:get_hero():freeze()
  sol.audio.set_music_volume(volume_bgm)
  game:get_hero():set_shield_sprite_id("hero/shield"..game:get_value("item_saved_shield"))
  game:set_ability("shield", game:get_value("item_saved_shield"))
  game:set_ability("sword", game:get_value("item_saved_sword"))
  game:set_command_keyboard_binding("action", game:get_value("item_saved_kb_action"))
  game:set_command_keyboard_binding("item_1", game:get_value("item_1_kb_slot"))
  game:set_command_keyboard_binding("item_2", game:get_value("item_2_kb_slot"))
  game:set_command_joypad_binding("action", game:get_value("item_saved_jp_action"))
  game:set_command_joypad_binding("item_1", game:get_value("item_1_jp_slot"))
  game:set_command_joypad_binding("item_2", game:get_value("item_2_jp_slot"))
  sol.timer.start(100, function()
    game:get_hero():unfreeze()
  end)
  game:set_pause_allowed(true)
end

function item:store_equipment()
    local kb_action_key = game:get_command_keyboard_binding("action")
	local kb_item_1_key = game:get_command_keyboard_binding("item_1")
	local kb_item_2_key = game:get_command_keyboard_binding("item_2")
	local jp_action_key = game:get_command_joypad_binding("action")
	local jp_item_1_key = game:get_command_joypad_binding("item_1")
	local jp_item_2_key = game:get_command_joypad_binding("item_2")
	
    game:set_ability("sword", 0)
    game:set_ability("shield", 0)
	
	if game:get_value("_item_slot_1") ~= item_name then game:set_command_keyboard_binding("item_1", nil); game:set_command_joypad_binding("item_1", nil) end
	if game:get_value("_item_slot_2") ~= item_name then game:set_command_keyboard_binding("item_2", nil); game:set_command_joypad_binding("item_2", nil) end

    game:set_value("item_saved_kb_action", kb_action_key)
	game:set_value("item_1_kb_slot", kb_item_1_key)
	game:set_value("item_2_kb_slot", kb_item_2_key)
	game:set_value("item_saved_jp_action", jp_action_key)
	game:set_value("item_1_jp_slot", jp_item_1_key)
	game:set_value("item_2_jp_slot", jp_item_2_key)
	
    game:set_pause_allowed(false)
end

function item:on_using()
  self:store_equipment()  
  game:set_item_on_use(true)
  game:show_cutscene_bars(true)
  game:set_value("using_ocarina", true)
  game:set_hud_enabled(false)
  sol.audio.set_music_volume((sol.audio.get_music_volume() / 3))
  game:get_hero():set_animation("playing", function()
	game:get_hero():start_ocarina()
  end)
end