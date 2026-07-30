local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local world = workspace:WaitForChild("HometownWorld")
local ambient = world:WaitForChild("AmbientTown")
local traffic = ambient:WaitForChild("Traffic")

-- Remove the older generated vehicles. Their movement scripts safely ignore destroyed models.
task.wait(2)
for _, item in ipairs(traffic:GetChildren()) do
	if item:IsA("Model") and (item.Name:find("Bus") or item.Name:find("Car") or item.Name:find("Taxi") or item.Name:find("Van")) then
		item:Destroy()
	end
end

local function part(name, size, cf, colour, material, parent, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = colour
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = collide == true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function textOn(partObject, face, text, colour)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 35
	gui.Parent = partObject
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = colour
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
end

local function cylinderWheel(parent, cf)
	local tyre = part("Tyre", Vector3.new(1.1, 3.2, 3.2), cf * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(18,18,20), Enum.Material.Rubber, parent)
	tye = tyre
	tye.Shape = Enum.PartType.Cylinder
	local hub = part("Hub", Vector3.new(1.15, 1.5, 1.5), tyre.CFrame, Color3.fromRGB(150,155,160), Enum.Material.Metal, parent)
	hub.Shape = Enum.PartType.Cylinder
end

-- Vehicles are built lengthways on local -Z so CFrame.lookAt faces them correctly.
local function makeBus(name, routeText)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = traffic
	local root = part("Root", Vector3.new(1,1,1), CFrame.new(), Color3.new(), nil, m)
	root.Transparency = 1
	m.PrimaryPart = root

	local black = Color3.fromRGB(15,18,22)
	local glass = Color3.fromRGB(30,48,62)
	part("LowerBody", Vector3.new(8.2,6.2,25), root.CFrame*CFrame.new(0,4.2,0), black, Enum.Material.Metal, m)
	part("UpperBody", Vector3.new(8.0,5.8,23.8), root.CFrame*CFrame.new(0,10.1,0.5), black, Enum.Material.Metal, m)
	part("Roof", Vector3.new(7.8,0.55,23.2), root.CFrame*CFrame.new(0,13.25,0.7), Color3.fromRGB(42,45,50), Enum.Material.Metal, m)

	-- Clean rounded-looking front made from layered boxes, not wedges.
	part("FrontLower", Vector3.new(7.9,5.7,1.0), root.CFrame*CFrame.new(0,4.4,-13.0), black, Enum.Material.Metal, m)
	part("FrontUpper", Vector3.new(7.7,5.4,0.9), root.CFrame*CFrame.new(0,10.2,-12.4)*CFrame.Angles(math.rad(-5),0,0), black, Enum.Material.Metal, m)
	local lowerGlass = part("LowerWindscreen", Vector3.new(6.8,3.9,0.25), root.CFrame*CFrame.new(0,6.1,-13.55)*CFrame.Angles(math.rad(-8),0,0), glass, Enum.Material.Glass, m)
	lowerGlass.Transparency = 0.18
	local upperGlass = part("UpperWindscreen", Vector3.new(6.8,3.9,0.25), root.CFrame*CFrame.new(0,11.1,-12.9)*CFrame.Angles(math.rad(-8),0,0), glass, Enum.Material.Glass, m)
	upperGlass.Transparency = 0.18

	for _, y in ipairs({6.6,10.8}) do
		for _, x in ipairs({-4.1,4.1}) do
			for z = -8.5, 9.5, 4.5 do
				local w = part("SideWindow", Vector3.new(0.22,3.0,3.6), root.CFrame*CFrame.new(x,y,z), glass, Enum.Material.Glass, m)
				w.Transparency = 0.2
			end
		end
	end

	local door = part("PassengerDoors", Vector3.new(0.28,4.8,3.2), root.CFrame*CFrame.new(-4.22,4.5,-8.2), glass, Enum.Material.Glass, m)
	door.Transparency = 0.16
	part("DoorDivider", Vector3.new(0.3,4.9,0.18), root.CFrame*CFrame.new(-4.36,4.5,-8.2), Color3.fromRGB(190,195,200), Enum.Material.Metal, m)

	for _, x in ipairs({-4.45,4.45}) do
		cylinderWheel(m, root.CFrame*CFrame.new(x,2.0,-8.7))
		cylinderWheel(m, root.CFrame*CFrame.new(x,2.0,8.2))
	end

	for _, x in ipairs({-2.7,2.7}) do
		local light = part("Headlight", Vector3.new(0.65,0.65,0.3), root.CFrame*CFrame.new(x,2.7,-13.65), Color3.fromRGB(255,248,210), Enum.Material.Neon, m)
		light.Shape = Enum.PartType.Ball
	end
	part("LeftMirror", Vector3.new(0.7,1.5,0.7), root.CFrame*CFrame.new(-4.7,7.0,-11.2), Color3.fromRGB(245,205,30), nil, m)
	part("RightMirror", Vector3.new(0.7,1.5,0.7), root.CFrame*CFrame.new(4.7,7.0,-11.2), Color3.fromRGB(245,205,30), nil, m)
	part("BlueTrim", Vector3.new(2.4,0.4,0.3), root.CFrame*CFrame.new(-2.5,1.8,-13.65), Color3.fromRGB(18,154,214), Enum.Material.Neon, m)
	part("GreenTrim", Vector3.new(2.4,0.4,0.3), root.CFrame*CFrame.new(0,1.8,-13.65), Color3.fromRGB(27,190,151), Enum.Material.Neon, m)
	part("OrangeTrim", Vector3.new(2.4,0.4,0.3), root.CFrame*CFrame.new(2.5,1.8,-13.65), Color3.fromRGB(245,158,48), Enum.Material.Neon, m)
	local destination = part("Destination", Vector3.new(5.8,1.25,0.3), root.CFrame*CFrame.new(0,8.8,-13.65), Color3.fromRGB(4,5,6), nil, m)
	textOn(destination, Enum.NormalId.Front, routeText, Color3.fromRGB(255,190,35))
	local operator = part("Operator", Vector3.new(4.8,0.9,0.3), root.CFrame*CFrame.new(0,7.45,-13.65), black, nil, m)
	textOn(operator, Enum.NormalId.Front, "HOMETOWN", Color3.fromRGB(245,245,245))
	return m
end

local function makeCar(name, colour, kind)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = traffic
	local root = part("Root", Vector3.new(1,1,1), CFrame.new(), Color3.new(), nil, m)
	root.Transparency = 1
	m.PrimaryPart = root
	local length = kind == "Van" and 10.5 or 8.5
	part("Chassis", Vector3.new(6.2,1.8,length), root.CFrame*CFrame.new(0,1.8,0), colour, Enum.Material.Metal, m)
	part("Cabin", Vector3.new(kind=="Van" and 5.8 or 5.2,2.3,kind=="Van" and 5.8 or 4.6), root.CFrame*CFrame.new(0,3.4,0.5), colour, Enum.Material.Metal, m)
	local frontGlass = part("FrontGlass", Vector3.new(4.5,1.7,0.22), root.CFrame*CFrame.new(0,3.7,-length/2-0.05)*CFrame.Angles(math.rad(-15),0,0), Color3.fromRGB(45,65,80), Enum.Material.Glass, m)
	frontGlass.Transparency = 0.2
	local backGlass = part("RearGlass", Vector3.new(4.4,1.5,0.2), root.CFrame*CFrame.new(0,3.6,length/2-0.1), Color3.fromRGB(45,65,80), Enum.Material.Glass, m)
	backGlass.Transparency = 0.25
	for _, x in ipairs({-3.15,3.15}) do
		cylinderWheel(m, root.CFrame*CFrame.new(x,1.25,-length*0.3))
		cylinderWheel(m, root.CFrame*CFrame.new(x,1.25,length*0.3))
	end
	for _, x in ipairs({-2.0,2.0}) do
		part("Headlight", Vector3.new(0.7,0.55,0.22), root.CFrame*CFrame.new(x,2.0,-length/2-0.15), Color3.fromRGB(255,248,210), Enum.Material.Neon, m)
	end
	part("FrontBumper", Vector3.new(5.8,0.45,0.35), root.CFrame*CFrame.new(0,1.1,-length/2-0.25), Color3.fromRGB(45,45,48), Enum.Material.Metal, m)
	part("RearBumper", Vector3.new(5.8,0.45,0.35), root.CFrame*CFrame.new(0,1.1,length/2+0.25), Color3.fromRGB(45,45,48), Enum.Material.Metal, m)
	return m
end

local function makePassenger(name, position, colour)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = ambient
	local root = part("Root", Vector3.new(1,1,1), CFrame.new(position), Color3.new(), nil, m)
	root.Transparency = 1
	m.PrimaryPart = root
	part("Torso", Vector3.new(2.1,2.7,1.2), root.CFrame*CFrame.new(0,3.8,0), colour, Enum.Material.Fabric, m)
	local head = part("Head", Vector3.new(1.6,1.6,1.6), root.CFrame*CFrame.new(0,6.0,0), Color3.fromRGB(224,184,145), nil, m)
	head.Shape = Enum.PartType.Ball
	for _, x in ipairs({-1.25,1.25}) do part("Arm", Vector3.new(0.7,2.5,0.7), root.CFrame*CFrame.new(x,3.8,0), Color3.fromRGB(224,184,145), nil, m) end
	for _, x in ipairs({-0.55,0.55}) do part("Leg", Vector3.new(0.8,2.7,0.9), root.CFrame*CFrame.new(x,1.4,0), Color3.fromRGB(45,50,65), Enum.Material.Fabric, m) end
	return m
end

local routeA = {
	{P=Vector3.new(-205,1.4,-9)},
	{P=Vector3.new(-55,1.4,-9), Stop=true},
	{P=Vector3.new(55,1.4,-9), Stop=true},
	{P=Vector3.new(205,1.4,-9)},
}
local routeB = {
	{P=Vector3.new(205,1.4,9)},
	{P=Vector3.new(55,1.4,9), Stop=true},
	{P=Vector3.new(-55,1.4,9), Stop=true},
	{P=Vector3.new(-205,1.4,9)},
}

local movers = {
	{Model=makeBus("TownDoubleDecker1","MS1  TOWN CENTRE"), Route=routeA, Speed=14, Index=1, T=0, Wait=0},
	{Model=makeBus("TownDoubleDecker2","MS2  HOMETOWN"), Route=routeB, Speed=13, Index=1, T=0, Wait=5},
}
local carColours = {
	Color3.fromRGB(175,35,35), Color3.fromRGB(35,80,145), Color3.fromRGB(225,225,225),
	Color3.fromRGB(45,45,48), Color3.fromRGB(190,140,40), Color3.fromRGB(70,130,85),
}
for i, colour in ipairs(carColours) do
	local route = i%2==0 and routeB or routeA
	table.insert(movers,{Model=makeCar("DetailedCar"..i,colour,i==6 and "Van" or "Car"),Route=route,Speed=18+i,Index=1,T=0,Wait=i*1.8})
end

local function passengerExchange(bus, stopPosition)
	local side = bus.PrimaryPart.CFrame.RightVector * -5.2
	local waiting = makePassenger("WaitingPassenger", stopPosition + side + Vector3.new(0,0,4), Color3.fromRGB(55,105,160))
	local doorPosition = bus.PrimaryPart.Position + bus.PrimaryPart.CFrame.RightVector * -4.8 + bus.PrimaryPart.CFrame.LookVector * 8
	local tween = TweenService:Create(waiting.PrimaryPart, TweenInfo.new(2.2,Enum.EasingStyle.Linear), {CFrame=CFrame.new(doorPosition)})
	tween:Play()
	tween.Completed:Connect(function() if waiting.Parent then waiting:Destroy() end end)

	task.delay(1.0,function()
		if not bus.Parent then return end
		local leaving = makePassenger("LeavingPassenger", doorPosition, Color3.fromRGB(160,70,90))
		local away = stopPosition + side + Vector3.new(0,0,-5)
		local t = TweenService:Create(leaving.PrimaryPart,TweenInfo.new(2.2,Enum.EasingStyle.Linear),{CFrame=CFrame.new(away)})
		t:Play()
		t.Completed:Connect(function() if leaving.Parent then leaving:Destroy() end end)
	end)
end

RunService.Heartbeat:Connect(function(dt)
	for _, mover in ipairs(movers) do
		if mover.Model.Parent and mover.Model.PrimaryPart then
			if mover.Wait > 0 then
				mover.Wait -= dt
			else
				local fromNode = mover.Route[mover.Index]
				local nextIndex = mover.Index % #mover.Route + 1
				local toNode = mover.Route[nextIndex]
				local distance = (toNode.P-fromNode.P).Magnitude
				mover.T += mover.Speed*dt/distance
				if mover.T >= 1 then
					mover.T = 0
					mover.Index = nextIndex
					if toNode.Stop and mover.Model.Name:find("DoubleDecker") then
						mover.Wait = 5
						passengerExchange(mover.Model,toNode.P)
					end
				else
					local pos = fromNode.P:Lerp(toNode.P,mover.T)
					local direction = (toNode.P-fromNode.P).Unit
					mover.Model:PivotTo(CFrame.lookAt(pos,pos+direction))
				end
			end
		end
	end
end)

print("Detailed traffic, bus stopping and passenger exchange loaded")