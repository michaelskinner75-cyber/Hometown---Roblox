local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local function part(parent, name, size, cf, colour, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = true
	p.Color = colour
	p.Material = material or Enum.Material.SmoothPlastic
	p.Transparency = transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function light(parent, cf, colour, range)
	local lamp = part(parent, "ExteriorLamp", Vector3.new(0.7, 1.1, 0.5), cf, Color3.fromRGB(35,35,35), Enum.Material.Metal)
	local glow = Instance.new("PointLight")
	glow.Color = colour
	glow.Brightness = 1.4
	glow.Range = range or 14
	glow.Shadows = true
	glow.Parent = lamp
end

local function tree(parent, cf, scale)
	part(parent, "TreeTrunk", Vector3.new(1.2*scale, 5*scale, 1.2*scale), cf * CFrame.new(0, 2.5*scale, 0), Color3.fromRGB(95,65,40), Enum.Material.Wood)
	local crown = part(parent, "TreeCrown", Vector3.new(5*scale, 5*scale, 5*scale), cf * CFrame.new(0, 6*scale, 0), Color3.fromRGB(55,125,65), Enum.Material.Grass)
	crown.Shape = Enum.PartType.Ball
end

local function fence(parent, centre, width, depth)
	local wood = Color3.fromRGB(150,112,72)
	for x = -width/2, width/2, 5 do
		part(parent, "FencePost", Vector3.new(0.5,3.2,0.5), CFrame.new(centre + Vector3.new(x,1.6,-depth/2)), wood, Enum.Material.WoodPlanks)
		part(parent, "FencePost", Vector3.new(0.5,3.2,0.5), CFrame.new(centre + Vector3.new(x,1.6,depth/2)), wood, Enum.Material.WoodPlanks)
	end
	for z = -depth/2, depth/2, 5 do
		part(parent, "FencePost", Vector3.new(0.5,3.2,0.5), CFrame.new(centre + Vector3.new(-width/2,1.6,z)), wood, Enum.Material.WoodPlanks)
		part(parent, "FencePost", Vector3.new(0.5,3.2,0.5), CFrame.new(centre + Vector3.new(width/2,1.6,z)), wood, Enum.Material.WoodPlanks)
	end
end

local function addEarlyDetails(folder, centre, front, tier)
	local rear = -front
	if tier <= 2 then
		part(folder,"CampRug",Vector3.new(6,0.15,4),CFrame.new(centre+Vector3.new(0,1.45,0)),Color3.fromRGB(120,45,35),Enum.Material.Fabric)
		part(folder,"Crate",Vector3.new(2.5,2.2,2.5),CFrame.new(centre+Vector3.new(-5,2,3)),Color3.fromRGB(125,88,48),Enum.Material.WoodPlanks)
		part(folder,"CoolBox",Vector3.new(2.8,1.8,2),CFrame.new(centre+Vector3.new(5,1.8,3)),Color3.fromRGB(210,220,225),Enum.Material.SmoothPlastic)
		for i=0,5 do
			local a=(math.pi*2/6)*i
			part(folder,"FireStone",Vector3.new(1.1,0.55,0.8),CFrame.new(centre+Vector3.new(math.cos(a)*2,0.35,rear*8+math.sin(a)*2)),Color3.fromRGB(95,90,85),Enum.Material.Rock)
		end
		local fire=part(folder,"CampFire",Vector3.new(1.3,1.3,1.3),CFrame.new(centre+Vector3.new(0,0.9,rear*8)),Color3.fromRGB(255,130,35),Enum.Material.Neon)
		fire.Shape=Enum.PartType.Ball
		local flame=Instance.new("Fire"); flame.Size=4; flame.Heat=5; flame.Parent=fire
	elseif tier <= 6 then
		part(folder,"FrontStep",Vector3.new(7,0.8,3),CFrame.new(centre+Vector3.new(0,0.4,front*10)),Color3.fromRGB(125,105,85),Enum.Material.Slate)
		part(folder,"Path",Vector3.new(5,0.2,10),CFrame.new(centre+Vector3.new(0,0.12,front*15)),Color3.fromRGB(145,140,130),Enum.Material.Cobblestone)
		part(folder,"WoodPile",Vector3.new(5,2.5,2),CFrame.new(centre+Vector3.new(-8,1.25,rear*4)),Color3.fromRGB(120,78,42),Enum.Material.Wood)
		light(folder,CFrame.new(centre+Vector3.new(3,5.5,front*9)),Color3.fromRGB(255,210,135),13)
		fence(folder,centre,28,25)
	elseif tier <= 12 then
		part(folder,"Driveway",Vector3.new(8,0.25,18),CFrame.new(centre+Vector3.new(9,0.14,front*16)),Color3.fromRGB(95,95,98),Enum.Material.Concrete)
		part(folder,"FrontPath",Vector3.new(5,0.22,13),CFrame.new(centre+Vector3.new(0,0.13,front*14)),Color3.fromRGB(160,155,145),Enum.Material.Cobblestone)
		for _,x in ipairs({-9,9}) do tree(folder,CFrame.new(centre+Vector3.new(x,0,rear*8)),0.8) end
		light(folder,CFrame.new(centre+Vector3.new(-3,5,front*12)),Color3.fromRGB(255,225,170),16)
		light(folder,CFrame.new(centre+Vector3.new(3,5,front*12)),Color3.fromRGB(255,225,170),16)
	elseif tier <= 20 then
		part(folder,"Driveway",Vector3.new(13,0.25,23),CFrame.new(centre+Vector3.new(13,0.14,front*18)),Color3.fromRGB(82,84,88),Enum.Material.Concrete)
		part(folder,"StonePath",Vector3.new(6,0.25,18),CFrame.new(centre+Vector3.new(0,0.14,front*18)),Color3.fromRGB(175,168,154),Enum.Material.Cobblestone)
		for _,x in ipairs({-14,-8,8,14}) do tree(folder,CFrame.new(centre+Vector3.new(x,0,rear*10)),0.95) end
		fence(folder,centre,42,35)
		light(folder,CFrame.new(centre+Vector3.new(-4,6,front*15)),Color3.fromRGB(255,230,180),18)
		light(folder,CFrame.new(centre+Vector3.new(4,6,front*15)),Color3.fromRGB(255,230,180),18)
	elseif tier <= 30 then
		part(folder,"GrandDrive",Vector3.new(18,0.3,30),CFrame.new(centre+Vector3.new(15,0.16,front*23)),Color3.fromRGB(72,74,78),Enum.Material.Concrete)
		part(folder,"GrandPath",Vector3.new(8,0.3,24),CFrame.new(centre+Vector3.new(0,0.16,front*22)),Color3.fromRGB(195,187,170),Enum.Material.Marble)
		local fountain=part(folder,"FountainBase",Vector3.new(10,1,10),CFrame.new(centre+Vector3.new(0,0.5,front*30)),Color3.fromRGB(220,220,215),Enum.Material.Marble)
		fountain.Shape=Enum.PartType.Cylinder
		part(folder,"FountainWater",Vector3.new(8,0.35,8),CFrame.new(centre+Vector3.new(0,1.05,front*30)),Color3.fromRGB(70,165,220),Enum.Material.Glass,0.2).Shape=Enum.PartType.Cylinder
		for _,x in ipairs({-18,-10,10,18}) do tree(folder,CFrame.new(centre+Vector3.new(x,0,rear*12)),1.1) end
		fence(folder,centre,52,44)
	else
		part(folder,"Plaza",Vector3.new(38,0.35,28),CFrame.new(centre+Vector3.new(0,0.18,front*23)),Color3.fromRGB(145,150,158),Enum.Material.Concrete)
		part(folder,"EntranceCanopy",Vector3.new(18,1.2,8),CFrame.new(centre+Vector3.new(0,10,front*16)),Color3.fromRGB(55,65,78),Enum.Material.Metal)
		for _,x in ipairs({-14,-7,0,7,14}) do
			part(folder,"Bollard",Vector3.new(0.8,3,0.8),CFrame.new(centre+Vector3.new(x,1.5,front*29)),Color3.fromRGB(55,58,65),Enum.Material.Metal)
		end
		for _,x in ipairs({-18,18}) do tree(folder,CFrame.new(centre+Vector3.new(x,0,front*28)),1.25) end
		light(folder,CFrame.new(centre+Vector3.new(-8,8,front*20)),Color3.fromRGB(210,235,255),24)
		light(folder,CFrame.new(centre+Vector3.new(8,8,front*20)),Color3.fromRGB(210,235,255),24)
	end
end

local function polish(plot)
	local house=plot:FindFirstChild("House")
	if not house then return end
	local old=house:FindFirstChild("PolishDetails")
	if old then old:Destroy() end
	local folder=Instance.new("Folder"); folder.Name="PolishDetails"; folder.Parent=house
	local centre=plot.Plot.Position
	local front=plot:GetAttribute("FrontDirection") or -1
	local tier=plot:GetAttribute("UpgradeTier") or 1
	addEarlyDetails(folder,centre,front,tier)
end

local function watch(plot)
	plot.ChildAdded:Connect(function(child)
		if child.Name=="House" then task.wait(0.1); polish(plot) end
	end)
	if plot:FindFirstChild("House") then polish(plot) end
end

for _,plot in ipairs(plotsFolder:GetChildren()) do if plot:IsA("Model") then watch(plot) end end
plotsFolder.ChildAdded:Connect(function(plot) if plot:IsA("Model") then watch(plot) end end)

print("Property visual polish loaded")