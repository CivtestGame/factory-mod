
local MAXSTACK_SIZE = 99

-- A function to created penalised factory drops.
local function factory_drops_from_recipe(recipe, drop_reduction)
   -- Essentially, converts a simplecrafting_lib recipe to something suitable
   -- for use in a NodeDef's `drop` table. Multiplies the number of drops by
   -- `drop_reduction` to apply a resource penalty to factory breakage.
   local items = {}
   for k, v in pairs(recipe) do
      local maxstack_adjusted = math.floor(v / MAXSTACK_SIZE)
      local maxstack_remainder = v % (maxstack_adjusted * MAXSTACK_SIZE)

      for i = 1, maxstack_adjusted, 1 do
         items[#items + 1] = k .. " " .. tostring(math.floor(MAXSTACK_SIZE * drop_reduction))
      end
      if maxstack_remainder > 0 then
         items[#items + 1] = k .. " " .. tostring(math.floor(maxstack_remainder * drop_reduction))
      end
   end

   return items
end

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
   "smelter_fuel",
   {
      input = { ["default:coalblock"] = 1 },
      burntime = 45,
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

-- Smelter Recipe

local smelter_recipe = {
   ["default:quicklime"] = 99,
   ["default:charcoal"] = 99,
   ["default:coke"] = 99
}

simplecrafting_lib.register(
   "burner",
   {
      input = smelter_recipe,
      output = "factory_mod:smelter 1",
      cooktime = 30
})

smelter_fns.drop = {
   max_items = 1,
   items = {
      { items = factory_drops_from_recipe(smelter_recipe, 0.5) }
   }
}

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
        on_timer = smelter_fns.on_timer,
        drop = smelter_fns.drop
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
        on_timer = smelter_fns.on_timer,
        drop = smelter_fns.drop
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

-- Advanced Smelter Recipe

local advanced_smelter_recipe = {
   ["default:bronze_ingot"] = 99,
   ["default:tin_ingot"] = 198,
   ["default:copper_ingot"] = 198
}

simplecrafting_lib.register(
   "smelter",
   {
      input = advanced_smelter_recipe,
      output = "factory_mod:advanced_smelter 1",
      cooktime = 30
})

advanced_smelter_fns.drop = {
   max_items = 1,
   items = {
      { items = factory_drops_from_recipe(advanced_smelter_recipe, 0.5) }
   }
}

--

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
        on_timer = advanced_smelter_fns.on_timer,
        drop = advanced_smelter_fns.drop
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
        on_timer = advanced_smelter_fns.on_timer,
        drop = advanced_smelter_fns.drop
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

-- Exceptional Smelter Recipe

local exceptional_smelter_recipe = {
   ["default:bronze_ingot"] = 297,
   ["default:iron_ingot"] = 297,
}

simplecrafting_lib.register(
   "advanced_smelter",
   {
      input = exceptional_smelter_recipe,
      output = "factory_mod:exceptional_smelter 1",
      cooktime = 30
})

exceptional_smelter_fns.drop = {
   max_items = 1,
   items = {
      { items = factory_drops_from_recipe(exceptional_smelter_recipe, 0.5) }
   }
}

--

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
        on_timer = exceptional_smelter_fns.on_timer,
        drop = exceptional_smelter_fns.drop
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
        on_timer = exceptional_smelter_fns.on_timer,
        drop = exceptional_smelter_fns.drop
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
      burntime = 50,
   }
)

simplecrafting_lib.register(
   "burner_fuel",
   {
      input = { ["default:charcoal"] = 1 },
      burntime = 30,
   }
)

simplecrafting_lib.register(
   "burner_fuel",
   {
      input = { ["default:coal_lump"] = 1 },
      burntime = 30,
   }
)

simplecrafting_lib.register(
   "smelter_fuel",
   {
      input = { ["default:coalblock"] = 1 },
      burntime = 9*30,
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
      output = "default:charcoal 2",
      cooktime = 2
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

--------------------------------------------------------------------------------
--
-- Stone Smelter
--
--------------------------------------------------------------------------------

simplecrafting_lib.register(
   "stone_smelter_fuel",
   {
      input = { ["default:coke"] = 1 },
      burntime = 80,
   }
)

simplecrafting_lib.register(
   "stone_smelter_fuel",
   {
      input = { ["default:charcoal"] = 1 },
      burntime = 40,
   }
)

simplecrafting_lib.register(
   "stone_smelter_fuel",
   {
      input = { ["default:coal_lump"] = 1 },
      burntime = 40,
   }
)

simplecrafting_lib.register(
   "smelter_fuel",
   {
      input = { ["default:coalblock"] = 1 },
      burntime = 360,
   }
)

simplecrafting_lib.register(
   "stone_smelter",
   {
      input = {
         ["default:cobble"] = 1
      },
      output = "default:stone 1",
      cooktime = 2
})

simplecrafting_lib.register(
   "stone_smelter",
   {
      input = {
         ["default:desert_sand"] = 2
      },
      output = "default:desert_sandstone 1",
      cooktime = 2
})

simplecrafting_lib.register(
   "stone_smelter",
   {
      input = {
         ["default:sand"] = 2
      },
      output = "default:sandstone 1",
      cooktime = 2
})

simplecrafting_lib.register(
   "stone_smelter",
   {
      input = {
         ["default:silver_sand"] = 2
      },
      output = "default:silver_sandstone 1",
      cooktime = 2
})

local stone_smelter_fns = simplecrafting_lib.generate_multifurnace_functions("stone_smelter", "stone_smelter_fuel", {
      show_guides = true,
      alphabetize_items = true,
      description = "Stone Smelter",
      protect_inventory = true,
--      crafting_time_multiplier = function(pos, recipe),
         active_node = "factory_mod:stone_smelter_active",
         lock_in_mode = "endless", -- "count"
         -- append_to_formspec = "string",
})

-- Stone Smelter Recipe

local stone_smelter_recipe = {
   ["default:stone"] = 297,
   ["default:sandstone"] = 99,
   ["default:silver_sandstone"] = 99,
   ["default:desert_sandstone"] = 99,
   ["default:coal_lump"] = 198
}

simplecrafting_lib.register(
   "burner",
   {
      input = stone_smelter_recipe,
      output = "factory_mod:stone_smelter 1",
      cooktime = 30
})

stone_smelter_fns.drop = {
   max_items = 1,
   items = {
      { items = factory_drops_from_recipe(stone_smelter_recipe, 0.5) }
   }
}

--

minetest.register_node("factory_mod:stone_smelter", {
	description = "Stone Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_stone_smelter_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = stone_smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = stone_smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = stone_smelter_fns.allow_metadata_inventory_take,
        can_dig = stone_smelter_fns.can_dig,
        on_construct = stone_smelter_fns.on_construct,
        on_metadata_inventory_move = stone_smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = stone_smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = stone_smelter_fns.on_metadata_inventory_take,
        on_receive_fields = stone_smelter_fns.on_receive_fields,
        on_timer = stone_smelter_fns.on_timer,
        drop = stone_smelter_fns.drop
})

minetest.register_node("factory_mod:stone_smelter_active", {
	description = "Stone Smelter",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png",
		{
			image = "default_stone_smelter_front_active.png",
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
	drop = "factory_mod:stone_smelter",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

        allow_metadata_inventory_move = stone_smelter_fns.allow_metadata_inventory_move,
        allow_metadata_inventory_put = stone_smelter_fns.allow_metadata_inventory_put,
        allow_metadata_inventory_take = stone_smelter_fns.allow_metadata_inventory_take,
        can_dig = stone_smelter_fns.can_dig,
        on_construct = stone_smelter_fns.on_construct,
        on_metadata_inventory_move = stone_smelter_fns.on_metadata_inventory_move,
        on_metadata_inventory_put = stone_smelter_fns.on_metadata_inventory_put,
        on_metadata_inventory_take = stone_smelter_fns.on_metadata_inventory_take,
        on_receive_fields = stone_smelter_fns.on_receive_fields,
        on_timer = stone_smelter_fns.on_timer,
        drop = stone_smelter_fns.drop
})
