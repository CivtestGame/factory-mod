local name = minetest.get_current_modname()..":pipe"

minetest.register_node(name, {
    description = "Pipe",
    tiles = {"^[colorize:#3248a8"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    on_place = NodeNetwork.citadel_network.before_node_place,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local network = NodeNetwork.IO_network(pos, "steam")
        network:update_infotext()
        f_util.debug(network.nodes)
    end
})

NodeNetwork.register_node("steam", name)