local name = minetest.get_current_modname() .. ":usage"

---@param node Node
---@param network IO_network
local function update(node, network, usage)
    minetest.chat_send_all("Sample usage update called!")
end

minetest.register_node(name, {
    description = "Usage",
    tiles = {"^[colorize:#000000"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local n = NodeNetwork.IO_network(pos, "electricity")
        f_util.debug(n.nodes)
    end
})

NodeNetwork.register_usage_node("electricity", name, update, 150)