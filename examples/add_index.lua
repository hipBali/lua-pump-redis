package.path = "../src/?.lua;lua/?.lua;" .. package.path

local tor = require "toredis"
-----------------------------

local startTime = os.clock()
local endTime

tor.addIndex{
	name = "customers",   
	index = {
		{ name = "name_day", segments = {"first_name"} }
	}
}

endTime = os.clock()
io.stderr:write( endTime - startTime )
io.stderr:write( "seconds \n" )
