---------Pulling Essnetials----------------------
local VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

--Registering item as usable
Citizen.CreateThread(function() --crates a thread
    for key, v in pairs(Config.DrugItems) do --opens table and runs once per table
      VORPInv.RegisterUsableItem(v.name, function(data) --registers the item usable
        VORPInv.subItem(data.source, v.name, 1) --removes the item
        local _source = data.source --sets source
        if Config.RandomDrugChance then --if the config option is true then
            if math.random(1, 4) == 1 then --chooeses a random number between 1 and 4, and if the number is 1 then
                TriggerClientEvent('bcc-acidtrip:Open', _source) --striggers client event
            else --if it is not 1 then
                TriggerClientEvent('bcc-acidtrip:ScreenEffectOnly', _source, v.effectime) --triggers the client event, and passes the effect time
            end --if the config option is not true then
        else
            TriggerClientEvent('bcc-acidtrip:Open', _source) --trigger the client event
        end
      end)
    end
end)

--This handles the version check
local versioner = exports['bcc-versioner'].initiate()
local repo = 'https://github.com/jakeyboi1/bcc-farming'
versioner.checkRelease(GetCurrentResourceName(), repo)