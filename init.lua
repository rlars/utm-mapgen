
utm_mapgen_path = minetest.get_modpath("utm_mapgen")

dofile(xyzreader_path .. "/registered_nodes.lua")


local c_air = minetest.get_content_id("air")
local c_grass = minetest.get_content_id("default:dirt_with_grass")
local c_stone = minetest.get_content_id("default:stone")
local c_leaves = minetest.get_content_id("default:leaves")
local c_roof = minetest.get_content_id("default:wood")
local c_street = minetest.get_content_id("default:dirt")

if core.settings:get("utm_mapgen_offset_east") == nil or core.settings:get("utm_mapgen_offset_north") == nil then
	core.log("warning", "Grid offsets in the game settings are not set.")
	core.debug("Please set the grid offsets in the mod´s game settings!")
end

core.register_mapgen_script(minetest.get_modpath("utm_mapgen").."/mapgen.lua")
