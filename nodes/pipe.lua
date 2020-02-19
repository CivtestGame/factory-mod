local p_name = minetest.get_current_modname()..":pipe"
f_constants.pipe = {name = p_name}

Network.register_node("steam", p_name)

function pipe.get_reg_values()
    return f_constants.pipe.name, {
        description = "Pipe",
        tiles = {"^[colorize:#3248a8"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            Network.on_node_place({"steam"}, IO_network, {pos = pos})
        end,
        on_destruct = function(pos, old_node)
            Network.on_node_destruction("steam", pos, true, IO_network)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local n = IO_network(pos, "steam")
            n:update_infotext()
            f_util.cdebug(n)
            f_util.cdebug(n.nodes)
        end
    }
end