local RunService = game:GetService("RunService")

local world = workspace:WaitForChild("HometownWorld")
local ambient = world:WaitForChild("AmbientTown")
local traffic = ambient:WaitForChild("Traffic")
local plots = world:WaitForChild("Plots")

local function makePart(className, name, size, cframe, colour, material, parent)
	local object = Instance.new(className)
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = colour
	object.Material = material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide = false
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end

local function addSurfaceText(part, face, text, colour, font)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "DisplayGui"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 45
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = colour
	label.Font = font or Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
	return label
end

local function wheel(model, root, x, z)
	local tyre = makePart("Part", "Wheel", Vector3.new(1.4, 3.4, 3.4), root.CFrame * CFrame.new(x, 2.1, z) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(18, 18, 20), Enum.Material.Rubber, model)
	tye = tyre
	tye.Shape = Enum.PartType.Cylinder
	local hub = makePart("Part", "WheelHub", Vector3.new(1.5, 1.65, 1.65), tyre.CFrame, Color3.fromRGB(170, 175, 180), Enum.Material.Metal, model)
	hub.Shape = Enum.PartType.Cylinder
end

local function createModernDoubleDecker(name, position, routeText)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = traffic

	local root = makePart("Part", "Root", Vector3.new(1, 1, 1), CFrame.new(position), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, model)
	root.Transparency = 1
	model.PrimaryPart = root

	local black = Color3.fromRGB(18, 20, 24)
	local darkGlass = Color3.fromRGB(38, 56, 70)
	local trimBlue = Color3.fromRGB(18, 154, 214)
	local trimGreen = Color3.fromRGB(27, 190, 151)
	local trimOrange = Color3.fromRGB(245, 158, 48)

	makePart("Part", "LowerBody", Vector3.new(29, 6.5, 8.4), root.CFrame * CFrame.new(-0.5, 4.5, 0), black, Enum.Material.Metal, model)
	makePart("Part", "UpperBody", Vector3.new(27.5, 6.2, 8.1), root.CFrame * CFrame.new(-1.1, 10.7, 0), black, Enum.Material.Metal, model)
	makePart("Part", "Roof", Vector3.new(25.8, 0.7, 7.7), root.CFrame * CFrame.new(-1.4, 14.1, 0), Color3.fromRGB(42, 44, 48), Enum.Material.Metal, model)

	local frontLower = makePart("WedgePart", "CurvedFrontLower", Vector3.new(4.2, 6.2, 8.25), root.CFrame * CFrame.new(14.2, 4.7, 0) * CFrame.Angles(0, math.rad(90), 0), black, Enum.Material.Metal, model)
	local frontUpper = makePart("WedgePart", "CurvedFrontUpper", Vector3.new(4.4, 6.1, 8.0), root.CFrame * CFrame.new(13.7, 10.8, 0) * CFrame.Angles(0, math.rad(90), 0), black, Enum.Material.Metal, model)
	frontLower.Name = "RoundedFrontLower"
	frontUpper.Name = "RoundedFrontUpper"

	local lowerScreen = makePart("Part", "LowerWindscreen", Vector3.new(0.35, 4.2, 6.8), root.CFrame * CFrame.new(16.15, 6.0, 0) * CFrame.Angles(0, 0, math.rad(-8)), darkGlass, Enum.Material.Glass, model)
	lowerScreen.Transparency = 0.18
	local upperScreen = makePart("Part", "UpperWindscreen", Vector3.new(0.35, 4.5, 6.8), root.CFrame * CFrame.new(15.65, 11.5, 0) * CFrame.Angles(0, 0, math.rad(-8)), darkGlass, Enum.Material.Glass, model)
	upperScreen.Transparency = 0.18

	for _, level in ipairs({7.0, 11.7}) do
		for _, side in ipairs({-4.16, 4.16}) do
			for x = -11, 9, 4 do
				local window = makePart("Part", "SideWindow", Vector3.new(3.25, 3.2, 0.22), root.CFrame * CFrame.new(x, level, side), darkGlass, Enum.Material.Glass, model)
				window.Transparency = 0.2
			end
		end
	end

	local doorGlass = makePart("Part", "FrontDoors", Vector3.new(0.3, 5.1, 3.2), root.CFrame * CFrame.new(10.8, 4.8, -4.24), darkGlass, Enum.Material.Glass, model)
	doorGlass.Transparency = 0.16
	makePart("Part", "DoorDivider", Vector3.new(0.18, 5.2, 0.18), root.CFrame * CFrame.new(10.8, 4.8, -4.4), Color3.fromRGB(185, 190, 195), Enum.Material.Metal, model)

	wheel(model, root, -10.5, -4.45)
	wheel(model, root, -10.5, 4.45)
	wheel(model, root, 9.5, -4.45)
	wheel(model, root, 9.5, 4.45)

	makePart("Part", "BlueStripe", Vector3.new(0.3, 0.5, 2.2), root.CFrame * CFrame.new(16.38, 2.25, -2.3), trimBlue, Enum.Material.Neon, model)
	makePart("Part", "GreenStripe", Vector3.new(0.3, 0.5, 2.2), root.CFrame * CFrame.new(16.38, 2.25, 0), trimGreen, Enum.Material.Neon, model)
	makePart("Part", "OrangeStripe", Vector3.new(0.3, 0.5, 2.2), root.CFrame * CFrame.new(16.38, 2.25, 2.3), trimOrange, Enum.Material.Neon, model)

	for _, z in ipairs({-2.8, 2.8}) do
		local light = makePart("Part", "Headlight", Vector3.new(0.4, 0.75, 0.75), root.CFrame * CFrame.new(16.45, 3.0, z), Color3.fromRGB(245, 245, 225), Enum.Material.Neon, model)
		light.Shape = Enum.PartType.Ball
	end

	for _, z in ipairs({-5.0, 5.0}) do
		makePart("Part", "YellowMirror", Vector3.new(1.3, 1.8, 0.6), root.CFrame * CFrame.new(14.6, 7.2, z), Color3.fromRGB(245, 205, 35), Enum.Material.SmoothPlastic, model)
	end

	local destination = makePart("Part", "DestinationDisplay", Vector3.new(0.32, 1.45, 5.8), root.CFrame * CFrame.new(16.3, 9.1, 0), Color3.fromRGB(4, 5, 6), Enum.Material.SmoothPlastic, model)
	addSurfaceText(destination, Enum.NormalId.Right, routeText, Color3.fromRGB(255, 190, 35), Enum.Font.Code)

	local operatorPanel = makePart("Part", "OperatorPanel", Vector3.new(0.32, 1.0, 5.5), root.CFrame * CFrame.new(16.35, 7.7, 0), black, Enum.Material.SmoothPlastic, model)
	addSurfaceText(operatorPanel, Enum.NormalId.Right, "HOMETOWN", Color3.fromRGB(245, 245, 245), Enum.Font.GothamBold)

	local plate = makePart("Part", "NumberPlate", Vector3.new(0.34, 0.55, 2.4), root.CFrame * CFrame.new(16.45, 1.55, 0), Color3.fromRGB(245, 245, 235), Enum.Material.SmoothPlastic, model)
	addSurfaceText(plate, Enum.NormalId.Right, "MS 75 BUS", Color3.fromRGB(25, 25, 25), Enum.Font.GothamBold)

	return model
end

for _, child in ipairs(traffic:GetChildren()) do
	if child.Name:find("HometownBus") or child.Name:find("ModernBus") then
		child:Destroy()
	end
end

local roadA = {Vector3.new(-205, 1.4, -9), Vector3.new(205, 1.4, -9)}
local roadB = {Vector3.new(205, 1.4, 9), Vector3.new(-205, 1.4, 9)}
local buses = {
	{Model = createModernDoubleDecker("ModernBus1", roadA[1], "MS1  TOWN CENTRE"), Route = roadA, Speed = 15, Index = 1, Distance = 0},
	{Model = createModernDoubleDecker("ModernBus2", roadB[1], "MS2  HOMETOWN"), Route = roadB, Speed = 14, Index = 1, Distance = 0},
}

RunService.Heartbeat:Connect(function(dt)
	for _, mover in ipairs(buses) do
		if mover.Model.Parent and mover.Model.PrimaryPart then
			local from = mover.Route[mover.Index]
			local nextIndex = mover.Index % #mover.Route + 1
			local to = mover.Route[nextIndex]
			local length = (to - from).Magnitude
			mover.Distance += mover.Speed * dt
			if mover.Distance >= length then
				mover.Distance = 0
				mover.Index = nextIndex
			else
				local position = from:Lerp(to, mover.Distance / length)
				mover.Model:PivotTo(CFrame.lookAt(position, position + (to - from).Unit))
			end
		end
	end
end)

local function formatMoney(value)
	local text = tostring(math.floor(value or 0))
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return "£" .. text
end

local function createYardSign(plot)
	local oldSign = plot:WaitForChild("Sign")
	local oldGui = oldSign:FindFirstChild("BillboardGui")
	if oldGui then oldGui.Enabled = false end
	oldSign.Transparency = 1
	oldSign.CanCollide = false

	local existing = plot:FindFirstChild("YardSign")
	if existing then existing:Destroy() end

	local front = plot:GetAttribute("FrontDirection") or -1
	local basePosition = plot.Plot.Position + Vector3.new(-22, 0.5, front * 27)
	local model = Instance.new("Model")
	model.Name = "YardSign"
	model.Parent = plot

	local post = makePart("Part", "Post", Vector3.new(0.55, 7.5, 0.55), CFrame.new(basePosition + Vector3.new(0, 3.75, 0)), Color3.fromRGB(238, 238, 232), Enum.Material.Wood, model)
	local arm = makePart("Part", "Arm", Vector3.new(6.5, 0.55, 0.55), CFrame.new(basePosition + Vector3.new(2.75, 7.0, 0)), Color3.fromRGB(238, 238, 232), Enum.Material.Wood, model)
	local board = makePart("Part", "Board", Vector3.new(5.5, 3.5, 0.35), CFrame.new(basePosition + Vector3.new(3.0, 5.3, 0)), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, model)
	local labelFront = addSurfaceText(board, Enum.NormalId.Front, "FOR SALE", Color3.fromRGB(22, 82, 52), Enum.Font.GothamBold)
	local labelBack = addSurfaceText(board, Enum.NormalId.Back, "FOR SALE", Color3.fromRGB(22, 82, 52), Enum.Font.GothamBold)

	local prompt = oldSign:FindFirstChild("PropertyPrompt")
	if prompt then
		prompt.Parent = post
		prompt.MaxActivationDistance = 14
	end

	local function refresh()
		local ownerId = plot:GetAttribute("OwnerUserId") or 0
		local built = plot:GetAttribute("HouseBuilt")
		local status = plot:GetAttribute("MarketStatus") or "None"
		local house = plot:FindFirstChild("House")
		local text
		local colour

		if ownerId == 0 then
			text = "FOR SALE\nBUILDING PLOT\n£2,500"
			colour = Color3.fromRGB(22, 82, 52)
		elseif not built then
			text = "SOLD\nREADY TO BUILD"
			colour = Color3.fromRGB(38, 92, 150)
		elseif status == "ForSale" then
			text = "FOR SALE\n" .. formatMoney(house and house:GetAttribute("SalePrice") or 0)
			colour = Color3.fromRGB(22, 82, 52)
		elseif status == "ToRent" then
			text = "TO RENT\n" .. formatMoney(house and house:GetAttribute("Rent") or 0) .. " RENT"
			colour = Color3.fromRGB(42, 88, 160)
		elseif status == "Rented" then
			text = "LET AGREED\nTENANT IN PLACE"
			colour = Color3.fromRGB(125, 52, 145)
		else
			text = "PROPERTY OWNED\nNOT ON MARKET"
			colour = Color3.fromRGB(78, 82, 88)
		end

		labelFront.Text = text
		labelBack.Text = text
		labelFront.TextColor3 = colour
		labelBack.TextColor3 = colour
	end

	refresh()
	for _, attribute in ipairs({"OwnerUserId", "HouseBuilt", "MarketStatus", "TenantName"}) do
		plot:GetAttributeChangedSignal(attribute):Connect(refresh)
	end
	plot.ChildAdded:Connect(refresh)
	plot.ChildRemoved:Connect(refresh)
end

for _, plot in ipairs(plots:GetChildren()) do
	task.spawn(createYardSign, plot)
end
plots.ChildAdded:Connect(function(plot)
	task.spawn(createYardSign, plot)
end)

print("Modern double-decker buses and realistic yard property signs loaded")