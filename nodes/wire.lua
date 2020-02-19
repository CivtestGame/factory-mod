local wire_name = minetest.get_current_modname()..":wire"

Network.register_node("electricity", wire_name)

function f_nodes.wire()
    return wire_name, {
        description = "Wire",
        tiles = {"^[colorize:#ebe134"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            Network.on_node_place({"electricity"}, IO_network, {pos = pos})
        end,
        on_destruct = function(pos, old_node)
            Network.on_node_destruction("electricity", pos, true, IO_network)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local n = IO_network(pos, "electricity")
            n:update_infotext()
            f_util.cdebug(n)
            f_util.cdebug(n.nodes)
        end
    }
end