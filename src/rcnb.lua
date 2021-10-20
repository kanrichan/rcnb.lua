---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-10-18 12:42:44
---@LastEditors: Kanri
---@LastEditTime: 2021-10-20 10:28:05
---@Description: Everything can be ecnoded into crNB with Lua.

local insert, concat = table.insert, table.concat
local unpack, pack = table.unpack, table.pack

local RCNB = {
    cr = {'r', 'R', 'Ŕ', 'ŕ', 'Ŗ', 'ŗ', 'Ř', 'ř', 'Ʀ', 'Ȑ', 'ȑ', 'Ȓ', 'ȓ', 'Ɍ', 'ɍ'},
    cc = {'c', 'C', 'Ć', 'ć', 'Ĉ', 'ĉ', 'Ċ', 'ċ', 'Č', 'č', 'Ƈ', 'ƈ', 'Ç', 'Ȼ', 'ȼ'},
    cn = {'n', 'N', 'Ń', 'ń', 'Ņ', 'ņ', 'Ň', 'ň', 'Ɲ', 'ƞ', 'Ñ', 'Ǹ', 'ǹ', 'Ƞ', 'ȵ'},
    cb = {'b', 'B', 'ƀ', 'Ɓ', 'ƃ', 'Ƅ', 'ƅ', 'ß', 'Þ', 'þ'},
    mr = {},
    mc = {},
    mn = {},
    mb = {}
}

local const = {
    sr = #RCNB.cr,
    sc = #RCNB.cc,
    sn = #RCNB.cn,
    sb = #RCNB.cb,
    src = #RCNB.cr * #RCNB.cc,
    snb = #RCNB.cn * #RCNB.cb,
    scnb = #RCNB.cc * #RCNB.cn * #RCNB.cb
}

-- @function init decode
function RCNB:init()
    for i, v in ipairs(self.cr) do
        self.mr[v] = i
    end
    for i, v in ipairs(self.cc) do
        self.mc[v] = i
    end
    for i, v in ipairs(self.cn) do
        self.mn[v] = i
    end
    for i, v in ipairs(self.cb) do
        self.mb[v] = i
    end
end

-- @function div two param
-- @param a number
-- @param b number
-- @return number
function RCNB.div(a, b)
    return math.floor(a / b)
end

-- @function slpit rcnb to rune
-- @param str rcnb string
-- @return rcnb rune array
function RCNB.split(str)
    local bytes = pack(string.byte(str, 1, -1))
    local skip = false
    local array = {}
    for i = 1, #bytes do
        if skip then
            skip = false
            -- double byte
            insert(array, string.char(bytes[i - 1], bytes[i]))
        elseif bytes[i] >= 192 and bytes[i] < 223 then
            skip = true
        elseif bytes[i] >= 0 and bytes[i] < 192 then
            -- single byte
            insert(array, string.char(bytes[i]))
        else
            error('length not nb')
        end
    end
    return array
end

-- @function covert bytes to rcnb
-- @param ... bytes need to encode
-- @return rcnb string
function RCNB:encode(...)
    local bytes = pack(...)
    local builder = {}
    local length = #bytes
    for i = 1, length >> 1, 1 do
        -- encode short
        local value = (bytes[i * 2 - 1] << 8) | bytes[i * 2]
        if value > 0xFFFF or value < 0 then
            error('overflow')
        elseif value > 0x7FFF then
            value = value & 0x7FFF
            insert(builder, self.cn[self.div(value % const.snb, const.sb) + 1])
            insert(builder, self.cb[value % const.sb + 1])
            insert(builder, self.cr[self.div(value, const.scnb) + 1])
            insert(builder, self.cc[self.div(value % const.scnb, const.snb) + 1])
        else
            insert(builder, self.cr[self.div(value, const.scnb) + 1])
            insert(builder, self.cc[self.div(value % const.scnb, const.snb) + 1])
            insert(builder, self.cn[self.div(value % const.snb, const.sb) + 1])
            insert(builder, self.cb[value % const.sb + 1])
        end
    end
    if length & 1 == 1 then
        -- encode byte
        local value = bytes[length]
        if value > 0xFF or value < 0 then
            error('overflow')
        elseif value > 0x7F then
            value = value & 0x7F
            insert(builder, self.cr[self.div(value, const.sb) + 1])
            insert(builder, self.cb[value % const.sb + 1])
        else
            insert(builder, self.cr[self.div(value, const.sc) + 1])
            insert(builder, self.cc[value % const.sc + 1])
        end
    end
    return concat(builder, '')
end

-- @function covert rcnb to bytes
-- @param str string need to decode
-- @return data
function RCNB:decode(str)
    local array = self.split(str)
    local length = #array
    local bytes = {}
    for i = 0, (length >> 2) - 1 do
        -- decode short
        local idx = {}
        local reverse = self.mr[array[i * 4 + 1]] == nil
        if reverse then
            idx[1] = self.mr[array[i * 4 + 3]]
            idx[2] = self.mc[array[i * 4 + 4]]
            idx[3] = self.mn[array[i * 4 + 1]]
            idx[4] = self.mb[array[i * 4 + 2]]
        else
            idx[1] = self.mr[array[i * 4 + 1]]
            idx[2] = self.mc[array[i * 4 + 2]]
            idx[3] = self.mn[array[i * 4 + 3]]
            idx[4] = self.mb[array[i * 4 + 4]]
        end
        if idx[1] == nil or idx[2] == nil or idx[3] == nil or idx[4] == nil then
            error('not enough nb')
        end
        local result = (idx[1] - 1) * const.scnb + (idx[2] - 1) * const.snb + (idx[3] - 1) * const.sb + (idx[4] - 1)
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
        local idx1 = self.mr[array[length - 1]]
        local idx2 = self.mc[array[length]]
        if idx1 == nil or idx2 == nil then
            idx1 = self.mn[array[length - 1]]
            idx2 = self.mb[array[length]]
            isnb = true
        end
        if isnb then
            insert(bytes, ((idx1 - 1) * const.sb + (idx2 - 1)) | 0x80)
        else
            insert(bytes, (idx1 - 1) * const.sc + (idx2 - 1))
        end
    end
    return unpack(bytes)
end

-- init decode
RCNB:init()

return RCNB
