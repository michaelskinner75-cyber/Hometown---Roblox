local SALE_VALUES = {
	Bungalow = 6500,
	FamilySemi = 8500,
	Cottage = 10500,
	Modern = 13500,
}

local function formatMoney(amount)
	local text = tostring(amount)
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then
			break
		end
	end
	return text
end

local function updateHouseEconomy(plotModel, house)
	if not house or house.Name ~= "House" then
		return
	end

	local houseType = house:GetAttribute("HouseType")
	local saleValue = SALE_VALUES[houseType]
	if not saleValue then
		return
	end

	house:SetAttribute("SalePrice", saleValue)

	local displayName = house:GetAttribute("DisplayName") or "House"
	local sign = plotModel:FindFirstChild("Sign")
	local prompt = sign and sign:FindFirstChild("PropertyPrompt")
	local billboard = sign and sign:FindFirstChild("BillboardGui")
	local label = billboard and billboard:FindFirstChild("TextLabel")

	if label then
		label.Text = string.upper(displayName) .. "\nVALUE £" .. formatMoney(saleValue)
	end
	if prompt then
		prompt.ActionText = "Sell for £" .. formatMoney(saleValue)
	end
end

local function watchPlot(plotModel)
	local existingHouse = plotModel:FindFirstChild("House")
	if existingHouse then
		updateHouseEconomy(plotModel, existingHouse)
	end

	plotModel.ChildAdded:Connect(function(child)
		if child.Name == "House" then
			updateHouseEconomy(plotModel, child)
		end
	end)
end

local function connectToWorld(world)
	local plots = world:WaitForChild("Plots")
	for _, plotModel in ipairs(plots:GetChildren()) do
		watchPlot(plotModel)
	end
	plots.ChildAdded:Connect(watchPlot)
end

local existingWorld = workspace:FindFirstChild("HometownWorld")
if existingWorld then
	connectToWorld(existingWorld)
end

workspace.ChildAdded:Connect(function(child)
	if child.Name == "HometownWorld" then
		connectToWorld(child)
	end
end)
