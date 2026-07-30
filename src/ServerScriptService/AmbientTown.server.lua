local RunService = game:GetService("RunService")

local world = workspace:WaitForChild("HometownWorld")
local oldAmbient = world:FindFirstChild("AmbientTown")
if oldAmbient then oldAmbient:Destroy() end

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

local movers = {}

local function part(name, size, cframe, colour, material, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = colour
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addMover(model, route, speed, pause)
	table.insert(movers, {Model=model, Route=route, Speed=speed, Pause=pause or 0, Index=1, Wait=0, Distance=0})
end

local skinTones = {
	Color3.fromRGB(255,219,172), Color3.fromRGB(232,190,145),
	Color3.fromRGB(181,132,96), Color3.fromRGB(112,78,65),
}
local clothes = {
	Color3.fromRGB(45,95,170), Color3.fromRGB(175,65,65), Color3.fromRGB(54,130,88),
	Color3.fromRGB(120,74,155), Color3.fromRGB(225,145,50), Color3.fromRGB(55,55,62),
}
local hairColours = {
	Color3.fromRGB(35,25,18), Color3.fromRGB(90,58,32),
	Color3.fromRGB(220,188,120), Color3.fromRGB(40,40,40),
}

local function makePerson(name, role, position, parent)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local root = part("Root", Vector3.new(1,1,1), CFrame.new(position), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model)
	root.Transparency = 1
	model.PrimaryPart = root

	local skin = skinTones[math.random(1,#skinTones)]
	local shirt = clothes[math.random(1,#clothes)]
	local trousers = clothes[math.random(1,#clothes)]
	local hair = hairColours[math.random(1,#hairColours)]

	part("Torso", Vector3.new(2.1,2.5,1.1), root.CFrame * CFrame.new(0,2.4,0), shirt, Enum.Material.Fabric, model)
	part("Head", Vector3.new(1.65,1.65,1.65), root.CFrame * CFrame.new(0,4.45,0), skin, Enum.Material.SmoothPlastic, model)
	part("Hair", Vector3.new(1.75,0.55,1.75), root.CFrame * CFrame.new(0,5.2,-0.05), hair, Enum.Material.SmoothPlastic, model)
	part("LeftArm", Vector3.new(0.65,2.4,0.65), root.CFrame * CFrame.new(-1.35,2.35,0), skin, Enum.Material.SmoothPlastic, model)
	part("RightArm", Vector3.new(0.65,2.4,0.65), root.CFrame * CFrame.new(1.35,2.35,0), skin, Enum.Material.SmoothPlastic, model)
	part("LeftLeg", Vector3.new(0.75,2.5,0.8), root.CFrame * CFrame.new(-0.48,0,0), trousers, Enum.Material.Fabric, model)
	part("RightLeg", Vector3.new(0.75,2.5,0.8), root.CFrame * CFrame.new(0.48,0,0), trousers, Enum.Material.Fabric, model)
	part("LeftShoe", Vector3.new(0.85,0.45,1.25), root.CFrame * CFrame.new(-0.48,-1.45,-0.18), Color3.fromRGB(35,35,38), Enum.Material.Leather, model)
	part("RightShoe", Vector3.new(0.85,0.45,1.25), root.CFrame * CFrame.new(0.48,-1.45,-0.18), Color3.fromRGB(35,35,38), Enum.Material.Leather, model)

	local head = model:FindFirstChild("Head")
	local face = Instance.new("Decal")
	face.Texture = "rbxasset://textures/face.png"
	face.Face = Enum.NormalId.Front
	face.Parent = head

	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.fromOffset(140,32)
	tag.StudsOffset = Vector3.new(0,6,0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 55
	tag.Parent = root
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundTransparency = 1
	label.Text = role
	label.TextColor3 = Color3.new(1,1,1)
	label.TextStrokeTransparency = 0.25
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.Parent = tag
	return model
end

local walkRoutes = {
	{Vector3.new(-155,2.9,31),Vector3.new(155,2.9,31),Vector3.new(155,2.9,52),Vector3.new(-155,2.9,52)},
	{Vector3.new(155,2.9,-31),Vector3.new(-155,2.9,-31),Vector3.new(-155,2.9,-52),Vector3.new(155,2.9,-52)},
	{Vector3.new(-130,2.9,31),Vector3.new(-70,2.9,60),Vector3.new(0,2.9,31),Vector3.new(70,2.9,60)},
	{Vector3.new(130,2.9,-31),Vector3.new(70,2.9,-60),Vector3.new(0,2.9,-31),Vector3.new(-70,2.9,-60)},
}
local roles = {"Resident","Shopper","Commuter","Dog Walker","Visitor","House Hunter"}
for i=1,18 do
	local route = walkRoutes[(i-1)%#walkRoutes+1]
	local npc = makePerson("TownResident"..i,roles[math.random(1,#roles)],route[1]+Vector3.new(math.random(-8,8),0,0),pedestriansFolder)
	addMover(npc,route,7+math.random()*3,math.random(0,2))
end

local function createVehicle(name, colour, position, isBus)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = trafficFolder
	local length = isBus and 28 or 11
	local width = isBus and 8 or 6
	local root = part("Root",Vector3.new(1,1,1),CFrame.new(position),Color3.new(1,1,1),Enum.Material.SmoothPlastic,model)
	root.Transparency = 1
	model.PrimaryPart = root
	part("Body",Vector3.new(length,isBus and 7 or 3.5,width),root.CFrame*CFrame.new(0,isBus and 4 or 2.3,0),colour,Enum.Material.Metal,model)
	part("Roof",Vector3.new(length-1,0.8,width-0.5),root.CFrame*CFrame.new(0,isBus and 7.8 or 4.4,0),Color3.fromRGB(225,225,225),Enum.Material.SmoothPlastic,model)
	for _,x in ipairs(isBus and {-10,-5,0,5,10} or {-3.2,3.2}) do
		for _,z in ipairs({-(width/2+0.05),width/2+0.05}) do
			local w=part("Window",Vector3.new(isBus and 3.4 or 3,isBus and 3 or 1.8,0.2),root.CFrame*CFrame.new(x,isBus and 5.2 or 3.2,z),Color3.fromRGB(115,180,215),Enum.Material.Glass,model)
			w.Transparency=0.25
		end
	end
	for _,x in ipairs({-(length/2-2.2),length/2-2.2}) do
		for _,z in ipairs({-(width/2+0.35),width/2+0.35}) do
			local wheel=part("Wheel",Vector3.new(1.6,3,3),root.CFrame*CFrame.new(x,1.5,z)*CFrame.Angles(math.rad(90),0,0),Color3.fromRGB(25,25,25),Enum.Material.Rubber,model)
			wheel.Shape=Enum.PartType.Cylinder
		end
	end
	if isBus then
		local display=part("Destination",Vector3.new(0.3,1.5,5.8),root.CFrame*CFrame.new(length/2+0.2,6.2,0),Color3.fromRGB(12,12,12),Enum.Material.SmoothPlastic,model)
		local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Right; gui.Parent=display
		local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text="MS1  TOWN CENTRE"; text.TextColor3=Color3.fromRGB(255,190,35); text.Font=Enum.Font.Code; text.TextScaled=true; text.Parent=gui
	end
	return model
end

local roadA={Vector3.new(-190,1.4,-9),Vector3.new(190,1.4,-9)}
local roadB={Vector3.new(190,1.4,9),Vector3.new(-190,1.4,9)}
local colours={Color3.fromRGB(45,95,170),Color3.fromRGB(180,55,55),Color3.fromRGB(230,230,225),Color3.fromRGB(45,45,50),Color3.fromRGB(210,145,40)}
for i=1,8 do
	local route=(i%2==0) and roadA or roadB
	local car=createVehicle("TrafficCar"..i,colours[(i-1)%#colours+1],route[1]+Vector3.new((i-1)*28,0,0),false)
	addMover(car,route,20+i,math.random(0,2))
end
local bus1=createVehicle("HometownBus1",Color3.fromRGB(25,45,70),roadA[1],true)
local bus2=createVehicle("HometownBus2",Color3.fromRGB(35,92,58),roadB[1],true)
addMover(bus1,roadA,15,4)
addMover(bus2,roadB,14,5)

local function createBusStop(position,facing)
	local model=Instance.new("Model"); model.Name="BusStop"; model.Parent=sceneryFolder
	part("Pole",Vector3.new(0.5,8,0.5),CFrame.new(position+Vector3.new(0,4,0)),Color3.fromRGB(75,75,80),Enum.Material.Metal,model)
	local flag=part("Flag",Vector3.new(0.4,2.5,3.8),CFrame.new(position+Vector3.new(0,7,0))*CFrame.Angles(0,math.rad(facing),0),Color3.fromRGB(35,65,105),Enum.Material.Metal,model)
	local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Right; gui.Parent=flag
	local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text="BUS STOP\nMS1"; label.TextColor3=Color3.fromRGB(255,210,45); label.Font=Enum.Font.GothamBold; label.TextScaled=true; label.Parent=gui
	part("ShelterBack",Vector3.new(0.35,7,12),CFrame.new(position+Vector3.new(3,3.5,0)),Color3.fromRGB(120,180,205),Enum.Material.Glass,model).Transparency=0.35
	part("Roof",Vector3.new(6,0.4,12),CFrame.new(position+Vector3.new(3,7,0)),Color3.fromRGB(70,75,80),Enum.Material.Metal,model)
	part("Bench",Vector3.new(2.5,0.5,8),CFrame.new(position+Vector3.new(1.5,1.5,0)),Color3.fromRGB(110,80,55),Enum.Material.WoodPlanks,model)
end
createBusStop(Vector3.new(-65,1,31),0)
createBusStop(Vector3.new(65,1,-31),180)

local customers = world:WaitForChild("PropertyCustomers")
local function improveCustomer(customer)
	task.wait()
	if not customer.Parent or not customer.PrimaryPart then return end
	for _,child in ipairs(customer:GetChildren()) do
		if child:IsA("BasePart") and child.Name~="HumanoidRootPart" then child.Transparency=1 end
	end
	local role=customer.Name:find("Buyer") and "Looking to buy" or "Looking to rent"
	local upgraded=makePerson("Detailed"..customer.Name,role,customer.PrimaryPart.Position,customer)
	for _,child in ipairs(upgraded:GetChildren()) do child.Parent=customer end
	upgraded:Destroy()
end
for _,customer in ipairs(customers:GetChildren()) do improveCustomer(customer) end
customers.ChildAdded:Connect(function(customer) task.spawn(improveCustomer,customer) end)

RunService.Heartbeat:Connect(function(dt)
	for i=#movers,1,-1 do
		local m=movers[i]
		if not m.Model.Parent or not m.Model.PrimaryPart then table.remove(movers,i) else
			if m.Wait>0 then m.Wait-=dt else
				local from=m.Route[m.Index]
				local nextIndex=m.Index%#m.Route+1
				local to=m.Route[nextIndex]
				local length=(to-from).Magnitude
				m.Distance+=m.Speed*dt
				if m.Distance>=length then
					m.Distance=0; m.Index=nextIndex; m.Wait=m.Pause
				else
					local alpha=m.Distance/length
					local pos=from:Lerp(to,alpha)
					m.Model:PivotTo(CFrame.lookAt(pos,pos+(to-from).Unit))
				end
			end
		end
	end
end)

print("Persistent pedestrians, buyers, renters, traffic and buses loaded")