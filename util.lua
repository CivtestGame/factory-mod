local function get_adjacent_nodes(pos, type)
    local return_pos = {}
    local posy = { x = pos.x, y = pos.y + 1, z = pos.z }
    local negy = { x = pos.x, y = pos.y - 1, z = pos.z }
    local posx = { x = pos.x + 1, y = pos.y, z = pos.z }
    local negx = { x = pos.x - 1, y = pos.y, z = pos.z }
    local posz = { x = pos.x, y = pos.y, z = pos.z + 1}
    local negz = { x = pos.x, y = pos.y, z = pos.z - 1}
    if minetest.get_node(posy).name == type then table.insert(return_pos, posy) end
    if minetest.get_node(negy).name == type then table.insert(return_pos, negy) end
    if minetest.get_node(posx).name == type then table.insert(return_pos, posx) end
    if minetest.get_node(negx).name == type then table.insert(return_pos, negx) end
    if minetest.get_node(posz).name == type then table.insert(return_pos, posz) end
    if minetest.get_node(negz).name == type then table.insert(return_pos, negz) end
    return return_pos
end

function f_util.find_neighbor_pipes(pos)
    return get_adjacent_nodes(pos, f_constants.pipe.name)
end

function f_util.find_neighbor_boilers(pos)
    return get_adjacent_nodes(pos, f_constants.boiler.name)
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