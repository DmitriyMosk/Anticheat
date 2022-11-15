local gc = {}

-- В БУДУЩЕМ: ПЛАНИРУЮ СДЕЛАТЬ ЭТОТ КОНФИГ НАЧАЛЬНЫМ, т.е. он будет установлен при первом запуске ( касается не всего, а может и всё ) 

    -- client config [Это можно редактировать]
    
    /* -- Данные для подключения к внешней дб, если в gc.datatype есть строка "tmysql" - [ДАННЫЕ ДОЛЖНЫ БЫТЬ ЗАПОЛНЕНЫ ОБЯЗАТЕЛЬНО]  */
    gc.tmysql = {
        hostname = 'phvservers.ru',
        username = 'a0230370_shurik',
        database = 'a0230370_detections', 
        password = 'F4WuBDW6',
        port = 3306 
    }
    
    /* -- Если файл будет загружен путём обхода sv_allowcslua 1 нужно ли античиту красть его? -- */
    gc.stealcheats = true 

    /* -- Игроки, которых не будет банить в случае обнаружения -- */
    gc.enablewhitelist = false    
    gc.whitelist = { -- steamid,usergroup
        ['STEAM_0:1:113627401'] = true
    }
    
    /* -- Игроки, который могут получать логи в реальном времени (отображаться будет в консоле) -- */
    gc.enableadminlog = true 
    gc.logreceiver = { -- steamid,usergroup
        ['superadmin'] = true,
        ['STEAM_0:1:113627401'] = true 
    }
    
    /* -- Тип ДБ для сохранения информации -- */
    /*
       #dataf - локальное дб [будет сохраняться в папку data/]
       #tmysql - внешнее дб 
    */

    gc.database = { --dataf
        eventlog = 'tmysql',  
        detectlog = 'tmysql'
    } 
    
    /* -- Включить ли проверку аккаунтов подключённых к SteamFamily ? -- */
    gc.familycheck = true  

    -- если людей будет банить без причины, поставь везде "nothing" (пример ниже) до последнего коментария , я сам разберусь  
        
        -- gc.checksource = 'nothing' - ЭТО ПРИМЕР

        -- ban,sban,kick,off,nothing  
        /*
            ban - юзеров будет банить через ULX
            sban - юзеров будет банить через SBAN  
            kick - юзеров будет кикать 
            off - модуль будет отключен 
            nothing - модуль будет работоспособен, но не будет ни банить, ни кикать 
        */ 
          
        /* -- Античит будет проверять местоположение загружаемых файлов -- */
        gc.checksource = 'ban'  
    
        /* -- Античит будет сверять местоположение файлов с gc.blockedsource(таблица ниже) -- */
        gc.blistsource = 'ban'   
         
        /* -- Некоторые люди пытаются обойти его путём отключения функций -- */ 
        gc.checkdetour = 'ban'  
        
        /* -- Античит будет отправлять пакеты клиенту для подтверждения работоспособности античита -- */ 
        gc.checkverify = 'kick'    -- Зачем бан?
        
        /* -- Если файл будет существовать на клиенте, он будет сверять его хеш с уже существующим -- */ 
        gc.verifyfiles = 'ban'  
    
        /* -- Есть особый список команд, которые являются динамическими для клиента их можно использовать в плохих целях, но я защитил это -- */
        gc.verifyluacmd = 'ban'  
        
        /* -- На сервере есть определённые функции, которые нуждаются в верификации RunString,CompileString,CompileFile -- */
        gc.verifyruncmd = 'ban'

        /* -- На сервере будет определённый список игроков, которые будут забанены изначально -- */
        gc.blacklist = 'ban'  -- это настраивается в файле sv_engine_mysql.lua 

        /* -- Какая мера наказания предполагается для игроков обходящих бан путём FamilySharing ? -- */ 
        gc.familyabuse = 'ban'
        
        /* -- Просто хуйта не трогай это)) --*/
        gc.ipbanned = 'ban'
    -- Всё выше до коментраия об отключении ты можешь отключить данные проверки  

    -- root config [Лучше не трогать это] 
    
    gc.eventlog = true

    gc.dataf = {
        dir = 'gac/',
        ['logs'] = {
            dir = 'logs/',
            file = '%s_eventlog.txt' 
        }, 
        ['detects'] = {
            dir = 'detects/',
            file = 'player_%s.json'
        },
        ['cheats'] = {
            dir = 'stealed/%s',
            file = 'stealed_%s.txt'
        }
    }

    gc.globalsource = {
        ['[C]'] = true,  
        ['RunString'] = true, 
        ['LuaCmd'] = true, 
        ['Startup'] = true
    } 
    
    gc.blockedsource = {   -- тут просто база данных. 
        ['external'] = true,   
        [''] = true, -- empty source
    }

    gc.badfragments = {
        ['require'] = { 
            ['f'] = {
                ['stringtables'] = '#bad',
                ['html'] = '#good',
                ['notifycation'] = '#good',
            }
        }, -- (str name) 
        ['CompileFile'] = {
           ['badf'] = true  
        }, -- (str path)
        ['CompileString'] = {
            ['source'] = 'RunString',
        }, -- (string code, string identifier, boolean HandleError=true)
        ['RunString'] = {
            ['source'] = 'RunString',
        } -- (string code, string identifier="RunString", boolean handleError=true)
    };
    gc.badfragments['RunStringEx'] = {
        [1] = gc.badfragments['RunString'][1],
        [2] = gc.badfragments['RunString'][2]
    } -- what?
    
    gc.translateban = {      -- подумать
        ['displayreason'] = '[G] Bad signatures Detected',
        ['blistsource'] = 'Signature bad source detections',
        ['checksource'] = 'Unknown source detection',
        ['checkdetour'] = 'Function address change detected', 
        ['checkverify'] = 'Verifycation filed',
        ['verifyluacmd'] = 'Unverified LuaCmd running',
        ['verifyfiles'] = 'Unverified file hash detected',
        ['verifyruncmd'] = 'Bad string signatures detected',
        ['blacklist'] = 'You have been banned',
        ['familyabuse'] = 'Ban ban through familysharing is prohibited',
        ['ipbanned'] = 'Bypass ban by changing account'
    } 

    gc.errorcodes = {
        ['t0x1:n'] = 'Error type value it`s not table.', 
        ['t0x2:e'] = 'Table error value. It`s is empty table.', 
        ['m0x1:c'] = 'Error mysql query. DB connection filed.', 
    }
    
    gc.failed = {
        ['decrypt'] = 3, 
        ['receive'] = 5 
    }

return gc