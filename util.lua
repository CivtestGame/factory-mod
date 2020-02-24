---@type Position
f_util.map_max_pos = {x = 30928, y = 30928, z = 30928}
---@type Position
f_util.map_min_pos = {x = -30928, y = -30928, z = -30928}

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

function f_util.cdebug(o)
    minetest.chat_send_all(f_util.dump(o))
end

function f_util.dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. f_util.dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end