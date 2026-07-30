local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("HometownRemotes")
local openPropertyMenu = remotes:WaitForChild("OpenPropertyMenu")
local propertyActionRequest = remotes:WaitForChild("PropertyActionRequest")
local propertyNotice = remotes:WaitForChild("PropertyNotice")

local currentPlotName
local currentInfo

local function money(value)
	local text = tostring(math.floor(value or 0))
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return "£" .. text
end

local gui = Instance.new("ScreenGui")
gui.Name = "PropertyManagementMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 30
gui.Enabled = false
gui.Parent = playerGui

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1,1)
shade.BackgroundColor3 = Color3.fromRGB(8,15,12)
shade.BackgroundTransparency = 0.28
shade.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5,0.5)
panel.Position = UDim2.fromScale(0.5,0.5)
panel.Size = UDim2.fromOffset(520,430)
panel.BackgroundColor3 = Color3.fromRGB(247,244,235)
panel.Parent = shade
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,18)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(360,390)
sizeConstraint.MaxSize = Vector2.new(560,440)
sizeConstraint.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,86)
header.BackgroundColor3 = Color3.fromRGB(36,94,61)
header.Parent = panel
Instance.new("UICorner",header).CornerRadius = UDim.new(0,18)
local headerFill = Instance.new("Frame")
headerFill.Size = UDim2.new(1,0,0,20)
headerFill.Position = UDim2.new(0,0,1,-20)
headerFill.BorderSizePixel = 0
headerFill.BackgroundColor3 = header.BackgroundColor3
headerFill.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-80,0,38)
title.Position = UDim2.fromOffset(22,10)
title.BackgroundTransparency = 1
title.Text = "MANAGE PROPERTY"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,-80,0,24)
subtitle.Position = UDim2.fromOffset(23,49)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(207,235,216)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 15
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(44,44)
close.Position = UDim2.new(1,-60,0,20)
close.BackgroundColor3 = Color3.fromRGB(27,70,47)
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 28
close.Parent = header
Instance.new("UICorner",close).CornerRadius = UDim.new(1,0)

local details = Instance.new("Frame")
details.Size = UDim2.new(1,-36,0,108)
details.Position = UDim2.fromOffset(18,104)
details.BackgroundColor3 = Color3.fromRGB(255,255,255)
details.Parent = panel
Instance.new("UICorner",details).CornerRadius = UDim.new(0,13)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(220,220,210)
stroke.Parent = details

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(0.5,-12,1,-20)
valueLabel.Position = UDim2.fromOffset(14,10)
valueLabel.BackgroundTransparency = 1
valueLabel.TextColor3 = Color3.fromRGB(35,92,58)
valueLabel.Font = Enum.Font.GothamBlack
valueLabel.TextSize = 24
valueLabel.TextXAlignment = Enum.TextXAlignment.Left
valueLabel.TextWrapped = true
valueLabel.Parent = details

local rentLabel = Instance.new("TextLabel")
rentLabel.Size = UDim2.new(0.5,-12,1,-20)
rentLabel.Position = UDim2.new(0.5,0,0,10)
rentLabel.BackgroundTransparency = 1
rentLabel.TextColor3 = Color3.fromRGB(80,92,84)
rentLabel.Font = Enum.Font.GothamBold
rentLabel.TextSize = 18
rentLabel.TextXAlignment = Enum.TextXAlignment.Left
rentLabel.TextWrapped = true
rentLabel.Parent = details

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-36,0,48)
statusLabel.Position = UDim2.fromOffset(18,224)
statusLabel.BackgroundColor3 = Color3.fromRGB(232,239,232)
statusLabel.TextColor3 = Color3.fromRGB(42,83,57)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.Parent = panel
Instance.new("UICorner",statusLabel).CornerRadius = UDim.new(0,10)

local buttons = Instance.new("Frame")
buttons.Size = UDim2.new(1,-36,0,126)
buttons.Position = UDim2.fromOffset(18,286)
buttons.BackgroundTransparency = 1
buttons.Parent = panel
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0,12)
layout.Parent = buttons

local function makeButton(name, colour)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0.5,-6,0,78)
	button.BackgroundColor3 = colour
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 17
	button.TextWrapped = true
	button.Parent = buttons
	Instance.new("UICorner",button).CornerRadius = UDim.new(0,12)
	return button
end

local leftButton = makeButton("LeftAction",Color3.fromRGB(42,111,72))
local rightButton = makeButton("RightAction",Color3.fromRGB(194,126,48))

local notice = Instance.new("TextLabel")
notice.AnchorPoint = Vector2.new(0.5,0)
notice.Position = UDim2.new(0.5,0,0,-80)
notice.Size = UDim2.fromOffset(460,64)
notice.BackgroundColor3 = Color3.fromRGB(35,92,58)
notice.TextColor3 = Color3.new(1,1,1)
notice.Font = Enum.Font.GothamBold
notice.TextSize = 17
notice.TextWrapped = true
notice.Visible = false
notice.Parent = gui
Instance.new("UICorner",notice).CornerRadius = UDim.new(0,12)

local function send(action)
	if not currentPlotName then return end
	propertyActionRequest:FireServer(currentPlotName,action)
	gui.Enabled = false
	currentPlotName = nil
end

local leftConnection
local rightConnection
local function bind(button, action)
	return button.MouseButton1Click:Connect(function()
		send(action)
	end)
end

local function refresh(plotName, info)
	currentPlotName = plotName
	currentInfo = info
	subtitle.Text = (info.HouseName or "House") .. " • " .. plotName
	valueLabel.Text = "SELL VALUE\n" .. money(info.SalePrice)
	rentLabel.Text = "RENTAL INCOME\n" .. money(info.Rent) .. " every 30 sec"
	local status = info.Status or "None"
	if status == "Rented" then
		statusLabel.Text = "Rented to " .. (info.TenantName or "Tenant") .. " — you can still sell with the tenant living there"
		leftButton.Text = "SELL WITH TENANT\n" .. money(info.SalePrice)
		rightButton.Text = "END TENANCY"
		leftButton.BackgroundColor3 = Color3.fromRGB(42,111,72)
		rightButton.BackgroundColor3 = Color3.fromRGB(168,76,61)
		if leftConnection then leftConnection:Disconnect() end
		if rightConnection then rightConnection:Disconnect() end
		leftConnection = bind(leftButton,"Sell")
		rightConnection = bind(rightButton,"EndTenancy")
	elseif status == "ForSale" or status == "ToRent" then
		statusLabel.Text = status == "ForSale" and "A buyer is on the way to view this house" or "A renter is on the way to view this house"
		leftButton.Text = "KEEP LISTING ACTIVE"
		rightButton.Text = "CANCEL LISTING"
		leftButton.BackgroundColor3 = Color3.fromRGB(90,104,95)
		rightButton.BackgroundColor3 = Color3.fromRGB(168,76,61)
		if leftConnection then leftConnection:Disconnect() end
		if rightConnection then rightConnection:Disconnect() end
		leftConnection = leftButton.MouseButton1Click:Connect(function() gui.Enabled=false end)
		rightConnection = bind(rightButton,"CancelListing")
	else
		statusLabel.Text = "Choose whether to sell now or keep the property for rental income"
		leftButton.Text = "LIST FOR SALE\n" .. money(info.SalePrice)
		rightButton.Text = "FIND A TENANT\n" .. money(info.Rent) .. " / 30 sec"
		leftButton.BackgroundColor3 = Color3.fromRGB(42,111,72)
		rightButton.BackgroundColor3 = Color3.fromRGB(194,126,48)
		if leftConnection then leftConnection:Disconnect() end
		if rightConnection then rightConnection:Disconnect() end
		leftConnection = bind(leftButton,"Sell")
		rightConnection = bind(rightButton,"Rent")
	end
	gui.Enabled = true
end

openPropertyMenu.OnClientEvent:Connect(refresh)
close.MouseButton1Click:Connect(function() gui.Enabled=false; currentPlotName=nil end)

propertyNotice.OnClientEvent:Connect(function(message)
	notice.Text = tostring(message)
	notice.Visible = true
	notice.Position = UDim2.new(0.5,0,0,-80)
	TweenService:Create(notice,TweenInfo.new(0.35,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,0,0,20)}):Play()
	task.delay(4,function()
		if notice.Text == tostring(message) then
			local tween=TweenService:Create(notice,TweenInfo.new(0.3),{Position=UDim2.new(0.5,0,0,-80)})
			tween:Play(); tween.Completed:Wait(); notice.Visible=false
		end
	end)
end)
