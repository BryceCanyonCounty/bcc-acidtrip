-----------------Pulling Essentials------------------------
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

--This will be called if the chance determines only to give you the high screen effect
RegisterNetEvent('bcc-acidtrip:ScreenEffectOnly')
AddEventHandler('bcc-acidtrip:ScreenEffectOnly',function(effecttime) --catches var from serv
    AnimpostfxPlay('MP_BountyLagrasSwamp') --plays screen effect
    Wait(effecttime) --waits the set time in config
    AnimpostfxStopAll() --stops the effect
end)

--This will instance the player, teleport them to the set coords, and play the high anims
RegisterNetEvent('bcc-acidtrip:Open')
AddEventHandler('bcc-acidtrip:Open', function()
    local instanceNumber = 575132  --any number (can add more players to the instance by using this number on them)
    VORPcore.instancePlayers(tonumber(GetPlayerServerId(PlayerId()))+ instanceNumber) --this instances the player(basically puts him into a sort of solo session type deal)
    SetEntityCoords(PlayerPedId(), Config.PlayerWakeUpCoords.x, Config.PlayerWakeUpCoords.y, Config.PlayerWakeUpCoords.z) --teleports the player to the coords
    AnimpostfxPlay('PlayerWakeUpKnockout') --plays screen effect
    exports.weathersync:setMyTime(0, 0, 0, 0, 0, 1) --sets the time to midnight and freezes the time(this can be done and only effect the one player as the player has been instanced!)
    Citizen.Wait(7000) --waits 7 seconds
    AnimpostfxStop('PlayerWakeUpKnockout') --clears the effect
    AnimpostfxPlay('MP_BountyLagrasSwamp') --plays effect
    TriggerEvent('bcc-acidtrip:Wave1') --triggers event
end)

------Enemy Npc Waves setup!-------
--Wave 1
RegisterNetEvent('bcc-acidtrip:Wave1')
AddEventHandler('bcc-acidtrip:Wave1', function()
    local model = GetHashKey('re_fleeingfamily_males_01') --sets the model to the varible ped to make set in the menu part of the code(Animal is a global set in menusetup.lua)
    PedTableAllDead(Config.PedSpawnCoordsWave1, model, 'bcc-acidtrip:Wave2') --triggers the ped spawn function and passes the data too it
end)

--Wave2
RegisterNetEvent('bcc-acidtrip:Wave2')
AddEventHandler('bcc-acidtrip:Wave2', function()
    local model = GetHashKey('re_fleeingfamily_males_01') --sets the model to the varible ped to make set in the menu part of the code(Animal is a global set in menusetup.lua)
    PedTableAllDead(Config.PedSpawnCoordsWave2, model, 'bcc-acidtrip:Wave3') --triggers the ped spawn function and passes the data too it
end)

--Wave3
RegisterNetEvent('bcc-acidtrip:Wave3')
AddEventHandler('bcc-acidtrip:Wave3', function()
    local model = GetHashKey('re_fleeingfamily_males_01') --sets the model to the varible ped to make set in the menu part of the code(Animal is a global set in menusetup.lua)
    PedTableAllDead(Config.PedSpawnCoordsWave2, model, 'bcc-acidtrip:TurnIntoAnimal') --triggers the ped spawn function and passes the data too it
end)

-----This is what will happen when the waves are defeated------
RegisterNetEvent('bcc-acidtrip:TurnIntoAnimal')
AddEventHandler('bcc-acidtrip:TurnIntoAnimal', function()
    AnimpostfxPlay('MP_NATURALISTANIMALTRANSFORMSTART') --plays effect
    TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_DRUNK_PASSED_OUT_FLOOR"), 7000, true, false, false, false) -- Plays the animation
    Wait(5000) --waits 5 seconds
    AnimpostfxStop('MP_NATURALISTANIMALTRANSFORMSTART') --stops effect
    ClearPedTasksImmediately(PlayerPedId()) --clears peds tasks/anims
    PlayerPedchange(false, Config.AnimalTransformationModel, Config.TimeAsAnimal, 'bcc-acidtrip:TurnIntoAnimalSpam', Config.SmokeExplosionDuringPedChange) --triggers the function and passes the data too it
end)

--This will happen after the initial animal transformation event is over
RegisterNetEvent('bcc-acidtrip:TurnIntoAnimalSpam')
AddEventHandler('bcc-acidtrip:TurnIntoAnimalSpam', function()
    PlayerPedchange(true, Config.AnimalTransformationModel, 1000, 'bcc-acidtrip:WakeUp/End', Config.SmokeExplosionDuringPedChange) --triggers the funciton and passes the data too it
end)

--This function will handle waking the player up
RegisterNetEvent('bcc-acidtrip:WakeUp/End')
AddEventHandler('bcc-acidtrip:WakeUp/End', function()
    AnimpostfxPlay('skytl_0300_04storm') --plays a cutscene of the sky moving
    Wait(6000) --waits 6 seconds
    AnimpostfxStopAll() --ends the cutscene
    VORPcore.instancePlayers(0) --removes the player from instance
    local d = math.random(1, #Config.WakeUpLocations) --random coords
    local wakeupcoords = Config.WakeUpLocations[d] --random coords
    SetEntityCoords(PlayerPedId(), wakeupcoords.x, wakeupcoords.y, wakeupcoords.z) --teleports player to the random coords
    AnimpostfxPlay('PlayerWakeUpDrunk') --plays the drunk wakeup effect
    Wait(1000)
    exports.weathersync:setSyncEnabled(true) --this will sync the time of day, and weather to the instance with all the players (only run this after players leaves instance)
    Wait(15000) --waits 15 seconds
    AnimpostfxStopAll() --removes the effect
end)