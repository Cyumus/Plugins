ITEM.name = "Biohazard Protection Suit"
ITEM.model = Model("models/aperturehz/aphaztechs/u4labtech_01.mdl")
ITEM.weight = 2
ITEM.desc = "A biohazard protection suit."
ITEM.flag = "k"
ITEM.category = "Clothing"
ITEM.price = 750

ITEM:Hook("Equip", function(itemTable, client, data, entity, index)
	if (SERVER) then
		client:ConCommand("say /me puts on the biohazard protection suit.")
		client:EmitSound("items/ammopickup.wav")
	end
end)

ITEM.functions = ITEM.functions or {}

ITEM.functions._CheckFilter = {
	text = "Check filter",
	menuOnly = true,
	tip = "It shows the status of the filters",
	icon = "icon16/weather_sun.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			local remainingTime = data.Filter or 0 
			
			if remainingTime == 0 then
				nut.util.Notify("Your filter has run out.", client)
			else
				nut.util.Notify("Your filter has " .. remainingTime .. " second(s) to run out." , client)
			end
			return false
		end
	end
}

ITEM.functions._Filter = {
	text = "Change filter",
	menuOnly = true,
	tip = "Changes the current filter and puts a new one.",
	icon = "icon16/weather_sun.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			if client:HasItem("air_filter") then
				local newData = table.Copy(data)
				
				newData.Filter = 300

				client:UpdateInv(itemTable.uniqueID, 1, newData, true)
				client:UpdateInv("air_filter", -1, {}, true)

				client:EmitSound("HL1/fvox/hiss.wav")
				nut.util.Notify("You changed your filter.", client)
				return true
			else
				nut.util.Notify("You have no filters in your inventory.", client)
			end
			return false
		end
	end
}