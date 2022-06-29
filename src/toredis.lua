package.path = "../src/?.lua;lua/?.lua;" .. package.path
pcall(require, "luarocks.require")
local redis = require 'redis'

local params = {
    host = '127.0.0.1',
    port = 6379,
}
local client = redis.connect(params)
----------------------------------------------------
local json = require "json"

r = {}

function r.getClient()
	return client
end

function r.getInfo()
	local base = client:get("base")
	local desc = client:get("desc")
	return base, desc
end

function r.toIndex(record,index)
	local idx = nil
	if type(index)=="table" then
		local ix = {}
		local r = record
		-- unique index passing
		r = record
		for n = 1,#index.segments do
			table.insert(ix,tostring(r[index.segments[n]]))
		end
		idx = table.concat(ix,"-")
	end
	return idx
end

function r.loadIndex(n,rec,td)
	local o_index = n 
	if td.index then
		local i_name,ix 
		local set = {}
		for _,idsc in pairs(td.index) do
			i_name = idsc.name
			ix = r.toIndex(rec,idsc)
			client:sadd(string.format("%s:%s:%s",td.name,i_name, ix), o_index )
		end
	end
end

function r.loadObjects(t,td)
	local n = 0
	for _,rec in pairs(t) do
		n = n + 1
		client:set(string.format("%s:%d",td.name,n),json.encode(rec))
		if not dtonly then
			r.loadIndex(n,rec,td)
		end
	end
	return n -- records processed
end

function r.addIndex(td)
	local base = json.decode(client:get("base"))
	td.name = td.name:upper()
	local size = base[td.name]
	assert(type(size)=="number", "Table doesn't exists!")
	for n=1,size do
		rec = client:get(string.format("%s:%d",td.name,n))
		r.loadIndex(n,rec,td)
	end
	local desc = json.decode(client:get("desc"))
	for k,v in pairs(td.index) do
		table.insert(desc[td.name], v)
	end
	client:set("desc", json.encode(desc))
end

function r.loadJsonModel(dbt_model,tagId)
	local desc = {}
	local base = {}
	for _,dt in pairs(dbt_model) do
		io.stderr:write(string.format("%s ",dt.name))
		local t =  json.load( dt.filename )
		dt.filename = nil
		if tagId then t = t[tagId] end
		dt.size = r.loadObjects(t,dt)
		desc[dt.name] = dt.index
		base[dt.name] = dt.size
		io.stderr:write(string.format("records: %d\n",dt.size))
		t = nil
		collectgarbage("collect")
	end
	client:set("base", json.encode(base))
	client:set("desc", json.encode(desc))
	base = nil
	desc = nil
	collectgarbage("collect")
end

return r
