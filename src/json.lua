local json = require "cjson"

function json.load( filename )
    local file, errorString = io.open( filename, "r" )
    if file then
        local contents = file:read( "*a" )
        local t = json.decode( contents )
        io.close( file )
        return t
    end
end

function json.save( t, filename )
    local file, errorString = io.open( filename, "w" )
    if file then
        file:write( json.encode( t ) )
        io.close( file )
        return true
    end
end 

return json
