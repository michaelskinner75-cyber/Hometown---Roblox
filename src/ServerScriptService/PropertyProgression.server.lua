local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local PLOT_PRICE = 2500

local LEVEL_NAMES = {
	"Camping Tent", "Large Tent", "Wooden Shelter", "Tiny Cabin", "Basic Shack",
	"Improved Shack", "Small Cottage", "Cosy Cottage", "Starter Bungalow", "Modern Bungalow",
	"Small Family Home", "Family Home", "Large Family Home", "Semi-Detached House", "Detached House",
	"Large Detached House", "Executive Home", "Luxury Home", "Country Villa", "Modern Villa",
	"Luxury Villa", "Grand Villa", "Small Manor", "Country Manor", "Grand Manor",
	"Mini Mansion", "Luxury Mansion", "Grand Mansion", "Estate Mansion", "Royal Mansion",
	"Low-Rise Apartments", "Apartment Block", "Large Apartment Block", "Luxury Apartments", "Residential Tower",
	"City Tower", "Glass Tower", "Executive Tower", "Prestige Tower", "Metropolitan Tower",
	"Downtown Skyscraper", "Luxury Skyscraper", "Financial Tower", "Landmark Tower", "Grand Skyscraper",
	"Supertall Tower", "Hometown Spire", "Hometown Megatower", "Sky City", "Hometown World Tower",
}

local TIERS = {}
for level, name in ipairs(LEVEL_NAMES) do
	local upgradeCost
	if level == 1 then
		upgradeCost = 0
	else
		upgradeCost = math.floor(900 * (1.19 ^ (level - 2)) / 50 + 0.5) * 50
	end
	local totalValue = math.floor((PLOT_PRICE + 1800 * (1.17 ^ (level - 1))) / 100 + 0.5) * 100
	local rent = math.max(50, math.floor((totalValue * 0.018) / 10 + 0.5) * 10)
	TIERS[level] = {
		Name = name,
		UpgradeCost = upgradeCost,
		SalePrice = totalValue,
		Rent = rent,
	}
end

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
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = colour
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeWindow(parent, size, position)
	local part = makePart(parent, "Window", size, position, Color3.fromRGB(115, 205, 255), Enum.Material.Glass)
	part.Transparency = 0.25
	part.Reflectance = 0.08
	return part
end

local function addDoor(house, centre, front, width, height, distance)
	return makePart(
		house,
		"Door",
		Vector3.new(width, height, 1),
		centre + Vector3.new(0, height / 2 + 1, front * distance),
		Color3.fromRGB(45, 65, 85),
		Enum.Material.Metal
	)
end

local function buildTent(house, centre, level)
	local width = 12 + level * 2
	local depth = 10 + level
	makePart(house, "TentFloor", Vector3.new(width, 0.5, depth), centre + Vector3.new(0, 1.2, 0), Color3.fromRGB(105, 80, 55), Enum.Material.WoodPlanks)
	local canvas = makePart(house, "TentCanvas", Vector3.new(width, 7 + level, depth), centre + Vector3.new(0, 5, 0), Color3.fromRGB(75 + level * 10, 125 + level * 8, 80), Enum.Material.Fabric)
	canvas.Shape = Enum.PartType.Wedge
end

local function buildCabin(house, centre, front, level)
	local localLevel = level - 2
	local width = 18 + localLevel * 3
	local height = 8 + localLevel * 1.5
	local depth = 16 + localLevel * 2
	makePart(house, "Cabin", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 1, 0), Color3.fromRGB(135, 95, 60), Enum.Material.WoodPlanks)
	makePart(house, "Roof", Vector3.new(width + 4, 2.5, depth + 4), centre + Vector3.new(0, height + 2.2, 0), Color3.fromRGB(75, 58, 45), Enum.Material.Slate)
	addDoor(house, centre, front, 4, 7, depth / 2 + 0.6)
end

local function buildHouse(house, centre, front, level)
	local localLevel = level - 7
	local floors = 1 + math.floor((localLevel - 1) / 4)
	local width = math.min(48, 25 + localLevel * 1.4)
	local depth = math.min(38, 21 + localLevel)
	local floorHeight = 9
	local height = floors * floorHeight
	local wallColour = Color3.fromRGB(225 - math.min(55, localLevel * 3), 210 - math.min(40, localLevel * 2), 185 + math.min(45, localLevel * 2))
	makePart(house, "MainBuilding", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 1, 0), wallColour, Enum.Material.Brick)
	makePart(house, "Roof", Vector3.new(width + 4, 3, depth + 4), centre + Vector3.new(0, height + 2.5, 0), Color3.fromRGB(75, 58, 50), Enum.Material.Slate)
	if level >= 14 then
		makePart(house, "Garage", Vector3.new(13, 9, depth - 4), centre + Vector3.new(width / 2 + 7, 5.5, 1), Color3.fromRGB(205, 205, 198), Enum.Material.Concrete)
	end
	for floor = 1, floors do
		local y = 5 + (floor - 1) * floorHeight
		for _, x in ipairs({-width * 0.28, width * 0.28}) do
			makeWindow(house, Vector3.new(5, 4, 0.6), Vector3.new(centre.X + x, centre.Y + y, centre.Z + front * (depth / 2 + 0.35)))
		end
	end
	addDoor(house, centre, front, 5, 8, depth / 2 + 0.6)
end

local function buildMansion(house, centre, front, level)
	local localLevel = level - 20
	local width = math.min(50, 38 + localLevel)
	local depth = math.min(40, 30 + localLevel * 0.5)
	local height = 18 + math.floor(localLevel / 3) * 4
	local stone = Color3.fromRGB(228, 220, 202)
	makePart(house, "MansionMain", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 1, 0), stone, Enum.Material.Marble)
	makePart(house, "LeftWing", Vector3.new(11, height * 0.72, depth - 4), centre + Vector3.new(-width / 2 - 5, height * 0.36 + 1, 1), stone, Enum.Material.Marble)
	makePart(house, "RightWing", Vector3.new(11, height * 0.72, depth - 4), centre + Vector3.new(width / 2 + 5, height * 0.36 + 1, 1), stone, Enum.Material.Marble)
	makePart(house, "Roof", Vector3.new(width + 5, 4, depth + 5), centre + Vector3.new(0, height + 3, 0), Color3.fromRGB(65, 50, 45), Enum.Material.Slate)
	for _, x in ipairs({-width * 0.3, -width * 0.1, width * 0.1, width * 0.3}) do
		makeWindow(house, Vector3.new(4, 6, 0.6), Vector3.new(centre.X + x, centre.Y + height * 0.58, centre.Z + front * (depth / 2 + 0.35)))
	end
	addDoor(house, centre, front, 7, 10, depth / 2 + 0.6)
end

local function buildTower(house, centre, front, level)
	local localLevel = level - 30
	local width = math.min(48, 30 + localLevel * 0.7)
	local depth = math.min(38, 25 + localLevel * 0.45)
	local height = 35 + localLevel * 6
	local bodyColour = Color3.fromRGB(math.max(40, 90 - localLevel * 2), math.max(65, 110 - localLevel), math.min(145, 120 + localLevel))
	makePart(house, "Podium", Vector3.new(math.min(54, width + 9), 8, math.min(44, depth + 8)), centre + Vector3.new(0, 5, 0), Color3.fromRGB(80, 85, 95), Enum.Material.Concrete)
	local tower = makePart(house, "Tower", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 9, 0), bodyColour, Enum.Material.Glass)
	tower.Transparency = 0.08
	for y = 16, height + 5, 9 do
		makeWindow(house, Vector3.new(width - 4, 4, 0.45), Vector3.new(centre.X, centre.Y + y, centre.Z + front * (depth / 2 + 0.25)))
	end
	if level >= 41 then
		makePart(house, "Crown", Vector3.new(width * 0.72, 8 + (level - 40), depth * 0.72), centre + Vector3.new(0, height + 14, 0), Color3.fromRGB(35, 42, 52), Enum.Material.Metal)
	end
	if level >= 47 then
		makePart(house, "Spire", Vector3.new(3, 25 + (level - 47) * 8, 3), centre + Vector3.new(0, height + 34, 0), Color3.fromRGB(195, 205, 215), Enum.Material.Metal)
	end
	addDoor(house, centre, front, 9, 10, depth / 2 + 4.6)
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

	if tier <= 2 then
		buildTent(house, centre, tier)
	elseif tier <= 6 then
		buildCabin(house, centre, front, tier)
	elseif tier <= 20 then
		buildHouse(house, centre, front, tier)
	elseif tier <= 30 then
		buildMansion(house, centre, front, tier)
	else
		buildTower(house, centre, front, tier)
	end

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
		prompt.ObjectText = "Level 1 Tent - " .. money(PLOT_PRICE)
		if label then label.Text = "FOR SALE\n" .. money(PLOT_PRICE) .. "\nSTARTS AT LEVEL 1" end
	elseif tier < #TIERS then
		local currentTier = TIERS[math.max(1, tier)]
		local nextTier = TIERS[tier + 1]
		prompt.ActionText = "Upgrade to Level " .. (tier + 1)
		prompt.ObjectText = nextTier.Name .. " - " .. money(nextTier.UpgradeCost)
		if label then
			label.Text = "LEVEL " .. tier .. ": " .. currentTier.Name:upper() .. "\nNEXT: " .. nextTier.Name:upper() .. "\n" .. money(nextTier.UpgradeCost)
		end
	else
		prompt.ActionText = "Maximum Level"
		prompt.ObjectText = "Level 50 - " .. TIERS[50].Name
		if label then label.Text = "LEVEL 50\n" .. TIERS[50].Name:upper() .. "\nMAXIMUM LEVEL" end
	end
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then
		local sign = plot:WaitForChild("Sign")
		for _, child in ipairs(sign:GetChildren()) do
			if child:IsA("ProximityPrompt") then child:Destroy() end
		end

		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "ProgressionPrompt"
		prompt.HoldDuration = 0.35
		prompt.MaxActivationDistance = 14
		prompt.RequiresLineOfSight = false
		prompt.Parent = sign

		plot:SetAttribute("UpgradeTier", plot:GetAttribute("UpgradeTier") or 0)
		refresh(plot, prompt)

		prompt.Triggered:Connect(function(player)
			local cash = cashValue(player)
			if not cash then return end
			local owner = plot:GetAttribute("OwnerUserId") or 0
			local tier = plot:GetAttribute("UpgradeTier") or 0

			if owner == 0 then
				if cash.Value < PLOT_PRICE then return end
				cash.Value -= PLOT_PRICE
				plot:SetAttribute("OwnerUserId", player.UserId)
				buildTier(plot, 1)
			elseif owner == player.UserId and tier < #TIERS then
				local cost = TIERS[tier + 1].UpgradeCost
				if cash.Value < cost then return end
				cash.Value -= cost
				buildTier(plot, tier + 1)
			end
			refresh(plot, prompt)
		end)

		task.spawn(function()
			while plot.Parent do
				refresh(plot, prompt)
				task.wait(2)
			end
		end)
	end
end

print("50-level property progression loaded")
