local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local PLOT_PRICE = 2500
local RENT_INTERVAL = 30

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

local function upgradeCost(level)
	if level <= 1 then return 0 end
	return math.floor(900 * (1.19 ^ (level - 2)) / 50 + 0.5) * 50
end

local function totalInvested(level)
	local total = PLOT_PRICE
	for currentLevel = 2, math.max(1, level) do
		total += upgradeCost(currentLevel)
	end
	return total
end

local function balancedValues(level)
	local invested = totalInvested(level)
	local salePrice = math.floor((invested * 1.15) / 50 + 0.5) * 50
	local rent = math.max(75, math.floor((salePrice * 0.0075) / 10 + 0.5) * 10)
	return salePrice, rent, invested
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

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then
		local sign = plot:WaitForChild("Sign")

		local sellPrompt = sign:FindFirstChild("SellPropertyPrompt") or Instance.new("ProximityPrompt")
		sellPrompt.Name = "SellPropertyPrompt"
		sellPrompt.ActionText = "Sell Property"
		sellPrompt.KeyboardKeyCode = Enum.KeyCode.F
		sellPrompt.GamepadKeyCode = Enum.KeyCode.ButtonY
		sellPrompt.HoldDuration = 1
		sellPrompt.MaxActivationDistance = 14
		sellPrompt.RequiresLineOfSight = false
		sellPrompt.Parent = sign

		local rentPrompt = sign:FindFirstChild("RentPropertyPrompt") or Instance.new("ProximityPrompt")
		rentPrompt.Name = "RentPropertyPrompt"
		rentPrompt.ActionText = "Rent Property"
		rentPrompt.KeyboardKeyCode = Enum.KeyCode.R
		rentPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
		rentPrompt.HoldDuration = 0.8
		rentPrompt.MaxActivationDistance = 14
		rentPrompt.RequiresLineOfSight = false
		rentPrompt.Parent = sign

		sellPrompt.Triggered:Connect(function(player)
		if (plot:GetAttribute("OwnerUserId") or 0) ~= player.UserId then return end
		local level = plot:GetAttribute("UpgradeTier") or 0
		if level <= 0 then return end
		local salePrice = balancedValues(level)
		local cash = cashValue(player)
		if not cash then return end
		cash.Value += salePrice
		resetProperty(plot)
	end)

		rentPrompt.Triggered:Connect(function(player)
		if (plot:GetAttribute("OwnerUserId") or 0) ~= player.UserId then return end
		local currentStatus = plot:GetAttribute("MarketStatus") or "None"
		if currentStatus == "Rented" then
			plot:SetAttribute("MarketStatus", "None")
			plot:SetAttribute("TenantName", "")
		else
			plot:SetAttribute("MarketStatus", "Rented")
			plot:SetAttribute("TenantName", "Hometown Tenant")
		end
	end)

		task.spawn(function()
		while plot.Parent do
			task.wait(RENT_INTERVAL)
			if (plot:GetAttribute("MarketStatus") or "None") == "Rented" then
				local ownerId = plot:GetAttribute("OwnerUserId") or 0
				local owner = game:GetService("Players"):GetPlayerByUserId(ownerId)
				local level = plot:GetAttribute("UpgradeTier") or 0
				if owner and level > 0 then
					local _, rent = balancedValues(level)
					local cash = cashValue(owner)
					if cash then cash.Value += rent end
				end
			end
		end
	end)

	task.spawn(function()
		while plot.Parent do
			local owner = plot:GetAttribute("OwnerUserId") or 0
			local level = plot:GetAttribute("UpgradeTier") or 0
			local house = plot:FindFirstChild("House")
			local progressionPrompt = sign:FindFirstChild("ProgressionPrompt")

			if owner ~= 0 and level > 0 and house then
				local salePrice, rent, invested = balancedValues(level)
				house:SetAttribute("SalePrice", salePrice)
				house:SetAttribute("Rent", rent)
				house:SetAttribute("InvestedValue", invested)
				sellPrompt.Enabled = true
				rentPrompt.Enabled = true
				sellPrompt.ObjectText = "Receive " .. money(salePrice)
				local rented = (plot:GetAttribute("MarketStatus") or "None") == "Rented"
				rentPrompt.ActionText = rented and "Stop Renting" or "Rent Property"
				rentPrompt.ObjectText = rented and ("Currently earning " .. money(rent) .. " / 30 sec") or ("Earn " .. money(rent) .. " / 30 sec")
				if progressionPrompt then
					progressionPrompt.ActionText = "Buy / Upgrade"
					progressionPrompt.ObjectText = "SELL [F]  •  RENT [R]  •  Level " .. level
				end
			else
				sellPrompt.Enabled = false
				rentPrompt.Enabled = false
				if progressionPrompt then
					progressionPrompt.ActionText = "Buy / Sell / Rent"
					progressionPrompt.ObjectText = "Buy this plot for " .. money(PLOT_PRICE)
				end
			end
			task.wait(0.5)
		end
	end)
	end
end

print("Balanced property selling and renting loaded")