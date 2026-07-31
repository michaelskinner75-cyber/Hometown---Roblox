local Players = game:GetService("Players")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local PAD_SPACING = 9
local PAD_FORWARD_OFFSET = 7
local PAD_SIZE = Vector3.new(0.5, 5, 5)
local TOUCH_COOLDOWN = 1.5

local function addLabel(part, text)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ActionLabel"
	billboard.Size = UDim2.fromOffset(170, 50)
	billboard.StudsOffset = Vector3.new(0, 2.8, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.1
	label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = billboard
end

local function createPad(folder, name, text, colour, cframe)
	local pad = Instance.new("Part")
	pad.Name = name
	pad.Shape = Enum.PartType.Cylinder
	pad.Size = PAD_SIZE
	pad.CFrame = cframe * CFrame.Angles(0, 0, math.rad(90))
	pad.Anchored = true
	pad.CanCollide = true
	pad.Material = Enum.Material.Neon
	pad.Color = colour
	pad.TopSurface = Enum.SurfaceType.Smooth
	pad.BottomSurface = Enum.SurfaceType.Smooth
	pad.Parent = folder
	addLabel(pad, text)
	return pad
end

local function classifyPrompt(prompt)
	local name = string.lower(prompt.Name)
	local action = string.lower(prompt.ActionText or "")

	if string.find(name, "sell") or string.find(action, "sell") then
		return "Sell"
	elseif string.find(name, "rent") or string.find(action, "rent") or string.find(action, "tenant") then
		return "Rent"
	elseif string.find(name, "progress") or string.find(action, "buy") or string.find(action, "upgrade") then
		return "Build"
	end

	return nil
end

local function getPlayerFromHit(hit)
	local character = hit and hit.Parent
	if not character then return nil end
	return Players:GetPlayerFromCharacter(character)
end

local function cashValue(player)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

local function resetProperty(plot)
	local house = plot:FindFirstChild("House")
	if house then house:Destroy() end

	local tenantReference = plot:FindFirstChild("TenantNpc")
	if tenantReference then
		if tenantReference:IsA("ObjectValue") and tenantReference.Value then
			tenantReference.Value:Destroy()
		end
		tenantReference:Destroy()
	end

	plot:SetAttribute("OwnerUserId", 0)
	plot:SetAttribute("HouseBuilt", false)
	plot:SetAttribute("HouseType", "")
	plot:SetAttribute("UpgradeTier", 0)
	plot:SetAttribute("MarketStatus", "None")
	plot:SetAttribute("TenantName", "")
end

local function setupPlot(plot)
	local sign = plot:WaitForChild("Sign")
	local oldFolder = plot:FindFirstChild("InteractionPads")
	if oldFolder then oldFolder:Destroy() end

	local folder = Instance.new("Folder")
	folder.Name = "InteractionPads"
	folder.Parent = plot

	local base = sign.CFrame * CFrame.new(0, -sign.Size.Y / 2 + 0.25, PAD_FORWARD_OFFSET)
	local buildPad = createPad(folder, "BuildPad", "BUY / UPGRADE", Color3.fromRGB(45, 170, 75), base * CFrame.new(-PAD_SPACING, 0, 0))
	local rentPad = createPad(folder, "RentPad", "STAND TO RENT", Color3.fromRGB(60, 130, 220), base)
	local sellPad = createPad(folder, "SellPad", "STAND TO SELL", Color3.fromRGB(220, 75, 75), base * CFrame.new(PAD_SPACING, 0, 0))

	local destinations = {
		Build = buildPad,
		Rent = rentPad,
		Sell = sellPad,
	}

	local rentDebounce = {}
	local sellDebounce = {}

	rentPad.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)
		if not player or rentDebounce[player] then return end
		if (plot:GetAttribute("OwnerUserId") or 0) ~= player.UserId then return end
		if (plot:GetAttribute("UpgradeTier") or 0) <= 0 then return end

		rentDebounce[player] = true
		local rented = (plot:GetAttribute("MarketStatus") or "None") == "Rented"
		plot:SetAttribute("MarketStatus", rented and "None" or "Rented")
		plot:SetAttribute("TenantName", rented and "" or "Hometown Tenant")
		task.delay(TOUCH_COOLDOWN, function() rentDebounce[player] = nil end)
	end)

	sellPad.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)
		if not player or sellDebounce[player] then return end
		if (plot:GetAttribute("OwnerUserId") or 0) ~= player.UserId then return end

		local house = plot:FindFirstChild("House")
		local salePrice = house and (house:GetAttribute("SalePrice") or 0) or 0
		local cash = cashValue(player)
		if not cash or salePrice <= 0 then return end

		sellDebounce[player] = true
		cash.Value += salePrice
		resetProperty(plot)
		task.delay(TOUCH_COOLDOWN, function() sellDebounce[player] = nil end)
	end)

	task.spawn(function()
		while plot.Parent do
			for _, descendant in ipairs(plot:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") then
					local kind = classifyPrompt(descendant)
					local destination = kind and destinations[kind]
					if destination and descendant.Parent ~= destination then
						descendant.Parent = destination
						descendant.MaxActivationDistance = 6
						descendant.RequiresLineOfSight = false
						descendant.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
					end
				end
			end
			task.wait(0.5)
		end
	end)
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then setupPlot(plot) end
end

plotsFolder.ChildAdded:Connect(function(plot)
	if plot:IsA("Model") then setupPlot(plot) end
end)

print("Separate property interaction pads loaded")
