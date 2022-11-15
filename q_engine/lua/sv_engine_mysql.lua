local connected = connected or false  
local db = db or db

hook.Add('Initialize', 'GAC.DataInit', function()
    db = easydata.MysqlConnect( 'anticheat_data' )  

    local q = [[
        CREATE TABLE IF NOT EXISTS player_detects(
            steamid VARCHAR(32), 
            name text, 
            ip text,
            reason text,
            info text,
            time int,
            PRIMARY KEY (steamid)
        );
    ]]

    if ( db ) then 
        GAC.ConsoleLog( 'Mysql connected successfully' )

        db:query_sync( q )
        connected = true  
    end   
end) 

GAC.data = {}

local errcod = GAC.config.errorcodes  

function GAC.data.StoredBan(tab) 
    if ( !connected ) then  
        GAC.Error(errcod['m0x1:c'])
        return  
    end   
    if ( !istable(tab) ) then 
        GAC.Error(errcod['t0x1:n'])
        return  
    end   
    db:query_ex('INSERT INTO `player_detects` (steamid,name,ip,reason,info,time) VALUES("?","?","?","?","?","?") ON DUPLICATE KEY UPDATE ip = VALUES(ip), reason = VALUES(reason), info = VALUES(info), name = VALUES(name)',tab)
end 

function GAC.data.IPSave(ip) 
    GAC.cache.ip[ip] = true  
end   

function GAC.data.SavedIP(ip) 
    return GAC.cache.ip[ip]
end 

GAC.cache.sB_users = {}

GAC.cache.sB_users['steamid'] = true  