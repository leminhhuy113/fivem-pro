-- client/main.lua — module-per-global: one global table, everything else local.
TemplateClient = {}

local isUiOpen = false

local function toggleUi(state)
    isUiOpen = state
    SetNuiFocus(state, state) -- Iron Rule 6: focus has a lifecycle
    SendNUIMessage({ action = state and 'open' or 'close' })
end

-- Iron Rule 6: every focus path gets a close path (ESC, button, stop, logout)
RegisterNUICallback('close', function(_, cb)
    toggleUi(false)
    cb('ok')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if isUiOpen then
        toggleUi(false)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and isUiOpen then
        toggleUi(false)
    end
end)

-- Iron Rule 3: no busy loops — adaptive wait, distance-gated work
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - Config.Interact.coords)
        if dist < Config.Interact.radius then
            wait = 0
            -- prompt / draw marker here; request handled server-side
            if IsControlJustReleased(0, 38) then -- E
                toggleUi(true)
            end
        end
        Wait(wait)
    end
end)

-- NUI asks, server decides: forward the request, never the reward
RegisterNUICallback('claimReward', function(_, cb)
    TriggerServerEvent('template:server:claimReward')
    cb('ok')
end)
