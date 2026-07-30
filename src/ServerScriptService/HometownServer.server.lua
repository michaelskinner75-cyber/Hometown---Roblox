local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local STARTING_CASH = 10000
local PLOT_PRICE = 2500

local HOUSE_TYPES = {
	Bungalow = {
		Name = "Starter Bungalow",
		Price = 2500,
		SalePrice = 3500,
		Description = "A cosy one-storey starter home",
	},
	FamilySemi = {
		Name = "Family Semi",
		Price = 4000,
		SalePrice = 5750,
		Description = "Two floors, driveway and garage",
	},
	Cottage = {
		Name = "Country Cottage",
		Price = 5500,
		SalePrice = 8000,
		Description = "Stone walls, chimney and garden",
	},
	Modern = {
		Name = "Modern Home",
		Price = 7500,
		SalePrice = 11000,
		Description = "Large windows and a flat roof",
	},
}

local remotes = ReplicatedStorage:FindFirstChild("HometownRemotes") or Instance.new("Folder")
remotes.Name = "HometownRemotes"
remotes.Parent = ReplicatedStorage

local openHouseMenu = remotes:FindFirstChild("OpenHouseMenu") or Instance.new("RemoteEvent")
openHouseMenu.Name = "OpenHouseMenu"
openHouseMenu.Parent = remotes

local buildHouseRequest = remotes:FindFirstChild("BuildHouseRequest") or Instance.new("RemoteEvent")
buildHouseRequest.Name = "BuildHouseRequest"
buildHouseRequest.Parent = remotes

local oldWorld = workspace:FindFirstChild("HometownWorld")
if oldWorld then
	oldWorld:Destroy()
end

local world = Instance.new("Folder")
world.Name = "HometownWorld"
world.Parent = workspace

local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end

local function makePart(name, size, position, colour, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Color = colour
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeWindow(size, position, parent)
	local window = makePart("Window", size, position, Color3.fromRGB(150, 215, 255), Enum.Material.Glass, parent)
	window.Transparency = 0.2
	window.Reflectance = 0.08
	return window
end

local function makeRoofWedge(name, size, position, rotationY, colour, parent)
	local wedge = Instance.new("WedgePart")
	wedge.Name = name
	wedge.Size = size
	wedge.Position = position
	wedge.Orientation = Vector3.new(0, rotationY, 0)
	wedge.Anchored = true
	wedge.Color = colour
	wedge.Material = Enum.Material.Slate
	wedge.Parent = parent
	return wedge
end

makePart("Ground", Vector3.new(420, 2, 420), Vector3.new(0, -1, 0), Color3.fromRGB(83, 145, 76), Enum.Material.Grass, world)
makePart("Road", Vector3.new(320, 1, 42), Vector3.new(0, 0.1, 0), Color3.fromRGB(50, 52, 56), Enum.Material.Asphalt, world)
makePart("Pavement1", Vector3.new(320, 1, 10), Vector3.new(0, 0.5, 26), Color3.fromRGB(170, 170, 170), Enum.Material.Concrete, world)
makePart("Pavement2", Vector3.new(320, 1, 10), Vector3.new(0, 0.5, -26), Color3.fromRGB(170, 170, 170), Enum.Material.Concrete, world)

for x = -140, 140, 30 do
	makePart("RoadMarking", Vector3.new(15, 0.15, 1), Vector3.new(x, 0.7, 0), Color3.fromRGB(245, 245, 225), Enum.Material.SmoothPlastic, world)
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "TownSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 1, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 0.25
spawn.Color = Color3.fromRGB(65, 170, 255)
spawn.Parent = world

local plotsFolder = Instance.new("Folder")
plotsFolder.Name = "Plots"
plotsFolder.Parent = world

local plotPositions = {
	Vector3.new(-110, 0.5, 75), Vector3.new(-35, 0.5, 75), Vector3.new(40, 0.5, 75), Vector3.new(115, 0.5, 75),
	Vector3.new(-110, 0.5, -75), Vector3.new(-35, 0.5, -75), Vector3.new(40, 0.5, -75), Vector3.new(115, 0.5, -75),
}

local wallColours = {
	Color3.fromRGB(234, 211, 171),
	Color3.fromRGB(217, 226, 232),
	Color3.fromRGB(229, 195, 184),
	Color3.fromRGB(205, 220, 191),
}

local function updateSign(plotModel, message, action)
	local sign = plotModel:FindFirstChild("Sign")
	local prompt = sign and sign:FindFirstChild("PropertyPrompt")
	local gui = sign and sign:FindFirstChild("BillboardGui")
	local label = gui and gui:FindFirstChild("TextLabel")
	if label then label.Text = message end
	if prompt then prompt.ActionText = action end
end

local function addFrontFeature(centre, frontDirection, x, y, distance, size, name, colour, material, parent)
	local z = centre.Z + frontDirection * distance
	return makePart(name, size, Vector3.new(centre.X + x, centre.Y + y, z), colour, material, parent)
end

local function createBungalow(plotModel, house, centre, frontDirection, wallColour)
	makePart("Foundation", Vector3.new(40, 1, 34), centre + Vector3.new(0, 1, 0), Color3.fromRGB(180, 180, 180), Enum.Material.Concrete, house)
	makePart("MainBuilding", Vector3.new(34, 12, 28), centre + Vector3.new(0, 7, 0), wallColour, Enum.Material.Brick, house)
	makePart("Roof", Vector3.new(38, 4, 32), centre + Vector3.new(0, 15, 0), Color3.fromRGB(80, 58, 50), Enum.Material.Slate, house)
	addFrontFeature(centre, frontDirection, 0, 5, 14.5, Vector3.new(5, 8, 1), "Door", Color3.fromRGB(50, 105, 85), Enum.Material.Wood, house)
	for _, x in ipairs({-10, 10}) do
		makeWindow(Vector3.new(6, 5, 0.7), Vector3.new(centre.X + x, centre.Y + 8, centre.Z + frontDirection * 14.6), house)
	end
	makePart("FrontPath", Vector3.new(5, 0.3, 15), centre + Vector3.new(0, 1, frontDirection * 21), Color3.fromRGB(150, 150, 150), Enum.Material.Concrete, house)
end

local function createFamilySemi(plotModel, house, centre, frontDirection, wallColour)
	makePart("Foundation", Vector3.new(44, 1, 38), centre + Vector3.new(0, 1, 0), Color3.fromRGB(175, 175, 175), Enum.Material.Concrete, house)
	makePart("MainBuilding", Vector3.new(30, 22, 30), centre + Vector3.new(-5, 12, 0), wallColour, Enum.Material.Brick, house)
	makePart("Garage", Vector3.new(13, 11, 26), centre + Vector3.new(17, 6.5, 2), Color3.fromRGB(205, 205, 198), Enum.Material.Brick, house)
	makePart("Roof", Vector3.new(34, 5, 34), centre + Vector3.new(-5, 25.5, 0), Color3.fromRGB(75, 65, 60), Enum.Material.Slate, house)
	addFrontFeature(centre, frontDirection, -5, 5, 15.5, Vector3.new(5, 8, 1), "Door", Color3.fromRGB(55, 80, 125), Enum.Material.Wood, house)
	addFrontFeature(centre, frontDirection, 17, 5, 11.5, Vector3.new(11, 8, 1), "GarageDoor", Color3.fromRGB(235, 235, 230), Enum.Material.Metal, house)
	for _, y in ipairs({8, 17}) do
		for _, x in ipairs({-13, 3}) do
			makeWindow(Vector3.new(5, 5, 0.7), Vector3.new(centre.X + x, centre.Y + y, centre.Z + frontDirection * 15.6), house)
		end
	end
	makePart("Driveway", Vector3.new(14, 0.3, 22), centre + Vector3.new(17, 1, frontDirection * 23), Color3.fromRGB(115, 115, 115), Enum.Material.Concrete, house)
end

local function createCottage(plotModel, house, centre, frontDirection)
	local stone = Color3.fromRGB(178, 169, 148)
	makePart("Foundation", Vector3.new(42, 1, 36), centre + Vector3.new(0, 1, 0), Color3.fromRGB(145, 145, 140), Enum.Material.Cobblestone, house)
	makePart("MainBuilding", Vector3.new(36, 15, 30), centre + Vector3.new(0, 8.5, 0), stone, Enum.Material.Cobblestone, house)
	makePart("Roof", Vector3.new(42, 6, 35), centre + Vector3.new(0, 19, 0), Color3.fromRGB(85, 52, 40), Enum.Material.Slate, house)
	makePart("Chimney", Vector3.new(5, 12, 5), centre + Vector3.new(12, 22, 4), Color3.fromRGB(125, 78, 60), Enum.Material.Brick, house)
	addFrontFeature(centre, frontDirection, 0, 5, 15.5, Vector3.new(5, 8, 1), "CottageDoor", Color3.fromRGB(95, 55, 35), Enum.Material.WoodPlanks, house)
	for _, x in ipairs({-11, 11}) do
		makeWindow(Vector3.new(6, 6, 0.8), Vector3.new(centre.X + x, centre.Y + 10, centre.Z + frontDirection * 15.6), house)
	end
	for _, x in ipairs({-20, 20}) do
		makePart("FlowerBed", Vector3.new(6, 1.2, 5), centre + Vector3.new(x, 1.6, frontDirection * 17), Color3.fromRGB(90, 65, 45), Enum.Material.Ground, house)
		for flower = -2, 2, 2 do
			makePart("Flower", Vector3.new(0.7, 1.7, 0.7), centre + Vector3.new(x + flower, 2.8, frontDirection * 17), Color3.fromRGB(235, 105 + flower * 10, 145), Enum.Material.Neon, house)
		end
	end
end

local function createModern(plotModel, house, centre, frontDirection)
	makePart("Foundation", Vector3.new(46, 1, 38), centre + Vector3.new(0, 1, 0), Color3.fromRGB(125, 125, 125), Enum.Material.Concrete, house)
	makePart("LowerFloor", Vector3.new(42, 11, 32), centre + Vector3.new(0, 6.5, 0), Color3.fromRGB(225, 225, 220), Enum.Material.Concrete, house)
	makePart("UpperFloor", Vector3.new(32, 10, 26), centre + Vector3.new(-5, 17, -2 * frontDirection), Color3.fromRGB(75, 82, 88), Enum.Material.Concrete, house)
	makePart("FlatRoof", Vector3.new(36, 1.5, 30), centre + Vector3.new(-5, 22.8, -2 * frontDirection), Color3.fromRGB(35, 38, 42), Enum.Material.SmoothPlastic, house)
	addFrontFeature(centre, frontDirection, 13, 5, 16.5, Vector3.new(6, 9, 1), "ModernDoor", Color3.fromRGB(35, 35, 35), Enum.Material.Metal, house)
	local lowerGlass = makeWindow(Vector3.new(20, 7, 0.8), Vector3.new(centre.X - 7, centre.Y + 7, centre.Z + frontDirection * 16.5), house)
	lowerGlass.Name = "PanoramicWindow"
	local upperGlass = makeWindow(Vector3.new(22, 6, 0.8), Vector3.new(centre.X - 5, centre.Y + 17, centre.Z + frontDirection * 15.1), house)
	upperGlass.Name = "UpperWindow"
	makePart("Balcony", Vector3.new(25, 1, 6), centre + Vector3.new(-5, 13, frontDirection * 17), Color3.fromRGB(105, 105, 105), Enum.Material.Concrete, house)
	makePart("Driveway", Vector3.new(12, 0.3, 22), centre + Vector3.new(16, 1, frontDirection * 23), Color3.fromRGB(90, 90, 90), Enum.Material.Concrete, house)
end

local function createHouse(plotModel, houseKey)
	local houseInfo = HOUSE_TYPES[houseKey]
	if not houseInfo then return nil end

	local centre = plotModel.Plot.Position
	local frontDirection = plotModel:GetAttribute("FrontDirection") or -1
	local colourIndex = ((tonumber(plotModel.Name:match("%d+")) or 1) - 1) % #wallColours + 1
	local wallColour = wallColours[colourIndex]

	local house = Instance.new("Model")
	house.Name = "House"
	house:SetAttribute("HouseType", houseKey)
	house:SetAttribute("DisplayName", houseInfo.Name)
	house:SetAttribute("SalePrice", houseInfo.SalePrice)
	house.Parent = plotModel

	if houseKey == "Bungalow" then
		createBungalow(plotModel, house, centre, frontDirection, wallColour)
	elseif houseKey == "FamilySemi" then
		createFamilySemi(plotModel, house, centre, frontDirection, wallColour)
	elseif houseKey == "Cottage" then
		createCottage(plotModel, house, centre, frontDirection)
	elseif houseKey == "Modern" then
		createModern(plotModel, house, centre, frontDirection)
	end

	return house
end

local function getPlayerCash(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	return leaderstats and leaderstats:FindFirstChild("Cash")
end

for index, position in ipairs(plotPositions) do
	local plotModel = Instance.new("Model")
	plotModel.Name = "Plot" .. index
	plotModel:SetAttribute("OwnerUserId", 0)
	plotModel:SetAttribute("HouseBuilt", false)
	plotModel:SetAttribute("HouseType", "")
	plotModel.Parent = plotsFolder

	makePart("Plot", Vector3.new(62, 1, 70), position, Color3.fromRGB(103, 170, 92), Enum.Material.Grass, plotModel)
	local frontDirection = position.Z > 0 and -1 or 1
	plotModel:SetAttribute("FrontDirection", frontDirection)
	local sign = makePart("Sign", Vector3.new(8, 6, 1), position + Vector3.new(0, 4, frontDirection * 31), Color3.fromRGB(245, 245, 245), Enum.Material.Wood, plotModel)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PropertyPrompt"
	prompt.ActionText = "Buy Plot"
	prompt.ObjectText = "Hometown Property"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = sign

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 110)
	gui.StudsOffset = Vector3.new(0, 4.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Name = "TextLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 0.05
	label.TextColor3 = Color3.fromRGB(30, 90, 50)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = "FOR SALE\n£2,500"
	label.Parent = gui

	prompt.Triggered:Connect(function(player)
		local cash = getPlayerCash(player)
		if not cash then return end

		local ownerId = plotModel:GetAttribute("OwnerUserId")
		local houseBuilt = plotModel:GetAttribute("HouseBuilt")

		if ownerId == 0 then
			if cash.Value < PLOT_PRICE then return end
			cash.Value -= PLOT_PRICE
			plotModel:SetAttribute("OwnerUserId", player.UserId)
			updateSign(plotModel, player.DisplayName .. "'s Plot\nCHOOSE A HOUSE", "Choose House")
			return
		end

		if ownerId ~= player.UserId then return end

		if not houseBuilt then
			openHouseMenu:FireClient(player, plotModel.Name, HOUSE_TYPES)
			return
		end

		local house = plotModel:FindFirstChild("House")
		local salePrice = house and house:GetAttribute("SalePrice") or 0
		if house then house:Destroy() end
		cash.Value += salePrice
		plotModel:SetAttribute("OwnerUserId", 0)
		plotModel:SetAttribute("HouseBuilt", false)
		plotModel:SetAttribute("HouseType", "")
		updateSign(plotModel, "FOR SALE\n£2,500", "Buy Plot")
	end)
end

buildHouseRequest.OnServerEvent:Connect(function(player, plotName, houseKey)
	if typeof(plotName) ~= "string" or typeof(houseKey) ~= "string" then return end
	local plotModel = plotsFolder:FindFirstChild(plotName)
	local houseInfo = HOUSE_TYPES[houseKey]
	local cash = getPlayerCash(player)
	if not plotModel or not houseInfo or not cash then return end
	if plotModel:GetAttribute("OwnerUserId") ~= player.UserId then return end
	if plotModel:GetAttribute("HouseBuilt") then return end
	if cash.Value < houseInfo.Price then return end

	cash.Value -= houseInfo.Price
	local house = createHouse(plotModel, houseKey)
	if not house then
		cash.Value += houseInfo.Price
		return
	end

	plotModel:SetAttribute("HouseBuilt", true)
	plotModel:SetAttribute("HouseType", houseKey)
	updateSign(plotModel, houseInfo.Name:upper() .. "\nVALUE £" .. string.format("%,d", houseInfo.SalePrice), "Sell for £" .. string.format("%,d", houseInfo.SalePrice))
end)

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = STARTING_CASH
	cash.Parent = leaderstats
end)