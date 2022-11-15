GAC = GAC or {
    cache = {
        ip = {},  
    }, 
}  
GAC.config = include'sv_engine_config.lua'

GAC.cache.string_chars = {} 
for i = 0, 255 do GAC.cache.string_chars[i] = string.char(i) end  

function GAC.ConsoleLog(str,...)   
    str = str:format(...)

    MsgC(Color(188, 0, 245),'[GAC] > ',Color(255,255,255),str,'\n')   
    
    if ( GAC.config.eventsave ) then  
 
    end  

    return str    
end   
 
function GAC.Error(str,...)   
    str = str:format(...)
    
    MsgC(Color(255,100,0),'[GAC-ERROR] > ',Color(255,50,0),str,'\n') 

    if ( GAC.config.eventlog ) then 
                
    end

    return str   
end   

local file_actions = {
    ['r'] = function(path)  -- Read
        return file.Read(path, 'DATA')
    end,  
    ['rw'] = function(path,info) -- ReWrite
        file.Write(path,info)
    end, 
    ['w'] = function(path,info) -- Write
        if ( !file.Exists(path, 'DATA') ) then  
            file.Write(path,info)
            return  
        end  
        file.Append(path,info..'\r')  
    end   
}

function GAC.FileData(a,id,data)  
    if ( !file_actions[a] ) then 
        GAC.Error('Unknown file action %s',a)
        return  
    end  
    
    local tpath = GAC.config.dataf[id]

    if ( !tpath or id == 'dir' ) then 
        GAC.Error('Unknown data ID %s',id) 
        return   
    end   

    local root = GAC.config.dataf.dir
    local path = root..tpath.dir..'/'..tpath.file
    
    if ( istable(data) ) then  
        path = path:format(unpack(data[1]))

        data = data[2]
    end  

    local dirs = string.GetPathFromFilename(path)

    if ( !file.IsDir(dirs, 'DATA') ) then 
        file.CreateDir(dirs)
    end  
    
    file_actions[a](path,data)
end  

function GAC.GenerateRandomString(len)
    local str = ""
    for i = 1, len do
      str = str .. GAC.cache.string_chars [math.random(33, 125)]
    end
    return str
end   

function GAC.SetupNetwork(nets) 
    for state,t in pairs( nets ) do
        for _,str in pairs( t ) do
            util.AddNetworkString('gac.'..state..'-'..str)
        end   
    end 
end    

GAC.SetupNetwork(
    {
        client = {
            'signature',
            --'player', -- for ban
            'adminlog', --gac.client-adminlog
            'getfile', 
            'callmenu'
        },
        server = {  
            'verifysource',
            'verifyruncmd'
        }
    }
) 

local bc_enc = function(str)  
    local ec = {str:byte(1, #str)}
    local cs,ks = '', {} -- вывод
        for i=1,#ec do 
            cs = cs .. ec[i]
            ks[i] = bit.tohex(#cs,2)
        end
    print(str,'__d2(\''..cs..'\',0x'..table.concat(ks, ',0x')..')')
    return cs,ks
end  

local newcrypt = {

}  

for i,v in pairs(newcrypt) do
    bc_enc(v)
end  

GAC.ConsoleLog('Loaded successfully')

include'sv_engine_mysql.lua'