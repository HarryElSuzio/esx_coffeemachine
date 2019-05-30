ESX               = nil
local ItemsLabels = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_coffeemachine:buyItem')
AddEventHandler('esx_coffeemachine:buyItem', function(itemName, price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	if price < 0 then
		print('esx_coffeemachine: ' .. xPlayer.identifier .. ' attempted to cheat money!')
		return
	end

	if xPlayer.getMoney() >= price then
			TriggerClientEvent('esx_coffeemachine:Random', source)
	else
		local missingMoney = price - xPlayer.getMoney()
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough', missingMoney))
	end

end)

RegisterServerEvent('esx_coffeemachine:TakeMoney')
AddEventHandler('esx_coffeemachine:TakeMoney', function(price)
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeMoney(price)
end)

RegisterServerEvent('esx_coffeemachine:DrankCoffee')
AddEventHandler('esx_coffeemachine:DrankCoffee', function()
	local _source = source
	TriggerClientEvent('esx_status:add', _source, 'thirst', 300000)
	TriggerClientEvent('esx_status:remove', source, 'pee', 100000)
end)
