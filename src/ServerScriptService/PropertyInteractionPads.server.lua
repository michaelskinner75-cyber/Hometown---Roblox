local Players = game:GetService("Players")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local PAD_SPACING = 12
local PAD_FORWARD_OFFSET = 8
local PAD_SIZE = Vector3.new(0.5, 5, 5)

local function money(value)
	local text = tostring(math.floor(value))
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return "£" .. text
end

local function addLabel(part, text)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ActionLabel"
	billboard.Size = UDim2.fromOffset(180, 52)
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
	return label
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
	local label = addLabel(pad, text)
	return pad, label
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

local function createActionPrompt(parent, name, actionText, objectText)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 6
	prompt.RequiresLineOfSight = false
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	prompt.Parent = parent
	return prompt
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
	local rentPad, rentLabel = createPad(folder, "RentPad", "RENT", Color3.fromRGB(60, 130, 220), base)
	local sellPad, sellLabel = createPad(folder, "SellPad", "SELL", Color3.fromRGB(220, 75, 75), base * CFrame.new(PAD_SPACING, 0, 0))

	local rentPrompt = createActionPrompt(rentPad, "PadRentPrompt", "Rent Property", "Own this land first")
	local sellPrompt = createActionPrompt(sellPad, "PadSellPrompt", "Sell Property", "Own this land first")
	rentPrompt.Enabled = false
	sellPrompt.Enabled = false

	rentPrompt.Triggered:Connect(function(player)
		if (plot:GetAttribute("OwnerUserId") or 0) ~= player.UserId then return end
		if (plot:GetAttribute("UpgradeTier") or 0) <= 0 then return end

		local rented = (plot:GetAttribute("MarketStatus") or "None") == "Rented"
		plot:SetAttribute("MarketStatus", rented and "None" or "Rented")
		plot:SetAttribute("TenantName", rented and "" or "Hometown Tenant")
	end)

	sellPrompt.Triggered:Connect(function(player)
		if (plot:GetAttribute("OwnerUserId") or 0) ~= player.UserId then return end
		local house = plot:FindFirstChild("House")
		local salePrice = house and (house:GetAttribute("SalePrice") or 0) or 0
		local cash = cashValue(player)
		if not cash or salePrice <= 0 then return end
		cash.Value += salePrice
		resetProperty(plot)
	end)

	task.spawn(function()
		local progressionPrompt
		while plot.Parent do
			if not progressionPrompt or not progressionPrompt.Parent then
				progressionPrompt = plot:FindFirstChild("ProgressionPrompt", true)
			end

			if progressionPrompt and progressionPrompt.Parent ~= buildPad then
				progressionPrompt.Parent = buildPad
				progressionPrompt.MaxActivationDistance = 6
				progressionPrompt.RequiresLineOfSight = false
				progressionPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
			end

			for _, descendant in ipairs(plot:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") and descendant ~= progressionPrompt and descendant ~= rentPrompt and descendant ~= sellPrompt then
					local lowerName = string.lower(descendant.Name)
					if string.find(lowerName, "rent") or string.find(lowerName, "sell") then
						descendant.Enabled = false
					end
				end
			end

			local owner = plot:GetAttribute("OwnerUserId") or 0
			local level = plot:GetAttribute("UpgradeTier") or 0
			local house = plot:FindFirstChild("House")
			local owned = owner ~= 0 and level > 0 and house ~= nil

			rentPrompt.Enabled = owned
			sellPrompt.Enabled = owned

			if owned then
				local rented = (plot:GetAttribute("MarketStatus") or "None") == "Rented"
				local rent = house:GetAttribute("Rent") or 0
				local salePrice = house:GetAttribute("SalePrice") or 0
				rentPrompt.ActionText = rented and "Stop Renting" or "Rent Property"
				rentPrompt.ObjectText = rented and ("Currently earning " .. money(rent) .. " / 30 sec") or ("Earn " .. money(rent) .. " / 30 sec")
				rentLabel.Text = rented and "STOP RENTING" or "RENT"
				sellPrompt.ObjectText = "Receive " .. money(salePrice)
				sellLabel.Text = "SELL " .. money(salePrice)
			else
				rentLabel.Text = "RENT"
				sellLabel.Text = "SELL"
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

print("Correct separate property pads loaded")
