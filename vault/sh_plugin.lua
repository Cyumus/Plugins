PLUGIN.name = "Vault"
PLUGIN.author = "Cyumus"
PLUGIN.desc = "A vault where you can save your money."

if SERVER then
	function PLUGIN:SaveData()
		local data = {}
	
		for k, v in pairs(ents.FindByClass("nut_vault")) do
			data[#data + 1] = {
				position = v:GetPos(),
				angles = v:GetAngles(),
				owner = v.owner,
				money = v.money,
				state = v.state
			}
		end
		print("Vaults has been saved successfully...")
		nut.util.WriteTable("vaults_table", data)
	end
	
	function PLUGIN:LoadData()
		local restored = nut.util.ReadTable("vaults_table")
		
		if (restored) then
			for k, v in pairs(restored) do
				local position = v.position
				local angles = v.angles
				local money = v.money
				local owner = v.owner
				local state = v.state
							
				local entity = ents.Create("nut_vault")
				entity:SetPos(position)
				entity:SetAngles(angles)
				entity.money = money
				entity.owner = owner
				entity.state = state
				entity:Spawn()
			end
		end
	end
end



nut.command.Register({
	onRun = function(client, arguments)
		tr = {}
		tr.start = client:GetShootPos()
		tr.endpos = tr.start + client:GetAimVector() * 200
		tr.filter = client
		trace = util.TraceHull(tr)
		
		local amount = tonumber(arguments[1])
		local box = trace.Entity
		
		if !amount then
			nut.util.Notify("You have to introduce a valid value", client)
			
			return
		elseif amount <= 0 then
			nut.util.Notify("You have to introduce a valid larger than 0", client)
			
			return
		elseif (client:GetMoney() - amount < 0) then
			nut.util.Notify("You don't have the money you want to deposit.", client)

			return
		end
			
		
		
		
		if box:IsValid() and box:GetClass() == "nut_vault" then
			if box.state != "opened" then
				nut.util.Notify("The vault has to be opened or in good state in order to deposit money.", client)
			else
				box.money = box.money + amount
				nut.util.Notify("You saved "..amount.." Tokens in the vault.", client)
				client:TakeMoney(amount)
			
			end
		else
			nut.util.Notify("You have to stare at a vault to do that.", client)
		end		

		
	end
}, "deposit")

nut.command.Register({
	onRun = function(client, arguments)
		tr = {}
		tr.start = client:GetShootPos()
		tr.endpos = tr.start + client:GetAimVector() * 200
		tr.filter = client
		trace = util.TraceHull(tr)
		
		local amount = tonumber(arguments[1])
		local box = trace.Entity
		
		if !amount then
			nut.util.Notify("You have to introduce a valid value", client)
			
			return
		elseif amount <= 0 then
			nut.util.Notify("You have to introduce a valid larger than 0", client)
			
			return
		elseif (box.money - amount < 0) then
			nut.util.Notify("You don't have this amount of money in the vault to withdraw.", client)

			return
		end
			
		
		
		
		if (trace.Entity:IsValid() and trace.Entity:GetClass() == "nut_vault") then
			if box.state != "opened" then
				nut.util.Notify("The vault has to be opened or in good state in order to withdraw money.", client)
			else
				box.money = box.money - amount
				nut.util.Notify("You have withdrawn "..amount.." Tokens from the vault.", client)
				client:TakeMoney(-amount)
			
			end
		else
			nut.util.Notify("You have to stare at a vault to do that.", client)
		end		

		
	end
}, "withdraw")

nut.command.Register({
	onRun = function(client)
		tr = {}
		tr.start = client:GetShootPos()
		tr.endpos = tr.start + client:GetAimVector() * 200
		tr.filter = client
		trace = util.TraceHull(tr)
		
		local box = trace.Entity
				
		if box:IsValid() and box:GetClass() == "nut_vault" then
			if box.state != "opened" then
				nut.util.Notify("The vault has to be opened or in good state in order to check the money inside.", client)
			else
				nut.util.Notify("Currently there are "..box.money.." Tokens in the vault.", client)
			
			end
		else
			nut.util.Notify("You have to stare at a vault to do that.", client)
		end		

		
	end
}, "check")