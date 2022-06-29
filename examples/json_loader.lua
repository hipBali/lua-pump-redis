
package.path = "../src/?.lua;lua/?.lua;" .. package.path

local tor = require "toredis"
-----------------------------

local db_model = require "bikestore_json.model"

local startTime = os.clock()

tor.loadJsonModel(db_model)

local endTime = os.clock()
io.stderr:write( endTime - startTime )
io.stderr:write( "seconds \n" )