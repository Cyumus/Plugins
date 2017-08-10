ITEM.name = "Hammer"
ITEM.desc = "A hammer"
ITEM.model = "models/twd/weapon/hammer.mdl"
ITEM.class = "hl2_m_hammer"
ITEM.width = 1
ITEM.height = 2
ITEM.price = 0
ITEM.category = "Tool"
ITEM.recipe = {["wooden_handle"] = 1,["metal_piece"] = 4}
ITEM.tools = {"welder"}
ITEM.cant = 1
ITEM.isBlueprint = false
ITEM.functions.EquipUn = {
	onCanRun = function(item)
		return false
	end
}
ITEM.functions.Equip = {
	onCanRun = function(item)
		return false
	end
}
