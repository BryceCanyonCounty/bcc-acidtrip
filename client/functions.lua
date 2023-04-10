------Functions----
local deadcheck = false --var used to see if player is dead
--This creates a function that when called will make smoke appear on a ped(you pass the ped too it)
function SmokeCloudOnPed(ped)
    local new_ptfx_dictionary = "scr_odd_fellows"
    local new_ptfx_name = "scr_river5_magician_smoke"
    local is_particle_effect_active = false
    local current_ptfx_dictionary = new_ptfx_dictionary
    local current_ptfx_name = new_ptfx_name
    local current_ptfx_handle_id = false
    local ptfx_offcet_x = 0.0
    local ptfx_offcet_y = 0.0
    local ptfx_offcet_z = -1.0
    local ptfx_rot_x = -90.0
    local ptfx_rot_y = 0.0
    local ptfx_rot_z = 0.0
    local ptfx_scale = 1.0
    local ptfx_axis_x = 0
    local ptfx_axis_y = 0
    local ptfx_axis_z = 0
    if not is_particle_effect_active then
        current_ptfx_dictionary = new_ptfx_dictionary
        current_ptfx_name = new_ptfx_name
        if not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(current_ptfx_dictionary)) then -- HasNamedPtfxAssetLoaded
            Citizen.InvokeNative(0xF2B2353BBC0D4E8F, GetHashKey(current_ptfx_dictionary))   --RequestNamedPtfxAsset
            local counter = 0
            while not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(current_ptfx_dictionary)) and counter <= 300 do   --while not HasNamedPtfxAssetLoaded
                Citizen.Wait(0)
            end
        end
        if Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(current_ptfx_dictionary)) then  -- HasNamedPtfxAssetLoaded
            Citizen.InvokeNative(0xA10DB07FC234DD12, current_ptfx_dictionary)  --UseParticleFxAsset
            current_ptfx_handle_id =  Citizen.InvokeNative(0xE6CFE43937061143,current_ptfx_name,ped,ptfx_offcet_x,ptfx_offcet_y,ptfx_offcet_z,ptfx_rot_x,ptfx_rot_y,ptfx_rot_z,ptfx_scale,ptfx_axis_x,ptfx_axis_y,ptfx_axis_z)     --StartNetworkedParticleFxNonLoopedOnEntity
            is_particle_effect_active = true
        else
            print("cant load ptfx dictionary!")
        end
    else
        if current_ptfx_handle_id then
            if Citizen.InvokeNative(0x9DD5AFF561E88F2A, current_ptfx_handle_id) then    --DoesParticleFxLoopedExist
                Citizen.InvokeNative(0x459598F579C98929, current_ptfx_handle_id, false)    --RemoveParticleFx
            end
        end
    current_ptfx_handle_id = false
    is_particle_effect_active = false
    end
end

--This function will spawn as many peds as set in a table, and detect when they are dead, when they all die it will trigger an event
function PedTableAllDead(pedcoordtable, model, event) --pedcoordtable = Table of ped coords to spawn. model = model hash of peds to spawn. Event = Client event to trigger when all peds are dead
    TriggerEvent('bcc-acidtrip:DeadCheck') --triggers the event for deadchecking
    local createdped = {} --creates a table for the peds spawned info to be stored in
    local count = {} --creates a table used to track the amount of peds left
    local runoncething = 0
    RequestModel(model)              --dont know but is needed
    if not HasModelLoaded(model) then
        RequestModel(model)
    end
    while not HasModelLoaded(model) or HasModelLoaded(model) == 0 or model == 1 do
        Citizen.Wait(1)
    end
    for k, v in pairs(pedcoordtable) do --for loop in the table runs once per table
        Wait(1000) --waits 1 second
        createdped[k] = CreatePed(model, v.x, v.y, v.z, false, true) --spawns the ped and stores them in the k key
        Citizen.InvokeNative(0x283978A15512B2FE, createdped[k], true) --This sets the ped into a random outift(fixes an invisiblity bug)
        Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, createdped[k]) --sets blips to track the peds
        TaskCombatPed(createdped[k], PlayerPedId()) --makes the ped attack the player
        if Config.SmokeOnNpcSpawn then
            SmokeCloudOnPed(createdped[k]) --triggers the smoke cloud function and passes the ped too it
        end
        count[k] = createdped[k] --sets count to equal createdped amount
        if runoncething == 0 then
            runoncething = runoncething + 1
            Citizen.CreateThread(function() --creates a thread
                local x = #pedcoordtable --sets x to the number of tables
                while true do --loop that runs until broken
                    Citizen.Wait(150) --waits 150ms prevents crashing
                    if deadcheck then break end --if player dead then break loop
                    for k, v in pairs(createdped) do
                        if IsEntityDead(v) then                                 --checks if the entities are dead
                            if IsEntityDead(v) then --if peds are dead then
                                if count[k] ~= nil then --if variable not nil then
                                    x = x - 1 --x = x - 1
                                    count[k] = nil --sets count too nil
                                    if x == 0 then --if x = 0 then(all peds are dead)
                                        TriggerEvent(event) --triggers the client event that is passed to this function
                                        runoncething = 0 break --changes the var back and breaks the loop
                                    end
                                end
                            end
                        end
                    end
                end
                if deadcheck then --if var true then
                    for key, value in pairs(createdped) do --for loop
                        DeletePed(value) --deletes ped (this deletes all peds created)
                    end
                    deadcheck = false --resets the variable so this code can be ran again
                    TriggerEvent('bcc-acidtrip:WakeUp/End') --triggers the end event
                end
            end)
        end
    end
end

RegisterNetEvent('bcc-acidtrip:DeadCheck')
AddEventHandler('bcc-acidtrip:DeadCheck', function()
    while true do --loops runs until broken
        Citizen.Wait(100) --waits 100ms
        if IsEntityDead(PlayerPedId()) == 1 then --if u die then
            deadcheck = true break --set var true break loop
        end
    end
end)

--Function to handle changing the players ped for a set time, and triggers an event once ped reset
function PlayerPedchange(multichange, model, time, event, smokeexplosion) --ped is the ped to change, model is the model to set it too, time is the time stayed as the, event is the event it will trigger after changing your ped back to normal, smoke explosion boolean
    --Multi Change Setup
    if multichange then --if var true then
        for k, v in pairs(AnimalHashes) do --for loop in the animal hashes table
            local model2 = GetHashKey(v.model)--var used to store the model for single ped change
            if smokeexplosion then --if var true then
                SmokeCloudOnPed(PlayerPedId()) --triggers the smoke cloud function on the player
            end
            if not IsModelValid(model2) then return end --if model is not valid then return ending function
            RequestModel(model2, 0) --requests/loads the model
            while not Citizen.InvokeNative(0x1283B8B89DD5D1B6, model2) do --while model hasnt loaded do
                Citizen.InvokeNative(0xFA28FE3A6246FC30, model2, 0) --request model
                Citizen.Wait(0) --wait 0ms prevents crashing
            end
            if HasModelLoaded(model2) then --once model loaded then
                Citizen.InvokeNative(0xED40380076A31506, PlayerId(), model2, false) --changes players model
	            Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true) --sets ped into random outfit preventing invisiblity bug
	            SetModelAsNoLongerNeeded(model2) --sets model as no longer needed
                Citizen.Wait(time) --waits the set time
            end
        end
        ExecuteCommand('rc') --uses the /rc command reseting the players ped
        Wait(200) --waits 200 ms
        TriggerEvent(event) --triggers the next event after the repeat has finished
    else --else if the var is not true
        --Single Change Setup
        local model2 = GetHashKey(model)--var used to store the model for single ped change
        if smokeexplosion then --if var true then
            SmokeCloudOnPed(PlayerPedId()) --triggers the smoke cloud function on the player
        end
        if not IsModelValid(model2) then return end --if model is not valid then return ending function
        RequestModel(model2, 0) --requests/loads the model
        while not Citizen.InvokeNative(0x1283B8B89DD5D1B6, model2) do --while model hasnt loaded do
            Citizen.InvokeNative(0xFA28FE3A6246FC30, model2, 0) --request model
            Citizen.Wait(0) --wait 0ms prevents crashing
        end
        if HasModelLoaded(model2) then --once model loaded then
            Citizen.InvokeNative(0xED40380076A31506, PlayerId(), model2, false) --changes players model
	        Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true) --sets ped into random outfit preventing invisiblity bug
	        SetModelAsNoLongerNeeded(model2) --sets model as no longer needed
            Citizen.Wait(time) --waits the set time
            ExecuteCommand('rc') --uses the /rc command reseting the players ped
            Wait(200) --waits 200 ms
            TriggerEvent(event) --triggers the next event after the repeat has finished
        end
    end
end

-------------Tables-----------------------------
--Table is used to store animal hashes for random ped changing
AnimalHashes = {
    {model = 'A_C_Bear_01'},
    {model = 'mp_a_c_deer_01'},
    {model = 'A_C_Duck_01'},
    {model = 'a_c_snakeredboa10ft_01'},
    {model = 'A_C_Alligator_01'},
    {model = 'A_C_Elk_01'},
    {model = 'A_C_Wolf'},
    {model = 'MP_A_C_WOLF_01'},
    {model = 'cs_dutch'},
    {model = 'cs_crackpotrobot'}
}