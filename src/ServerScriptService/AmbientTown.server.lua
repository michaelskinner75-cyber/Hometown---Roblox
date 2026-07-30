local TweenService = game:GetService("TweenService")

local world = workspace:WaitForChild("HometownWorld")

local oldAmbient = world:FindFirstChild("AmbientTown")
if oldAmbient then
	oldAmbient:Destroy()
end

local ambient = Instance.new("Folder")
ambient.Name = "AmbientTown"
ambient.Parent = world

local pedestriansFolder = Instance.new("Folder")
pedestriansFolder.Name = "Pedestrians"
pedestriansFolder.Parent = ambient

local trafficFolder = Instance.new("Folder")
trafficFolder.Name = "Traffic"
trafficFolder.Parent = ambient

local sceneryFolder = Instance.new("Folder")
sceneryFolder.Name = "Scenery"
sceneryFolder.Parent = ambient

local function part(name, size, cframe, colour, material, parent, anchored)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = colour
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = anchored ~= false
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function weld(root, item)
	local joint = Instance.new("WeldConstraint")
	joint.Part0 = root
	joint.Part1 = item
	joint.Parent = root
end

local skinTones = {
	Color3.fromRGB(255, 219, 172),
	Color3.fromRGB(230, 184, 145),
	Color3.fromRGB(177, 126, 91),
	Color3.fromRGB(109, 76, 65),
}

local clothingColours = {
	Color3.fromRGB(46, 94, 170), Color3.fromRGB(170, 57, 57),
	Color3.fromRGB(51, 125, 86), Color3.fromRGB(117, 71, 150),
	Color3.fromRGB(225, 140, 48), Color3.fromRGB(48, 48, 55),
}

local hairColours = {
	Color3.fromRGB(40, 28, 20), Color3.fromRGB(98, 64, 38),
	Color3.fromRGB(220, 188, 125), Color3.fromRGB(35, 35, 35),
}

local function makePedestrian(index, startPosition)
	local model = Instance.new("Model")
	model.Name = "TownResident" .. index
	model.Parent = pedestriansFolder

	local root = part("HumanoidRootPart", Vector3.new(1.8, 2.2, 1), CFrame.new(startPosition), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model, true)
	root.Transparency = 1
	model.PrimaryPart = root

	local skin = skinTones[math.random(1, #skinTones)]
	local shirt = clothingColours[math.random(1, #clothingColours)]
	local trousers = clothingColours[math.random(1, #clothingColours)]

	local torso = part("UpperTorso", Vector3.new(2.1, 2.2, 1.1), root.CFrame * CFrame.new(0, 1.25, 0), shirt, Enum.Material.Fabric, model, true)
	local head = part("Head", Vector3.new(1.65, 1.65, 1.65), root.CFrame * CFrame.new(0, 3.15, 0), skin, Enum.Material.SmoothPlastic, model, true)
	local hair = part("Hair", Vector3.new(1.75, 0.5, 1.75), root.CFrame * CFrame.new(0, 3.9, -0.05), hairColours[math.random(1,#hairColours)], Enum.Material.SmoothPlastic, model, true)
	local leftArm = part("LeftArm", Vector3.new(0.65, 2.2, 0.65), root.CFrame * CFrame.new(-1.35, 1.2, 0), skin, Enum.Material.SmoothPlastic, model, true)
	local rightArm = part("RightArm", Vector3.new(0.65, 2.2, 0.65), root.CFrame * CFrame.new(1.35, 1.2, 0), skin, Enum.Material.SmoothPlastic, model, true)
	local leftLeg = part("LeftLeg", Vector3.new(0.75, 2.4, 0.8), root.CFrame * CFrame.new(-0.48, -1.25, 0), trousers, Enum.Material.Fabric, model, true)
	local rightLeg = part("RightLeg", Vector3.new(0.75, 2.4, 0.8), root.CFrame * CFrame.new(0.48, -1.25, 0), trousers, Enum.Material.Fabric, model, true)

	for _, item in ipairs({torso, head, hair, leftArm, rightArm, leftLeg, rightLeg}) do
		weld(root, item)
	end

	local face = Instance.new("Decal")
	face.Name = "Face"
	face.Texture = "rbxasset://textures/face.png"
	face.Face = Enum.NormalId.Front
	face.Parent = head

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(120, 30)
	billboard.StudsOffset = Vector3.new(0, 4.8, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 45
	billboard.Parent = root
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundTransparency = 1
	label.Text = ({"Resident", "Shopper", "Commuter", "Dog Walker", "Visitor"})[math.random(1,5)]
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextStrokeTransparency = 0.35
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.Parent = billboard

	return model
end

local walkingRoutes = {
	{Vector3.new(-150,3,31), Vector3.new(150,3,31)},
	{Vector3.new(150,3,-31), Vector3.new(-150,3,-31)},
	{Vector3.new(-120,3,31), Vector3.new(-120,3,60), Vector3.new(-55,3,60)},
	{Vector3.new(120,3,-31), Vector3.new(120,3,-60), Vector3.new(55,3,-60)},
}

local function runPedestrian(model, route, speed)
	task.spawn(function()
		local current = 1
		while model.Parent do
			local nextIndex = current % #route + 1
			local from = model.PrimaryPart.Position
			local destination = route[nextIndex]
			local distance = (destination - from).Magnitude
			local duration = math.max(1, distance / speed)
			model:PivotTo(CFrame.lookAt(from, Vector3.new(destination.X, from.Y, destination.Z)))
			local tween = TweenService:Create(model.PrimaryPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(destination, destination + (destination - from).Unit)})
			tween:Play()
			tween.Completed:Wait()
			current = nextIndex
			task.wait(math.random(1,4))
		end
	end)
end

for i = 1, 14 do
	local route = walkingRoutes[(i - 1) % #walkingRoutes + 1]
	local npc = makePedestrian(i, route[1] + Vector3.new(math.random(-8,8),0,math.random(-2,2)))
	runPedestrian(npc, route, math.random(7,10))
end

local function createVehicle(name, colour, position, isBus)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = trafficFolder
	local length = isBus and 28 or 11
	local width = isBus and 8 or 6
	local root = part("Root", Vector3.new(length, 1, width), CFrame.new(position), colour, Enum.Material.Metal, model, true)
	root.Transparency = 1
	model.PrimaryPart = root

	local body = part("Body", Vector3.new(length, isBus and 7 or 3.5, width), root.CFrame * CFrame.new(0, isBus and 4 or 2.3, 0), colour, Enum.Material.Metal, model, true)
	weld(root, body)
	local roof = part("Roof", Vector3.new(length - 1, 0.8, width - 0.4), root.CFrame * CFrame.new(0, isBus and 7.8 or 4.4, 0), Color3.fromRGB(230,230,230), Enum.Material.SmoothPlastic, model, true)
	weld(root, roof)

	for _, x in ipairs(isBus and {-10,-5,0,5,10} or {-3.2,3.2}) do
		for _, z in ipairs({-(width/2+0.05), width/2+0.05}) do
			local window = part("Window", Vector3.new(isBus and 3.4 or 3, isBus and 3 or 1.8, 0.2), root.CFrame * CFrame.new(x, isBus and 5.2 or 3.2, z), Color3.fromRGB(115,180,215), Enum.Material.Glass, model, true)
			window.Transparency = 0.25
			weld(root, window)
		end
	end

	for _, x in ipairs({-(length/2-2.2), length/2-2.2}) do
		for _, z in ipairs({-(width/2+0.35), width/2+0.35}) do
			local wheel = part("Wheel", Vector3.new(1.6,3,3), root.CFrame * CFrame.new(x,1.5,z) * CFrame.Angles(math.rad(90),0,0), Color3.fromRGB(25,25,25), Enum.Material.Rubber, model, true)
			wheel.Shape = Enum.PartType.Cylinder
			weld(root, wheel)
		end
	end

	if isBus then
		local display = part("DestinationDisplay", Vector3.new(0.25,1.4,5.6), root.CFrame * CFrame.new(length/2+0.15,6.2,0), Color3.fromRGB(15,15,15), Enum.Material.SmoothPlastic, model, true)
		weld(root, display)
		local surface = Instance.new("SurfaceGui")
		surface.Face = Enum.NormalId.Right
		surface.Parent = display
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1,1)
		text.BackgroundTransparency = 1
		text.Text = "MS1  ARBROATH"
		text.TextColor3 = Color3.fromRGB(255,190,35)
		text.Font = Enum.Font.Code
		text.TextScaled = true
		text.Parent = surface
	end
	return model
end

local roadRoutes = {
	{Vector3.new(-185,1.4,-9), Vector3.new(185,1.4,-9)},
	{Vector3.new(185,1.4,9), Vector3.new(-185,1.4,9)},
}

local function runVehicle(model, route, speed, pauseAtCentre)
	task.spawn(function()
		local current = 1
		while model.Parent do
			local destination = route[current % #route + 1]
			local from = model.PrimaryPart.Position
			local direction = (destination - from).Unit
			model:PivotTo(CFrame.lookAt(from, from + direction))
			local duration = (destination - from).Magnitude / speed
			local tween = TweenService:Create(model.PrimaryPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(destination, destination + direction)})
			tween:Play()
			tween.Completed:Wait()
			current = current % #route + 1
			if pauseAtCentre then task.wait(4) else task.wait(math.random(1,3)) end
		end
	end)
end

local vehicleColours = {
	Color3.fromRGB(45,95,170), Color3.fromRGB(180,55,55),
	Color3.fromRGB(230,230,225), Color3.fromRGB(45,45,50),
	Color3.fromRGB(210,145,40),
}

for i = 1, 6 do
	local route = roadRoutes[(i - 1) % 2 + 1]
	local car = createVehicle("TrafficCar" .. i, vehicleColours[(i - 1) % #vehicleColours + 1], route[1] + Vector3.new(i*18,0,0), false)
	runVehicle(car, route, 20 + i)
end

local bus = createVehicle("HometownBus", Color3.fromRGB(25,45,70), Vector3.new(-175,1.4,-9), true)
runVehicle(bus, roadRoutes[1], 15, true)

local function createBusStop(position, facing)
	local model = Instance.new("Model")
	model.Name = "BusStop"
	model.Parent = sceneryFolder
	local pole = part("Pole", Vector3.new(0.5,8,0.5), CFrame.new(position + Vector3.new(0,4,0)), Color3.fromRGB(75,75,80), Enum.Material.Metal, model, true)
	local flag = part("Flag", Vector3.new(0.4,2.5,3.8), CFrame.new(position + Vector3.new(0,7,0)) * CFrame.Angles(0,math.rad(facing),0), Color3.fromRGB(35,65,105), Enum.Material.Metal, model, true)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Right
	gui.Parent = flag
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundTransparency = 1
	label.Text = "BUS STOP\nMS1"
	label.TextColor3 = Color3.fromRGB(255,210,45)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
	part("ShelterBack", Vector3.new(0.35,7,12), CFrame.new(position + Vector3.new(3,3.5,0)), Color3.fromRGB(120,180,205), Enum.Material.Glass, model, true).Transparency = 0.45
	part("ShelterRoof", Vector3.new(5,0.4,12), CFrame.new(position + Vector3.new(1,7,0)), Color3.fromRGB(65,75,85), Enum.Material.Metal, model, true)
	part("Bench", Vector3.new(2.5,0.5,7), CFrame.new(position + Vector3.new(0.7,1.5,0)), Color3.fromRGB(110,75,45), Enum.Material.WoodPlanks, model, true)
end

createBusStop(Vector3.new(-35,1,31), 0)
createBusStop(Vector3.new(35,1,-31), 180)

local function decorativeHome(name, centre, wallColour, roofColour)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = sceneryFolder
	part("Foundation", Vector3.new(42,1,35), CFrame.new(centre + Vector3.new(0,0.5,0)), Color3.fromRGB(155,155,150), Enum.Material.Concrete, model, true)
	part("House", Vector3.new(34,15,28), CFrame.new(centre + Vector3.new(0,8,0)), wallColour, Enum.Material.Brick, model, true)
	local roofA = part("RoofA", Vector3.new(38,3,32), CFrame.new(centre + Vector3.new(0,17,0)) * CFrame.Angles(0,0,math.rad(12)), roofColour, Enum.Material.Slate, model, true)
	local roofB = part("RoofB", Vector3.new(38,3,32), CFrame.new(centre + Vector3.new(0,17,0)) * CFrame.Angles(0,0,math.rad(-12)), roofColour, Enum.Material.Slate, model, true)
	for _, x in ipairs({-10,10}) do
		local w = part("Window", Vector3.new(6,5,0.4), CFrame.new(centre + Vector3.new(x,9,-14.2)), Color3.fromRGB(150,215,255), Enum.Material.Glass, model, true)
		w.Transparency = 0.25
	end
	part("Door", Vector3.new(5,8,0.6), CFrame.new(centre + Vector3.new(0,5,-14.4)), Color3.fromRGB(65,100,80), Enum.Material.Wood, model, true)
	part("Driveway", Vector3.new(10,0.3,24), CFrame.new(centre + Vector3.new(18,0.7,-22)), Color3.fromRGB(120,120,120), Enum.Material.Concrete, model, true)
end

decorativeHome("OakView", Vector3.new(-135,0,145), Color3.fromRGB(229,210,177), Color3.fromRGB(70,55,50))
decorativeHome("RoseCottage", Vector3.new(-50,0,145), Color3.fromRGB(194,208,185), Color3.fromRGB(82,52,42))
decorativeHome("HillHouse", Vector3.new(50,0,145), Color3.fromRGB(215,220,225), Color3.fromRGB(60,65,72))
decorativeHome("ParkVilla", Vector3.new(135,0,145), Color3.fromRGB(225,192,180), Color3.fromRGB(75,55,50))

print("Hometown ambient life loaded: pedestrians, traffic, bus stops, bus and extra homes")