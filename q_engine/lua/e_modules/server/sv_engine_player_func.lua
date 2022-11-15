function GAC.GetPlayerIP(pl) 
    if ( !IsValid(pl) ) then return end

    local ip = pl:IPAddress() 
    if ( ip == 'loopback' ) then return '127.0.0.1' end   

    return ip:Split(":")[1]
end   

function GAC.GetPlayerIPPort(pl) 
    if ( !IsValid(pl) ) then return end

    local ip = pl:IPAddress() 
    if ( ip == 'loopback' ) then return 'localport' end   
    
    return ip:Split(":")[2] 
end 

function GAC.GetPlayerInfo(pl) 
    if ( !IsValid(pl) ) then return end  

    local info = {
        ['ip'] = GAC.GetPlayerIP(pl), 
        ['port'] = GAC.GetPlayerIPPort(pl), 
        ['steamid'] = pl:SteamID(), 
        ['steamid64'] = pl:SteamID64(),
        ['name'] = pl:Name(),
        ['lender'] = pl.LenderID or 'no'   
    }
    
    return info 
end    

function GAC.Detect(pl,reason,info)    
    if ( !IsValid(pl) ) then return end  

    if ( !pl.DoBan ) then  
        local getpunish = GAC.config[reason] or 'ban'

        if ( getpunish == 'nothing' or getpunish == 'off' ) then return end  

        local translate = GAC.config.translateban[reason] or reason  
        local displayban = GAC.config.translateban['displayreason']
        local years = tostring(math.random(50, 100))

        GAC.AdminLog('Detected A: %s Reason: %s',pl:Name(),translate)

        if ( GAC.config.enablewhitelist and ( GAC.config.whitelist[pl:SteamID()] or GAC.config.whitelist[pl:GetUserGroup()] ) ) then 
            return  
        end   

        GAC.data.IPSave(GAC.GetPlayerIP(pl)) 
        
        if ( getpunish == 'ban' or getpunish == 'sban' ) then 
            local tab = {
                pl:SteamID(), 
                pl:Name(), 
                GAC.GetPlayerIP(pl),
                translate, 
                util.TableToJSON(info),
                os.time()
            } 
            GAC.data.StoredBan(tab) 
        end  

        if ( !ULib and getpunish == 'ban' ) then 
            pl:Ban(years,displayban)  
        elseif ( !ULib and getpunish == 'kick' ) then 
            pl:Kick(displayban)
        elseif ( ULib and getpunish == 'ban' ) then 
            RunConsoleCommand('ulx', 'banid', pl:SteamID(), years..'y', displayban)
        elseif ( ULib and getpunish == 'sban' ) then  
            RunConsoleCommand('ulx', 'sbanid', pl:SteamID(), years..'y', displayban)
        elseif ( ULib and getpunish == 'kick' ) then  
            RunConsoleCommand('ulx', 'kick', pl:Name(), displayban)
        end  
        pl.DoBan = true 
    end   
end  

function GAC.AdminLog(s,...) 
    s = s:format(...)
    for _, pl in pairs ( player.GetAll() ) do
        if ( GAC.config.enableadminlog and ( GAC.config.logreceiver[pl:GetUserGroup()] or GAC.config.logreceiver[pl:SteamID()] ) ) then  
            net.Start'gac.client-adminlog'
                net.WriteString(s)
            net.Send(pl) 
        end   
    end  
end   