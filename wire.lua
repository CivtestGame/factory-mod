f_constants.wire = {name = minetest.get_current_modname()..":wire"}

function wire.get_reg_values()
    return f_constants.wire.name, {
        description = "Wire",
        tiles = {"^[colorize:#ebe134"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    }
end