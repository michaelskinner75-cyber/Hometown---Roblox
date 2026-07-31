local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local properties = {
	{name = "Wooden Shed", template = ServerStorage:WaitForChild("House01_WoodenShed"), price = 2500, rent = 50, yawOffset = math.rad(180)},
	{name = "Tree House", template = ServerStorage:WaitForChild("House02_TreeHouse"), price = 7500, rent = 150, yawOffset = math.rad(180)},
	{name = "Log Cabin", template = ServerStorage:WaitForChild("House03_LogCabin"), price = 15000, rent = 300, yawOffset = math.rad(180)},
	{name = "Small House", template = ServerStorage:WaitForChild("House04_SmallHouse"), price = 35000, rent = 700, yawOffset = math.rad(180)},
	{name = "Large House", template = ServerStorage:WaitForChild("House05_LargeHouse"), price = 75000, rent = 1500, yawOffset = math.rad(180)},
}

local function findMoneyValue(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		for _, name in ipairs({"Cash", "Money", "Coins", "Balance"}) do
			local value = leaderstats:FindFirstChild(name)
			if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
				return value
			end
		end
	end
	for _, name in ipairs({"Cash", "Money", "Coins", "Balance"}) do
		local value = player:FindFirstChild(name)
		if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
			return value
		end
	end
	return nil
end

local function getBalance(player)
	local value = findMoneyValue(player)
	if value then return value.Value end
	for _, name in ipairs({"Cash", "Money", "Coins", "Balance"}) do
		local attribute = player:GetAttribute(name)
		if typeof(attribute) == "number" then return attribute end
	end
	return 0
end

local function changeBalance(player, amount)
	local value = findMoneyValue(player)
	if value then
		value.Value += amount
		return true
	end
	for _, name in ipairs({"Cash", "Money", "Coins", "Balance"}) do
		local attribute = player:GetAttribute(name)
		if typeof(attribute) == "number" then
			player:SetAttribute(name, attribute + amount)
			return true
		end
	end
	return false
end

local function cleanModel(model)
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
			object:Destroy()
		elseif object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
			object:Destroy()
		elseif object:IsA("BasePart") then
			object.Anchored = true
		end
	end
end

local function disableLegacyPlotControls(plot)
	local selector = plot:FindFirstChild("HouseSelector")
	if selector then selector:Destroy() end
	for _, object in ipairs(plot:GetDescendants()) do
		if object:IsA("ProximityPrompt") then
			object.Enabled = false
		elseif object:IsA("BasePart") then
			local lower = string.lower(object.Name)
			if string.find(lower, "upgrade") or string.find(lower, "sell") or string.find(lower, "rentpad") then
				object.Transparency = 1
				object.CanCollide = false
			end
		end
	end
end

local roadCentreZ = 0
local grounds = {}
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if plot:IsA("Model") and ground and ground:IsA("BasePart") and not plot:GetAttribute("CommercialReserved") then
		table.insert(grounds, {plot = plot, ground = ground})
		roadCentreZ += ground.Position.Z
	end
end
if #grounds > 0 then roadCentreZ /= #grounds end

table.sort(grounds, function(a, b)
	if math.abs(a.ground.Position.X - b.ground.Position.X) > 0.1 then
		return a.ground.Position.X < b.ground.Position.X
	end
	return a.ground.Position.Z < b.ground.Position.Z
end)

local function createSign(plot, ground, title, price, rent)
	local old = plot:FindFirstChild("RentalPropertySign")
	if old then old:Destroy() end

	local roadSide = ground.Position.Z > roadCentreZ and -1 or 1
	local sign = Instance.new("Part")
	sign.Name = "RentalPropertySign"
	sign.Size = Vector3.new(6, 4, 0.5)
	sign.Anchored = true
	sign.CanCollide = false
	sign.Position = Vector3.new(ground.Position.X, ground.Position.Y + 3, ground.Position.Z + roadSide * ((ground.Size.Z / 2) - 3))
	sign.Parent = plot

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(320, 150)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 130
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Name = "PropertyText"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(30, 45, 55)
	label.BackgroundTransparency = 0.08
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Text = string.format("%s\nBUY £%s\nRENT £%s / 30 SEC", title, price, rent)
	label.Parent = gui

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "BuyRentalProperty"
	prompt.ActionText = "Buy for £" .. price
	prompt.ObjectText = title
	prompt.HoldDuration = 0.8
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = sign
	return prompt, label
end

local function placePropertyBuilding(plot, ground, data, index)
	disableLegacyPlotControls(plot)
	local oldHouse = plot:FindFirstChild("House")
	if oldHouse then oldHouse:Destroy() end

	local house = data.template:Clone()
	house.Name = "House"
	house:SetAttribute("ImportedHouseLevel", index)
	house:SetAttribute("RentalProperty", true)
	house.Parent = plot
	cleanModel(house)

	local _, size = house:GetBoundingBox()
	local scale = math.min(
		(ground.Size.X * 0.78) / math.max(size.X, 0.01),
		(ground.Size.Z * 0.72) / math.max(size.Z, 0.01),
		1
	)
	if scale < 1 then house:ScaleTo(scale) end

	local facesRoadYaw = ground.Position.Z > roadCentreZ and math.rad(180) or 0
	local yaw = facesRoadYaw + data.yawOffset
	house:PivotTo(CFrame.new(ground.Position.X, 0, ground.Position.Z) * CFrame.Angles(0, yaw, 0))
	local box, boxSize = house:GetBoundingBox()
	local bottomY = box.Position.Y - boxSize.Y / 2
	local targetY = ground.Position.Y + ground.Size.Y / 2
	house:PivotTo(CFrame.new(0, targetY - bottomY, 0) * house:GetPivot())

	plot:SetAttribute("RentalPropertyName", data.name)
	plot:SetAttribute("PurchasePrice", data.price)
	plot:SetAttribute("RentIncome", data.rent)
	plot:SetAttribute("RentalOwnerUserId", 0)
	plot:SetAttribute("HouseBuilt", true)

	local prompt, label = createSign(plot, ground, data.name, data.price, data.rent)
	prompt.Triggered:Connect(function(player)
		if (plot:GetAttribute("RentalOwnerUserId") or 0) ~= 0 then return end
		if getBalance(player) < data.price then return end
		if not changeBalance(player, -data.price) then return end
		plot:SetAttribute("RentalOwnerUserId", player.UserId)
		plot:SetAttribute("RentalOwnerName", player.Name)
		prompt.Enabled = false
		label.Text = string.format("%s\nOWNED BY %s\nRENT £%s / 30 SEC", data.name, player.DisplayName, data.rent)
	end)
end

task.wait(3)
for index, data in ipairs(properties) do
	local entry = grounds[index]
	if entry then
		placePropertyBuilding(entry.plot, entry.ground, data, index)
	end
end

-- McDonald's is a premium commercial rental property.
task.spawn(function()
	local highStreet = world:WaitForChild("HighStreet", 20)
	if not highStreet then return end
	local restaurant = highStreet:FindFirstChild("HighStreetRestaurant", true)
	if not restaurant then return end
	local box, size = restaurant:GetBoundingBox()
	local sign = Instance.new("Part")
	sign.Name = "McDonaldsPurchaseSign"
	sign.Size = Vector3.new(7, 5, 0.6)
	sign.Anchored = true
	sign.CanCollide = false
	sign.Position = box.Position + Vector3.new(0, -size.Y / 2 + 3, size.Z / 2 + 4)
	sign.Parent = highStreet

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(350, 160)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 150
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Text = "McDONALD'S\nBUY £1,000,000\nRENT £20,000 / 30 SEC"
	label.Parent = gui

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Buy for £1,000,000"
	prompt.ObjectText = "McDonald's"
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = sign

	highStreet:SetAttribute("McDonaldsOwnerUserId", 0)
	prompt.Triggered:Connect(function(player)
		if (highStreet:GetAttribute("McDonaldsOwnerUserId") or 0) ~= 0 then return end
		if getBalance(player) < 1000000 then return end
		if not changeBalance(player, -1000000) then return end
		highStreet:SetAttribute("McDonaldsOwnerUserId", player.UserId)
		highStreet:SetAttribute("McDonaldsOwnerName", player.Name)
		prompt.Enabled = false
		label.Text = "McDONALD'S\nOWNED BY " .. player.DisplayName .. "\nRENT £20,000 / 30 SEC"
	end)
end)

-- Pay rent every 30 seconds while the owner is in the server.
task.spawn(function()
	while true do
		task.wait(30)
		for index, data in ipairs(properties) do
			local entry = grounds[index]
			if entry then
				local ownerId = entry.plot:GetAttribute("RentalOwnerUserId") or 0
				if ownerId > 0 then
					local player = Players:GetPlayerByUserId(ownerId)
					if player then changeBalance(player, data.rent) end
				end
			end
		end
		local highStreet = world:FindFirstChild("HighStreet")
		if highStreet then
			local ownerId = highStreet:GetAttribute("McDonaldsOwnerUserId") or 0
			if ownerId > 0 then
				local player = Players:GetPlayerByUserId(ownerId)
				if player then changeBalance(player, 20000) end
			end
		end
	end
end)

print("Fresh prebuilt buy-to-rent property portfolio loaded")
