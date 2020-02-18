local wire_name = minetest.get_current_modname()..":wire"
f_constants.wire = {name = wire_name}

function wire.get_reg_values()
    return f_constants.wire.name, {
        description = "Wire",
        tiles = {"^[colorize:#ebe134"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            Network.on_node_place({f_constants.networks.electricity}, IO_network, {pos = pos})
        end,
        after_destruct = function(pos, old_node)
            Network.on_node_destruction(pos, true, IO_network, f_constants.networks.electricity)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local n = IO_network(pos, f_constants.networks.electricity)
            n:update_infotext()
            f_util.cdebug(n)
            f_util.cdebug(n.nodes)
        end
    }
end