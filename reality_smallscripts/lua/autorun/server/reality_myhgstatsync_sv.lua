/*
 * This addon was checked for any sensitive or revealing information
 * that could be potentially harmful towards our users. If you, the 
 * reader, see ANY potentially sensitive, revealing, or harmful information
 * or data in this addon or anywhere else in this repository, please
 * immediately reach out through a pull request or to our staff members.
 *
 * In addition, please remember that these addons were made over the
 * course of several years, and have altered significantly compared
 * to their original state. They very well may not work in the presence
 * of other community addons, and likely will not function properly
 * unless loaded alongside other addons in this collection. We will
 * provide zero support, guidance, or troubleshooting to anyone having
 * difficulty with these addons, so please use at your own risk. 
 *
 * Some information was omitted from this file.
*/

// ~reality (squarebush#0001)
// TODO: uncomment all -- lines
if SERVER then 

    util.AddNetworkString('reality_myhgstatssync_initial');
    util.AddNetworkString('reality_myhgstatssync_request');
    util.AddNetworkString('reality_myhgstatssync_print');

    // constants & configurables
    local secondsBetweenUpdates = 600    // the amount of seconds between looping through all connected players and syncing their stats
    local secondsBetweenRetry = 60      // the amount of seconds between connection retries if the db becomes disconnected
    local maxRetry = 4                  // the maximum amount of times the script will try to reconnect to the db
    local currentRetry = 0              // counter for the current retry that we're on
    local db = mysqloo.connect(         // database object (duh)
        '(OMITTED)', 
        '(OMITTED)', 
        '(OMITTED)',
        '(OMITTED)',
        3306
    )

    // helper func to make sure our connection hasn't been lost
    local function verifyConnection() 
        if db:status() == mysqloo.DATABASE_NOT_CONNECTED then 
            db:connect()
        end 
    end 

    // helper func that's the same as saPrint but for all admins, not just superadmins
    local function aPrint(...)
        local arg = { ... }
        for k, v in ipairs(player.GetHumans()) do
            if v:IsAdmin() then 
                --v:ChatPrint('[ADMIN] ' .. unpack(arg))
            end 
        end
    end 

    // helper func to more easily print to all connected superadmins and above
    local function saPrint(...)
        local arg = { ... }
        for k, v in ipairs(player.GetHumans()) do
            if v:IsSuperAdmin() then 
                --v:ChatPrint('[!SADMIN!] ' .. unpack(arg))
            end 
        end
    end 

    // set up a player queue and add players on initialspawn so we are sure we only call once for each player
    local queuedPlayers = {}
    hook.Add('PlayerInitialSpawn', 'reality_myhgstatsync_initialJoinInsert', function(ply)
        queuedPlayers[ply:SteamID64()] = true
    end)

    // use the player meta table to more modularly interact with database and its utilities
    local meta = FindMetaTable('Player')

    // pretty print stuff for our client
    function meta:MyHGPrint(str, err)
        if err == nil || (err != 1 || er != 0) then err = 0 end 

        // write and send our arguments
        net.Start('reality_myhgstatssync_print')
            net.WriteString(str)
            net.WriteBit(err)
        net.Send(self)        
    end 

    // create our meta function ONLY for the first initial sync of a player's stats (on first spawn)
    function meta:MyHGSyncInitial() 
        // disallow bots from being synced
        if self:IsBot() then return end 

        // if for some reason we our S64 isn't initialized, don't proceed
        if not self:SteamID64() then return end 

        // only allow players that are in the queue to sync initially
        if queuedPlayers[self:SteamID64()] == true then 
            queuedPlayers[self:SteamID64()] = nil 

            local escNick = '\'' .. db:escape(self:Nick()) .. '\''  // our escaped nickname
            local curTime = os.time()                               // the current os time (for last join)
            local playtime = tonumber(self:GetUTimeTotalTime())     // seconds of playtime
            local group = '\'' .. self:GetUserGroup() .. '\''       // ulx usergroup
            local qStr = 'INSERT INTO myhg_player_info (steamid64, lastnick, lastjoin, playtime, ulxgroup) VALUES (\'' 
                .. self:SteamID64() .. '\', '
                .. escNick .. ', '
                .. curTime .. ', '
                .. playtime .. ', '
                .. group .. ') ON DUPLICATE KEY UPDATE ' // https://stackoverflow.com/questions/6107752/how-to-perform-an-upsert-so-that-i-can-use-both-new-and-old-values-in-update-par
                .. 'lastnick = ' .. escNick .. ', '
                .. 'lastjoin = ' .. curTime .. ', '
                .. 'playtime = ' .. playtime .. ', '
                .. 'ulxgroup = ' .. group .. ';'

            // insert or update on first join
            local q = db:query(qStr)

            // if we have a problem, notify the player
            q.onError = function(_, err, sql)
                ErrorNoHalt('SQL Error on initial sync, query:\n' .. sql .. '\nError:\n' .. err .. '\n')
                self:MyHGPrint('Your MyHG sync request failed. Please rejoin and contact a manager or developer if this reoccurs.', 1)
                aPrint('The player ' .. self:Nick() .. ' (' .. self:SteamID64() .. ') had their initial sync request fail.')
            end

            // success callback func
            q.onSuccess = function(_, _)
                net.Start('reality_myhgstatssync_initial')
                net.Send(self)
                self:MyHGPrint('Your MyHG stats were initially synced.')
                self.MyHGEntryExists = true
            end 

            // make sure our db connection is valid and then start the query
            verifyConnection()
            q:start()
        else 
            local warn = 'Player ' .. self:Nick() .. ' (' .. self:SteamID64() .. ') sent MyHG sync request after being dequeued, this is suspicious.'
            MsgC(Color(255, 0, 0), warn)
            saPrint(warn)
        end
    end

    // this meta function is for any sync request, not just for first join
    // this differs from Player:MyHGSyncInitial in that this function does not 
    // update the lastjoin field
    function meta:MyHGSync() 
        // disallow bots
        if self:IsBot() then return end 

        // if for some reason we our S64 isn't initialized, don't proceed
        if not self:SteamID64() then return end 

        // ensure this user has an entry in our sql db, otherwise we will get sql update error
        if not self.MyHGEntryExists then
            self:MyHGPrint('Your initial sync either errored or was not processed correctly, doing that now...')
            queuedPlayers[self:SteamID64()] = true
            self:MyHGSyncInitial()

            // don't sync again if we just synced them, waste of resources
            return
        end 

        local escNick = '\'' .. db:escape(self:Nick()) .. '\''
        local playtime = tonumber(self:GetUTimeTotalTime())
        local group = '\'' .. self:GetUserGroup() .. '\''
        local qStr = 'UPDATE myhg_player_info SET '
            .. 'lastnick = ' .. escNick
            .. ', playtime = ' .. playtime
            .. ', ulxgroup = ' .. group
            .. ' WHERE steamid64 = \'' .. self:SteamID64() .. '\';'

        // insert or update on first join
        local q = db:query(qStr)

        // notify the player and admins if we have a problem
        q.onError = function(_, err, sql)
            ErrorNoHalt('SQL Error on routine sync, query:\n' .. sql .. '\nError:\n' .. err .. '\n')
            self:MyHGPrint('Your MyHG sync request failed. Contact a manager or developer if this reoccurs.', 1)
            aPrint('The player ' .. self:Nick() .. ' (' .. self:SteamID64() .. ') had their initial sync request fail.')
        end

        // notify the player if their stats were updated
        q.onSuccess = function(_, data)
            PrintTable(data)
            self:MyHGPrint('Your MyHG stats were synced.')
        end 

        // make sure our db connection is valid and then start the query
        verifyConnection()
        q:start()
    end

    // call Player:MyHGSyncInitial() when the player first joins
    net.Receive('reality_myhgstatssync_initial', function(_, ply)
        ply:MyHGSyncInitial()
    end)

    // callback for database successful connection
    db.onConnected = function(db)
        MsgC(Color(156, 199, 255), 'MyHG DB connection success\n')

        // start our timer to update everyone's stats
        if timer.Exists('myhgstatsync_update') then timer.Remove('myhgstatsync_update') end 
        timer.Create('myhgstatsync_update', secondsBetweenUpdates, 0, function()
            for k, v in ipairs(player.GetHumans()) do
                v:MyHGSync()
            end
        end)
    end 

    // callback for database connection error
    db.onConnectionFailed = function(db, err)
        MsgC(Color(255, 60, 60), 'MyHG DB connection failed:\n')
        ErrorNoHalt(err)
        print('\n')

        // notify superadmins
        saPrint('[SADMIN] MyHG db has failed to connect! This is attempt #' .. currentRetry .. ". Contact someone with DB perms if this persists.")
        
        // only retry if we haven't hit our limit
        if currentRetry < maxRetry then
            print('Retrying MyHG DB connection in ' .. secondsBetweenRetry .. ' seconds')
            timer.Simple(secondsBetweenRetry, function()
                currentRetry = currentRetry + 1
                db:connect()
            end)
        else 
            // notify superadmins
            saPrint('[SADMIN] MyHG db has reached max reconnect retries! Contact someone with DB perms.')
        end
    end

    // we've gotta knock over the first domino! the callback associated with this method call kick-starts the whole thing.
    db:connect()

end 