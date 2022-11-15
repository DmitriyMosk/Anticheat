local b = net 
-- проверить friendly

function GAC.VerifyLuaCmd(pl,source,hash,bytecode)
    if ( pl._SendingLua and pl._SendingLua > 0 ) then 
        pl._SendingLua = pl._SendingLua - 1  
    else      
        GAC.Detect( pl, 'verifyluacmd', { 
            ['c'] = 'Count: '..tostring(pl._SendingLua)
        } )
    end  
end

function GAC.VerifySource(pl,source,bytecode,hash)
    print(source,bytecode,hash)
    local rhash = util.CRC(file.Read(source, 'GAME') or '')  
    
    if ( GAC.config.verifyluacmd ~= 'off' and source == 'LuaCmd' ) then 
        GAC.VerifyLuaCmd(pl) 
        return true  
    end  

    if( GAC.config.blistsource ~= 'off' and GAC.config.blockedsource[source:Trim()] ) then 
        GAC.Detect( pl, 'blistsource', {
            ['src'] = source, ['bc'] = bytecode,
        } ) 
        return true  
    end   
    
    if ( GAC.config.verifyfiles ~= 'off' and hash ~= '0' ) then 
        if ( hash == rhash ) then return true end   
        if ( GAC.config.stealcheats ) then 
            pl.StealFile = true 
    
            pl.DetectInfo = { ['src'] = source, ['bc'] = bytecode, ['hash'] = hash, ['rhash'] = rhash }
            
            b.Start'gac.client-getfile' 
                b.WriteString(source)
            b.Send(pl)
        end  
        if ( !pl.StealFile ) then  
            GAC.Detect( pl, 'verifyfiles', {
                ['src'] = source, ['bc'] = bytecode, ['hash'] = hash, ['rhash'] = rhash
            } )  
        end    
        return true 
    end  
    
    if ( file.Exists(source, 'MOD') ) then return true end 

    if( GAC.config.checksource ~= 'off' and !GAC.config.globalsource[source] ) then  -- зачем exists? Если файл есть на сервере -> его путь по любым случаям не будет подоходить к таблице
        GAC.Detect( pl, 'unknownsource', {
            ['src'] = source, ['bc'] = bytecode, ['hash'] = hash, ['rhash'] = rhash
        } )
        return true    
    end  
     
    return false  
end  

b.Receive('gac.server-verifysource', function(len,pl)
    local t = net.ReadTable()
    GAC.VerifySource(pl,t[1],t[2],t[3])
end)  

b.Receive('gac.client-getfile',function(len,pl)
    if ( !pl.StealFile ) then return end  

    local s = net.ReadUInt(32) 
    local d = util.Decompress(net.ReadData(s)) 
    local fileID = util.CRC(d)
     
    GAC.FileData('rw','cheats',{ { pl:SteamID64() or '0', fileID },d })
    
    pl.Stealed = true  

    GAC.Detect( pl, 'verifyfile', pl.DetectInfo)
end)

b.Receive('gac.server-verifyruncmd',function(len,pl) 
    
    if ( GAC.config.verifyruncmd == 'off' ) then return end  

    local func = GAC.config.badfragments

    local s = net.ReadString()
    local t = net.ReadTable()  

    if ( !func[t.f] ) then 
        GAC.Error('Unknown detection func: %s | player: %s',t.f,pl:SteamID())
        return     
    end   

    t.s = t.s or func[t.f]['source']
    
    local result = GAC.VerifySource(pl,t.sr,0,t.h)
    
    if ( result ) then return end  

    local str_frag,detect,info = func[t.f]['f'][s],false,{}   
    
    if ( func[t.f]['badf'] or str_frag == '#bad') then 
        detect = true  
    end  
       
    if ( detect ) then 
        GAC.Detect( pl,'verifyruncmd', {
            func = t.f, frag = s, csrc = t.sr  
        } )    
    end    
end)

local meta = FindMetaTable('Player')

if (meta._SendLua == nil) then
	meta._SendLua = meta.SendLua
	function meta:SendLua(c)
        self._SendingLua = self._SendingLua or 0 
        self._SendingLua = self._SendingLua + 1 

		self:_SendLua(c)
	end
end
meta = nil

local _BroadcastLua = BroadcastLua
function BroadcastLua(...)
	for i,v in pairs(player.GetAll()) do
		v._SendingLua = v._SendingLua or 0  
        v._SendingLua = v._SendingLua + 1  
	end
	_BroadcastLua(...)
end

local _game_CleanUpMap = game.CleanUpMap
function game.CleanUpMap(...) 
	local args = {...}
	if (args[1] ~= true) then
		for i,v in pairs(player.GetAll()) do
		    v._SendingLua = v._SendingLua or 0  
            v._SendingLua = v._SendingLua + 1  
		end
	end
end

local function Encrypt(str, key)
	local output = ''
	
	local kbc = { string.byte(key,1,#key) } -- кажется, это трудоёмкий процесс
	
	local carry = 0
	for i = 1, #str do 
		local c = string.byte(str, i)
		c = bit.bxor (c,kbc[(i - 1) % #key + 1])
		c = bit.bxor (c,(carry + i) % 256)
		
		output = output .. GAC.cache.string_chars [c]
		
		carry = c
	end
	
	return output
end

hook.Add('PlayerAuthed','GAC.PlayerFirewall',function(pl,sid,uid)
    if ( !IsValid(pl) ) then return end
    
    if ( GAC.config.blacklist ~= 'off' and GAC.cache.sB_users[sid] ) then  
        GAC.Detect(pl,'blacklist',{})
    end   

    if ( GAC.config.ipbanned ~= 'off' and GAC.data.SavedIP(GAC.GetPlayerIP(pl)) ) then 
        GAC.Detect(pl,'ipbanned',{ ['last_ip'] = GAC.GetPlayerIP(pl) })
    end  

    if ( GAC.config.familyabuse ~= 'off' ) then 
        local fid = pl:GetLenderID()
        if ( !fid or fid == '0' ) then return end  

        if ( ULib.bans[fid] ) then 
            GAC.Detect(pl,'familyabuse',{['fid'] = fid})
        end  
        if ( GAC.config.blacklist and GAC.cache.sB_users[fid] ) then
            GAC.Detect(pl,'blacklist',{['fid'] = fid})
        end  
    end  
end) 

hook.Add('PlayerNetworkStart','GAC.StartPlayer',function(pl)
    if( GAC.config.checkverify == 'off' ) then return end  

    local timerName = 'gac.playertimer:'..pl:SteamID64()  

    if ( timer.Exists(timerName) ) then return end  
    timer.Create(timerName, 5, 0,function()                 
        if ( !IsValid(pl) ) then return end  

        pl.DecryptKey = GAC.GenerateRandomString(math.random(10, 15))
        pl.VerifyKey = GAC.GenerateRandomString(math.random(8, 14))  
         
        local vkey = Encrypt(pl.VerifyKey,pl.DecryptKey)

        if ( pl.VerifyStatus == 'wait' and !pl:IsTimingOut()) then   
            pl.FailedReceive = pl.FailedReceive or 0 
            pl.FailedReceive = pl.FailedReceive + 1

            if ( pl.FailedReceive > GAC.config.failed['receive'] ) then 
                GAC.Detect(pl,'checkverify')  
            end  
        else   
            if ( pl.FailedReceive and pl.FailedReceive > 0 ) then 
                pl.FailedVerify = 0
            end  
        end  
        
        b.Start'gac.client-signature'
            b.WriteString(pl.DecryptKey)
            b.WriteTable({string.byte(vkey,1,#vkey)})
        b.Send(pl)

        pl.VerifyStatus = 'wait' 
    end)  
end) 
--ulx unban STEAM_0:1:113627401
b.Receive('gac.client-signature',function(len,pl) 
    local key = b.ReadTable()
    local verifycateFunc1 = b.ReadBool() 
    local verifycateFunc2 = b.ReadBool() 
    local functionstrings = b.ReadString()  
    local functionsources = b.ReadString() 
    local functioncrchash = b.ReadString()  

    key = string.char(unpack(key)) -- writeString не способен нормально отправить строку, я перевожу её в биты

    pl.VerifyStatus = 'received'
    
    if ( key ~= pl.VerifyKey ) then 
        pl.FailedDecrypt = pl.FailedDecrypt or 0 
        pl.FailedDecrypt = pl.FailedDecrypt + 1   
        
        if ( pl.FailedDecrypt > GAC.config.failed['decrypt'] ) then
            GAC.Detect(pl,'checkverify',{
                ['deckey'] = pl.DecryptKey,
                ['svkey'] = pl.VerifyKey,   
                ['clkey'] = key
            })
        end   
    end      

    if ( GAC.config.checkdetour ~= 'off' ) then  
        if ( verifycateFunc1 ~= true and verifycateFunc2 ~= false ) then -- то бан а может просто бан?
            local result = GAC.VerifySource(pl,functionsources,0,functioncrchash)
             
            if ( result ) then return end  

            GAC.Detect(pl,'checkdetour',{
                ['func'] = functionstrings,
                ['src'] = functionsources 
            })
        end   
    end   
end)

hook.Add('PlayerDisconnected','GAC.EndPlayer',function(pl)
    local timerName = 'gac.playertimer:'..pl:SteamID64()
    if ( timer.Exists(timerName) ) then 
        timer.Remove(timerName)
    end  
end)