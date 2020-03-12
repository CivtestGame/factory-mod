local name = minetest.get_current_modname()..":turbine"

---@param node Node
---@param network IO_network
local function update(node, network, usage)
    minetest.chat_send_all("Turbine update called")
    local n = NodeNetwork.IO_network(node.pos, "electricity")
    n:update_production(node.pos, usage*10)
    n:save()
end

minetest.register_node(name, {
    description = "Turbine",
    tiles = {"^[colorize:#48a832"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        f_util.cdebug(NodeNetwork.IO_network(pos, "electricity"):get_node(pos))
        f_util.cdebug(NodeNetwork.IO_network(pos, "steam"):get_node(pos))
    end,
})

NodeNetwork.register_transfer_node("steam", "electricity", name, update, 10)