ITEM.name = "Bandage"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 0
ITEM.category = "Medicine"
ITEM.recipe = {["cloth"] = 2}
ITEM.cant = 1
ITEM.isBlueprint = false
ITEM.functions.Use = {
	name = "Usar",
	sound = "items/medshot4.wav",
	onRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + 25, 100))
	end
}
