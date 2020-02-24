
--------------------------------------------------------------------------------
--
-- Smelter
--
--------------------------------------------------------------------------------

simplecrafting_lib.register(
   "smelter_fuel",
   {
      input = { ["default:coke"] = 1 },
      burntime = 10,
   }
)

simplecrafting_lib.register(
   "smelter_fuel",
   {
      input = { ["default:charcoal"] = 1 },
      burntime = 5,
   }
)

simplecrafting_lib.register(
   "smelter_fuel",
   {
      input = { ["default:coal_lump"] = 1 },
      burntime = 5,
   }
)

simplecrafting_lib.register(
   "smelter",
   {
      input = {
         ["default:stone_with_copper"] = 1
      },
      output = "default:copper_lump 1",
      cooktime = 15
})

simplecrafting_lib.register(
   "smelter",
   {
      input = {
         ["default:copper_lump"] = 1
      },
      output = "default:copper_ingot 1",
      cooktime = 15
})

simplecrafting_lib.register(
   "smelter",
   {
      input = {
         ["default:stone_with_tin"] = 1
      },
      output = "default:tin_lump 1",
      cooktime = 15
})

simplecrafting_lib.register(
   "smelter",
   {
      input = {
         ["default:tin_lump"] = 1
      },
      output = "default:tin_ingot 1",
      cooktime = 15
})

simplecrafting_lib.register(
   "smelter",
   {
      input = {
         ["default:tin_lump"] = 1,
         ["default:copper_lump"] = 1,
      },
      output = "default:bronze_ingot 1",
      cooktime = 30
})

simplecrafting_lib.register(
   "smelter",
   {
      input = {
         ["default:bronze_ingot"] = 99,
         ["default:tin_ingot"] = 99,
         ["default:copper_ingot"] = 99
      },
      output = "factory_mod:advanced_smelter 1",
      cooktime = 30
})

local smelter_fns = simplecrafting_lib.generate_multifurnace_functions("smelter", "smelter_fuel", {
      show_guides = true,
      alphabetize_items = true,
      description = "Smelter",
      protect_inventory = true,
--      crafting_time_multiplier = function(pos, recipe),
         active_node = "factory_mod:smelter_active",
         lock_in_mode = "endless", -- "count"
         -- append_to_formspec = "string",
})

-- smelter_fns.allow_metadata_inventory_move
-- smelter_fns.allow_metadata_inventory_put
-- smelter_fns.allow_metadata_inventory_take
-- smelter_fns.can_dig
-- smelter_fns.on_construct
-- smelter_fns.on_metadata_inventory_move
-- smelter_fns.on_metadata_inventory_put
-- smelter_fns.on_metadata_inventory_take
-- smelter_fns.on_receive_fields
-- smelter_fns.on_timer

--
-- Node definitions
--


minetest.register_node("factory_mod:smelter", {
	description = "Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_smelter_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = smelter_fns.allow_metadata_inventory_take,
        can_dig = smelter_fns.can_dig,
        on_construct = smelter_fns.on_construct,
        on_metadata_inventory_move = smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = smelter_fns.on_metadata_inventory_take,
        on_receive_fields = smelter_fns.on_receive_fields,
        on_timer = smelter_fns.on_timer
})

minetest.register_node("factory_mod:smelter_active", {
	description = "Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png",
		{
			image = "default_smelter_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "factory_mod:smelter",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = smelter_fns.allow_metadata_inventory_take,
        can_dig = smelter_fns.can_dig,
        on_construct = smelter_fns.on_construct,
        on_metadata_inventory_move = smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = smelter_fns.on_metadata_inventory_take,
        on_receive_fields = smelter_fns.on_receive_fields,
        on_timer = smelter_fns.on_timer
})

--------------------------------------------------------------------------------
--
-- Advanced Smelter
--
--------------------------------------------------------------------------------


simplecrafting_lib.register(
   "advanced_smelter_fuel",
   {
      input = { ["default:coke"] = 1 },
      burntime = 10,
   }
)

simplecrafting_lib.register(
   "advanced_smelter_fuel",
   {
      input = { ["default:charcoal"] = 1 },
      burntime = 5,
   }
)

simplecrafting_lib.register(
   "advanced_smelter",
   {
      input = {
         ["default:stone_with_iron"] = 1
      },
      output = "default:iron_lump 1",
      cooktime = 10
})

simplecrafting_lib.register(
   "advanced_smelter",
   {
      input = {
         ["default:iron_lump"] = 1,
         ["default:obsidian_shard"] = 3
      },
      output = "default:iron_ingot 1",
      cooktime = 10
})

simplecrafting_lib.register(
   "advanced_smelter",
   {
      input = {
         ["default:bronze_ingot"] = 297,
         ["default:iron_ingot"] = 297,
      },
      output = "factory_mod:exceptional_smelter 1",
      cooktime = 30
})

local advanced_smelter_fns = simplecrafting_lib.generate_multifurnace_functions("advanced_smelter", "advanced_smelter_fuel", {
      show_guides = true,
      alphabetize_items = true,
      description = "Advanced Smelter",
      protect_inventory = true,
--      crafting_time_multiplier = function(pos, recipe),
         active_node = "factory_mod:advanced_smelter_active",
         lock_in_mode = "endless", -- "count"
         -- append_to_formspec = "string",
})

minetest.register_node("factory_mod:advanced_smelter", {
	description = "Advanced Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_advanced_smelter_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = advanced_smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = advanced_smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = advanced_smelter_fns.allow_metadata_inventory_take,
        can_dig = advanced_smelter_fns.can_dig,
        on_construct = advanced_smelter_fns.on_construct,
        on_metadata_inventory_move = advanced_smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = advanced_smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = advanced_smelter_fns.on_metadata_inventory_take,
        on_receive_fields = advanced_smelter_fns.on_receive_fields,
        on_timer = advanced_smelter_fns.on_timer
})

minetest.register_node("factory_mod:advanced_smelter_active", {
	description = "Advanced Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png",
		{
			image = "default_advanced_smelter_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "factory_mod:advanced_smelter",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = advanced_smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = advanced_smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = advanced_smelter_fns.allow_metadata_inventory_take,
        can_dig = advanced_smelter_fns.can_dig,
        on_construct = advanced_smelter_fns.on_construct,
        on_metadata_inventory_move = advanced_smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = advanced_smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = advanced_smelter_fns.on_metadata_inventory_take,
        on_receive_fields = advanced_smelter_fns.on_receive_fields,
        on_timer = advanced_smelter_fns.on_timer
})

--------------------------------------------------------------------------------
--
-- Exceptional Smelter
--
--------------------------------------------------------------------------------

simplecrafting_lib.register(
   "exceptional_smelter_fuel",
   {
      input = { ["default:coke"] = 1 },
      burntime = 10,
   }
)

simplecrafting_lib.register(
   "exceptional_smelter_fuel",
   {
      input = { ["default:charcoal"] = 1 },
      burntime = 5,
   }
)

simplecrafting_lib.register(
   "exceptional_smelter",
   {
      input = {
         ["default:iron_lump"] = 1,
         ["default:quicklime"] = 8
      },
      output = "default:steel_ingot 1",
      cooktime = 25
})

simplecrafting_lib.register(
   "exceptional_smelter",
   {
      input = {
         ["default:stone_with_gold"] = 1
      },
      output = "default:gold_lump 1",
      cooktime = 10
})

simplecrafting_lib.register(
   "exceptional_smelter",
   {
      input = {
         ["default:gold_lump"] = 1
      },
      output = "default:gold_ingot 1",
      cooktime = 10
})

local exceptional_smelter_fns = simplecrafting_lib.generate_multifurnace_functions("exceptional_smelter", "exceptional_smelter_fuel", {
      show_guides = true,
      alphabetize_items = true,
      description = "Exceptional Smelter",
      protect_inventory = true,
--      crafting_time_multiplier = function(pos, recipe),
         active_node = "factory_mod:exceptional_smelter_active",
         lock_in_mode = "endless", -- "count"
         -- append_to_formspec = "string",
})

minetest.register_node("factory_mod:exceptional_smelter", {
	description = "Exceptional Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_exceptional_smelter_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = exceptional_smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = exceptional_smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = exceptional_smelter_fns.allow_metadata_inventory_take,
        can_dig = exceptional_smelter_fns.can_dig,
        on_construct = exceptional_smelter_fns.on_construct,
        on_metadata_inventory_move = exceptional_smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = exceptional_smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = exceptional_smelter_fns.on_metadata_inventory_take,
        on_receive_fields = exceptional_smelter_fns.on_receive_fields,
        on_timer = exceptional_smelter_fns.on_timer
})

minetest.register_node("factory_mod:exceptional_smelter_active", {
	description = "Exceptional Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png",
		{
			image = "default_exceptional_smelter_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "factory_mod:exceptional_smelter",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = exceptional_smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = exceptional_smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = exceptional_smelter_fns.allow_metadata_inventory_take,
        can_dig = exceptional_smelter_fns.can_dig,
        on_construct = exceptional_smelter_fns.on_construct,
        on_metadata_inventory_move = exceptional_smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = exceptional_smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = exceptional_smelter_fns.on_metadata_inventory_take,
        on_receive_fields = exceptional_smelter_fns.on_receive_fields,
        on_timer = exceptional_smelter_fns.on_timer
})


--------------------------------------------------------------------------------
--
-- Smelter Hat
--
--------------------------------------------------------------------------------

-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node(
   "factory_mod:smelter_exhaust",
   {
      description = "Smelter Exhaust",
      tiles = {
         "default_furnace_bottom.png",
         "default_furnace_bottom.png",
         "default_furnace_side.png",
         "default_furnace_side.png",
         "default_furnace_side.png",
         "default_furnace_side.png"
      },
      drawtype = "nodebox",
      paramtype = "light",
      groups = { cracky = 3, stone = 1 },
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      node_box = {
         type = "fixed",
         fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
            {-0.4375, 0, -0.4375, 0.4375, 0.25, 0.4375}, -- NodeBox4
            {-0.3125, 0.25, -0.3125, 0.3125, 0.375, 0.3125}, -- NodeBox5
            {-0.1875, 0.375, -0.1875, 0.1875, 0.5, 0.1875}, -- NodeBox6
         }
      }
})

-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node(
   "factory_mod:ingot_catcher",
   {
      description = "Ingot Catcher",
      groups = { cracky = 3, stone = 1 },
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      tiles = {
         "default_ingot_catcher_top.png",
         "default_ingot_catcher_left_right.png",
         "default_ingot_catcher_left_right.png",
         "default_ingot_catcher_left_right.png",
         "default_ingot_catcher_side2.png",
         "default_ingot_catcher_side.png"
      },
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
         type = "fixed",
         fixed = {
            {0.0625, -0.5, -0.25, 0.4375, -0.375, 0.25}, -- Base
            {0, -0.375, -0.3125, 0.125, -0.25, 0.3125}, -- Wall1
            {0.375, -0.375, -0.3125, 0.5, -0.25, 0.3125}, -- Wall2
            {0.0625, -0.375, -0.3125, 0.4375, -0.25, -0.1875}, -- Wall3
            {0.0625, -0.375, 0.1875, 0.4375, -0.25, 0.3125}, -- Wall4
            {0.0625, -0.1875, -0.0625, 0.25, -0.125, 0.0625}, -- PipeBase1
            {-0.125, -0.125, -0.0625, 0.0625, -0.0625, 0.0625}, -- PipeBase2
            {-0.3125, -0.0625, -0.0625, -0.125, 5.58794e-009, 0.0625}, -- PipeBase3
            {-0.5, 0, -0.0625, -0.3125, 0.0625, 0.0625}, -- PipeBase4
            {-0.0625, -0.1875, -0.125, 0.25, 0.125, -0.0625}, -- PipeSide1
            {-0.0625, -0.1875, 0.0625, 0.25, 0.125, 0.125}, -- PipeSide2
            {-0.5, -0.5, 0.0625, -0.0625, 0.1875, 0.125}, -- PipeSide3
            {-0.5, -0.5, -0.125, -0.0625, 0.1875, -0.0625}, -- PipeSide4
         }
      }
})

--------------------------------------------------------------------------------
--
-- Burner
--
--------------------------------------------------------------------------------

simplecrafting_lib.register(
   "burner_fuel",
   {
      input = { ["default:coke"] = 1 },
      burntime = 20,
   }
)

simplecrafting_lib.register(
   "burner_fuel",
   {
      input = { ["default:charcoal"] = 1 },
      burntime = 15,
   }
)

simplecrafting_lib.register(
   "burner_fuel",
   {
      input = { ["default:coal_lump"] = 1 },
      burntime = 10,
   }
)

simplecrafting_lib.register(
   "burner",
   {
      input = {
         ["default:limestone_dust"] = 2
      },
      output = "default:quicklime 1",
      cooktime = 5
})

simplecrafting_lib.register(
   "burner",
   {
      input = {
         ["default:coral_skeleton"] = 1
      },
      output = "default:quicklime 1",
      cooktime = 5
})

simplecrafting_lib.register(
   "burner",
   {
      input = {
         ["default:coal_lump"] = 2
      },
      output = "default:coke 1",
      cooktime = 5
})

simplecrafting_lib.register(
   "burner",
   {
      input = {
         ["group:wood"] = 5
      },
      output = "default:charcoal 1",
      cooktime = 10
})

simplecrafting_lib.register(
   "burner",
   {
      input = {
         ["group:tree"] = 1
      },
      output = "default:charcoal 1",
      cooktime = 2
})

simplecrafting_lib.register(
   "burner",
   {
      input = {
         ["default:quicklime"] = 99,
         ["default:charcoal"] = 99,
         ["default:coke"] = 99
      },
      output = "factory_mod:smelter 1",
      cooktime = 30
})

local burner_fns = simplecrafting_lib.generate_multifurnace_functions("burner", "burner_fuel", {
      show_guides = true,
      alphabetize_items = true,
      description = "Burner",
      protect_inventory = true,
--      crafting_time_multiplier = function(pos, recipe),
         active_node = "factory_mod:burner_active",
         lock_in_mode = "endless", -- "count"
         -- append_to_formspec = "string",
})

minetest.register_node("factory_mod:burner", {
	description = "Burner",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_burner_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = burner_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = burner_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = burner_fns.allow_metadata_inventory_take,
        can_dig = burner_fns.can_dig,
        on_construct = burner_fns.on_construct,
        on_metadata_inventory_move = burner_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = burner_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = burner_fns.on_metadata_inventory_take,
        on_receive_fields = burner_fns.on_receive_fields,
        on_timer = burner_fns.on_timer
})

minetest.register_node("factory_mod:burner_active", {
	description = "Burner",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_burner_front_active.png"
		-- {
		-- 	image = "default_furnace_front_active.png",
		-- 	backface_culling = false,
		-- 	animation = {
		-- 		type = "vertical_frames",
		-- 		aspect_w = 16,
		-- 		aspect_h = 16,
		-- 		length = 1.5
		-- 	},
		-- }
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "factory_mod:burner",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = burner_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = burner_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = burner_fns.allow_metadata_inventory_take,
        can_dig = burner_fns.can_dig,
        on_construct = burner_fns.on_construct,
        on_metadata_inventory_move = burner_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = burner_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = burner_fns.on_metadata_inventory_take,
        on_receive_fields = burner_fns.on_receive_fields,
        on_timer = burner_fns.on_timer
})

minetest.register_craft({
	output = 'factory_mod:burner',
	recipe = {
		{'group:stone', 'group:stone', 'group:stone'},
		{'group:stone', 'default:torch', 'group:stone'},
		{'group:stone', 'group:stone', 'group:stone'},
	}
})
