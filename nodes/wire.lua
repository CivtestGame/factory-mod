local wire_name = minetest.get_current_modname()..":wire"
local set_vals = {save_id = "wire", io_name = "Electricity", types = {wire_name, f_constants.turbine.name}}
f_constants.wire = {name = wire_name, set_values = set_vals}

function wire.get_reg_values()
    return f_constants.wire.name, {
        description = "Wire",
        tiles = {"^[colorize:#ebe134"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            node_network.on_node_place({f_constants.wire.set_values}, pos)
        end,
        after_destruct = function(pos, old_node)
            node_network.on_node_destruction(f_constants.wire.set_values, pos, true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            minetest.chat_send_all(f_util.dump(node_network.get_network(f_constants.wire.set_values, pos)))
        end
    }
end