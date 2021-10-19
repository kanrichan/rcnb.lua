---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-10-18 12:42:44
---@LastEditors: Kanri
---@LastEditTime: 2021-10-19 18:43:58
---@Description: Everything can be ecnoded into crNB with Lua.

local insert, concat = table.insert, table.concat

local cr = {'r', 'R', 'Ŕ', 'ŕ', 'Ŗ', 'ŗ', 'Ř', 'ř', 'Ʀ', 'Ȑ', 'ȑ', 'Ȓ', 'ȓ', 'Ɍ', 'ɍ'}
local cc = {'c', 'C', 'Ć', 'ć', 'Ĉ', 'ĉ', 'Ċ', 'ċ', 'Č', 'č', 'Ƈ', 'ƈ', 'Ç', 'Ȼ', 'ȼ'}
local cn = {'n', 'N', 'Ń', 'ń', 'Ņ', 'ņ', 'Ň', 'ň', 'Ɲ', 'ƞ', 'Ñ', 'Ǹ', 'ǹ', 'Ƞ', 'ȵ'}
local cb = {'b', 'B', 'ƀ', 'Ɓ', 'ƃ', 'Ƅ', 'ƅ', 'ß', 'Þ', 'þ'}

local sr = #cr
local sc = #cc
local sn = #cn
local sb = #cb
local src = sr * sc
local snb = sn * sb
local scnb = sc * snb

local mr = {}
local mc = {}
local mn = {}
local mb = {}

for i, v in ipairs(cr) do
    mr[v] = i - 1
end

for i, v in ipairs(cc) do
    mc[v] = i - 1
end

for i, v in ipairs(cn) do
    mn[v] = i - 1
end

for i, v in ipairs(cb) do
    mb[v] = i - 1
end

local function div(a, b)
    return math.floor(a / b)
end

-- @function covert bytes to rcnb
-- @param ... bytes need to encode
-- @return rcnb string
function ecnode(...)
    local bytes = table.pack(...)
    local builder = {}
    local length = #bytes
    for i = 1, length >> 1, 1 do
        -- encode short
        local value = (bytes[i * 2 - 1] << 8) | bytes[i * 2]
        if value > 0xFFFF then
            error('overflow')
        end
        if value > 0x7FFF then
            value = value & 0x7FFF
            insert(builder, cn[div(value % snb, sb) + 1])
            insert(builder, cb[value % sb + 1])
            insert(builder, cr[div(value, scnb) + 1])
            insert(builder, cc[div(value % scnb, snb) + 1])
        else
            insert(builder, cr[div(value, scnb) + 1])
            insert(builder, cc[div(value % scnb, snb) + 1])
            insert(builder, cn[div(value % snb, sb) + 1])
            insert(builder, cb[value % sb + 1])
        end
    end
    if length & 1 == 1 then
        -- encode byte
        local value = bytes[length]
        if value > 0xFF then
            error('overflow')
        end
        if value > 0x7F then
            value = value & 0x7F
            insert(builder, cr[div(value, sb) + 1])
            insert(builder, cb[value % sb + 1])
        else
            insert(builder, cr[div(value, sc) + 1])
            insert(builder, cc[value % sc + 1])
        end
    end
    return concat(builder, '')
end

local function split(str)
    local bytes = {string.byte(str, 1, -1)}
    local skip = false
    local array = {}
    for i = 1, #bytes do
        if skip then
            skip = false
            insert(array, string.char(bytes[i - 1], bytes[i]))
        elseif bytes[i] >= 192 and bytes[i] < 223 then
            skip = true
        elseif bytes[i] >= 0 and bytes[i] < 192 then
            insert(array, string.char(bytes[i]))
        else
            error('length not nb')
        end
    end
    return array
end

-- @function covert rcnb to bytes
-- @param str string need to decode
-- @return data
function decode(str)
    local array = split(str)
    local length = #array
    local bytes = {}
    for i = 0, (length >> 2) - 1 do
        -- decode short
        local idx = {}
        local reverse = mr[array[i * 4 + 1]] == nil
        if reverse then
            idx[1] = mr[array[i * 4 + 3]]
            idx[2] = mc[array[i * 4 + 4]]
            idx[3] = mn[array[i * 4 + 1]]
            idx[4] = mb[array[i * 4 + 2]]
        else
            idx[1] = mr[array[i * 4 + 1]]
            idx[2] = mc[array[i * 4 + 2]]
            idx[3] = mn[array[i * 4 + 3]]
            idx[4] = mb[array[i * 4 + 4]]
        end
        if idx[1] == nil or idx[2] == nil or idx[3] == nil or idx[4] == nil then
            error('not enough nb')
        end
        local result = idx[1] * scnb + idx[2] * snb + idx[3] * sb + idx[4]
        if result > 0x7FFF then
            error('overflow')
        end
        if reverse then
            result = result | 0x8000
        end
        insert(bytes, result >> 8)
        insert(bytes, result & 0xFF)
    end
    if length & 2 == 2 then
        -- decode byte
        local isnb = false
        local idx1 = mr[array[length - 1]]
        local idx2 = mc[array[length]]
        if idx1 == nil or idx2 == nil then
            idx1 = mn[array[length - 1]]
            idx2 = mb[array[length]]
            isnb = true
        end
        if isnb then
            insert(bytes, (idx1 * sb + idx2) | 0x80)
        else
            insert(bytes, idx1 * sc + idx2)
        end
    end
    return table.unpack(bytes)
end

return {
    encode = ecnode,
    decode = decode
}
