local name = minetest.get_current_modname()..":pipe"

Network.register_node("steam", name)

function f_nodes.pipe()
    return name, {
        description = "Pipe",
        tiles = {"^[colorize:#3248a8"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            IO_network.on_node_place("steam", {pos = pos})
        end,
        after_destruct = function(pos, old_node)
            IO_network.on_node_destruction("steam", pos, "normal", true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local n = IO_network(pos, "steam")
            n:update_infotext()
            f_util.cdebug(n)
        end
    }
end