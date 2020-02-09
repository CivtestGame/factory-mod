---@param node_name string
---@param types string[]
---@return boolean
local function same_type(node_name, types)
    for _, type in pairs(types) do
        if node_name == type then return true end
    end
end
--Type is an optional filter
---@param pos Position
---@param type string[]
function f_util.get_adjacent_nodes(pos, types)
    local return_pos = {}
    local posy = { x = pos.x, y = pos.y + 1, z = pos.z }
    local negy = { x = pos.x, y = pos.y - 1, z = pos.z }
    local posx = { x = pos.x + 1, y = pos.y, z = pos.z }
    local negx = { x = pos.x - 1, y = pos.y, z = pos.z }
    local posz = { x = pos.x, y = pos.y, z = pos.z + 1}
    local negz = { x = pos.x, y = pos.y, z = pos.z - 1}
    if types then
        if same_type(minetest.get_node(posy).name,types) then table.insert(return_pos, posy) end
        if same_type(minetest.get_node(negy).name,types) then table.insert(return_pos, negy) end
        if same_type(minetest.get_node(posx).name,types) then table.insert(return_pos, posx) end
        if same_type(minetest.get_node(negx).name,types) then table.insert(return_pos, negx) end
        if same_type(minetest.get_node(posz).name,types) then table.insert(return_pos, posz) end
        if same_type(minetest.get_node(negz).name,types) then table.insert(return_pos, negz) end
    else
        return_pos = {posy,negy,posx,negx,posz,negz}
    end
    return return_pos
end

f_util.map_max_pos = {x = 30928, y = 30928, z = 30928}
f_util.map_min_pos = {x = -30928, y = -30928, z = -30928}

function f_util.find_neighbor_pipes(pos)
    return f_util.get_adjacent_nodes(pos, {f_constants.pipe.name})
end

function f_util.find_neighbor_boilers(pos)
    return f_util.get_adjacent_nodes(pos, {f_constants.boiler.name})
end

function f_util.is_same_pos(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

function f_util.get_min_pos(pos1,pos2)
    return {x = math.min(pos1.x, pos2.x),y = math.min(pos1.y, pos2.y),z = math.min(pos1.z, pos2.z)}
end

function f_util.get_max_pos(pos1,pos2)
    return {x = math.max(pos1.x, pos2.x),y = math.max(pos1.y, pos2.y),z = math.max(pos1.z, pos2.z)}
end

function f_util.debug(o)
    minetest.debug(f_util.dump(o))
end

function f_util.dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end