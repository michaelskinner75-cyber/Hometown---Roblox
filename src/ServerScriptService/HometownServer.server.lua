local Players = game:GetService("Players")

local STARTING_CASH = 10000
local PLOT_PRICE = 2500
local HOUSE_PRICE = 4000
local SALE_PRICE = 8000

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
	part.Parent = parent
	return part
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

local function updateSign(plotModel, message, action)
	local sign = plotModel:FindFirstChild("Sign")
	local prompt = sign and sign:FindFirstChild("PropertyPrompt")
	local gui = sign and sign:FindFirstChild("BillboardGui")
	local label = gui and gui:FindFirstChild("TextLabel")
	if label then label.Text = message end
	if prompt then prompt.ActionText = action end
end

local function createHouse(plotModel)
	local centre = plotModel.Plot.Position
	local house = Instance.new("Model")
	house.Name = "House"
	house.Parent = plotModel

	makePart("Foundation", Vector3.new(38, 1, 34), centre + Vector3.new(0, 1, 0), Color3.fromRGB(175, 175, 175), Enum.Material.Concrete, house)
	makePart("MainBuilding", Vector3.new(32, 16, 28), centre + Vector3.new(0, 9, 0), Color3.fromRGB(230, 205, 165), Enum.Material.Brick, house)
	makePart("Roof", Vector3.new(36, 5, 32), centre + Vector3.new(0, 19.5, 0), Color3.fromRGB(90, 55, 45), Enum.Material.Slate, house)
	makePart("Door", Vector3.new(5, 9, 1), centre + Vector3.new(0, 5.5, -14.5), Color3.fromRGB(65, 105, 85), Enum.Material.Wood, house)

	for _, xOffset in ipairs({-9, 9}) do
		local window = makePart("Window", Vector3.new(6, 6, 0.7), centre + Vector3.new(xOffset, 10, -14.6), Color3.fromRGB(155, 215, 255), Enum.Material.Glass, house)
		window.Transparency = 0.25
	end
end

for index, position in ipairs(plotPositions) do
	local plotModel = Instance.new("Model")
	plotModel.Name = "Plot" .. index
	plotModel:SetAttribute("OwnerUserId", 0)
	plotModel:SetAttribute("HouseBuilt", false)
	plotModel.Parent = plotsFolder

	makePart("Plot", Vector3.new(62, 1, 70), position, Color3.fromRGB(103, 170, 92), Enum.Material.Grass, plotModel)
	local signDirection = position.Z > 0 and -1 or 1
	local sign = makePart("Sign", Vector3.new(8, 6, 1), position + Vector3.new(0, 4, signDirection * 31), Color3.fromRGB(245, 245, 245), Enum.Material.Wood, plotModel)

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
		local leaderstats = player:FindFirstChild("leaderstats")
		local cash = leaderstats and leaderstats:FindFirstChild("Cash")
		if not cash then return end

		local ownerId = plotModel:GetAttribute("OwnerUserId")
		local houseBuilt = plotModel:GetAttribute("HouseBuilt")

		if ownerId == 0 then
			if cash.Value < PLOT_PRICE then return end
			cash.Value -= PLOT_PRICE
			plotModel:SetAttribute("OwnerUserId", player.UserId)
			updateSign(plotModel, player.DisplayName .. "'s Plot\nREADY TO BUILD", "Build House £4,000")
			return
		end

		if ownerId ~= player.UserId then return end

		if not houseBuilt then
			if cash.Value < HOUSE_PRICE then return end
			cash.Value -= HOUSE_PRICE
			createHouse(plotModel)
			plotModel:SetAttribute("HouseBuilt", true)
			updateSign(plotModel, "FINISHED HOUSE\nVALUE £8,000", "Sell House £8,000")
			return
		end

		local house = plotModel:FindFirstChild("House")
		if house then house:Destroy() end
		cash.Value += SALE_PRICE
		plotModel:SetAttribute("OwnerUserId", 0)
		plotModel:SetAttribute("HouseBuilt", false)
		updateSign(plotModel, "FOR SALE\n£2,500", "Buy Plot")
	end)
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = STARTING_CASH
	cash.Parent = leaderstats
end)
