local p_name = minetest.get_current_modname()..":pipe"
f_constants.pipe = {name = p_name}


function pipe.get_reg_values()
    return f_constants.pipe.name, {
        description = "Pipe",
        tiles = {"^[colorize:#3248a8"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            node_network.on_node_place({f_constants.networks.pipe}, {pos = pos})
        end,
        after_destruct = function(pos, old_node)
            node_network.on_node_destruction(f_constants.networks.pipe, pos, true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            minetest.chat_send_all(f_util.dump(node_network.get_network(f_constants.networks.pipe, pos).nodes))
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