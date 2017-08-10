ITEM.name = "Medkit"
ITEM.uniqueID = "cr_medkit"
ITEM.desc = "A first aid kit"
ITEM.model = "models/Items/HealthKit.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.price = 0
ITEM.category = "Medicine"
ITEM.recipe = {["cloth"] = 1, ["bandage"] = 2, ["sheepdip"] = 1}
ITEM.cant = 1
ITEM.functions.Use = {
	name = "Usar",
	sound = "items/medshot4.wav",
	onRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + 75, 100))
	end
}
