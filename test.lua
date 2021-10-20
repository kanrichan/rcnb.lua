---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-10-19 17:43:31
---@LastEditors: Kanri
---@LastEditTime: 2021-10-20 11:04:50
---@Description: test rcnb

local rcnb = require('src/rcnb')
-- encode ȐȼŃƅȓčƞÞƦȻƝƃŖć
print(rcnb:encode(string.byte('Who NB?', 1, -1)))
-- decode RCNB!
print(string.char(rcnb:decode('ȐĉņþƦȻƝƃŔć')))
