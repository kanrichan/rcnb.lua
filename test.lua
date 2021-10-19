---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-10-19 17:43:31
---@LastEditors: Kanri
---@LastEditTime: 2021-10-19 17:45:55
---@Description: test rcnb

rcnb = require("rcnb")
print(rcnb.encode(string.byte("测试", 1, -1)))
print(string.char(rcnb.decode(rcnb.encode(string.byte("测试", 1, -1)))))