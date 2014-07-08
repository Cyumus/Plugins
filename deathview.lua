PLUGIN.name = "First Person Death View"
PLUGIN.author = "Thadah Denyse"
PLUGIN.desc = "Provides death vision."

if CLIENT then
	function CalcView(pl, origin, angles, fov)
    local ragdoll = pl:GetRagdollEntity()
	   
    if(!ragdoll || ragdoll == NULL || !ragdoll:IsValid()) then return end
       
    local eyes = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))  
    local view = {
        origin = eyes.Pos,
        angles = eyes.Ang,
		fov = 90, 
		}
        return view
    end
	-- If the model has no eyes...
	if (!eyes) then
	return
	end
    hook.Add("CalcView", "DeathView", CalcView)
end
