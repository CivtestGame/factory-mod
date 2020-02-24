local name = minetest.get_current_modname()..":turbine"

---@param node Node
---@param network IO_network
local function update(node, network, usage)
    minetest.chat_send_all("Turbine update called")
    local n = NodeNetwork.IO_network(node.pos, "electricity")
    n:update_production(node.pos, usage*10)
    n:save()
end

NodeNetwork.register_usage_node("steam", name, update)
NodeNetwork.register_production_node("electricity", name)

function f_nodes.turbine()
    return name, {
        description = "Turbine",
        tiles = {"^[colorize:#48a832"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            NodeNetwork.on_node_place("electricity", {pos = pos, production = 0})
            NodeNetwork.on_node_place("steam",{pos = pos, demand=10})
        end,
        after_destruct = function(pos, old_node)
            NodeNetwork.on_node_destruction("electricity", pos, true)
            NodeNetwork.on_node_destruction("steam", pos, true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            f_util.cdebug(NodeNetwork.IO_network(pos, "electricity"):get_node(pos))
            f_util.cdebug(NodeNetwork.IO_network(pos, "steam"):get_node(pos))
        end,
    }
end