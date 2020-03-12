local wire_name = minetest.get_current_modname()..":wire"

minetest.register_node(wire_name, {
    description = "Wire",
    tiles = {"^[colorize:#ebe134"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local n = NodeNetwork.IO_network(pos, "electricity")
        n:update_infotext()
        f_util.debug(n.nodes)
    end
})

NodeNetwork.register_node("electricity", wire_name)