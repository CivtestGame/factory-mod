f_constants.usage = {name = minetest.get_current_modname()..":usage"}

---@param node Node
---@param network IO_network
function usage.update(node, network, usage)
    minetest.chat_send_all("Sample usage update called!")
end

function usage.get_reg_values()   
    return f_constants.usage.name, {
        description = "Usage",
        tiles = {"^[colorize:#000000"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
		after_place_node = function(pos, placer, itemstack, pointed_thing)
            IO_network.on_node_place(f_constants.networks.electricity,{pos = pos}, "use", 150)
        end,
    }
end
