f_constants.pipe = {name = minetest.get_current_modname()..":pipe", max_steam = 10}

local function get_pipe_networks()
    return minetest.deserialize(factory_mod_storage:get_string("pipe_networks")) or {}
end

local function save_pipe_networks(networks)
    factory_mod_storage:set_string("pipe_networks", minetest.serialize(networks))
end

local function create_new_pipe_network(pos, name)
    local new_network = {}
    new_network.min_pos = pos
    new_network.max_pos = pos
    new_network.steam_units = 0
    new_network.pipes = {pos}
    local networks = get_pipe_networks()
    if name == nil then -- THis code can probably be replaced with table.getn()
        local count = 0
        local new_name = true
        while new_name do
            count = count + 1
            if networks[count] == nil then new_name = false end
        end
        name = count
    end
    networks[name] = new_network
    save_pipe_networks(networks)
end

local function delete_pipe_network(network_key)
    local networks = get_pipe_networks()
    table.remove(networks, network_key)
    save_pipe_networks(networks)
end

local function add_to_pipe_network(pipe_pos, netowrk, network_key)
    network.min_pos = f_util.get_min_pos(network.min_pos, pipe_pos)
    network.max_pos = f_util.get_max_pos(network.max_pos, pipe_pos)
    table.insert(network.pipes, pipe_pos)
    pipe.save_pipe_network(network_key, network)
end

local function remove_pipe(pipe_pos) --TODO: Handle network splits
    local network,network_key = pipe.get_network_from_pos(pipe_pos)
    minetest.debug("Removing pipe at " .. f_util.dump(pipe_pos))
    if network ~= nil then
        --If yes, for every edge we are on, subtract 1
        local update_min = false
        local update_max = false
        --We might need these values if we have to upadte the min/max pos
        local new_min_pos = network.pipes[1]
        local new_max_pos = network.pipes[1]
        --Check if the pipe we are removing is on the edge of the network. If it is we will have to update the corresponding max/min position
        local x_diff = network.min_pos.x ~= network.max_pos.x
        local y_diff = network.min_pos.y ~= network.max_pos.y
        local z_diff = network.min_pos.z ~= network.max_pos.z
        if (x_diff and network.min_pos.x == pipe_pos.x) or (y_diff and network.min_pos.y == pipe_pos.y) or (z_diff and network.min_pos.z == pipe_pos.z) then update_min = true end
        if (x_diff and network.max_pos.x == pipe_pos.x) or (y_diff and network.max_pos.y == pipe_pos.y) or (z_diff and network.max_pos.z == pipe_pos.z) then update_max = true end
        minetest.debug("Update min/max is " .. tostring(update_min) .. tostring(update_max))
        for key,pipe in pairs(network.pipes) do
            if f_util.is_same_pos(pipe,pipe_pos) then
                table.remove(network.pipes, key)
            else
                if update_min then new_min_pos = f_util.get_min_pos(new_min_pos, pipe) end
                if update_max then new_max_pos = f_util.get_max_pos(new_max_pos, pipe) end
            end
        end
        minetest.debug(f_util.dump(new_min_pos))
        minetest.debug(f_util.dump(new_max_pos))
        if update_min then network.min_pos = new_min_pos end
        if update_max then network.max_pos = new_max_pos end
    end
    if table.getn(network.pipes) > 0 then pipe.save_pipe_network(network_key,network)
    else delete_pipe_network(network_key) end
end

local function pipe_affer_construct(pos,player) --Takes location of a new pipe and figures out what network to add it to
    local connected_pipes = f_util.find_neighbor_pipes(pos)
    if table.getn(connected_pipes) > 0 then
        if table.getn(connected_pipes) > 1 then --Check to see if there is more than one connected pipe
            minetest.chat_send_player(player:get_player_name(),"Nope! Too many pipes")
            return
        end
        local network, network_key = pipe.get_network_from_pos(connected_pipes[1])
        if network_key ~= nil then
            add_to_pipe_network(pos,network, network_key)
        else
            minetest.debug("Pipe on construct error! Check source code")
        end
    else -- No connected pipes 
        create_new_pipe_network(pos)
    end
end

--Start of global methods

function pipe.get_reg_values()
    return f_constants.pipe.name, {
        description = "Pipe",
        tiles = {"^[colorize:#3248a8"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            pipe_affer_construct(pos,placer)
        end,
        on_destruct = function (pos)
            remove_pipe(pos)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            minetest.chat_send_player(player:get_player_name(), "This pipe network contains " .. f_steam.get_steam(pos) .. " units of steam")
        end,
    }
end

function pipe.save_pipe_network(network_key, network)
    local networks = get_pipe_networks()
    networks[network_key] = network
    --minetest.debug("Saving this to pipe networks" .. f_util.dump(networks))
    save_pipe_networks(networks)
end

function pipe.get_network_key(pos)
    for key, network in pairs(get_pipe_networks()) do
        local networkArea = VoxelArea:new({MinEdge = network.min_pos, MaxEdge = network.max_pos})
        if networkArea:containsp(pos) then
            for _,pipe in pairs(network.pipes) do
                if f_util.is_same_pos(pipe,pos) then
                    return key
                end
            end
        end
    end
end

function pipe.get_network(network_key) -- We prefer this method as it is less resource intensive than the one underneath
    return get_pipe_networks()[network_key]
end

function pipe.get_network_from_pos(pos)
    local key = pipe.get_network_key(pos)
    return get_pipe_networks()[key], key
end

function pipe.get_max_steam(network)
        return table.getn(network.pipes)*f_constants.pipe.max_steam
end