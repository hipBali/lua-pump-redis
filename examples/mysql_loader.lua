package.path = "../src/?.lua;lua/?.lua;" .. package.path

--
-- apt-get install lua-sql-mysql
--

local f_mysql = require "frommysql"

local ct = {
	host = "127.0.0.1",
	port = 3306,
	database = "bikestore",
	user = "test",
	password = "test",

	-- maximum records to pump in one step
	blocksize = 500*1000,
	
	-- data pump W/wo index creation
	dataonly = false,
	
	-- tables to process includes OR excludes
	includes = nil, 
	excludes = nil
}
-----------------------------

local startTime = os.clock()
local endTime

local model = f_mysql.getMySQLInfo(ct)
f_mysql.loadMySqlModel(ct, model )

endTime = os.clock()
io.stderr:write( endTime - startTime )
io.stderr:write( "seconds \n" )