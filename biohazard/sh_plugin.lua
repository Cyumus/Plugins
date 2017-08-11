local PLUGIN = PLUGIN
local playerMeta = FindMetaTable("Player")

PLUGIN.name = "Biohazard Alert"
PLUGIN.author = "Cyumus"
PLUGIN.desc = "Plugin that allows the spread of diseases."
PLUGIN.bioPlayers = PLUGIN.bioPlayers or {}
PLUGIN.infectionLevels = {} 
PLUGIN.infectedZones = PLUGIN.infectedZones or {}
PLUGIN.infectedPlayers = {}

PLUGIN.maxBio = 100
PLUGIN.bioAmount = 0.004629
PLUGIN.restoreBioAmount = 0.005
PLUGIN.thinkTime = 1
PLUGIN.damageTime = 3

if (SERVER) then
	resource.AddWorkshop("150687900")
	function PLUGIN:LoadData()
		PLUGIN.infectedPlayers = nut.util.ReadTable("infected_players")
		PLUGIN.infectedZones = nut.util.ReadTable("infected_zones")
		PLUGIN.infectionLevels = nut.util.ReadTable("infection_levels")
	end

	function PLUGIN:SaveData()
		nut.util.WriteTable("infected_players", PLUGIN.infectedPlayers)
		nut.util.WriteTable("infected_zones", PLUGIN.infectedZones)
		nut.util.WriteTable("infection_levels", PLUGIN.infectionLevels)
	end

	function PLUGIN:CanThroughBadAir(client)
		return false -- If this is true, The server will not think your breath status.
	end

	function PLUGIN:GetBioAmount(client, amount)
		if client:HasItem( "clothing_biosuit") then
			for k, v in pairs(client:GetItemsByClass("clothing_biosuit")) do
				local data = v.data

				if data.Equipped then
					if data.Filter and data.Filter > 0 then
						data.Filter = math.Clamp(data.Filter - 1, 0, math.huge)
						return 0
					end
				end
			end
		end
		
		if client:HasItem( "clothing_civilprotection") then
			for k, v in pairs(client:GetItemsByClass("clothing_civilprotection")) do
				local data = v.data

				if data.Equipped then
					return 0
				end
			end
		end
		
		return amount
	end
	
	function PLUGIN:GetrestoreAmount(client, amount)
		-- Add some perks/mask/item effects here.
		return amount
	end

	local damageTime = RealTime()
	function PLUGIN:OnBreathBiohazard(client, beingInfected)
		if (beingInfected) then
			if damageTime < RealTime() then
				damageTime = RealTime() + self.damageTime
				client:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
			end
		else
			local infectionLevel = self.infectionLevels[client:SteamID()][client.character.index] or 0
			if infectionLevel > 50 then
				if damageTime < RealTime() then
					damageTime = RealTime() + self.damageTime

					client:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
				end
			end
		end
	end
	
	function PLUGIN:Infect(client, beingInfected)
		if (beingInfected) then
			self.infectedPlayers[client:SteamID()] = self.infectedPlayers[client:SteamID()] or {}
			if (self.infectedPlayers[client:SteamID()][client.character.index]) then return end
			
			table.insert(PLUGIN.infectedPlayers, {client})
			self.infectedPlayers[client:SteamID()][client.character.index] = true
			nut.util.WriteTable("infected_players", PLUGIN.infectedPlayers)
		else
			local target = nut.command.FindPlayer(client)
			for target, v in pairs(self.infectedPlayers) do
				table.remove(self.infectedPlayers, target)	
				nut.util.WriteTable("infected_players", PLUGIN.infectedPlayers)
			end
		end
	end
	
	function PLUGIN:beingInfectedGrave(client, beingInfected)
		if (beingInfected) then
			self.infectedPlayers[client:SteamID()] = self.infectedPlayers[client:SteamID()] or {}
			if (self.infectedPlayers[client:SteamID()][client.character.index]) then return end			
					
			local originalDescription = client.character:GetVar("description")
			local pronoun, possesive = // Lua has no ternary expressions, so I use and/or expressions to make the trick (hehe)
							string.find(client:GetModel().lower(), "female") and // The model has 'female' in it?
								'She', 'her'		// Then it's a female
							or					// else
								'He', 'his'			// It's a male
								
			changeDescription(client, Format("%s has some stains all over %s body. %s", pronoun, possesive, originalDescription) )
			thenDo(5, function()
				choke(client, "/me coughs", 10, Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
				thenDo(5, function()
					choke(client, "/me coughs blood", nil, Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
					client:AddBuff("bleeding")
					thenDo(2, function()
						client:RemoveBuff("bleeding")
						thenDo(5, function()
							changeDescription(client, Format("%s has some infected stains all over %s body. %s", pronoun, possesive, originalDescription) )
							choke(client, nil, nil, Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
							thenDo(5, function()
								changeDescription(client, Format("%s has lots of blooding infected stains all over %s body. %s", pronoun, possesive, originalDescription) )
								choke(client, Format("/it The stains of %s started to bleed", client:Name()), 20, Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
								client:AddBuff("bleeding")
							end)
						end)
					end)
				end)
			end)
			
			self.Infect(client, beingInfected)
		end
	end
	
	local function choke(client, dmg, msg, snd)
		if (msg) then client:ConCommand("say " .. msg) end
		if (dmg) then client:TakeDamage(dmg) end
		if (snd) then client:EmitSound(snd) end
	end
		
	
	local function changeDescription(client, newDescription)
		client.character:SetVar("description", newDescription)
	end
	
	local function thenDo(nextChoke, callBack)
		timer.Simple(nextChoke, callBack)
	end
	local function vecabs( v1, v2 )
		local fv1, fv2 = Vector( 0, 0, 0 ), Vector(0, 0, 0)
	
		for i = 1,3 do
			if v1[i] > v2[i] then
				fv1[i] = v2[i]
				fv2[i] = v1[i]
			else
				fv1[i] = v1[i]
				fv2[i] = v2[i]
			end
		end
		
		return fv1, fv2
	end
	
	function PLUGIN:CreateInfectedZone(client)
		self.playerList = player.GetAll()
		for k, client in pairs(self.playerList) do
			local pos = client:GetPos() + client:OBBCenter()
			local vector1, vector2 = vecabs( pos + Vector(-30, -30, -30), pos + Vector(30, 30, 30))
			for k, vec in pairs(PLUGIN.infectedZones) do
				table.remove(PLUGIN.infectedZones, k)
				nut.util.WriteTable("infected_zones", PLUGIN.infectedZones)
				break
			end
			table.insert(PLUGIN.infectedZones, {vector1, vector2})
			nut.util.WriteTable("infected_zones", PLUGIN.infectedZones)
			return
		end			
	end
	
	function PLUGIN:DoPlayerDeath( client )
		self.infectionLevels[client:SteamID()][client.character.index] = 0
		netstream.Start(client, "nut_SyncBiohazard", self.infectionLevels[client:SteamID()][client.character.index])
	end

	function PLUGIN:PlayerLoadedChar(client)
		self.infectionLevels[client:SteamID()] = self.infectionLevels[client:SteamID()] or {}
		self.infectionLevels[client:SteamID()][client.character.index] = self.infectionLevels[client:SteamID()][client.character.index] or 0
		netstream.Start(client, "nut_SyncBiohazard", self.infectionLevels[client:SteamID()][client.character.index])
	end

	local thinktime = RealTime()
	function PLUGIN:Think()
		if (thinktime < RealTime()) then
			thinktime = RealTime() + self.thinkTime
			
			
			for k, client in pairs(player.GetAll()) do
				
				local pos = client:GetPos() + client:OBBCenter() -- preventing fuckering around.
				beingInfected = false
				if (!client.character) then
					continue
				end

				if (nut.schema.Call("CanThroughBadAir", client) == true) then
					continue
				end
				
				for k, vec in pairs(PLUGIN.infectedZones) do
					table.remove(PLUGIN.infectedZones, k)
					nut.util.WriteTable("infected_zones", PLUGIN.infectedZones)
				end
				
				for k, vec in pairs(PLUGIN.infectedZones) do
					if (pos:WithinAABox(vec[1], vec[2])) then
						nut.schema.Call("Infect", client, true)
					else
						nut.schema.Call("Infect", client, false)
					end
				end
				for target, v in pairs(self.bioPlayers) do
					beingInfected = true
					if beingInfected == true then
					
						local name = nut.util.FindPlayer(target)
						local bioAmount = self.bioAmount
						bioAmount = nut.schema.Call("GetBioAmount", client, bioAmount)
						
						self.infectionLevels[client:SteamID()] = self.infectionLevels[client:SteamID()] or {}
						self.infectionLevels[client:SteamID()][client.character.index] = self.infectionLevels[client:SteamID()][client.character.index] or 0
						local infectionLevel = self.infectionLevels[client:SteamID()][client.character.index]
						infectionLevel = math.Clamp(infectionLevel + bioAmount, 0, 100)
						self.infectionLevels[client:SteamID()][client.character.index] = infectionLevel
						netstream.Start(client, "nut_SyncBiohazard", infectionLevel)
						if (bioAmount > 0) then
							if (self.maxBio <= infectionLevel) then
								nut.schema.Call("OnBreathBiohazard", client, true)
							else
								nut.schema.Call("OnBreathBiohazard", client, false)
								beingInfected = false
							end
							if (bioAmount == 100) then
								nut.schema.Call("beingInfectedGrave", client, true)
								nut.schema.Call("CreateInfectedZone", client)
							end
							return
						end
					end
				end
				
				if (beingInfected == false) then
					local restoreAmount = self.restoreBioAmount
					restoreAmount = nut.schema.Call("GetrestoreAmount", client, restoreAmount)
					self.infectionLevels[client:SteamID()] = self.infectionLevels[client:SteamID()] or {}
					self.infectionLevels[client:SteamID()][client.character.index] = self.infectionLevels[client:SteamID()][client.character.index] or 0
					local infectionLevel = self.infectionLevels[client:SteamID()][client.character.index]
					infectionLevel = math.Clamp( infectionLevel - restoreAmount, 0, 100)
					self.infectionLevels[client:SteamID()][client.character.index] = infectionLevel
					netstream.Start(client, "nut_SyncBiohazard", infectionLevel)
					if (infectionLevel == 0) then
						self.infectedPlayers[client:SteamID()] = self.infectedPlayers[client:SteamID()] or {}
						self.infectedPlayers[client:SteamID()][client.character.index] = false	
					end
				end
			end
		end
	end
else
	local biohazard = 0
	netstream.Hook("nut_SyncBiohazard", function(data)
		biohazard = data
	end)	
	local cure = 0
	netstream.Hook("nut_SyncBiohazard2", function(data)
		cure = data
	end)

	PLUGIN.deltaBlur = SCHEMA.deltaBlur or 0

	function PLUGIN:RenderScreenspaceEffects()
		local blur = biohazard/self.maxBio
		self.deltaBlur = math.Approach(self.deltaBlur, blur, FrameTime() * 0.25)

		if (self.deltaBlur > 0) then
			DrawMotionBlur(0.1, self.deltaBlur, 0.01)
		end
	end
end

nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
			local target = nut.command.FindPlayer(client, arguments[1])
			table.insert(PLUGIN.bioPlayers, {target})
			nut.util.WriteTable("infected_players", PLUGIN.bioPlayers)
			local name = tostring(target:Name())
			nut.util.Notify("You infected "..name, client)
	end
}, "plyinfect")

nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
		local target = nut.command.FindPlayer(client, arguments[1])
	
		for target, v in pairs(PLUGIN.bioPlayers) do
			if target then
				table.remove(PLUGIN.bioPlayers, target)
				nut.util.WriteTable("infected_players", PLUGIN.bioPlayers)
				local name = nut.util.FindPlayer(arguments[1])
				nut.util.Notify("You cured "..name:Name(), client)
				beingInfected = false
				
				return
			end
		end
		PLUGIN.infectedPlayers[client:SteamID()] = PLUGIN.infectedPlayers[client:SteamID()] or {}
		PLUGIN.infectedPlayers[client:SteamID()][client.character.index] = false
	end
}, "plycure")