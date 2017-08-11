ITEM.name = "Vault"
ITEM.uniqueID = "vault"
ITEM.category = "Furnitures"
ITEM.flag = "m"
ITEM.weight = 3
ITEM.price = 300
ITEM.model = Model("models/props_vtmb/safe.mdl")
ITEM.desc = "A vault where you can save your money."

ITEM.functions = {}
ITEM.functions.Use = {
	alias = "Place",
	icon = "icon16/weather_sun.png",
	run = function(itemTable, client, data)
		if (SERVER) then
		
			local position
			if (IsValid(entity)) then
				position = entity:GetPos() + Vector(0, 0, 4)
			else
				local data2 = {
					start = client:GetShootPos(),
					endpos = client:GetShootPos() + client:GetAimVector() * 72,
					filter = client
				}
				local trace = util.TraceLine(data2)
				position = trace.HitPos + Vector(0, 0, 16)
			end
			
			local entity2 = entity
			local entity = ents.Create("nut_vault")
			entity:SetPos(position)
			if (IsValid(entity2)) then
				entity:SetAngles(entity2:GetAngles())
			end
			entity:Spawn()
			entity:Activate()
			
		end
	end
}