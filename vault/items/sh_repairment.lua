ITEM.name = "Toolkit"
ITEM.desc = "A toolkit."
ITEM.uniqueID = "toolkit"
ITEM.model = Model("models/props_c17/SuitCase001a.mdl")
ITEM.category = "Utils"
ITEM.flag = "i"
ITEM.price = 200
ITEM.functions = {}
ITEM.functions.Open = {
	text = "Open",
	run = function(itemTable, client, data)
		if (CLIENT) then return end
		client:UpdateInv("food2_vegtableoil", 1, nil, true)
		client:UpdateInv("junk_cb", 3, nil, true)
		client:UpdateInv("hl2_m_wrench", 1, nil, true)
		client:UpdateInv("hl2_m_hammer", 1, nil, true)
		
	end
}
ITEM.functions.Use = {
	text = "Use",
	run = function(itemTable, client, data)
		if (CLIENT) then return end
		
		local raytrace = client:GetEyeTraceNoCursor()
		local box = raytrace.Entity
		
		if (box:IsValid() and box:GetClass() == "nut_vault") then
			nut.util.Notify("You use this toolkit and repair the vault.", client)
			timer.Simple(3, function()
				local luck = tonumber(math.floor(math.random(0, 3)))
				if luck >= 1 then
					nut.util.Notify("You repaired the vault successfully.", client)
					box.state = "closed"
					client:UpdateInv("toolkit", 1, nil, true)
				else
					nut.util.Notify("The toolkit brokes and you couldn't repair the vault.", client)
				end
			end)	
		end				
	end
}