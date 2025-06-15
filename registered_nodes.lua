
stairs.register_slab(
	"house",
	nil,
	{cracky = 3},
	{"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
	"House Slab",
	default.node_sound_dirt_defaults(),
	false
)

minetest.register_node("xyzreader:house_on_grass", {
    description = "House on Grass",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_grass.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

stairs.register_stair_outer(
	"house_on_grass",
	nil,
	{cracky = 3},
	{"default_grass.png^(default_desert_stone.png^[mask:utm_mapgen_quarter_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
	"House Outer Stair",
	default.node_sound_dirt_defaults(),
	false
)

stairs.register_stair_inner(
	"house_on_grass",
	nil,
	{cracky = 3},
	{"default_grass.png^(default_desert_stone.png^[mask:utm_mapgen_three_quarter_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
	"House Inner Stair",
	default.node_sound_dirt_defaults(),
	false
)

stairs.register_stair(
	"house_on_grass",
	nil,
	{cracky = 3},
	{"default_grass.png^(default_desert_stone.png^[mask:utm_mapgen_half_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
	"House Stair",
	default.node_sound_dirt_defaults(),
	false
)

stairs.register_stair_outer(
	"house_on_stone",
	nil,
	{cracky = 3},
	{"default_stone.png^(default_desert_stone.png^[mask:utm_mapgen_quarter_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
	"House Outer Stair on Stone",
	default.node_sound_dirt_defaults(),
	false
)

stairs.register_stair_inner(
	"house_on_stone",
	nil,
	{cracky = 3},
	{"default_stone.png^(default_desert_stone.png^[mask:utm_mapgen_three_quarter_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
	"House Inner Stair on Stone",
	default.node_sound_dirt_defaults(),
	false
)

stairs.register_stair(
	"house_on_stone",
	nil,
	{cracky = 3},
	{"default_stone.png^(default_desert_stone.png^[mask:utm_mapgen_half_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
	"House Stair on Stone",
	default.node_sound_dirt_defaults(),
	false
)

minetest.register_node("xyzreader:quarter_house", {
    description = "Quarter House",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0, 0, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:half_house", {
    description = "Half House",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0.5, 0, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:three_quarter_house", {
    description = "Three Quarter House",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0.5, 0, 0.5},
            {-0.5, -0.5, -0.5, 0, 0, 0},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:split_house", {
    description = "Split House",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0, 0, 0.5},
            {0, -0.5, -0.5, 0.5, 0, 0},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})


minetest.register_node("xyzreader:full_house_full_height", {
    description = "Full House Full Height",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:quarter_house_full_height", {
    description = "Quarter House Full Height",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:half_house_full_height", {
    description = "Half House Full Height",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:three_quarter_house_full_height", {
    description = "Three Quarter House Full Height",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0.5, 0.5, 0.5},
            {-0.5, -0.5, -0.5, 0, 0.5, 0},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:split_house_full_height", {
    description = "Split House Full Height",
    drawtype = "nodebox",
    tiles = {"default_desert_stone.png", "default_stone.png", "default_fence_aspen_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0, 0, 0.5, 0.5},
            {0, -0.5, -0.5, 0.5, 0.5, 0},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:split_house_on_grass", {
    description = "Split House on Grass",
    drawtype = "nodebox",
    tiles = {"default_grass.png^(default_desert_stone.png^[mask:utm_mapgen_split_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
            {-0.5, 0, 0, 0, 0.5, 0.5},
            {0, 0, -0.5, 0.5, 0.5, 0},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:split_house_on_stone", {
    description = "Split House on Stone",
    drawtype = "nodebox",
    tiles = {"default_stone.png^(default_desert_stone.png^[mask:utm_mapgen_split_alpha.png)", "default_stone.png", "[combine:16x16:0,0=default_fence_aspen_wood.png:0,8=default_dirt.png\\^default_grass_side.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
            {-0.5, 0, 0, 0, 0.5, 0.5},
            {0, 0, -0.5, 0.5, 0.5, 0},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})




stairs.register_slab(
	"half_road",
	nil,
	{cracky = 3},
	{"default_grass.png^(default_stone.png^[mask:utm_mapgen_half_alpha.png)", "default_grass.png", "default_grass.png"},
	"Half Road Slab",
	default.node_sound_dirt_defaults(),
	false
)

minetest.register_node("xyzreader:half_road", {
    description = "Half Road Block",
    drawtype = "nodebox",
    tiles = {"default_grass.png^(default_stone.png^[mask:utm_mapgen_half_alpha.png)", "default_grass.png", "default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

stairs.register_slab(
	"quarter_road",
	nil,
	{cracky = 3},
	{"default_grass.png^(default_stone.png^[mask:utm_mapgen_quarter_alpha.png)", "default_grass.png", "default_grass.png"},
	"Quarter Road Slab",
	default.node_sound_dirt_defaults(),
	false
)

minetest.register_node("xyzreader:quarter_road", {
    description = "Quarter Road Block",
    drawtype = "nodebox",
    tiles = {"default_grass.png^(default_stone.png^[mask:utm_mapgen_quarter_alpha.png)", "default_grass.png", "default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

stairs.register_slab(
	"three_quarter_road",
	nil,
	{cracky = 3},
	{"default_grass.png^(default_stone.png^[mask:utm_mapgen_three_quarter_alpha.png)", "default_grass.png", "default_grass.png"},
	"Three Quarter Road Slab",
	default.node_sound_dirt_defaults(),
	false
)

minetest.register_node("xyzreader:three_quarter_road", {
    description = "Three Quarter Road Block",
    drawtype = "nodebox",
    tiles = {"default_grass.png^(default_stone.png^[mask:utm_mapgen_three_quarter_alpha.png)", "default_grass.png", "default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

stairs.register_slab(
	"split_road",
	nil,
	{cracky = 3},
	{"default_grass.png^(default_stone.png^[mask:utm_mapgen_split_alpha.png)", "default_grass.png", "default_grass.png"},
	"Split Road Slab",
	default.node_sound_dirt_defaults(),
	false
)

minetest.register_node("xyzreader:split_road", {
    description = "Split Road Block",
    drawtype = "nodebox",
    tiles = {"default_grass.png^(default_stone.png^[mask:utm_mapgen_split_alpha.png)", "default_grass.png", "default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

stairs.register_slab(
	"water",
	nil,
	{cracky = 3},
	{"default_obsidian.png^(default_water.png^[opacity:160)"},
	"Water Slab",
	default.node_sound_dirt_defaults(),
	false
)

minetest.register_node("xyzreader:water_block", {
    description = "Water Block",
    drawtype = "nodebox",
    tiles = {"default_obsidian.png^(default_water.png^[opacity:160)"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_node("xyzreader:slab_leaves", {
    description = "Leaves Slab",
    drawtype = "nodebox",
	use_texture_alpha = true,
    --drawtype = "allfaces_optional",
    --drawtype = "normal",
    tiles = {"default_leaves.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})


minetest.register_node("xyzreader:leaves_on_grass", {
    description = "Leaves on Grass",
    drawtype = "nodebox",
    tiles = {"default_grass.png^default_leaves.png", "default_grass.png", "[combine:16x16:0,0=default_leaves.png:0,8=default_dirt.png\\^default_grass_side.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})
