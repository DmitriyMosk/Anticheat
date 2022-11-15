local include_sv = (SERVER) and include or function() end
local include_cl = (SERVER) and AddCSLuaFile or include
local include_sh = function(f) include_sv(f) include_cl(f) end

local function include_dir(dir,state) 
    local files,dirs = file.Find(dir..'/*','LUA')
    for i,v in pairs(files) do 
        if ( v:find('.src') ) then continue end 
        if ( state == SERVER ) then 
            include_sv(dir..'/'..v)
        elseif ( state == CLIENT ) then 
            include_cl(dir..'/'..v)
        else        
            include_sh(dir..'/'..v)      
        end  
    end
end    

include_dir('e_modules/server',SERVER) 
include_dir('e_modules',CLIENT) 
