local ServerStorage = game:GetService("ServerStorage")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local houseChoices = {
	{name = "Wooden Shed", template = ServerStorage:WaitForChild("House01_WoodenShed")},
	{name = "Tree House", template = ServerStorage:WaitForChild("House02_TreeHouse")},
	{name = "Log Cabin", template = ServerStorage:WaitForChild("House03_LogCabin")},
	{name = "Small House", template = ServerStorage:WaitForChild("House04_SmallHouse")},
	{name = "Large House", template = ServerStorage:WaitForChild("House05_LargeHouse")},
}

local function cleanImportedModel(model)
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

local roadCentreZ = 0
local plotCount = 0
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if ground and ground:IsA("BasePart") then
		roadCentreZ += ground.Position.Z
		plotCount += 1
	end
end
if plotCount > 0 then
	roadCentreZ /= plotCount
end

local function isOwnedBy(plot, player)
	local ownerUserId = plot:GetAttribute("OwnerUserId") or plot:GetAttribute("OwnerId")
	if typeof(ownerUserId) == "number" then
		return ownerUserId == player.UserId
	end

	local ownerName = plot:GetAttribute("OwnerName") or plot:GetAttribute("Owner")
	if typeof(ownerName) == "string" and ownerName ~= "" then
		return ownerName == player.Name
	end

	return plot:GetAttribute("Owned") == true
end

local function placeHouse(plot, choiceIndex)
	local ground = plot:FindFirstChild("Plot")
	local choice = houseChoices[choiceIndex]
	if not ground or not choice then return end

	local oldHouse = plot:FindFirstChild("House")
	if oldHouse then oldHouse:Destroy() end

	local house = choice.template:Clone()
	house.Name = "House"
	house:SetAttribute("ImportedHouseLevel", choiceIndex)
	house:SetAttribute("ImportedHouseName", choice.name)
	house.Parent = plot
	cleanImportedModel(house)

	local _, initialSize = house:GetBoundingBox()
	local availableX = ground.Size.X * 0.82
	local availableZ = ground.Size.Z * 0.82
	local scale = math.min(
		availableX / math.max(initialSize.X, 0.01),
		availableZ / math.max(initialSize.Z, 0.01),
		1
	)
	if scale < 1 then
		house:ScaleTo(scale)
	end

	-- All five imports were facing away from the road, so use the opposite yaw.
	-- Plots above the road face south; plots below the road face north.
	local yaw = ground.Position.Z > roadCentreZ and math.rad(180) or 0
	house:PivotTo(CFrame.new(ground.Position.X, 0, ground.Position.Z) * CFrame.Angles(0, yaw, 0))

	local boxCFrame, boxSize = house:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
	local targetY = ground.Position.Y + ground.Size.Y / 2
	house:PivotTo(CFrame.new(0, targetY - bottomY, 0) * house:GetPivot())

	plot:SetAttribute("HouseBuilt", true)
	plot:SetAttribute("SelectedHouseType", choiceIndex)
	plot:SetAttribute("SelectedHouseName", choice.name)
end

local function createSelector(plot)
	if plot:GetAttribute("CommercialReserved") then return end
	local ground = plot:FindFirstChild("Plot")
	if not ground or not ground:IsA("BasePart") then return end

	local oldSelector = plot:FindFirstChild("HouseSelector")
	if oldSelector then oldSelector:Destroy() end

	-- Start empty. A house is only placed after the plot owner chooses one.
	local existingHouse = plot:FindFirstChild("House")
	if existingHouse then existingHouse:Destroy() end
	plot:SetAttribute("HouseBuilt", false)

	local selector = Instance.new("Folder")
	selector.Name = "HouseSelector"
	selector.Parent = plot

	local roadSide = ground.Position.Z > roadCentreZ and -1 or 1
	local buttonSpacing = 7
	local startX = -((#houseChoices - 1) * buttonSpacing) / 2

	for index, choice in ipairs(houseChoices) do
		local button = Instance.new("Part")
		button.Name = "ChooseHouse" .. index
		button.Size = Vector3.new(5.5, 0.6, 5.5)
		button.Anchored = true
		button.CanCollide = false
		button.Material = Enum.Material.Neon
		button.Position = Vector3.new(
			ground.Position.X + startX + ((index - 1) * buttonSpacing),
			ground.Position.Y + ground.Size.Y / 2 + 0.35,
			ground.Position.Z + roadSide * ((ground.Size.Z / 2) - 5)
		)
		button.Parent = selector

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Build " .. choice.name
		prompt.ObjectText = "Choose your home"
		prompt.HoldDuration = 0.4
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Enabled = false
		prompt.Parent = button

		prompt.Triggered:Connect(function(player)
			if isOwnedBy(plot, player) then
				placeHouse(plot, index)
			end
		end)
	end

	task.spawn(function()
		while selector.Parent do
			local owned = false
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				if isOwnedBy(plot, player) then
					owned = true
					break
				end
			end
			for _, object in ipairs(selector:GetDescendants()) do
				if object:IsA("ProximityPrompt") then
					object.Enabled = owned
				end
			end
			task.wait(0.5)
		end
	end)
end

task.wait(3)
for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then
		createSelector(plot)
	end
end

print("Owned plots now allow players to choose one of five road-facing houses")
