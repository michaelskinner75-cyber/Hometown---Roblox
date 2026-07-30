local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local MOBILE_GUI_NAMES = {
	HouseMenu = true,
	HouseSelectionMenu = true,
	PropertyManagementMenu = true,
	HometownUI = true,
	CashHUD = true,
}

local function viewportSize()
	camera = workspace.CurrentCamera or camera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function safeInsets()
	local topLeft, bottomRight = GuiService:GetGuiInset()
	return topLeft, bottomRight
end

local function findMainPanel(screenGui)
	local best
	local bestArea = 0
	for _, child in ipairs(screenGui:GetDescendants()) do
		if child:IsA("Frame") and child.Visible then
			local size = child.AbsoluteSize
			local area = size.X * size.Y
			if area > bestArea and child.BackgroundTransparency < 1 then
				best = child
				bestArea = area
			end
		end
	end
	return best
end

local function ensureScale(guiObject)
	local scale = guiObject:FindFirstChild("MobileScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = "MobileScale"
		scale.Parent = guiObject
	end
	return scale
end

local function makeButtonsTouchFriendly(root)
	for _, object in ipairs(root:GetDescendants()) do
		if object:IsA("GuiButton") then
			object.Active = true
			object.Selectable = true
			object.AutoButtonColor = true
			if UserInputService.TouchEnabled then
				local minimum = Instance.new("UISizeConstraint")
				minimum.Name = "MobileTouchMinimum"
				minimum.MinSize = Vector2.new(48, 48)
				minimum.Parent = object
			end
		end
	end
end

local function fitScreenGui(screenGui)
	if not screenGui:IsA("ScreenGui") then return end
	if not MOBILE_GUI_NAMES[screenGui.Name] then return end

	screenGui.IgnoreGuiInset = false
	screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	makeButtonsTouchFriendly(screenGui)

	local panel = findMainPanel(screenGui)
	if not panel then return end

	local view = viewportSize()
	local topLeft, bottomRight = safeInsets()
	local availableWidth = math.max(280, view.X - topLeft.X - bottomRight.X - 20)
	local availableHeight = math.max(220, view.Y - topLeft.Y - bottomRight.Y - 20)
	local panelSize = panel.AbsoluteSize
	if panelSize.X <= 0 or panelSize.Y <= 0 then return end

	local scaleValue = math.min(1, availableWidth / panelSize.X, availableHeight / panelSize.Y)
	if UserInputService.TouchEnabled then
		scaleValue = math.clamp(scaleValue, 0.62, 1)
	else
		scaleValue = math.clamp(scaleValue, 0.8, 1)
	end

	ensureScale(panel).Scale = scaleValue

	if panel.AnchorPoint ~= Vector2.new(0.5, 0.5) then
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
	end
	panel.Position = UDim2.fromScale(0.5, 0.5)
end

local function fitAll()
	for _, child in ipairs(playerGui:GetChildren()) do
		fitScreenGui(child)
	end
end

playerGui.ChildAdded:Connect(function(child)
	task.defer(function()
		task.wait(0.1)
		fitScreenGui(child)
	end)
end)

playerGui.DescendantAdded:Connect(function(object)
	if object:IsA("GuiButton") and UserInputService.TouchEnabled then
		task.defer(function()
			local screenGui = object:FindFirstAncestorOfClass("ScreenGui")
			if screenGui and MOBILE_GUI_NAMES[screenGui.Name] then
				makeButtonsTouchFriendly(screenGui)
				fitScreenGui(screenGui)
			end
		end)
	end
end)

if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		task.defer(fitAll)
	end)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			task.defer(fitAll)
		end)
	end
	task.defer(fitAll)
end)

task.defer(function()
	task.wait(0.5)
	fitAll()
end)
