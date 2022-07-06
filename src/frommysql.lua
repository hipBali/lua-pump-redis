package.path = "../src/?.lua;lua/?.lua;" .. package.path

local luasql = require "luasql.mysql"
local tor = require "toredis"
local json = require "json"

local m = {}

local con, env, cur

local colTypes = {}
local includes, excludes

function m.connect(ct)
	env = assert (luasql.mysql())
	con = assert (env:connect(ct.database,ct.user,ct.password,ct.host,ct.port))
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
		r[k] = colTypes[table_name][k](v)
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

function m.getColTypes(table_name)
	cur = assert (con:execute(string.format("SELECT * FROM %s LIMIT 1", table_name)))
	local colts = cur:getcoltypes()
	local colns = cur:getcolnames()
	cur:close()
	colTypes[table_name] = {}
	for k,v in pairs(colts) do
	  local ft = v
	  if ft:find("number") then
		ft = tonumber
	  else
	    ft = tostring
	  end
	  colTypes[table_name][colns[k]] = ft	
	end
end

local function proc_ct(ct)
	if ct.includes then
		assert(type(ct.includes)=="table")
		local ix = {} 
		for k,v in pairs(ct.includes) do
			ix[v:upper()] = 1
		end
		includes = ix
	elseif ct.excludes then
		assert(type(ct.excludes)=="table")
		local ex = {}
		for k,v in pairs(ct.excludes) do
			ex[v:upper()] = 1
		end
		excludes = ex
	end
end

function m.getMySQLInfo(ct)
	proc_ct(ct)
	m.connect(ct)
	res = m.s_query("SHOW TABLES")
	local tables = {}
	for _,row in pairs(res) do 
		for _,tname in pairs(row) do
			if includes and includes[tname:upper()]==nil then break end
			if excludes and excludes[tname:upper()] then break end
			table.insert(tables,{name=tname:upper(), tablename=tname, index={}})
			local tid = #tables
			m.getColTypes(tname)
			if not ct.dataonly then
				res2 = m.s_query(string.format("SHOW INDEX FROM %s",tname), string.format("Tables_in_%s",tname))
				local indexes = {}
				for k,v in pairs(res2) do
					if v.Key_name == "PRIMARY" then v.Key_name = "pk" end
					indexes[v.Key_name] = indexes[v.Key_name] or {name=v.Key_name, segments={}}
					table.insert(indexes[v.Key_name].segments, v.Column_name)
				end
				for k,v in pairs(indexes) do
					table.insert(tables[tid].index,v)
				end
				res2 = nil
				collectgarbage("collect")
			end
		end
	end
	res = nil
	collectgarbage("collect")
	m.disconnect()
	return tables
end


function m.loadMySqlModel(ct, model, callBackFunc)
	m.connect(ct)
	local desc = {}
	local base = {}
	local res = m.s_query(string.format(
		"SELECT table_name AS name, table_rows AS size FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '%s'", ct.database))
	
	local t_info = {}
	for k,v in pairs(res) do
		t_info[v.name:upper()] = tonumber(v.size)
	end

	local psize=ct.blocksize
	local abort
	for _,dt in pairs(model) do
		local size = t_info[dt.name]
		if size then
			io.stderr:write(string.format("%s - %d\n",dt.name, size))
			for i=0,size,psize do
				res = m.query(string.format("SELECT * FROM %s limit %d,%d",dt.tablename,i,i+psize), dt.tablename)
				if not res then
					abort = true
					break
				else
					tor.loadObjects(res,dt,ct.dataonly)
				end
				res = nil
				collectgarbage("collect")
			end
			if abort then
				break
			end
			desc[dt.name] = dt.index
			base[dt.name] = t_info[dt.name] 
		end
	end
	tor.getClient():set("base", json.encode(base))
	tor.getClient():set("desc", json.encode(desc))
	base = nil
	desc = nil
	m.disconnect()
end

return m