
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
         ["default:stone_with_iron"] = 1
      },
      output = "default:iron_lump 1",
      cooktime = 30
})

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
         ["default:iron_lump"] = 1,
         ["default:obsidian_shard"] = 5
      },
      output = "default:iron_ingot 1",
      cooktime = 20
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
		"default_furnace_side.png", "default_furnace_front.png"
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
			image = "default_furnace_front_active.png",
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
         ["default:iron_lump"] = 1,
         ["default:quicklime"] = 8
      },
      output = "default:steel_ingot 1",
      cooktime = 25
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
		"default_furnace_side.png", "default_furnace_front.png"
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
			image = "default_furnace_front_active.png",
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
