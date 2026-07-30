local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HometownHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(250, 70)
frame.Position = UDim2.new(1, -270, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 95, 60)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "HOMETOWN CASH"
title.TextColor3 = Color3.fromRGB(210, 240, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local cashText = Instance.new("TextLabel")
cashText.Size = UDim2.new(1, -20, 0, 35)
cashText.Position = UDim2.fromOffset(10, 28)
cashText.BackgroundTransparency = 1
cashText.TextColor3 = Color3.fromRGB(255, 255, 255)
cashText.Font = Enum.Font.GothamBlack
cashText.TextSize = 29
cashText.TextXAlignment = Enum.TextXAlignment.Left
cashText.Parent = frame

local function formatMoney(amount)
	local text = tostring(amount)
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return "£" .. text
end

local cash = player:WaitForChild("leaderstats"):WaitForChild("Cash")
local function updateCash()
	cashText.Text = formatMoney(cash.Value)
end

cash:GetPropertyChangedSignal("Value"):Connect(updateCash)
updateCash()
