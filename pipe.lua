local resource_values = {name = "steam", max_per_node = 10}
pipe.set_values = {save_id = "pipe", resource = resource_values}
f_constants.pipe = {name = minetest.get_current_modname()..":pipe"}


function pipe.get_reg_values()
    return f_constants.pipe.name, {
        description = "Pipe",
        tiles = {"^[colorize:#3248a8"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            node_network.on_node_place(pipe.set_values, pos, f_constants.pipe.name)
        end,
        after_destruct = function(pos, old_node)
            node_network.on_node_destruction(pipe.set_values, pos, true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            minetest.chat_send_all(f_util.dump(node_network.get_network(pipe.set_values, pos).nodes))
        end
    }
end

function pipe.get_max_steam(network)
        return table.getn(network.nodes)*f_constants.pipe.max_steam
end

function pipe.update_infotext(network)
    for _, pos in pairs(network.nodes) do
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext",  "Contains " .. network.steam_units .. " units of steam")
    end
end