if SERVER then return end
local PANEL = {}
	function PANEL:Init()
		self:SetPos(ScrW()/3, ScrH()/3)
		self:SetSize(ScrW()/2, ScrH()/2)
		self:MakePopup()
		self.panel = vgui.Create("DPanel", self)
		self.panel:SetSize( 0.98630137 * self:GetWide(), 0.79802955665025 * self:GetTall() )
		self.panel:SetPos( 0.01369863 * self:GetWide(), 0.078817733990148 * self:GetTall() )
		self.list = vgui.Create("DScrollPanel", self.panel)
		self.list:Dock(FILL)
		self.list:SetDrawBackground(true)

		self.page = 1
		function refreshCrafting()
			self:SetTitle(self.title or "")
			if (IsValid(self.list)) then
				self.list:Remove()
			end
			self.list = vgui.Create("DScrollPanel", self.panel)
			self.list:Dock(FILL)
			self.list:SetDrawBackground(true)
			if (self.page == 1) then
				self.craftButton:SetText("Craft")
				self.craftButton:SetEnabled(false)
				self.craftButton:SetTextColor(Color(0,0,0,200))
				self.closeBackButton:SetText("Close")
				self.closeBackButton.DoClick = function()
					self:Remove()
				end

				addCategoryButtons(self.craftableitems)
			elseif (self.page == 2) then
				self.closeBackButton:SetText("Back")
				self.closeBackButton.DoClick = function()
					self.page = 1
					addCategoryButtons(self.craftableitems)
					refreshCrafting()
				end

				self.craftButton:SetText("Craft")
				self.craftButton:SetEnabled(false)
				self.craftButton:SetTextColor(Color(0,0,0,200))
				self.craftButton.DoClick = function()
					netstream.Start("nut_lc_CraftItem", self.itemSelected.uniqueID, self.caller)
				end
				addItemButtons(self.categorySelected)
			end
		end

		function addCategoryButtons(categories)
			self.categories = {}
			if categories and table.getn(categories) > 0 then
				for k, v in SortedPairs(nut.item.list) do
					local id = v.uniqueID
					if (table.HasValue(categories, id)) then
						local cat = v.category
						if (!table.HasValue(self.categories, cat)) then
							table.insert(self.categories, cat)
						end
					end
				end
			else
				self.youHaveNo = vgui.Create("DLabel", self)
				local t = "You don't have objects to craft"
				self.youHaveNo:SetText(t)
				local width, heigth = surface.GetTextSize(t)
				self.youHaveNo:SetSize(width,heigth)
				self.youHaveNo:SetPos( ((0.78630136986301 * self:GetWide()) - (0.01369863 * self:GetWide()) - (0.2 * self:GetWide()))/2 + (self.youHaveNo:GetWide()/2), 0.91625615763547 * self:GetTall() )
				self.youHaveNo:SetZPos(999)
			end

			local localPos = 0
			local buttonSizeW = 0.98630137 * self:GetWide()
			local buttonSizeH = 0.2 * self:GetTall()
			for _, v in pairs(self.categories) do
				local creatingButton = vgui.Create("DButton", self.list)
				creatingButton:SetText(v)
				creatingButton:SetPos(0, localPos)
				creatingButton:SetSize(buttonSizeW, buttonSizeH)
				creatingButton.DoClick = function()
					self.categorySelected = v
					self.page = 2
					refreshCrafting()
				end
				self.categoriesButtons[v] = creatingButton
				localPos = localPos + buttonSizeH
			end
		end

		function addItemButtons(category, itemSel)
			self.oldButton = nil
			self.oldLabel = nil
			self.oldDesc = nil
			items = {}
			if category then
				for k, v in SortedPairs(nut.item.list) do
					local id = v.uniqueID
					if (table.HasValue(self.craftableitems, id)) then
						local cat = v.category
						if (cat == category) then
							table.insert(items, v)
						end
					end
				end
			end
			if (IsValid(self.list)) then
				self.list:Remove()
			end
			self.list = vgui.Create("DScrollPanel", self.panel)
			self.list:Dock(FILL)
			self.list:SetDrawBackground(true)

			local localPos = 0
			local buttonSizeW = 0.98630137 * self:GetWide()
			local buttonSizeH = 0.2 * self:GetTall()
			self.itemsButtons = {}
			self.itemIcons = {}
			self.itemLabels = {}
			self.itemDescs = {}
			for _, v in pairs(items) do
				local creatingItemButton = vgui.Create("DButton", self.list)
				local icon = vgui.Create("nutItemIcon", self.list)
				local name = vgui.Create("DLabel", self.list)
				local desc = vgui.Create("DLabel", self.list)

				name:SetTextColor(Color(100,100,100,200))
				name:SetFont("nutMediumFont")
				local width, heigth = surface.GetTextSize(v.name)
				name:SetSize(width*2, heigth*1.25)
				name:SetPos(0.01369863 * self:GetWide() + 100, localPos + ((buttonSizeH) / 3) - 5)
				name:SetText(v.name)

				self.itemLabels[v.name] = name

				local text = v.desc
				if text == "noDesc" then
					text = "No valid description has been provided"
				end
				desc:SetTextColor(Color(100,100,100,200))
				desc:SetFont("nutSmallFont")
				local w, h = surface.GetTextSize(text)
				desc:SetSize(math.min(w, buttonSizeW), h)
				desc:SetPos(0.01369863 * self:GetWide() + 100, localPos + (3*(buttonSizeH) / 5) - 5)
				desc:SetText(text)

				self.itemDescs[v.name] = desc

				icon:SetSize(64, 64)
				icon:SetZPos(999)
				icon:SetModel(v.model)
				icon:SetPos(0.01369863 * self:GetWide(), localPos + (buttonSizeH - 64) / 2)

				self.itemIcons[v.name] = icon

				creatingItemButton:SetText("")
				creatingItemButton:SetPos(0, localPos)
				creatingItemButton:SetSize(buttonSizeW, buttonSizeH)
				creatingItemButton.OnCursorEntered = function()
					if (self.oldButton != creatingItemButton) then
						name:SetTextColor(Color(255,255,255,255))
						desc:SetTextColor(Color(255,255,255,255))
					end
				end
				creatingItemButton.OnCursorExited = function()
					if (self.oldButton != creatingItemButton) then
						name:SetTextColor(Color(100,100,100,200))
						desc:SetTextColor(Color(100,100,100,200))
					end
				end
				creatingItemButton.DoClick = function()
					self.itemSelected = v
					if (self.oldButton) then
						self.oldButton:SetEnabled(true)
					end
					if (self.oldLabel) then
						self.oldLabel:SetTextColor(Color(100,100,100,200))
					end
					if (self.oldDesc) then
						self.oldDesc:SetTextColor(Color(100,100,100,200))
					end
					self.craftButton:SetEnabled(true)
					self.craftButton:SetTextColor(Color(255,255,255,255))
					creatingItemButton:SetEnabled(false)
					name:SetTextColor(Color(255,255,255,255))
					desc:SetTextColor(Color(255,255,255,255))
					self.oldButton = self.itemsButtons[v.name]
					self.oldLabel = name
					self.oldDesc = desc
				end

				self.itemsButtons[v.name] = creatingItemButton
				localPos = localPos + buttonSizeH
			end
		end

		self.closeBackButton = vgui.Create( "DButton", self )
		self.closeBackButton:SetPos( 0.78630136986301 * self:GetWide(), 0.91625615763547 * self:GetTall() )
		self.closeBackButton:SetSize( 0.2 * self:GetWide(), 0.054187192118227 * self:GetTall() )
		self.closeBackButton:SetText("Close")
		self.closeBackButton:SetTextColor(Color(255,255,255,255))
		self.closeBackButton:SetDrawBackground(true)
		self.closeBackButton.DoClick = function()
			self:Remove()
		end
		self.craftButton = vgui.Create( "DButton", self )
		self.craftButton:SetEnabled(false)
		self.craftButton:SetPos( 0.01369863 * self:GetWide(), 0.91625615763547 * self:GetTall() )
		self.craftButton:SetSize( 0.2 * self:GetWide(), 0.054187192118227 * self:GetTall() )
		self.craftButton:SetText("Craft")
		self.craftButton:SetTextColor(Color(255,255,255,255))

		self.categories = {}
		self.categorySelected = ""
		self.nextBuy = 0
		self.categoriesButtons = {}
		self.itemsButtons = {}
		self.itemSelected = ""
		self.done = false
	end

	function PANEL:Think()
		if (!self:IsActive()) then
			self:MakePopup()
		end
		if (self.done) then
			refreshCrafting()
			self.done = false
		end
	end
vgui.Register("nut_lc_Crafting", PANEL, "DFrame")
