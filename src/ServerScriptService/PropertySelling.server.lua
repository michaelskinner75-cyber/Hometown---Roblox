local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

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
	if house then
		house:Destroy()
	end

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
		local sellPrompt = sign:FindFirstChild("SellPropertyPrompt")

		if not sellPrompt then
			sellPrompt = Instance.new("ProximityPrompt")
			sellPrompt.Name = "SellPropertyPrompt"
			sellPrompt.ActionText = "Sell Property"
			sellPrompt.ObjectText = "Owner only"
			sellPrompt.KeyboardKeyCode = Enum.KeyCode.F
			sellPrompt.GamepadKeyCode = Enum.KeyCode.ButtonY
			sellPrompt.HoldDuration = 1.2
			sellPrompt.MaxActivationDistance = 14
			sellPrompt.RequiresLineOfSight = false
			sellPrompt.Parent = sign
		end

		sellPrompt.Triggered:Connect(function(player)
			if (plot:GetAttribute("OwnerUserId") or 0) ~= player.UserId then
				return
			end

			local house = plot:FindFirstChild("House")
			local salePrice = house and house:GetAttribute("SalePrice") or 0
			local cash = cashValue(player)
			if not cash or salePrice <= 0 then
				return
			end

			cash.Value += salePrice
			resetProperty(plot)
		end)

		task.spawn(function()
			while plot.Parent do
				local owner = plot:GetAttribute("OwnerUserId") or 0
				local house = plot:FindFirstChild("House")
				local salePrice = house and house:GetAttribute("SalePrice") or 0
				sellPrompt.Enabled = owner ~= 0 and salePrice > 0
				if sellPrompt.Enabled then
					sellPrompt.ObjectText = "Receive " .. money(salePrice)
				end
				task.wait(1)
			end
		end)
	end
end

print("Property selling loaded")
