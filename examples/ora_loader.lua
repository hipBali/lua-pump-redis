package.path = "../src/?.lua;lua/?.lua;" .. package.path

local f_ora= require "fromora"
require "toredis"

local ct = {

	service = "myService",
	user = "myUser",
	password = "myPass",
	
	owner = "myDbOwner",

	-- maximum records to pump in one step
	blocksize = 300*1000,
	
	-- tables to process includes OR excludes
	includes = nil, 
	excludes = nil 
}
-----------------------------

local startTime = os.clock()

local model = f_ora.getOracleInfo(ct)
f_ora.loadOracleModel(ct, model )

local endTime = os.clock()
io.stderr:write( endTime - startTime )
io.stderr:write( "seconds \n" )