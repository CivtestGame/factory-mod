local name = minetest.get_current_modname() .. ":usage"

---@param node Node
---@param network IO_network
local function update(node, network, usage)
    minetest.chat_send_all("Sample usage update called!")
end

IO_network.register_usage_node("electricity", name, update)

function f_nodes.usage()   
    return name, {
        description = "Usage",
        tiles = {"^[colorize:#000000"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
		after_place_node = function(pos, placer, itemstack, pointed_thing)
            IO_network.on_node_place("electricity",{pos = pos, demand=150})
        end,
        after_destruct = function(pos, old_node)
            IO_network.on_node_destruction("electricity", pos, "use", true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local n = IO_network(pos, "electricity")
            f_util.cdebug(n.nodes)
            f_util.cdebug(n)
        end
    }
end
