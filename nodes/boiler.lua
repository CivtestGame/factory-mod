local name = minetest.get_current_modname()..":boiler"

local function get_formspec(burn_pct)
    local formspec = {
        "size[8,6]",
        "list[context;fuel;3,0;1,1;]",
        "image[4,0;1,1;default_furnace_fire_bg.png^[lowpart:",
        (burn_pct),":default_furnace_fire_fg.png]",
        "list[current_player;main;0,2;8,4;]",
        "listring[]",
    }
    return table.concat(formspec, "")
end

---@param pos Position
---@param listname string
---@param index number
---@param stack any
---@param player any
local function consume_fuel(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local fuel_stack = inv:get_stack("fuel", 1)
	local fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = {fuel_stack}})
	if fuel.time > 0 then
		local total_time = fuel.time * fuel_stack:get_count() --Total time that the stack can burn for
		f_util.cdebug(total_time)
		fuel_stack:clear()
		inv:set_stack("fuel", 1,fuel_stack)
		local network = NodeNetwork.IO_network(pos, "steam")
		local node, node_key = network:get_node(pos)
		local previous_value = node.burn_end
		if not previous_value or previous_value < os.time() then previous_value = os.time() end
		node.burn_end = total_time + previous_value
		local diff = node.burn_end - os.time()
		network:set_node(node, node_key)
		network:update_production(pos, 10)
		network:save()
		f_util.cdebug(diff)
		minetest.after(diff, NodeNetwork.IO_network.check_burntime, pos, "steam")
	end
end

minetest.register_node(name, {
    description = "Boiler",
    tiles = {"^[colorize:#a83232"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size('fuel', 1)
    	meta:set_string("formspec", get_formspec(0))
	end,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    	f_util.cdebug(NodeNetwork.IO_network(pos, "steam"):get_node(pos))
    end,
	on_metadata_inventory_put = consume_fuel
})

NodeNetwork.register_production_node("steam", name)