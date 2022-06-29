package.path = "../src/?.lua;lua/?.lua;" .. package.path

local tor = require "toredis"
-----------------------------

local base, desc = tor.getInfo()

print(base)
print("--------------------------")
print(desc)
