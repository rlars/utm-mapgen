
local c_air = minetest.get_content_id("air")
local c_grass = minetest.get_content_id("default:dirt_with_grass")
local c_stone = minetest.get_content_id("default:stone")
local c_wall = minetest.get_content_id("default:aspen_wood")
local c_leaves = minetest.get_content_id("default:leaves")
local c_roof = minetest.get_content_id("default:desert_stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_full_house_full_height = minetest.get_content_id("xyzreader:full_house_full_height")
local c_small_house = minetest.get_content_id("xyzreader:quarter_house")
local c_small_house_full_height = minetest.get_content_id("xyzreader:quarter_house_full_height")
local c_small_house_and_grass = minetest.get_content_id("stairs:stair_outer_house_on_grass")
local c_small_house_and_stone = minetest.get_content_id("stairs:stair_outer_house_on_stone")
local c_half_house_and_grass = minetest.get_content_id("stairs:stair_house_on_grass")
local c_half_house_and_stone = minetest.get_content_id("stairs:stair_house_on_stone")
local c_half_house = minetest.get_content_id("xyzreader:half_house")
local c_half_house_full_height = minetest.get_content_id("xyzreader:half_house_full_height")
local c_split_house = minetest.get_content_id("xyzreader:split_house")
local c_split_house_full_height = minetest.get_content_id("xyzreader:split_house_full_height")
local c_split_house_and_grass = minetest.get_content_id("xyzreader:split_house_on_grass")
local c_split_house_and_stone = minetest.get_content_id("xyzreader:split_house_on_stone")
local c_three_quarter_house_and_grass = minetest.get_content_id("stairs:stair_inner_house_on_grass")
local c_three_quarter_house_and_stone = minetest.get_content_id("stairs:stair_inner_house_on_stone")
local c_three_quarter_house = minetest.get_content_id("xyzreader:three_quarter_house")
local c_three_quarter_house_full_height = minetest.get_content_id("xyzreader:three_quarter_house_full_height")
local c_full_house_and_grass = minetest.get_content_id("xyzreader:house_on_grass")
local c_full_house = minetest.get_content_id("stairs:slab_house")
local c_half_grass = minetest.get_content_id("stairs:slab_dirt_with_grass")
local c_half_tree_top = minetest.get_content_id("xyzreader:slab_leaves")
local c_house = minetest.get_content_id("stairs:slab_steelblock")
local c_tree_and_grass = minetest.get_content_id("xyzreader:leaves_on_grass")
local c_half_stone = minetest.get_content_id("stairs:slab_stone")
local c_water = minetest.get_content_id("xyzreader:water_block")
local c_half_water = minetest.get_content_id("stairs:slab_water")
local c_half_road = minetest.get_content_id("stairs:slab_half_road")
local c_half_road_and_grass = minetest.get_content_id("xyzreader:half_road")
local c_quarter_road = minetest.get_content_id("stairs:slab_quarter_road")
local c_quarter_road_and_grass = minetest.get_content_id("xyzreader:quarter_road")
local c_three_quarter_road = minetest.get_content_id("stairs:slab_three_quarter_road")
local c_three_quarter_road_and_grass = minetest.get_content_id("xyzreader:three_quarter_road")
local c_split_road = minetest.get_content_id("stairs:slab_split_road")
local c_split_road_and_grass = minetest.get_content_id("xyzreader:split_road")

local gridX_offset = core.settings:get("utm_mapgen_offset_east") or 0
local gridY_offset = core.settings:get("utm_mapgen_offset_north") or 0


-- parse a file containing binary uint8s
local function parseBinaryFile(filename)
    local file = io.open(filename, "rb")
    if not file then
        core.log("verbose", "Could not open file: " .. filename)
        return nil
    end

    local values = {}
    while true do
        local data = file:read(1)
        if not data then break end
        table.insert(values, data:byte(1))
    end

    file:close()
    return values
end

local function parseUInt16File(filename)
    local file = io.open(filename, "rb")
    if not file then
        core.log("verbose", "Could not open file: " .. filename)
        return nil
    end

    local values = {}
    local values2 = {}
    while true do
        local datalow = file:read(1)
        if not datalow then break end
        local datahigh = file:read(1)
        table.insert(values, datalow:byte(1))
        table.insert(values2, datahigh:byte(1))
    end

    file:close()
    return values, values2
end

local cached_chunks = {}

local function get_or_load_chunk(x, y)
	for i, chunk in ipairs(cached_chunks) do
		if chunk.x == x and chunk.y == y then
			if i ~= 0 then
				-- put to first place in cache
				table.remove(cached_chunks, i)
				table.insert(cached_chunks, 0, chunk)
			end
			return chunk.data
		end
	end
	
	local usage_data, road_data = parseUInt16File(core.get_modpath("xyzreader") .. "/geodata/usage_32_" .. x .. "_" .. y .. ".bin")
	
	if usage_data == nil then
		return nil
	end
	
	local chunk = {
		ground_height = parseBinaryFile(core.get_modpath("xyzreader") .. "/geodata/height_dgm_32_" .. x .. "_" .. y .. ".bin"),
		object_height = parseBinaryFile(core.get_modpath("xyzreader") .. "/geodata/height_dom_32_" .. x .. "_" .. y .. ".bin"),
		usage_data = usage_data,
		road_data = road_data
	}
	table.insert(cached_chunks, 0, chunk)
	while #cached_chunks > 4 do
		table.remove(cached_chunks, 4)
	end
	
	return chunk
end

local function get_chunk_grid(x, z)
	return math.floor(1/500 * x) * 10, math.floor(1/500 * z) * 10
end


local function quarter_u_to_rot(u)
	if u == 1 then
		return 0
	elseif u == 2 then
		return 1
	elseif u == 8 then
		return 2
	elseif u == 4 then
		return 3
	end
	return 0
end

local function half_u_to_rot(u)
	if u == 1+2 then
		return 0
	elseif u == 2+8 then
		return 1
	elseif u == 4+8 then
		return 2
	elseif u == 4+1 then
		return 3
	end
	return 0
end

local function three_quarter_u_to_rot(u)
	if u == 1+2+4 then
		return 0
	elseif u == 1+2+8 then
		return 1
	elseif u == 4+8+2 then
		return 2
	elseif u == 4+1+8 then
		return 3
	end
	return 0
end

local function split_u_to_rot(u)
	if u == 1+8 then
		return 0
	elseif u == 2+4 then
		return 1
	end
	return 0
end

local full_height_houses = {quarter=c_small_house_full_height, half=c_half_house_full_height, three=c_three_quarter_house_full_height, split=c_split_house_full_height, full=c_full_house_full_height}
local half_height_houses = {quarter=c_small_house, half=c_half_house, three=c_three_quarter_house, split=c_split_house, full=c_full_house}
local half_height_houses_on_grass = {quarter=c_small_house_and_grass, half=c_half_house_and_grass, three=c_three_quarter_house_and_grass, split=c_split_house_and_grass, full=c_full_house_and_grass}
local half_height_houses_on_stone = {quarter=c_small_house_and_stone, half=c_half_house_and_stone, three=c_three_quarter_house_and_stone, split=c_split_house_and_stone, full=c_full_house_and_grass}

local function usage_to_node_suffix(usage)
	local u = math.floor(usage / 16)
	if u == 1 or u == 2 or u == 4 or u == 8 then
		return "quarter", quarter_u_to_rot(u)
	elseif u == 1+2 or u == 2+8 or u == 4+8 or u == 4+1 then
		return "half", half_u_to_rot(u)
	elseif u == 1+2+4 or u == 1+2+8 or u == 4+8+2 or u == 4+1+8 then
		return "three", three_quarter_u_to_rot(u)
	elseif u == 1+8 or u == 4+2 then
		return "split", split_u_to_rot(u)
	else
		return "full", split_u_to_rot(u)
	end
end

local function get_house_node(full_height, no_ground, on_stone, nodetype)
	if full_height then
		return full_height_houses[nodetype]
	elseif no_ground then
		return half_height_houses[nodetype]
	elseif on_stone then
		return half_height_houses_on_stone[nodetype]
	else
		return half_height_houses_on_grass[nodetype]
	end
end


	
local function mg_generate_gridchunk(data, param2_data, data_va, minp, maxp, chunk)
	if chunk == nil then return false end
	
	local object_height = chunk.object_height
	local ground_height = chunk.ground_height
	local usage_data = chunk.usage_data
	local road_data = chunk.road_data
	local geodata_va = VoxelArea:new({MinEdge={x=0, y=0, z=0}, MaxEdge={x=499, y=0, z=499}})
	local gridx, gridy = get_chunk_grid(minp.x, minp.z)
	
	local any_modification = false
	
	for x = minp.x, maxp.x do
		for z = minp.z, maxp.z do
			local _x = x - gridx * 50
			local _z = z - gridy * 50
			if _x >= 0 and _x < 500 and _z >= 0 and _z < 500 then
				local object_h = (object_height[geodata_va:index(_x, 0, _z)] or -4) / 2
				local ground_h = (ground_height[geodata_va:index(_x, 0, _z)] or -4) / 2
				local usage = usage_data[geodata_va:index(_x, 0, _z)] or 0
				local road_details = road_data[geodata_va:index(_x, 0, _z)] or 0
				local isroad = usage == 4 or math.fmod(usage, 8) >= 4
				usage = isroad and usage - 4 or usage

				if object_h <= maxp.y and (object_h >=minp.y or ground_h >= maxp.y) then
					any_modification = true
					for y = maxp.y, minp.y, -1 do
						local vi = data_va:index(x, y, z)
						if y > math.max(object_h, ground_h) + 0.51 then
							data[vi] = c_air
						elseif y > object_h + 0.5 and y <= ground_h + 0.51 then
							local full_height = y <= ground_h + 0.01
							if usage == 1 then
								if full_height then
									data[vi] = c_leaves
								else
									data[vi] = c_half_tree_top
								end
							elseif usage >= 8 then
								local node_suffix, rotation = usage_to_node_suffix(usage)
								data[vi] = get_house_node(full_height, true, isroad, node_suffix)
								param2_data[vi] = rotation
							else
								data[vi] = c_air
							end
						elseif y > object_h then
							local full_height = ground_h >= object_h + 0.99
							if usage > 8 then
								local node_suffix, rotation = usage_to_node_suffix(usage)
								data[vi] = get_house_node(full_height, true, isroad, node_suffix)
								param2_data[vi] = rotation
							elseif usage == 1 and not isroad then
								if full_height then
									data[vi] = c_leaves
								else
									data[vi] = c_half_tree_top
								end
							else
								data[vi] = c_air
							end
						elseif y > object_h - 0.5 then
							if usage == 0 and not isroad then
								data[vi] = c_half_grass
							elseif usage == 1 and not isroad then
								data[vi] = c_tree_and_grass
							elseif usage == 2 then
								data[vi] = c_half_water
							elseif usage > 8 then
								local node_suffix, rotation = usage_to_node_suffix(usage)
								data[vi] = get_house_node(nil, false, isroad, node_suffix)
								param2_data[vi] = rotation
							elseif isroad then
								local u = math.floor(road_details / 16)
								if u == 1 or u == 2 or u == 4 or u == 8 then
									data[vi] = c_quarter_road
									param2_data[vi] = quarter_u_to_rot(u)
								elseif u == 1+2 or u == 2+8 or u == 4+8 or u == 4+1 then
									data[vi] = c_half_road
									param2_data[vi] = half_u_to_rot(u)
								elseif u == 1+2+4 or u == 1+2+8 or u == 4+8+2 or u == 4+1+8 then
									data[vi] = c_three_quarter_road
									param2_data[vi] = three_quarter_u_to_rot(u)
								elseif u == 1+8 or u == 4+2 then
									data[vi] = c_split_road
									param2_data[vi] = split_u_to_rot(u)
								else
									data[vi] = c_half_stone
								end
							end
						elseif y > object_h - 1.0 then
							if usage == 2 then
								data[vi] = c_water
							elseif isroad then
								local u = math.floor(road_details / 16)
								if u == 1 or u == 2 or u == 4 or u == 8 then
									data[vi] = c_quarter_road_and_grass
									param2_data[vi] = quarter_u_to_rot(u)
								elseif u == 1+2 or u == 2+8 or u == 4+8 or u == 4+1 then
									data[vi] = c_half_road_and_grass
									param2_data[vi] = half_u_to_rot(u)
								elseif u == 1+2+4 or u == 1+2+8 or u == 4+8+2 or u == 4+1+8 then
									data[vi] = c_three_quarter_road_and_grass
									param2_data[vi] = three_quarter_u_to_rot(u)
								elseif u == 1+8 or u == 4+2 then
									data[vi] = c_split_road_and_grass
									param2_data[vi] = split_u_to_rot(u)
								else
									data[vi] = c_stone
								end
							else
								data[vi] = c_grass
							end
						else
							data[vi] = c_dirt
						end
					end
				end
			end
		end
	end
	return any_modification
end


local mybuf = {}

local function mg_generate_coarse(vm, minp, maxp, seed)

	local data = vm:get_data(mybuf)
	mybuf = data
	local param2_data = vm:get_param2_data()
	local emin, emax = vm:get_emerged_area()
	local data_va = VoxelArea:new{
		MinEdge=emin,
		MaxEdge=emax,
	}
	
	-- position in the 10 km - grid
	local gridx, gridy = get_chunk_grid(minp.x, minp.z)
	
	core.log("verbose", "generate at ".. minp.x .. ", z " .. minp.z .. " grid: " .. gridx .. ", " .. gridy)
	
	local chunk = get_or_load_chunk(gridx + gridX_offset, gridy + gridY_offset)
	
	local any_mod = false
	
	local splitX = maxp.x >= gridx * 50 + 500 and gridx * 50 + 499 or nil
	local splitZ = maxp.z >= gridy * 50 + 500 and gridy * 50 + 499 or nil
	local new_maxp = {x = splitX or maxp.x, y = maxp.y, z = splitZ or maxp.z}
	
	any_mod = mg_generate_gridchunk(data, param2_data, data_va, minp, new_maxp, chunk)
	if splitX then
		gridx, gridy = get_chunk_grid(maxp.x, minp.z)
		chunk = get_or_load_chunk(gridx + gridX_offset, gridy + gridY_offset)
		local new_minp = {x = splitX + 1, y = minp.y, z = minp.z}
		new_maxp = {x = maxp.x, y = maxp.y, z = splitZ or maxp.z}
		local _any_mod = mg_generate_gridchunk(data, param2_data, data_va, new_minp, new_maxp, chunk)
		any_mod = any_mod or _any_mod
	end
	if splitZ then
		gridx, gridy = get_chunk_grid(minp.x, maxp.z)
		chunk = get_or_load_chunk(gridx + gridX_offset, gridy + gridY_offset)
		local new_minp = {x = minp.x, y = minp.y, z = splitZ + 1}
		new_maxp = {x = splitX or maxp.x, y = maxp.y, z = maxp.z}
		local _any_mod = mg_generate_gridchunk(data, param2_data, data_va, new_minp, new_maxp, chunk)
		any_mod = any_mod or _any_mod
	end
	if splitX and splitZ then
		gridx, gridy = get_chunk_grid(maxp.x, maxp.z)
		chunk = get_or_load_chunk(gridx + gridX_offset, gridy + gridY_offset)
		local new_minp = {x = splitX + 1, y = minp.y, z = splitZ + 1}
		local _any_mod = mg_generate_gridchunk(data, param2_data, data_va, new_minp, maxp, chunk)
		any_mod = any_mod or _any_mod
	end
	
	if any_mod then
		vm:set_data(data)
		vm:set_param2_data(param2_data)
		vm:calc_lighting()
	end
end







local function get_fine_chunk_grid(x, z)
	return math.floor(1/1000 * x), math.floor(1/1000 * z)
end


local function parseUInt16HeightFile(filename)
    local file = io.open(filename, "rb")
    if not file then
        core.log("verbose", "Could not open file: " .. filename)
        return nil
    end

    local values = {}
    while true do
        local datalow = file:read(1)
        if not datalow then break end
        local datahigh = file:read(1)
        table.insert(values, datahigh:byte(1) * 256 + datalow:byte(1))
    end

    file:close()
    return values
end

local function get_or_load_fine_chunk(x, y)
	for i, chunk in ipairs(cached_chunks) do
		if chunk.x == x and chunk.y == y then
			if i ~= 0 then
				-- put to beginning of cache
				table.remove(cached_chunks, i)
				table.insert(cached_chunks, 0, chunk)
			end
			return chunk.data
		end
	end
	
	usage_data = parseBinaryFile(core.get_modpath("xyzreader") .. "/geodata_1/landcover_32" .. x .. "_" .. y .. ".bin")
	
	core.log("verbose", "Create new chunk for " .. "landcover_32" .. x .. "_" .. y .. ".bin, " ..(usage_data and "with usage_data" or "without usage_data"))
	if usage_data == nil then
		return nil
	end
	
	local chunk = {
		ground_height = parseUInt16HeightFile(core.get_modpath("xyzreader") .. "/geodata_1/dgm1_32_" .. x .. "_" .. y .. ".bin"),
		object_height = parseUInt16HeightFile(core.get_modpath("xyzreader") .. "/geodata_1/dom1_32_" .. x .. "_" .. y .. ".bin"),
		usage_data = usage_data
	}
	table.insert(cached_chunks, 0, chunk)
	while #cached_chunks > 4 do
		table.remove(cached_chunks, 4)
	end
	
	return chunk
end

local function mg_generate_finegridchunk(data, data_va, minp, maxp, chunk)
	if chunk == nil then return false end
	
	local object_height = chunk.object_height
	local ground_height = chunk.ground_height
	local usage_data = chunk.usage_data
	
	local gridx, gridy = get_fine_chunk_grid(minp.x, minp.z)
	
	local groundHeightData_va = VoxelArea:new({MinEdge={x=0, y=0, z=0}, MaxEdge={x=1000, y=0, z=1000}})
	local objectHeightData_va = VoxelArea:new({MinEdge={x=0, y=0, z=0}, MaxEdge={x=999, y=0, z=999}})
	
	local any_mod = false
	
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local _x = x - gridx * 1000
			local _z = z - gridy * 1000

			local ground_h = (ground_height[groundHeightData_va:index(_x, 0, _z)] or 0) / 16 + 4
			local object_h = (object_height[objectHeightData_va:index(_x, 0, _z)] or 0) / 16 + 4
			local isHouse = usage_data[objectHeightData_va:index(_x, 0, _z)] == 8
			local isPath = usage_data[objectHeightData_va:index(_x, 0, _z)] == 4

			if (object_h <= maxp.y or maxp.y > 0) and (object_h >=minp.y or ground_h >= minp.y) then
				any_mod = true
				for y = maxp.y, minp.y, -1 do
					local vi = data_va:index(x, y, z)
					if y > object_h then
						data[vi] = c_air
					elseif y > ground_h then
						if isHouse then
							if y > object_h - 1 then
								data[vi] = c_roof
							else
								data[vi] = c_wall
							end
						else							
							if y > object_h - 5 then
								data[vi] = c_leaves
							else
								data[vi] = c_air
							end
						end
					else
						if isPath then
							data[vi] = c_stone
						else
							data[vi] = c_grass
						end
					end
				end
			end
		end
	end
	
	return any_mod
end

local function mg_generate_fine(vm, minp, maxp, seed)

	local data = vm:get_data(mybuf)
	mybuf = data
	local emin, emax = vm:get_emerged_area()
	local data_va = VoxelArea:new{
		MinEdge=emin,
		MaxEdge=emax,
	}
	
	-- position in the 10 km - grid
	local gridx, gridy = get_fine_chunk_grid(minp.x, minp.z)
	
	local chunk = get_or_load_fine_chunk(gridx + 470, gridy + 5415)
	
	local any_mod = false
	
	local splitX = maxp.x >= gridx * 1000 + 1000 and gridx * 1000 + 999 or nil
	local splitZ = maxp.z >= gridy * 1000 + 1000 and gridy * 1000 + 999 or nil
	local new_maxp = {x = splitX or maxp.x, y = maxp.y, z = splitZ or maxp.z}
	
	any_mod = mg_generate_finegridchunk(data, data_va, minp, new_maxp, chunk)
	if splitX then
		gridx, gridy = get_fine_chunk_grid(maxp.x, minp.z)
		chunk = get_or_load_fine_chunk(gridx + 470, gridy + 5415)
		local new_minp = {x = splitX + 1, y = minp.y, z = minp.z}
		new_maxp = {x = maxp.x, y = maxp.y, z = splitZ or maxp.z}
		local _any_mod = mg_generate_finegridchunk(data, data_va, new_minp, new_maxp, chunk)
		any_mod = any_mod or _any_mod
	end
	if splitZ then
		gridx, gridy = get_fine_chunk_grid(minp.x, maxp.z)
		chunk = get_or_load_fine_chunk(gridx + 470, gridy + 5415)
		local new_minp = {x = minp.x, y = minp.y, z = splitZ + 1}
		new_maxp = {x = splitX or maxp.x, y = maxp.y, z = maxp.z}
		local _any_mod = mg_generate_finegridchunk(data, data_va, new_minp, new_maxp, chunk)
		any_mod = any_mod or _any_mod
	end
	if splitX and splitZ then
		gridx, gridy = get_fine_chunk_grid(maxp.x, maxp.z)
		chunk = get_or_load_fine_chunk(gridx + 470, gridy + 5415)
		local new_minp = {x = splitX + 1, y = minp.y, z = splitZ + 1}
		local _any_mod = mg_generate_finegridchunk(data, data_va, new_minp, maxp, chunk)
		any_mod = any_mod or _any_mod
	end
	
	if any_mod then
		vm:set_data(data)
		vm:calc_lighting()
	end
end


core.register_on_generated(mg_generate_coarse)
