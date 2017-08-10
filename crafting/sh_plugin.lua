PLUGIN.name = "Crafting"
PLUGIN.author = "Cyumus"
PLUGIN.desc   = "A crafting plugin based on raw materials"

nut.util.include("derma/sh_menu.lua")

if (SERVER) then

	resource.AddWorkshop("294107789")
	resource.AddWorkshop("152429256")

	function PLUGIN:SaveData()
		local data = {}

		for k, v in ipairs(ents.FindByClass("nut_craftingtable")) do
			data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetModel(), v.title}
		end

		self:setData(data)
	end

	function PLUGIN:LoadData()
		local data = self:getData()

		if (data) then
			for k, v in ipairs(data) do
				local storage = ents.Create("nut_craftingtable")
				storage:SetPos(v[1])
				storage:SetAngles(v[2])
				storage:Spawn()
				storage:SetModel(v[3])
				storage:setNetVar("title", v[4])
				storage:SetSolid(SOLID_VPHYSICS)
				storage:PhysicsInit(SOLID_VPHYSICS)
				storage:Spawn()

				local physObject = storage:GetPhysicsObject()

				if (physObject) then
					physObject:Sleep()
				end
			end
		end
	end
end

function PLUGIN:showCraftableItems(client)
	local data = client:getChar():getData("craftableItems")
	if !data then
		client:getChar():setData("craftableItems", {})
	end
	return data
end

local function getItemEntity(item)
	for k, v in SortedPairs(nut.item.list) do
		if (item == v.uniqueID) then
			return v
		end
	end
	return nil
end

local function canPlayerCraft(client, item)
	local inventory = client:getChar():getInv()
	local items = inventory:getItems()
	local recipe = copyTable(item.recipe) --So that the original table isn't erased for the item
	local tools = item.tools

	if (!recipe) then
		return nil, item
	end

	if recipe then
		for _,v in pairs(items) do
			for k2,v2 in pairs (recipe) do
				if (v.uniqueID == k2) then
					recipe[k2] = v2 - 1
				end
			end
		end
		for k3, v3 in pairs(recipe) do
			if v3 > 0 then
				return false, item
			end
		end
	end

	if tools then
		for _,item in pairs (items) do
			for _,v0 in pairs(tools) do
				if item.uniqueID == v0 then
					table.RemoveByValue(tools, v0)
				end
			end
		end

		if table.getn(tools) > 0 then
			return 0, item
		end
	end

	return true, item
end

function remove(inventory, item, quantity)
	local items = inventory:getItems()
	for _, v in pairs(items) do
		if (quantity <= 0) then
			break
		else
			if (v.uniqueID == item) then
				v:remove()
				quantity = quantity - 1
			end
		end
	end
end

function give(client, item)
	local given = true
	local i = 0
	while (given and i < item.cant) do
		given = client:getChar():getInv():add(item.uniqueID)
		i = i + 1
	end
	return given
end

function copyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function craft(client, item)
	local recipe = item.recipe
	if (give(client,item)) then
		for k, v in pairs(recipe) do
			remove(client:getChar():getInv(), k, v)
		end
		client:notifyLocalized("lc_youCrafted", item.name)
		return true
	else
		client:notifyLocalized("lc_cantFit", item.name)
		return false
	end
end

netstream.Hook("nut_lc_CraftItem", function(client, item, machine)
	local itemEntity = getItemEntity(item)
	if !itemEntity or itemEntity == nil then
		ErrorNoHalt("@lc_corrupt")
	end
	local canCraft, item = canPlayerCraft(client, itemEntity)
	if (canCraft == nil) then
		client:notifyLocalized("lc_noRecipe", item.name)
		return false
	end
	if (canCraft == 0) then
		client:notifyLocalized("lc_noTools", item.name)
		return false
	end
	if (canCraft) then
		return craft(client, item)
	end
	client:notifyLocalized("lc_youHaventRecipe", item.name)
	return false
end)
