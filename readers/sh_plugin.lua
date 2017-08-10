local PLUGIN = PLUGIN

PLUGIN.name = "Card Readers"
PLUGIN.author = "Cyumus"
PLUGIN.desc = "Adds card readers with different access levels"
PLUGIN.readerType = {"nut_cwureader", "nut_comreader", "nut_admreader", "nut_nucreader"}

nut.config.add("openTime", 4.0, "How much time a door will stay open.", nil, {
	form = "Float",
	data = {min=1.0, max=3600.0},
	category = "Readers"
})

if (SERVER) then
	resource.AddWorkshop("282312812")

	function PLUGIN:SaveData()
		local data = {}

		for _, v in pairs(self.readerType) do
			for _, v2 in pairs(ents.FindByClass(v)) do
				data[#data + 1] = {reader = v, position = v2:GetPos(), angles = v2:GetAngles(), door = v2.door}
			end
		end

		self:setData(data)
	end

	function PLUGIN:LoadData()
		local locks = self:getData()

		for k, v in ipairs(locks) do
			local reader = v.reader
			local position = v.position
			local angles = v.angles
			local door = v.door
			if !door then continue end

			local entity = ents.Create(reader)
				entity:SetPos(position)
				entity:SetAngles(angles)
				entity.door = door
				entity:Spawn()

			for _, door in pairs( ents.FindInSphere( door, 5 ) ) do
				if door then
					door:Fire( "close", .1 )
					door:Fire( "lock", .1 )
				end
			end
		end
	end
end

local function IsDoor(entity)
	return string.find(entity:GetClass(), "door")
end

local function getReaders()
	return PLUGIN.readerType
end

nut.command.add("addlock", {
	adminOnly = true,
	onRun = function(client)
		tr = {}
		tr.start = client:GetShootPos()
		tr.endpos = tr.start + client:GetAimVector() * 200
		tr.filter = client
		trace = util.TraceHull(tr)

		lock = trace.Entity

		if (!client:getNetVar("lock")) then
			if (lock:IsValid())  then
				for k, v in pairs(getReaders()) do
					if (lock:GetClass(v)) then
						client:setNetVar("lock", lock)
						return "@validDoor"
					end
				end
			end
		else
			if trace.Entity:IsValid() and IsDoor(lock) then
				local ourLock = client:getNetVar("lock")
				ourLock.door = lock:GetPos()
				lock:Fire( "close", .1 )
				lock:Fire( "lock", .1 )

				client:setNetVar("lock", nil)
				return "@readerAdded"
			else
				client:setNetVar("lock", nil)
				return "@valuesRestored"
			end
		end

	end
})
