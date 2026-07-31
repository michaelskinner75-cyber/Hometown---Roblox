local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")
local store = DataStoreService:GetDataStore("HometownPropertyProgressV1")

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

local function tierInfo(level)
	level = math.clamp(math.floor(tonumber(level) or 1), 1, 50)
	local totalValue = math.floor((2500 + 1800 * (1.17 ^ (level - 1))) / 100 + 0.5) * 100
	return {
		Name = LEVEL_NAMES[level],
		SalePrice = totalValue,
		Rent = math.max(50, math.floor((totalValue * 0.018) / 10 + 0.5) * 10),
	}
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
	return part
end

local function addDoor(house, centre, front, width, height, distance)
	makePart(house, "Door", Vector3.new(width, height, 1), centre + Vector3.new(0, height / 2 + 1, front * distance), Color3.fromRGB(45, 65, 85), Enum.Material.Metal)
end

local function rebuildHouse(plot, level)
	level = math.clamp(math.floor(tonumber(level) or 1), 1, 50)
	local old = plot:FindFirstChild("House")
	if old then old:Destroy() end

	local centre = plot.Plot.Position
	local front = plot:GetAttribute("FrontDirection") or -1
	local info = tierInfo(level)
	local house = Instance.new("Model")
	house.Name = "House"
	house:SetAttribute("HouseType", "Tier" .. level)
	house:SetAttribute("DisplayName", info.Name)
	house:SetAttribute("SalePrice", info.SalePrice)
	house:SetAttribute("Rent", info.Rent)
	house:SetAttribute("UpgradeTier", level)
	house.Parent = plot

	if level <= 2 then
		local width = 12 + level * 2
		local depth = 10 + level
		makePart(house, "TentFloor", Vector3.new(width, 0.5, depth), centre + Vector3.new(0, 1.2, 0), Color3.fromRGB(105, 80, 55), Enum.Material.WoodPlanks)
		local canvas = makePart(house, "TentCanvas", Vector3.new(width, 7 + level, depth), centre + Vector3.new(0, 5, 0), Color3.fromRGB(75 + level * 10, 125 + level * 8, 80), Enum.Material.Fabric)
		canvas.Shape = Enum.PartType.Wedge
	elseif level <= 6 then
		local localLevel = level - 2
		local width = 18 + localLevel * 3
		local height = 8 + localLevel * 1.5
		local depth = 16 + localLevel * 2
		makePart(house, "Cabin", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 1, 0), Color3.fromRGB(135, 95, 60), Enum.Material.WoodPlanks)
		makePart(house, "Roof", Vector3.new(width + 4, 2.5, depth + 4), centre + Vector3.new(0, height + 2.2, 0), Color3.fromRGB(75, 58, 45), Enum.Material.Slate)
		addDoor(house, centre, front, 4, 7, depth / 2 + 0.6)
	elseif level <= 20 then
		local localLevel = level - 7
		local floors = 1 + math.floor((localLevel - 1) / 4)
		local width = math.min(48, 25 + localLevel * 1.4)
		local depth = math.min(38, 21 + localLevel)
		local height = floors * 9
		makePart(house, "MainBuilding", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 1, 0), Color3.fromRGB(205, 195, 175), Enum.Material.Brick)
		makePart(house, "Roof", Vector3.new(width + 4, 3, depth + 4), centre + Vector3.new(0, height + 2.5, 0), Color3.fromRGB(75, 58, 50), Enum.Material.Slate)
		for floor = 1, floors do
			local y = 5 + (floor - 1) * 9
			for _, x in ipairs({-width * 0.28, width * 0.28}) do
				makeWindow(house, Vector3.new(5, 4, 0.6), Vector3.new(centre.X + x, centre.Y + y, centre.Z + front * (depth / 2 + 0.35)))
			end
		end
		addDoor(house, centre, front, 5, 8, depth / 2 + 0.6)
	elseif level <= 30 then
		local localLevel = level - 20
		local width = math.min(50, 38 + localLevel)
		local depth = math.min(40, 30 + localLevel * 0.5)
		local height = 18 + math.floor(localLevel / 3) * 4
		local stone = Color3.fromRGB(228, 220, 202)
		makePart(house, "MansionMain", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 1, 0), stone, Enum.Material.Marble)
		makePart(house, "LeftWing", Vector3.new(11, height * 0.72, depth - 4), centre + Vector3.new(-width / 2 - 5, height * 0.36 + 1, 1), stone, Enum.Material.Marble)
		makePart(house, "RightWing", Vector3.new(11, height * 0.72, depth - 4), centre + Vector3.new(width / 2 + 5, height * 0.36 + 1, 1), stone, Enum.Material.Marble)
		makePart(house, "Roof", Vector3.new(width + 5, 4, depth + 5), centre + Vector3.new(0, height + 3, 0), Color3.fromRGB(65, 50, 45), Enum.Material.Slate)
		addDoor(house, centre, front, 7, 10, depth / 2 + 0.6)
	else
		local localLevel = level - 30
		local width = math.min(48, 30 + localLevel * 0.7)
		local depth = math.min(38, 25 + localLevel * 0.45)
		local height = 35 + localLevel * 6
		makePart(house, "Podium", Vector3.new(math.min(54, width + 9), 8, math.min(44, depth + 8)), centre + Vector3.new(0, 5, 0), Color3.fromRGB(80, 85, 95), Enum.Material.Concrete)
		local tower = makePart(house, "Tower", Vector3.new(width, height, depth), centre + Vector3.new(0, height / 2 + 9, 0), Color3.fromRGB(65, 95, 125), Enum.Material.Glass)
		tower.Transparency = 0.08
		if level >= 41 then makePart(house, "Crown", Vector3.new(width * 0.72, 8 + (level - 40), depth * 0.72), centre + Vector3.new(0, height + 14, 0), Color3.fromRGB(35, 42, 52), Enum.Material.Metal) end
		if level >= 47 then makePart(house, "Spire", Vector3.new(3, 25 + (level - 47) * 8, 3), centre + Vector3.new(0, height + 34, 0), Color3.fromRGB(195, 205, 215), Enum.Material.Metal) end
		addDoor(house, centre, front, 9, 10, depth / 2 + 4.6)
	end

	plot:SetAttribute("HouseBuilt", true)
	plot:SetAttribute("HouseType", "Tier" .. level)
	plot:SetAttribute("UpgradeTier", level)
	return house
end

local function findOwnedPlot(userId)
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and (plot:GetAttribute("OwnerUserId") or 0) == userId then
			return plot
		end
	end
end

local function snapshot(player)
	local plot = findOwnedPlot(player.UserId)
	if not plot then return {HasProperty = false} end
	return {
		HasProperty = true,
		PlotName = plot.Name,
		Tier = math.clamp(plot:GetAttribute("UpgradeTier") or 1, 1, 50),
		MarketStatus = plot:GetAttribute("MarketStatus") or "None",
		TenantName = plot:GetAttribute("TenantName") or "",
	}
end

local function savePlayer(player)
	local data = snapshot(player)
	local ok, err = pcall(function()
		store:UpdateAsync("player_" .. player.UserId, function()
			return data
		end)
	end)
	if not ok then warn("Property save failed for", player.Name, err) end
end

local function restorePlayer(player)
	local ok, data = pcall(function()
		return store:GetAsync("player_" .. player.UserId)
	end)
	if not ok then warn("Property load failed for", player.Name, data); return end
	if type(data) ~= "table" or data.HasProperty ~= true then return end

	local plot = data.PlotName and plotsFolder:FindFirstChild(data.PlotName)
	if not plot or (plot:GetAttribute("OwnerUserId") or 0) ~= 0 then
		for _, candidate in ipairs(plotsFolder:GetChildren()) do
			if candidate:IsA("Model") and (candidate:GetAttribute("OwnerUserId") or 0) == 0 then
				plot = candidate
				break
			end
		end
	end
	if not plot then warn("No free plot available to restore", player.Name); return end

	plot:SetAttribute("OwnerUserId", player.UserId)
	plot:SetAttribute("MarketStatus", data.MarketStatus == "Rented" and "Rented" or "None")
	plot:SetAttribute("TenantName", tostring(data.TenantName or ""))
	rebuildHouse(plot, data.Tier)
	plot:SetAttribute("MarketStatus", data.MarketStatus == "Rented" and "Rented" or "None")
	plot:SetAttribute("TenantName", tostring(data.TenantName or ""))
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		task.wait(3)
		restorePlayer(player)
	end)
end)

Players.PlayerRemoving:Connect(savePlayer)

task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(savePlayer, player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)

print("Property persistence loaded")