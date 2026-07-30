local Players = game:GetService("Players")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local PLOT_PRICE = 2500
local TIERS = {
	{Name="Starter House", UpgradeCost=0, SalePrice=5000, Rent=250},
	{Name="Family Home", UpgradeCost=5000, SalePrice=11000, Rent=500},
	{Name="Detached House", UpgradeCost=10000, SalePrice=23000, Rent=850},
	{Name="Luxury Villa", UpgradeCost=25000, SalePrice=52000, Rent=1500},
	{Name="Mansion", UpgradeCost=60000, SalePrice=120000, Rent=3000},
	{Name="Apartment Tower", UpgradeCost=150000, SalePrice=300000, Rent=7000},
	{Name="Hometown Skyscraper", UpgradeCost=400000, SalePrice=800000, Rent=18000},
}

local function money(value)
	local text = tostring(math.floor(value))
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return "£" .. text
end

local function cashValue(player)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

local function makePart(parent, name, size, position, colour, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.CanCollide = true
	p.Color = colour
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function window(parent, size, position)
	local p = makePart(parent, "Window", size, position, Color3.fromRGB(120,205,255), Enum.Material.Glass)
	p.Transparency = 0.25
	return p
end

local function buildTier(plot, tier)
	local old = plot:FindFirstChild("House")
	if old then old:Destroy() end

	local centre = plot.Plot.Position
	local front = plot:GetAttribute("FrontDirection") or -1
	local info = TIERS[tier]
	local house = Instance.new("Model")
	house.Name = "House"
	house:SetAttribute("HouseType", "Tier" .. tier)
	house:SetAttribute("DisplayName", info.Name)
	house:SetAttribute("SalePrice", info.SalePrice)
	house:SetAttribute("Rent", info.Rent)
	house:SetAttribute("UpgradeTier", tier)
	house.Parent = plot

	local wall = Color3.fromRGB(225 - tier * 8, 215 - tier * 5, 195 + tier * 4)
	local roof = Color3.fromRGB(70,55,50)

	if tier == 1 then
		makePart(house,"Body",Vector3.new(26,10,22),centre+Vector3.new(0,6,0),wall,Enum.Material.Brick)
		makePart(house,"Roof",Vector3.new(30,3,26),centre+Vector3.new(0,12.5,0),roof,Enum.Material.Slate)
	elseif tier == 2 then
		makePart(house,"Body",Vector3.new(32,16,26),centre+Vector3.new(0,9,0),wall,Enum.Material.Brick)
		makePart(house,"Roof",Vector3.new(36,4,30),centre+Vector3.new(0,19,0),roof,Enum.Material.Slate)
	elseif tier == 3 then
		makePart(house,"Main",Vector3.new(36,20,28),centre+Vector3.new(-4,11,0),wall,Enum.Material.Brick)
		makePart(house,"Garage",Vector3.new(14,12,24),centre+Vector3.new(21,7,2),Color3.fromRGB(205,205,200),Enum.Material.Concrete)
		makePart(house,"Roof",Vector3.new(40,4,32),centre+Vector3.new(-4,23,0),roof,Enum.Material.Slate)
	elseif tier == 4 then
		makePart(house,"Lower",Vector3.new(42,12,32),centre+Vector3.new(0,7,0),Color3.fromRGB(235,235,230),Enum.Material.Concrete)
		makePart(house,"Upper",Vector3.new(34,11,26),centre+Vector3.new(-5,18,-2*front),Color3.fromRGB(90,100,110),Enum.Material.Concrete)
		makePart(house,"FlatRoof",Vector3.new(38,1.5,30),centre+Vector3.new(-5,24.2,-2*front),Color3.fromRGB(35,38,42),Enum.Material.Metal)
	elseif tier == 5 then
		makePart(house,"MansionMain",Vector3.new(46,24,34),centre+Vector3.new(0,13,0),Color3.fromRGB(226,218,200),Enum.Material.Marble)
		makePart(house,"LeftWing",Vector3.new(14,18,28),centre+Vector3.new(-27,10,2),Color3.fromRGB(226,218,200),Enum.Material.Marble)
		makePart(house,"RightWing",Vector3.new(14,18,28),centre+Vector3.new(27,10,2),Color3.fromRGB(226,218,200),Enum.Material.Marble)
		makePart(house,"Roof",Vector3.new(54,4,40),centre+Vector3.new(0,27,0),roof,Enum.Material.Slate)
	elseif tier == 6 then
		makePart(house,"Podium",Vector3.new(48,8,38),centre+Vector3.new(0,5,0),Color3.fromRGB(95,100,110),Enum.Material.Concrete)
		makePart(house,"Tower",Vector3.new(34,58,28),centre+Vector3.new(0,38,0),Color3.fromRGB(70,90,105),Enum.Material.Glass)
		for y=14,62,8 do window(house,Vector3.new(30,4,0.5),Vector3.new(centre.X,centre.Y+y,centre.Z+front*14.2)) end
	else
		makePart(house,"Podium",Vector3.new(52,10,42),centre+Vector3.new(0,6,0),Color3.fromRGB(70,75,82),Enum.Material.Concrete)
		makePart(house,"Skyscraper",Vector3.new(38,110,32),centre+Vector3.new(0,66,0),Color3.fromRGB(55,75,92),Enum.Material.Glass)
		makePart(house,"Crown",Vector3.new(30,12,26),centre+Vector3.new(0,127,0),Color3.fromRGB(35,40,48),Enum.Material.Metal)
		for y=18,112,8 do window(house,Vector3.new(34,4,0.5),Vector3.new(centre.X,centre.Y+y,centre.Z+front*16.2)) end
	end

	local doorName = tier >= 6 and "TowerEntrance" or "Door"
	makePart(house,doorName,Vector3.new(tier>=6 and 9 or 5,tier>=6 and 10 or 8,1),centre+Vector3.new(0,tier>=6 and 6 or 5,front*(tier>=6 and 19.5 or (tier==5 and 17.5 or 14.5))),Color3.fromRGB(40,55,70),Enum.Material.Metal)

	plot:SetAttribute("HouseBuilt", true)
	plot:SetAttribute("HouseType", "Tier" .. tier)
	plot:SetAttribute("UpgradeTier", tier)
	plot:SetAttribute("MarketStatus", "None")
	plot:SetAttribute("TenantName", "")
	return house
end

local function signLabel(plot)
	local sign = plot:FindFirstChild("Sign")
	local gui = sign and sign:FindFirstChild("BillboardGui")
	return gui and gui:FindFirstChild("TextLabel")
end

local function refresh(plot, prompt)
	local owner = plot:GetAttribute("OwnerUserId") or 0
	local tier = plot:GetAttribute("UpgradeTier") or 0
	local label = signLabel(plot)
	if owner == 0 then
		prompt.ActionText = "Buy Property"
		prompt.ObjectText = "Starter property " .. money(PLOT_PRICE)
		if label then label.Text = "FOR SALE\n" .. money(PLOT_PRICE) .. "\nINCLUDES STARTER HOUSE" end
	elseif tier < #TIERS then
		local nextTier = TIERS[tier + 1]
		prompt.ActionText = "Upgrade"
		prompt.ObjectText = nextTier.Name .. " - " .. money(nextTier.UpgradeCost)
		if label then label.Text = TIERS[tier].Name:upper() .. "\nNEXT: " .. nextTier.Name:upper() .. "\n" .. money(nextTier.UpgradeCost) end
	else
		prompt.ActionText = "Fully Upgraded"
		prompt.ObjectText = TIERS[tier].Name
		if label then label.Text = "HOMETOWN SKYSCRAPER\nMAX LEVEL" end
	end
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then
		local sign = plot:WaitForChild("Sign")
		local oldPrompt = sign:FindFirstChild("PropertyPrompt")
		if oldPrompt then oldPrompt:Destroy() end

		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "ProgressionPrompt"
		prompt.HoldDuration = 0.35
		prompt.MaxActivationDistance = 14
		prompt.RequiresLineOfSight = false
		prompt.Parent = sign

		plot:SetAttribute("UpgradeTier", plot:GetAttribute("UpgradeTier") or 0)
		refresh(plot,prompt)

		prompt.Triggered:Connect(function(player)
			local cash = cashValue(player)
			if not cash then return end
			local owner = plot:GetAttribute("OwnerUserId") or 0
			local tier = plot:GetAttribute("UpgradeTier") or 0

			if owner == 0 then
				if cash.Value < PLOT_PRICE then return end
				cash.Value -= PLOT_PRICE
				plot:SetAttribute("OwnerUserId", player.UserId)
				buildTier(plot,1)
			elseif owner == player.UserId and tier < #TIERS then
				local cost = TIERS[tier+1].UpgradeCost
				if cash.Value < cost then return end
				cash.Value -= cost
				buildTier(plot,tier+1)
			end
			refresh(plot,prompt)
		end)

		task.spawn(function()
			while plot.Parent do
				refresh(plot,prompt)
				task.wait(2)
			end
		end)
	end
end

print("Property upgrade progression loaded")