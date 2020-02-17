f_constants.usage = {name = minetest.get_current_modname()..":usage"}

---@param pos Position
---@param ratio number
---@param network Network | nil
function usage.update(pos, ratio, network)
    local s_v = f_constants.networks.electricity
    network = network or node_network.get_network(s_v, pos)
    minetest.chat_send_all("Called usage!")
    f_util.cdebug(network[s_v.io_name].demand)
end

function usage.get_reg_values()   
    return f_constants.usage.name, {
        description = "Usage",
        tiles = {"^[colorize:#000000"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
		after_place_node = function(pos, placer, itemstack, pointed_thing)
            io_network.on_node_place(f_constants.networks.electricity, {pos = pos}, "use")
        end,
    }
end
