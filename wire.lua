local set_vals = {save_id = "wire"}
f_constants.wire = {name = minetest.get_current_modname()..":wire", set_values = set_vals}

function wire.get_reg_values()
    return f_constants.wire.name, {
        description = "Wire",
        tiles = {"^[colorize:#ebe134"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            node_network.on_node_place(f_constants.wire.set_values, pos, f_constants.wire.name)
        end,
        after_destruct = function(pos, old_node)
            node_network.on_node_destruction(f_constants.wire.set_values, pos, true)
        end,
    }
end