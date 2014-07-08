local PANEL = {}
	function PANEL:Init()
		self:SetPos(ScrW() * 0.250, ScrH() * 0.125)
		self:SetSize(ScrW() * 0.5, ScrH() * 0.75)
		self:MakePopup()
		self:ShowCloseButton(false)
		self:SetDraggable(false)
		self:SetDrawOnTop(true)
		self:SetTitle("Book 1")
		

		local panel = self:Add("DScrollPanel")
		panel:Dock(FILL)
		panel:SetDrawBackground(false) // You can edit this if you want to draw those ugly eye-destroyer white background

		local text = panel:Add("HTML", "DLabel")
		text:Dock(FILL)
		text:SetSize(512, 400) // If you need moar space to your text, you can adjust this c:
		text:SetPos(0, 10)
		text:SetHTML([[
		<p align="center"><font color='red' size='6'>TITLE HERE</font></p><br/>
		<font color='white' size='2'>HI GUYS, THIS IS A TEST TEXT.
		YOU CAN USE HTML WHEN YOU'RE WRITTING YOUR BOOKS.
		IT'S A SIMPLE-MADE KIND OF BOOK PLUGIN. YOU CAN EDIT AS YOU
		WANT. BUT DO NOT SELL IT OR MAKE MONEY WITH IT OR...<br/>
		<img src = "http://www.quickmeme.com/img/c0/c05b2dbeb09bc025bcc7cdcfa9a68a72d4939bc71403074360a272e9e28969bb.jpg" height="200" width="450"><br/>
		OH, IT WASN'T A THREAT.</font>
		<br/>
		<br/>
		<font color='white'>Yes, it was c:</font>
		
		]])

		local submit = self:Add("DButton")
		submit:Dock(BOTTOM)
		submit:DockMargin(0, 5, 0, 0)
		submit:SetText("Close")
		submit.DoClick = function()
			self:Close()
			nut.gui.data:Remove()
		end
	end
vgui.Register("nut_book1", PANEL, "DFrame")

netstream.Hook("nut_book1", function()
	if (nut.gui.charMenu) then
		nut.gui.charMenu:Remove()
	end

	nut.gui.data = vgui.Create("nut_book1")
end)

// PS: Don't blame me if I failed on my English, I'm spaniard c:
