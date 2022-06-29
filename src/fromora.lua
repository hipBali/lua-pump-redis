package.path = "../src/?.lua;lua/?.lua;" .. package.path

local luasql = require "luasql.oci8"
local tor = require "toredis"
local json = require "json"

local m = {}

local con, env, cur

local includes, excludes

function m.connect(ct)
	env = assert (luasql.oci8())
	con = assert (env:connect(ct.service,ct.user,ct.password))
	return con, env
end

function m.disconnect()
	con:close()
	env:close()
end

local function cp_s_row(row)
	local r = {}
	for k,v in pairs(row) do
		r[k] = v
	end
	return r
end

function m.s_query(sql)
	cur = assert (con:execute(sql))
	local t = {}
	local row = cur:fetch ({},"a")	
	while row do
	  table.insert(t,cp_s_row(row))
	  row = cur:fetch (row, "a")	
	end
	cur:close()
	return t
end

local function cp_row(row, table_name)
	local r = {}
	for k,v in pairs(row) do
		r[k] = v
	end
	return r
end

function m.query(sql, table_name)
	cur = assert (con:execute(string.format(sql,table_name)))
	local t = {}
	local row = cur:fetch ({},"a")	
	while row do
	  table.insert(t,cp_row(row, table_name))
	  row = cur:fetch (row, "a")	
	end
	cur:close()
	return t
end

local function proc_ct(ct)
	if ct.includes then
		assert(type(ct.includes)=="table")
		local t = {}
		for k,v in pairs(ct.includes) do
			t[v:upper()] = 1
		end
		includes = t
	elseif ct.excludes then
		assert(type(ct.excludes)=="table")
		local t = {}
		for k,v in pairs(ct.excludes) do
			t[v:upper()] = 1
		end
		excludes = t
	end
end

function m.getOracleInfo(ct)
	proc_ct(ct)
	m.connect(ct)
	res = m.s_query(string.format("SELECT table_name FROM all_tables WHERE owner='%s'",ct.owner))
	local tables = {}
	for _,row in pairs(res) do 
		for _,tname in pairs(row) do
			if includes and not includes[tname:upper()] then break end
			if excludes and excludes[tname:upper()] then break end
			table.insert(tables,{name=tname:upper(), tablename=tname, index={}})
			local tid = #tables
			res2 = m.s_query(string.format(
				"select table_name, index_name,column_name,column_position from dba_ind_columns where table_name='%s' and table_owner= %s",
				tnametname:upper(), ct.owner))
			local indexes = {}
			for k,v in pairs(res2) do
				if v.INDEX_NAME:find("PK_") then v.INDEX_NAME = "pk" end
				indexes[v.INDEX_NAME] = indexes[v.INDEX_NAME] or {name=v.INDEX_NAME, segments={}}
				table.insert(indexes[v.INDEX_NAME].segments, v.COLUMN_NAME)
			end
			for k,v in pairs(indexes) do
				table.insert(tables[tid].index,v)
			end
			res2 = nil
			collectgarbage("collect")
		end
	end
	res = nil
	collectgarbage("collect")
	m.disconnect()
	return tables
end


function m.loadOracleModel(ct, model, callBackFunc)
	m.connect(ct)
	local desc = {}
	local base = {}
	local res = m.s_query(string.format(
		"select table_name name, num_rows size from dba_tables where owner = '%s'", ct.owner))
	
	local t_info = {}

	for k,v in pairs(res) do
		t_info[v.name:upper()] = tonumber(v.size)
	end

	local psize=ct.blocksize
	local abort
	for _,dt in pairs(model) do
		io.stderr:write(string.format("%s\n",dt.tablename))
		for i=0,t_info[dt.tablename:upper()],psize do
			res = m.query(string.format("SELECT * FROM %s WHERE ROWNUM>%d and ROWNUM<=%d",dt.tablename,i,i+psize), dt.tablename)
			if not res then
				abort = true
				break
			else
				tor.loadObjects(res,dt)
			end
			res = nil
			collectgarbage("collect")
		end
		if abort then
			break
		end
		desc[dt.name:upper()] = dt.index
		base[dt.name:upper()] = t_info[dt.name:upper()]
	end
	tor.getClient():set("base", json.encode(base))
	tor.getClient():set("desc", json.encode(desc))
	base = nil
	desc = nil
	m.disconnect()
end

return m