
-- Unused nodes

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
