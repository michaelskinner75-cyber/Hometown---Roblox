local TweenService = game:GetService("TweenService")

local BUILD_DELAY = 0.08

local function formatMoney(amount)
	local text = tostring(math.floor(amount or 0))
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return text
end

local function newPart(parent, name, size, cframe, colour, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = true
	part.Color = colour
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape then part.Shape = shape end
	part.Parent = parent
	return part
end

local function newWedge(parent, name, size, cframe, colour, material)
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = true
	part.Color = colour
	part.Material = material or Enum.Material.Slate
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function stagePart(parts, part)
	local originalTransparency = part.Transparency
	part:SetAttribute("FinalTransparency", originalTransparency)
	part.Transparency = 1
	part.CanCollide = false
	table.insert(parts, part)
	return part
end

local function addWindow(parent, parts, position, size, frontDirection, warm)
	local frameColour = Color3.fromRGB(244, 244, 238)
	local glassColour = warm and Color3.fromRGB(255, 220, 145) or Color3.fromRGB(145, 205, 235)
	local z = position.Z
	stagePart(parts, newPart(parent, "WindowFrame", size + Vector3.new(1.1, 1.1, 0.35), CFrame.new(position.X, position.Y, z), frameColour, Enum.Material.Wood))
	local glass = newPart(parent, "WindowGlass", size, CFrame.new(position.X, position.Y, z + frontDirection * 0.22), glassColour, Enum.Material.Glass)
	glass.Transparency = 0.18
	glass.CanCollide = false
	stagePart(parts, glass)
	stagePart(parts, newPart(parent, "WindowBarV", Vector3.new(0.28, size.Y, 0.22), CFrame.new(position.X, position.Y, z + frontDirection * 0.38), frameColour, Enum.Material.Wood))
	stagePart(parts, newPart(parent, "WindowBarH", Vector3.new(size.X, 0.28, 0.22), CFrame.new(position.X, position.Y, z + frontDirection * 0.38), frameColour, Enum.Material.Wood))
	stagePart(parts, newPart(parent, "WindowSill", Vector3.new(size.X + 1.3, 0.35, 1), CFrame.new(position.X, position.Y - size.Y / 2 - 0.35, z + frontDirection * 0.28), frameColour, Enum.Material.Concrete))
end

local function addDoor(parent, parts, position, frontDirection, colour, width)
	width = width or 5
	stagePart(parts, newPart(parent, "DoorFrame", Vector3.new(width + 1.2, 9.8, 1.2), CFrame.new(position), Color3.fromRGB(240, 238, 228), Enum.Material.Wood))
	stagePart(parts, newPart(parent, "FrontDoor", Vector3.new(width, 8.8, 0.8), CFrame.new(position.X, position.Y, position.Z + frontDirection * 0.3), colour, Enum.Material.WoodPlanks))
	local handle = newPart(parent, "DoorHandle", Vector3.new(0.35, 0.35, 0.35), CFrame.new(position.X + width * 0.32, position.Y, position.Z + frontDirection * 0.85), Color3.fromRGB(225, 190, 80), Enum.Material.Metal, Enum.PartType.Ball)
	handle.CanCollide = false
	stagePart(parts, handle)
end

local function addGableRoof(parent, parts, centre, width, depth, height, colour)
	local halfDepth = depth / 2
	stagePart(parts, newWedge(parent, "RoofLeft", Vector3.new(width + 3, height, halfDepth + 2), CFrame.new(centre.X, centre.Y, centre.Z - halfDepth / 2) * CFrame.Angles(0, 0, 0), colour, Enum.Material.Slate))
	stagePart(parts, newWedge(parent, "RoofRight", Vector3.new(width + 3, height, halfDepth + 2), CFrame.new(centre.X, centre.Y, centre.Z + halfDepth / 2) * CFrame.Angles(0, math.rad(180), 0), colour, Enum.Material.Slate))
	stagePart(parts, newPart(parent, "RoofRidge", Vector3.new(width + 3.5, 0.55, 0.65), CFrame.new(centre.X, centre.Y + height / 2, centre.Z), Color3.fromRGB(62, 54, 50), Enum.Material.Slate))
end

local function addHedge(parent, parts, position, size)
	local hedge = newPart(parent, "Hedge", size, CFrame.new(position), Color3.fromRGB(55, 118, 58), Enum.Material.Grass)
	stagePart(parts, hedge)
end

local function addTree(parent, parts, position, scale)
	scale = scale or 1
	stagePart(parts, newPart(parent, "TreeTrunk", Vector3.new(1.6, 6 * scale, 1.6), CFrame.new(position.X, position.Y + 3 * scale, position.Z), Color3.fromRGB(105, 74, 48), Enum.Material.Wood))
	local crown = newPart(parent, "TreeCrown", Vector3.new(7 * scale, 7 * scale, 7 * scale), CFrame.new(position.X, position.Y + 8 * scale, position.Z), Color3.fromRGB(65, 135, 67), Enum.Material.Grass, Enum.PartType.Ball)
	stagePart(parts, crown)
end

local function addExteriorLight(parent, parts, position)
	local lamp = newPart(parent, "PorchLight", Vector3.new(0.8, 1.2, 0.8), CFrame.new(position), Color3.fromRGB(255, 222, 145), Enum.Material.Neon)
	lamp.CanCollide = false
	stagePart(parts, lamp)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 222, 170)
	light.Brightness = 1.2
	light.Range = 12
	light.Parent = lamp
end

local function clearOldVisuals(house)
	for _, child in ipairs(house:GetChildren()) do
		child:Destroy()
	end
end

local function buildBungalow(house, centre, frontDirection, parts)
	local wall = Color3.fromRGB(235, 218, 184)
	stagePart(parts, newPart(house, "Foundation", Vector3.new(43, 1, 37), CFrame.new(centre + Vector3.new(0, 1, 0)), Color3.fromRGB(175, 172, 166), Enum.Material.Concrete))
	stagePart(parts, newPart(house, "MainWalls", Vector3.new(35, 11, 29), CFrame.new(centre + Vector3.new(0, 7, 0)), wall, Enum.Material.Brick))
	stagePart(parts, newPart(house, "PorchRoof", Vector3.new(13, 1, 7), CFrame.new(centre.X, centre.Y + 10.5, centre.Z + frontDirection * 17), Color3.fromRGB(88, 65, 54), Enum.Material.Slate))
	for _, x in ipairs({-5, 5}) do
		stagePart(parts, newPart(house, "PorchPost", Vector3.new(0.8, 8, 0.8), CFrame.new(centre.X + x, centre.Y + 5.5, centre.Z + frontDirection * 19.5), Color3.fromRGB(245, 242, 230), Enum.Material.Wood))
	end
	addGableRoof(house, parts, centre + Vector3.new(0, 15, 0), 37, 31, 6, Color3.fromRGB(91, 66, 55))
	addDoor(house, parts, Vector3.new(centre.X, centre.Y + 5.2, centre.Z + frontDirection * 14.8), frontDirection, Color3.fromRGB(56, 111, 91))
	for _, x in ipairs({-10.5, 10.5}) do
		addWindow(house, parts, Vector3.new(centre.X + x, centre.Y + 8, centre.Z + frontDirection * 14.75), Vector3.new(6, 5.2, 0.45), frontDirection, true)
	end
	stagePart(parts, newPart(house, "FrontPath", Vector3.new(5, 0.35, 17), CFrame.new(centre.X, centre.Y + 1, centre.Z + frontDirection * 23), Color3.fromRGB(155, 151, 142), Enum.Material.Pavement))
	addHedge(house, parts, Vector3.new(centre.X - 18, centre.Y + 2.2, centre.Z + frontDirection * 17), Vector3.new(7, 3, 3))
	addHedge(house, parts, Vector3.new(centre.X + 18, centre.Y + 2.2, centre.Z + frontDirection * 17), Vector3.new(7, 3, 3))
	addExteriorLight(house, parts, Vector3.new(centre.X + 3.5, centre.Y + 7.5, centre.Z + frontDirection * 15.3))
end

local function buildFamilySemi(house, centre, frontDirection, parts)
	stagePart(parts, newPart(house, "Foundation", Vector3.new(47, 1, 40), CFrame.new(centre + Vector3.new(0, 1, 0)), Color3.fromRGB(170, 170, 166), Enum.Material.Concrete))
	stagePart(parts, newPart(house, "MainWalls", Vector3.new(31, 22, 31), CFrame.new(centre + Vector3.new(-6, 12, 0)), Color3.fromRGB(216, 198, 171), Enum.Material.Brick))
	stagePart(parts, newPart(house, "Garage", Vector3.new(14, 11, 27), CFrame.new(centre + Vector3.new(17, 6.5, 2)), Color3.fromRGB(224, 218, 203), Enum.Material.Brick))
	addGableRoof(house, parts, centre + Vector3.new(-6, 25.5, 0), 34, 34, 7, Color3.fromRGB(70, 65, 62))
	stagePart(parts, newPart(house, "GarageRoof", Vector3.new(16, 1, 30), CFrame.new(centre + Vector3.new(17, 12.5, 2)), Color3.fromRGB(75, 70, 66), Enum.Material.Slate))
	addDoor(house, parts, Vector3.new(centre.X - 5, centre.Y + 5.2, centre.Z + frontDirection * 15.8), frontDirection, Color3.fromRGB(55, 82, 128))
	stagePart(parts, newPart(house, "GarageDoorFrame", Vector3.new(12.3, 8.8, 1.2), CFrame.new(centre.X + 17, centre.Y + 5.3, centre.Z + frontDirection * 15.6), Color3.fromRGB(245, 245, 240), Enum.Material.Metal))
	for line = -3, 3, 2 do
		stagePart(parts, newPart(house, "GaragePanel", Vector3.new(10.8, 0.22, 0.25), CFrame.new(centre.X + 17, centre.Y + 5.3 + line, centre.Z + frontDirection * 16.25), Color3.fromRGB(184, 184, 180), Enum.Material.Metal))
	end
	for _, y in ipairs({8, 17}) do
		for _, x in ipairs({-13, 2}) do
			addWindow(house, parts, Vector3.new(centre.X + x, centre.Y + y, centre.Z + frontDirection * 15.7), Vector3.new(5.2, 5.2, 0.45), frontDirection, y == 8)
		end
	end
	stagePart(parts, newPart(house, "Driveway", Vector3.new(15, 0.35, 24), CFrame.new(centre.X + 17, centre.Y + 1, centre.Z + frontDirection * 25), Color3.fromRGB(112, 111, 108), Enum.Material.Pavement))
	stagePart(parts, newPart(house, "DoorPath", Vector3.new(5, 0.35, 16), CFrame.new(centre.X - 5, centre.Y + 1, centre.Z + frontDirection * 23), Color3.fromRGB(154, 150, 143), Enum.Material.Pavement))
	addTree(house, parts, Vector3.new(centre.X - 22, centre.Y + 1, centre.Z + frontDirection * 15), 0.8)
	addExteriorLight(house, parts, Vector3.new(centre.X - 1.5, centre.Y + 7.5, centre.Z + frontDirection * 16.3))
end

local function buildCottage(house, centre, frontDirection, parts)
	stagePart(parts, newPart(house, "StoneFoundation", Vector3.new(44, 1, 38), CFrame.new(centre + Vector3.new(0, 1, 0)), Color3.fromRGB(145, 141, 132), Enum.Material.Cobblestone))
	stagePart(parts, newPart(house, "StoneWalls", Vector3.new(37, 15, 31), CFrame.new(centre + Vector3.new(0, 8.5, 0)), Color3.fromRGB(181, 171, 149), Enum.Material.Cobblestone))
	addGableRoof(house, parts, centre + Vector3.new(0, 19.5, 0), 41, 35, 8, Color3.fromRGB(82, 54, 42))
	stagePart(parts, newPart(house, "Chimney", Vector3.new(5, 13, 5), CFrame.new(centre + Vector3.new(12, 22, 4)), Color3.fromRGB(128, 79, 59), Enum.Material.Brick))
	stagePart(parts, newPart(house, "ChimneyCap", Vector3.new(6, 0.8, 6), CFrame.new(centre + Vector3.new(12, 28.5, 4)), Color3.fromRGB(92, 64, 54), Enum.Material.Brick))
	stagePart(parts, newPart(house, "TimberBeam", Vector3.new(37.5, 0.7, 0.7), CFrame.new(centre.X, centre.Y + 13, centre.Z + frontDirection * 15.7), Color3.fromRGB(93, 65, 45), Enum.Material.WoodPlanks))
	addDoor(house, parts, Vector3.new(centre.X, centre.Y + 5.2, centre.Z + frontDirection * 15.8), frontDirection, Color3.fromRGB(96, 58, 38))
	for _, x in ipairs({-11, 11}) do
		addWindow(house, parts, Vector3.new(centre.X + x, centre.Y + 10, centre.Z + frontDirection * 15.75), Vector3.new(6, 5.8, 0.45), frontDirection, true)
	end
	stagePart(parts, newPart(house, "WindingPath", Vector3.new(5, 0.35, 18), CFrame.new(centre.X, centre.Y + 1, centre.Z + frontDirection * 24), Color3.fromRGB(144, 136, 121), Enum.Material.Cobblestone))
	for _, x in ipairs({-18, 18}) do
		stagePart(parts, newPart(house, "FlowerBed", Vector3.new(8, 1.1, 5), CFrame.new(centre.X + x, centre.Y + 1.6, centre.Z + frontDirection * 18), Color3.fromRGB(91, 67, 46), Enum.Material.Ground))
		for offset = -3, 3, 2 do
			local flower = newPart(house, "Flower", Vector3.new(0.7, 1.5, 0.7), CFrame.new(centre.X + x + offset, centre.Y + 2.8, centre.Z + frontDirection * 18), Color3.fromRGB(235, 105 + (offset + 3) * 12, 145), Enum.Material.Neon, Enum.PartType.Ball)
			flower.CanCollide = false
			stagePart(parts, flower)
		end
	end
	addHedge(house, parts, Vector3.new(centre.X - 21, centre.Y + 2.1, centre.Z + frontDirection * 10), Vector3.new(4, 3.2, 17))
	addHedge(house, parts, Vector3.new(centre.X + 21, centre.Y + 2.1, centre.Z + frontDirection * 10), Vector3.new(4, 3.2, 17))
	addExteriorLight(house, parts, Vector3.new(centre.X + 3.8, centre.Y + 7.5, centre.Z + frontDirection * 16.3))
end

local function buildModern(house, centre, frontDirection, parts)
	stagePart(parts, newPart(house, "Foundation", Vector3.new(48, 1, 40), CFrame.new(centre + Vector3.new(0, 1, 0)), Color3.fromRGB(122, 123, 124), Enum.Material.Concrete))
	stagePart(parts, newPart(house, "LowerFloor", Vector3.new(43, 11, 33), CFrame.new(centre + Vector3.new(0, 6.5, 0)), Color3.fromRGB(232, 231, 224), Enum.Material.Concrete))
	stagePart(parts, newPart(house, "UpperFloor", Vector3.new(33, 10, 27), CFrame.new(centre + Vector3.new(-6, 17, -2 * frontDirection)), Color3.fromRGB(70, 77, 83), Enum.Material.Concrete))
	stagePart(parts, newPart(house, "FeatureWall", Vector3.new(8, 22, 34), CFrame.new(centre + Vector3.new(17, 12, 0)), Color3.fromRGB(142, 103, 70), Enum.Material.WoodPlanks))
	stagePart(parts, newPart(house, "FlatRoof", Vector3.new(37, 1.4, 31), CFrame.new(centre + Vector3.new(-6, 22.8, -2 * frontDirection)), Color3.fromRGB(35, 38, 42), Enum.Material.SmoothPlastic))
	addDoor(house, parts, Vector3.new(centre.X + 14, centre.Y + 5.3, centre.Z + frontDirection * 16.8), frontDirection, Color3.fromRGB(38, 39, 41), 5.5)
	addWindow(house, parts, Vector3.new(centre.X - 8, centre.Y + 7, centre.Z + frontDirection * 16.7), Vector3.new(21, 7, 0.45), frontDirection, true)
	addWindow(house, parts, Vector3.new(centre.X - 6, centre.Y + 17, centre.Z + frontDirection * 15.7), Vector3.new(22, 6, 0.45), frontDirection, false)
	stagePart(parts, newPart(house, "Balcony", Vector3.new(26, 1, 6), CFrame.new(centre.X - 6, centre.Y + 13, centre.Z + frontDirection * 18), Color3.fromRGB(109, 111, 112), Enum.Material.Concrete))
	for _, x in ipairs({-17, -6, 5}) do
		local rail = newPart(house, "GlassRail", Vector3.new(0.35, 3.2, 0.35), CFrame.new(centre.X + x, centre.Y + 14.8, centre.Z + frontDirection * 20.7), Color3.fromRGB(188, 225, 238), Enum.Material.Glass)
		rail.Transparency = 0.3
		rail.CanCollide = false
		stagePart(parts, rail)
	end
	local longRail = newPart(house, "GlassBalconyRail", Vector3.new(25, 3, 0.3), CFrame.new(centre.X - 6, centre.Y + 14.8, centre.Z + frontDirection * 20.7), Color3.fromRGB(188, 225, 238), Enum.Material.Glass)
	longRail.Transparency = 0.45
	longRail.CanCollide = false
	stagePart(parts, longRail)
	stagePart(parts, newPart(house, "Driveway", Vector3.new(13, 0.35, 24), CFrame.new(centre.X + 17, centre.Y + 1, centre.Z + frontDirection * 25), Color3.fromRGB(91, 92, 94), Enum.Material.Pavement))
	stagePart(parts, newPart(house, "SteppingPath", Vector3.new(6, 0.35, 17), CFrame.new(centre.X + 10, centre.Y + 1, centre.Z + frontDirection * 23), Color3.fromRGB(151, 151, 148), Enum.Material.Concrete))
	addHedge(house, parts, Vector3.new(centre.X - 21, centre.Y + 1.8, centre.Z + frontDirection * 18), Vector3.new(5, 2.5, 12))
	addExteriorLight(house, parts, Vector3.new(centre.X + 10.5, centre.Y + 8, centre.Z + frontDirection * 17.3))
end

local builders = {
	Bungalow = buildBungalow,
	FamilySemi = buildFamilySemi,
	Cottage = buildCottage,
	Modern = buildModern,
}

local function animateBuild(plotModel, house)
	if house:GetAttribute("Polished") then return end
	house:SetAttribute("Polished", true)

	local houseType = house:GetAttribute("HouseType")
	local builder = builders[houseType]
	if not builder then return end

	local plot = plotModel:FindFirstChild("Plot")
	if not plot then return end

	local prompt = plotModel:FindFirstChild("Sign") and plotModel.Sign:FindFirstChild("PropertyPrompt")
	local label = plotModel:FindFirstChild("Sign") and plotModel.Sign:FindFirstChild("BillboardGui") and plotModel.Sign.BillboardGui:FindFirstChild("TextLabel")
	if prompt then prompt.Enabled = false end

	clearOldVisuals(house)
	local parts = {}
	local centre = plot.Position
	local frontDirection = plotModel:GetAttribute("FrontDirection") or -1
	builder(house, centre, frontDirection, parts)

	local total = #parts
	for index, part in ipairs(parts) do
		if not part.Parent then continue end
		local finalTransparency = part:GetAttribute("FinalTransparency") or 0
		local tween = TweenService:Create(part, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = finalTransparency})
		tween:Play()
		part.CanCollide = finalTransparency < 0.9
		if label and index % 6 == 0 then
			local percentage = math.floor(index / total * 100)
			label.Text = "BUILDING " .. percentage .. "%"
		end
		task.wait(BUILD_DELAY)
	end

	local displayName = house:GetAttribute("DisplayName") or "House"
	local salePrice = house:GetAttribute("SalePrice") or 0
	if label then label.Text = string.upper(displayName) .. "\nVALUE £" .. formatMoney(salePrice) end
	if prompt then
		prompt.ActionText = "Sell for £" .. formatMoney(salePrice)
		prompt.Enabled = true
	end
end

local function watchPlot(plotModel)
	local existing = plotModel:FindFirstChild("House")
	if existing then task.spawn(animateBuild, plotModel, existing) end
	plotModel.ChildAdded:Connect(function(child)
		if child.Name == "House" then
			task.spawn(animateBuild, plotModel, child)
		end
	end)
end

local function watchWorld(world)
	local plots = world:WaitForChild("Plots")
	for _, plot in ipairs(plots:GetChildren()) do watchPlot(plot) end
	plots.ChildAdded:Connect(watchPlot)
end

local world = workspace:FindFirstChild("HometownWorld")
if world then task.spawn(watchWorld, world) end
workspace.ChildAdded:Connect(function(child)
	if child.Name == "HometownWorld" then task.spawn(watchWorld, child) end
end)
