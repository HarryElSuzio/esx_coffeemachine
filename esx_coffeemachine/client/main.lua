ESX                           = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	Citizen.Wait(5000)
	
	function requestDBItems(ShopItems)
		for k,v in pairs(ShopItems) do
			Config.Zones[k].Items = v
		end
	end
end)


function OpenShopMenu(zone)
	local elements = {}
	TriggerServerEvent('esx_coffeemachine:buyItem', "water", 1)
end

AddEventHandler('esx_coffeemachine:hasEnteredMarker', function(zone)

	CurrentAction     = 'machine_menu'
	CurrentActionMsg  = _U('press_context')
	CurrentActionData = {zone = zone}
end)

AddEventHandler('esx_coffeemachine:hasExitedMarker', function(zone)

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if(GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.Size.x) then
					isInMarker  = true
					ShopItems   = v.Items
					currentZone = k
					LastZone    = k
				end
			end
		end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('esx_coffeemachine:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_coffeemachine:hasExitedMarker', LastZone)
		end
	end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlJustReleased(0, 38) then

        if CurrentAction == 'machine_menu' then
          OpenShopMenu(CurrentActionData.zone)
        end
		
        CurrentAction = nil
      end
    end
  end
end)

RegisterNetEvent('esx_coffeemachine:Random')
AddEventHandler('esx_coffeemachine:Random', function(prop_name)
	local lottery =  math.random(1,9)
	local ped = GetPlayerPed(-1)
	if lottery <= 6 then
		if not IsAnimated then
			local prop_name = prop_name or 'p_ing_coffeecup_01'
			IsAnimated = true
			local playerPed = GetPlayerPed(-1)
			Citizen.CreateThread(function()
				FreezeEntityPosition(ped, true)
				ClearPedTasksImmediately(ped)
				ESX.ShowNotification('Venta. Por favor espere...')
				TriggerServerEvent('esx_coffeemachine:TakeMoney', 1)
				Citizen.Wait(3000)
				TriggerEvent('InteractSound_CL:PlayOnOne', 'SodaMachine', 1.0)
				Citizen.Wait(2000)
				local x,y,z = table.unpack(GetEntityCoords(playerPed))
				RequestAnimDict('amb@medic@standing@kneel@base')  
				while not HasAnimDictLoaded('amb@medic@standing@kneel@base') do
					Citizen.Wait(0)
				end
				TaskPlayAnim(playerPed, 'amb@medic@standing@kneel@base', 'base', 3.0, 3.0, 2000, 0, 1, true, true, true)
				Citizen.Wait(700)
				ESX.ShowNotification('Acabas de comprar ~r~Cafe~s~ por ~g~$1~s~. Gracias por su compra!')
				prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
				AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 18905), 0.12, 0.028, 0.001, 300.00, 180.0, 20.0, true, true, false, true, 1, true)
				Citizen.Wait(1500)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				Citizen.Wait(1000)
				
				RequestAnimDict('mp_player_intdrink')  
				while not HasAnimDictLoaded('mp_player_intdrink') do
					Citizen.Wait(0)
				end
				TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)
				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
				FreezeEntityPosition(ped, false)
				TriggerServerEvent('esx_coffeemachine:DrankCoffee', 0)
			end)
		end
	end
	if lottery == 7 then
			Citizen.CreateThread(function()
			ESX.ShowNotification('La maquina esta temporalmente fuera de servicio')
			end)
		end
	if lottery == 8 then
			Citizen.CreateThread(function()
			ESX.ShowNotification('La maquina no tiene ese producto')
			end)
		end
	if lottery == 9 then
			Citizen.CreateThread(function()
			FreezeEntityPosition(ped, true)
			ClearPedTasksImmediately(ped)
			ESX.ShowNotification('Venta. Por favor espera...')
			Citizen.Wait(3000)
			TriggerEvent('InteractSound_CL:PlayOnOne', 'SodaMachine', 1.0)
			Citizen.Wait(5000)
			ESX.ShowNotification('La maquina a tenido un error y se a quedado con tu dinero')
			FreezeEntityPosition(ped, false)
			end)
		end
end)
