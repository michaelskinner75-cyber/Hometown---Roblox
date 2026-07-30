local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("HometownRemotes")
local openHouseMenu = remotes:WaitForChild("OpenHouseMenu")
local buildHouseRequest = remotes:WaitForChild("BuildHouseRequest")

local order = {"Bungalow", "FamilySemi", "Cottage", "Modern"}
local currentPlotName = nil

local function formatMoney(amount)
	local text = tostring(amount)
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return "£" .. text
end

local gui = Instance.new("ScreenGui")
gui.Name = "HouseSelectionMenu"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(10, 18, 14)
shade.BackgroundTransparency = 0.25
shade.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.86, 0, 0, 470)
panel.BackgroundColor3 = Color3.fromRGB(245, 242, 232)
panel.Parent = shade

local panelSize = Instance.new("UISizeConstraint")
panelSize.MaxSize = Vector2.new(1050, 470)
panelSize.MinSize = Vector2.new(700, 430)
panelSize.Parent = panel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 18)
panelCorner.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 80)
header.BackgroundColor3 = Color3.fromRGB(35, 95, 60)
header.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 18)
headerCorner.Parent = header

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 20)
headerCover.Position = UDim2.new(0, 0, 1, -20)
headerCover.BorderSizePixel = 0
headerCover.BackgroundColor3 = header.BackgroundColor3
headerCover.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 38)
title.Position = UDim2.fromOffset(24, 10)
title.BackgroundTransparency = 1
title.Text = "CHOOSE YOUR HOUSE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -90, 0, 24)
subtitle.Position = UDim2.fromOffset(25, 46)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Pick a design to build on your plot"
subtitle.TextColor3 = Color3.fromRGB(205, 235, 215)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 15
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(46, 46)
closeButton.Position = UDim2.new(1, -62, 0, 17)
closeButton.BackgroundColor3 = Color3.fromRGB(25, 72, 45)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 30
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

local cards = Instance.new("Frame")
cards.Size = UDim2.new(1, -32, 1, -112)
cards.Position = UDim2.fromOffset(16, 96)
cards.BackgroundTransparency = 1
cards.Parent = panel

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.25, -12, 1, 0)
grid.CellPadding = UDim2.fromOffset(12, 0)
grid.FillDirectionMaxCells = 4
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = cards

local accentColours = {
	Bungalow = Color3.fromRGB(191, 144, 78),
	FamilySemi = Color3.fromRGB(75, 116, 170),
	Cottage = Color3.fromRGB(116, 135, 86),
	Modern = Color3.fromRGB(72, 78, 86),
}

local icons = {
	Bungalow = "🏠",
	FamilySemi = "🏘",
	Cottage = "🏡",
	Modern = "▰",
}

local function makeCard(houseKey, info, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = houseKey
	card.LayoutOrder = layoutOrder
	card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	card.Parent = cards

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 14)
	cardCorner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(218, 218, 208)
	stroke.Thickness = 1.5
	stroke.Parent = card

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(1, 0, 0, 115)
	preview.BackgroundColor3 = accentColours[houseKey]
	preview.Parent = card

	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 14)
	previewCorner.Parent = preview

	local previewCover = Instance.new("Frame")
	previewCover.Size = UDim2.new(1, 0, 0, 14)
	previewCover.Position = UDim2.new(0, 0, 1, -14)
	previewCover.BorderSizePixel = 0
	previewCover.BackgroundColor3 = preview.BackgroundColor3
	previewCover.Parent = preview

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromScale(1, 1)
	icon.BackgroundTransparency = 1
	icon.Text = icons[houseKey]
	icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = houseKey == "Modern" and 72 or 58
	icon.Parent = preview

	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(1, -20, 0, 48)
	name.Position = UDim2.fromOffset(10, 126)
	name.BackgroundTransparency = 1
	name.Text = info.Name
	name.TextColor3 = Color3.fromRGB(35, 55, 42)
	name.Font = Enum.Font.GothamBold
	name.TextSize = 19
	name.TextWrapped = true
	name.Parent = card

	local description = Instance.new("TextLabel")
	description.Size = UDim2.new(1, -20, 0, 52)
	description.Position = UDim2.fromOffset(10, 175)
	description.BackgroundTransparency = 1
	description.Text = info.Description
	description.TextColor3 = Color3.fromRGB(90, 100, 92)
	description.Font = Enum.Font.Gotham
	description.TextSize = 14
	description.TextWrapped = true
	description.Parent = card

	local price = Instance.new("TextLabel")
	price.Size = UDim2.new(1, -20, 0, 30)
	price.Position = UDim2.fromOffset(10, 234)
	price.BackgroundTransparency = 1
	price.Text = "BUILD  " .. formatMoney(info.Price)
	price.TextColor3 = Color3.fromRGB(35, 95, 60)
	price.Font = Enum.Font.GothamBlack
	price.TextSize = 18
	price.Parent = card

	local value = Instance.new("TextLabel")
	value.Size = UDim2.new(1, -20, 0, 22)
	value.Position = UDim2.fromOffset(10, 263)
	value.BackgroundTransparency = 1
	value.Text = "Sale value " .. formatMoney(info.SalePrice)
	value.TextColor3 = Color3.fromRGB(110, 110, 105)
	value.Font = Enum.Font.Gotham
	value.TextSize = 13
	value.Parent = card

	local buildButton = Instance.new("TextButton")
	buildButton.Size = UDim2.new(1, -20, 0, 48)
	buildButton.Position = UDim2.new(0, 10, 1, -58)
	buildButton.BackgroundColor3 = Color3.fromRGB(35, 95, 60)
	buildButton.Text = "BUILD THIS HOUSE"
	buildButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buildButton.Font = Enum.Font.GothamBold
	buildButton.TextSize = 14
	buildButton.Parent = card

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = buildButton

	buildButton.MouseButton1Click:Connect(function()
		if not currentPlotName then return end
		buildHouseRequest:FireServer(currentPlotName, houseKey)
		gui.Enabled = false
		currentPlotName = nil
	end)
end

local function clearCards()
	for _, child in ipairs(cards:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

openHouseMenu.OnClientEvent:Connect(function(plotName, houseTypes)
	currentPlotName = plotName
	clearCards()
	for index, houseKey in ipairs(order) do
		local info = houseTypes[houseKey]
		if info then
			makeCard(houseKey, info, index)
		end
	end
	gui.Enabled = true
end)

closeButton.MouseButton1Click:Connect(function()
	gui.Enabled = false
	currentPlotName = nil
end)

shade.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Target == shade then
		gui.Enabled = false
		currentPlotName = nil
	end
end)