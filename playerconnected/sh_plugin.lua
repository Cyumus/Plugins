local PLUGIN = PLUGIN

PLUGIN.name = "Player Connected"
PLUGIN.author = "Cyumus"
PLUGIN.desc = "A plugin that shows a message in the chat wether a player has connected to the server or disconnected from it."

function PLUGIN:PlayerConnect(client, ip)
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(client.." has connected to the server.")
	end
end

function PLUGIN:PlayerDisconnected(client)
	PrintMessage(HUD_PRINTTALK, client:Name().." has disconnected from the server.")
end
	