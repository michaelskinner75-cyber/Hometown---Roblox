local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local STARTING_CASH = 10000
local PLOT_PRICE = 2500
local RENT_INTERVAL = 30

local HOUSE_TYPES = {
	Bungalow = {Name = "Starter Bungalow", Price = 2500, SalePrice = 6500, Rent = 350, Description = "A cosy one-storey starter home"},
	FamilySemi = {Name = "Family Semi", Price = 4000, SalePrice = 8500, Rent = 500, Description = "Two floors, driveway and garage"},
	Cottage = {Name = "Country Cottage", Price = 5500, SalePrice = 10500, Rent = 650, Description = "Stone walls, chimney and garden"},
	Modern = {Name = "Modern Home", Price = 7500, SalePrice = 13500, Rent = 850, Description = "Large windows and a flat roof"},
}

local NAMES = {"Alex", "Sophie", "Jamie", "Maya", "Callum", "Isla", "Lewis", "Ava", "Noah", "Emily", "Finlay", "Lucy"}
local remotes = ReplicatedStorage:FindFirstChild("HometownRemotes") or Instance.new("Folder")
remotes.Name = "HometownRemotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
	local event = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
	return event
end

local openHouseMenu = remote("OpenHouseMenu")
local buildHouseRequest = remote("BuildHouseRequest")
local openPropertyMenu = remote("OpenPropertyMenu")
local propertyActionRequest = remote("PropertyActionRequest")
local propertyNotice = remote("PropertyNotice")

local oldWorld = workspace:FindFirstChild("HometownWorld")
if oldWorld then oldWorld:Destroy() end

local world = Instance.new("Folder")
world.Name = "HometownWorld"
world.Parent = workspace

local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end

local function makePart(name, size, position, colour, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Color = colour
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeWindow(size, position, parent)
	local window = makePart("Window", size, position, Color3.fromRGB(150, 215, 255), Enum.Material.Glass, parent)
	window.Transparency = 0.2
	window.Reflectance = 0.08
	return window
end

makePart("Ground", Vector3.new(420, 2, 420), Vector3.new(0, -1, 0), Color3.fromRGB(83, 145, 76), Enum.Material.Grass, world)
makePart("Road", Vector3.new(320, 1, 42), Vector3.new(0, 0.1, 0), Color3.fromRGB(50, 52, 56), Enum.Material.Asphalt, world)
makePart("Pavement1", Vector3.new(320, 1, 10), Vector3.new(0, 0.5, 26), Color3.fromRGB(170, 170, 170), Enum.Material.Concrete, world)
makePart("Pavement2", Vector3.new(320, 1, 10), Vector3.new(0, 0.5, -26), Color3.fromRGB(170, 170, 170), Enum.Material.Concrete, world)
for x = -140, 140, 30 do
	makePart("RoadMarking", Vector3.new(15, 0.15, 1), Vector3.new(x, 0.7, 0), Color3.fromRGB(245, 245, 225), Enum.Material.SmoothPlastic, world)
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "TownSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 1, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 0.25
spawn.Color = Color3.fromRGB(65, 170, 255)
spawn.Parent = world

local plotsFolder = Instance.new("Folder")
plotsFolder.Name = "Plots"
plotsFolder.Parent = world
local npcsFolder = Instance.new("Folder")
npcsFolder.Name = "PropertyCustomers"
npcsFolder.Parent = world

local plotPositions = {
	Vector3.new(-110, 0.5, 75), Vector3.new(-35, 0.5, 75), Vector3.new(40, 0.5, 75), Vector3.new(115, 0.5, 75),
	Vector3.new(-110, 0.5, -75), Vector3.new(-35, 0.5, -75), Vector3.new(40, 0.5, -75), Vector3.new(115, 0.5, -75),
}
local wallColours = {
	Color3.fromRGB(234, 211, 171), Color3.fromRGB(217, 226, 232),
	Color3.fromRGB(229, 195, 184), Color3.fromRGB(205, 220, 191),
}

local function formatMoney(value)
	local text = tostring(math.floor(value))
	while true do
		local updated, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		text = updated
		if count == 0 then break end
	end
	return "£" .. text
end

local function updateSign(plotModel, message, action)
	local sign = plotModel:FindFirstChild("Sign")
	local prompt = sign and sign:FindFirstChild("PropertyPrompt")
	local gui = sign and sign:FindFirstChild("BillboardGui")
	local label = gui and gui:FindFirstChild("TextLabel")
	if label then label.Text = message end
	if prompt then prompt.ActionText = action end
end

local function frontFeature(centre, frontDirection, x, y, distance, size, name, colour, material, parent)
	return makePart(name, size, Vector3.new(centre.X + x, centre.Y + y, centre.Z + frontDirection * distance), colour, material, parent)
end

local function addWindowFrames(window, parent)
	local p = window.Position
	local s = window.Size
	makePart("WindowTop", Vector3.new(s.X + 0.5, 0.35, s.Z + 0.2), p + Vector3.new(0, s.Y / 2, 0), Color3.fromRGB(245,245,240), Enum.Material.Wood, parent)
	makePart("WindowBottom", Vector3.new(s.X + 0.5, 0.35, s.Z + 0.2), p - Vector3.new(0, s.Y / 2, 0), Color3.fromRGB(245,245,240), Enum.Material.Wood, parent)
	makePart("WindowCross", Vector3.new(0.3, s.Y, s.Z + 0.2), p, Color3.fromRGB(245,245,240), Enum.Material.Wood, parent)
end

local function createHouse(plotModel, houseKey)
	local info = HOUSE_TYPES[houseKey]
	if not info then return nil end
	local centre = plotModel.Plot.Position
	local front = plotModel:GetAttribute("FrontDirection") or -1
	local colour = wallColours[((tonumber(plotModel.Name:match("%d+")) or 1) - 1) % #wallColours + 1]
	local house = Instance.new("Model")
	house.Name = "House"
	house:SetAttribute("HouseType", houseKey)
	house:SetAttribute("DisplayName", info.Name)
	house:SetAttribute("SalePrice", info.SalePrice)
	house:SetAttribute("Rent", info.Rent)
	house.Parent = plotModel

	if houseKey == "Bungalow" then
		makePart("Foundation", Vector3.new(40,1,34), centre + Vector3.new(0,1,0), Color3.fromRGB(180,180,180), Enum.Material.Concrete, house)
		makePart("MainBuilding", Vector3.new(34,12,28), centre + Vector3.new(0,7,0), colour, Enum.Material.Brick, house)
		makePart("Roof", Vector3.new(39,4,33), centre + Vector3.new(0,15,0), Color3.fromRGB(80,58,50), Enum.Material.Slate, house)
		frontFeature(centre, front, 0,5,14.5, Vector3.new(5,8,1), "Door", Color3.fromRGB(50,105,85), Enum.Material.Wood, house)
		for _, x in ipairs({-10,10}) do local w = makeWindow(Vector3.new(6,5,0.7), Vector3.new(centre.X+x,centre.Y+8,centre.Z+front*14.6),house); addWindowFrames(w,house) end
		makePart("Porch", Vector3.new(10,0.5,6), centre + Vector3.new(0,1.4,front*17), Color3.fromRGB(155,135,110), Enum.Material.WoodPlanks, house)
		makePart("FrontPath", Vector3.new(5,0.3,15), centre + Vector3.new(0,1,front*24), Color3.fromRGB(150,150,150), Enum.Material.Concrete, house)
	elseif houseKey == "FamilySemi" then
		makePart("Foundation", Vector3.new(44,1,38), centre + Vector3.new(0,1,0), Color3.fromRGB(175,175,175), Enum.Material.Concrete, house)
		makePart("MainBuilding", Vector3.new(30,22,30), centre + Vector3.new(-5,12,0), colour, Enum.Material.Brick, house)
		makePart("Garage", Vector3.new(13,11,26), centre + Vector3.new(17,6.5,2), Color3.fromRGB(205,205,198), Enum.Material.Brick, house)
		makePart("Roof", Vector3.new(34,5,34), centre + Vector3.new(-5,25.5,0), Color3.fromRGB(75,65,60), Enum.Material.Slate, house)
		frontFeature(centre,front,-5,5,15.5,Vector3.new(5,8,1),"Door",Color3.fromRGB(55,80,125),Enum.Material.Wood,house)
		frontFeature(centre,front,17,5,11.5,Vector3.new(11,8,1),"GarageDoor",Color3.fromRGB(235,235,230),Enum.Material.Metal,house)
		for _, y in ipairs({8,17}) do for _, x in ipairs({-13,3}) do local w=makeWindow(Vector3.new(5,5,0.7),Vector3.new(centre.X+x,centre.Y+y,centre.Z+front*15.6),house); addWindowFrames(w,house) end end
		makePart("Driveway", Vector3.new(14,0.3,22), centre + Vector3.new(17,1,front*23), Color3.fromRGB(115,115,115), Enum.Material.Concrete, house)
	elseif houseKey == "Cottage" then
		makePart("Foundation", Vector3.new(42,1,36), centre + Vector3.new(0,1,0), Color3.fromRGB(145,145,140), Enum.Material.Cobblestone, house)
		makePart("MainBuilding", Vector3.new(36,15,30), centre + Vector3.new(0,8.5,0), Color3.fromRGB(178,169,148), Enum.Material.Cobblestone, house)
		makePart("Roof", Vector3.new(42,6,35), centre + Vector3.new(0,19,0), Color3.fromRGB(85,52,40), Enum.Material.Slate, house)
		makePart("Chimney", Vector3.new(5,12,5), centre + Vector3.new(12,22,4), Color3.fromRGB(125,78,60), Enum.Material.Brick, house)
		frontFeature(centre,front,0,5,15.5,Vector3.new(5,8,1),"CottageDoor",Color3.fromRGB(95,55,35),Enum.Material.WoodPlanks,house)
		for _, x in ipairs({-11,11}) do local w=makeWindow(Vector3.new(6,6,0.8),Vector3.new(centre.X+x,centre.Y+10,centre.Z+front*15.6),house); addWindowFrames(w,house) end
		for _, x in ipairs({-20,20}) do makePart("FlowerBed",Vector3.new(6,1.2,5),centre+Vector3.new(x,1.6,front*17),Color3.fromRGB(90,65,45),Enum.Material.Ground,house) end
	else
		makePart("Foundation", Vector3.new(46,1,38), centre + Vector3.new(0,1,0), Color3.fromRGB(125,125,125), Enum.Material.Concrete, house)
		makePart("LowerFloor", Vector3.new(42,11,32), centre + Vector3.new(0,6.5,0), Color3.fromRGB(225,225,220), Enum.Material.Concrete, house)
		makePart("UpperFloor", Vector3.new(32,10,26), centre + Vector3.new(-5,17,-2*front), Color3.fromRGB(75,82,88), Enum.Material.Concrete, house)
		makePart("FlatRoof", Vector3.new(36,1.5,30), centre + Vector3.new(-5,22.8,-2*front), Color3.fromRGB(35,38,42), Enum.Material.SmoothPlastic, house)
		frontFeature(centre,front,13,5,16.5,Vector3.new(6,9,1),"ModernDoor",Color3.fromRGB(35,35,35),Enum.Material.Metal,house)
		makeWindow(Vector3.new(20,7,0.8),Vector3.new(centre.X-7,centre.Y+7,centre.Z+front*16.5),house)
		makeWindow(Vector3.new(22,6,0.8),Vector3.new(centre.X-5,centre.Y+17,centre.Z+front*15.1),house)
		makePart("Balcony", Vector3.new(25,1,6), centre + Vector3.new(-5,13,front*17), Color3.fromRGB(105,105,105), Enum.Material.Concrete, house)
		makePart("Driveway", Vector3.new(12,0.3,22), centre + Vector3.new(16,1,front*23), Color3.fromRGB(90,90,90), Enum.Material.Concrete, house)
	end
	return house
end

local function getPlayerCash(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	return leaderstats and leaderstats:FindFirstChild("Cash")
end

local function createCustomer(plotModel, purpose)
	local model = Instance.new("Model")
	model.Name = purpose .. "Customer"
	model:SetAttribute("CustomerName", NAMES[math.random(1,#NAMES)])
	model.Parent = npcsFolder
	local root = makePart("HumanoidRootPart",Vector3.new(2,2,1),Vector3.new(0,3,0),Color3.new(1,1,1),Enum.Material.SmoothPlastic,model)
	root.Transparency = 1
	root.Anchored = false
	local torso = makePart("Torso",Vector3.new(2,2,1),root.Position,Color3.fromRGB(math.random(60,220),math.random(60,220),math.random(60,220)),Enum.Material.Fabric,model)
	torso.Anchored = false
	local head = makePart("Head",Vector3.new(2,1,1),root.Position+Vector3.new(0,1.5,0),Color3.fromRGB(235,190,150),Enum.Material.SmoothPlastic,model)
	head.Anchored = false
	local hum = Instance.new("Humanoid")
	hum.DisplayName = model:GetAttribute("CustomerName") .. " - " .. purpose
	hum.Parent = model
	local weld1 = Instance.new("WeldConstraint"); weld1.Part0=root; weld1.Part1=torso; weld1.Parent=root
	local weld2 = Instance.new("WeldConstraint"); weld2.Part0=torso; weld2.Part1=head; weld2.Parent=torso
	model.PrimaryPart = root
	local plotPos = plotModel.Plot.Position
	local side = plotPos.Z > 0 and 1 or -1
	model:PivotTo(CFrame.new(Vector3.new(plotPos.X,3,side*15)))
	task.spawn(function()
		hum:MoveTo(Vector3.new(plotPos.X,3,plotPos.Z - (plotModel:GetAttribute("FrontDirection") or -1)*17))
	end)
	return model
end

local function resetPlot(plotModel)
	local house = plotModel:FindFirstChild("House")
	if house then house:Destroy() end
	local tenantNpc = plotModel:FindFirstChild("TenantNpc")
	if tenantNpc and tenantNpc.Value then tenantNpc.Value:Destroy() end
	plotModel:SetAttribute("OwnerUserId",0)
	plotModel:SetAttribute("HouseBuilt",false)
	plotModel:SetAttribute("HouseType","")
	plotModel:SetAttribute("MarketStatus","None")
	plotModel:SetAttribute("TenantName","")
	updateSign(plotModel,"FOR SALE\n£2,500","Buy Plot")
end

local function startSale(plotModel, player)
	if plotModel:GetAttribute("MarketStatus") == "ForSale" then return end
	plotModel:SetAttribute("MarketStatus","ForSale")
	local house = plotModel:FindFirstChild("House")
	local price = house and house:GetAttribute("SalePrice") or 0
	local tenant = plotModel:GetAttribute("TenantName") or ""
	updateSign(plotModel,"FOR SALE\n"..formatMoney(price)..(tenant ~= "" and "\nTENANT: "..tenant or ""),"View Property")
	local buyer = createCustomer(plotModel,"Buyer")
	propertyNotice:FireClient(player,"A buyer is viewing "..plotModel.Name.."...")
	task.delay(8,function()
		if not plotModel.Parent or plotModel:GetAttribute("MarketStatus") ~= "ForSale" then if buyer then buyer:Destroy() end return end
		local cash = getPlayerCash(player)
		if cash then cash.Value += price end
		propertyNotice:FireClient(player,(buyer:GetAttribute("CustomerName") or "A buyer").." bought the property for "..formatMoney(price).."!")
		if buyer then buyer:Destroy() end
		resetPlot(plotModel)
	end)
end

local function startRental(plotModel, player)
	if plotModel:GetAttribute("MarketStatus") ~= "None" then return end
	plotModel:SetAttribute("MarketStatus","ToRent")
	local house = plotModel:FindFirstChild("House")
	local rent = house and house:GetAttribute("Rent") or 0
	updateSign(plotModel,"TO LET\n"..formatMoney(rent).." every 30 sec","Waiting for tenant")
	local renter = createCustomer(plotModel,"Renter")
	propertyNotice:FireClient(player,"A potential tenant is coming to view "..plotModel.Name.."...")
	task.delay(7,function()
		if not plotModel.Parent or plotModel:GetAttribute("MarketStatus") ~= "ToRent" then if renter then renter:Destroy() end return end
		local tenantName = renter:GetAttribute("CustomerName") or "Tenant"
		plotModel:SetAttribute("TenantName",tenantName)
		plotModel:SetAttribute("MarketStatus","Rented")
		local ref = Instance.new("ObjectValue")
		ref.Name = "TenantNpc"
		ref.Value = renter
		ref.Parent = plotModel
		updateSign(plotModel,"RENTED\n"..tenantName.."\n"..formatMoney(rent).." / 30 sec","Manage Property")
		propertyNotice:FireClient(player,tenantName.." has moved in!")
		task.spawn(function()
			while plotModel.Parent and plotModel:GetAttribute("MarketStatus") == "Rented" and plotModel:GetAttribute("OwnerUserId") == player.UserId do
				task.wait(RENT_INTERVAL)
				if plotModel:GetAttribute("MarketStatus") ~= "Rented" then break end
				local cash = getPlayerCash(player)
				if cash then cash.Value += rent end
				propertyNotice:FireClient(player,"Rent received from "..tenantName..": "..formatMoney(rent))
			end
		end)
	end)
end

for index, position in ipairs(plotPositions) do
	local plotModel = Instance.new("Model")
	plotModel.Name = "Plot"..index
	plotModel:SetAttribute("OwnerUserId",0)
	plotModel:SetAttribute("HouseBuilt",false)
	plotModel:SetAttribute("HouseType","")
	plotModel:SetAttribute("MarketStatus","None")
	plotModel:SetAttribute("TenantName","")
	plotModel.Parent = plotsFolder
	makePart("Plot",Vector3.new(62,1,70),position,Color3.fromRGB(103,170,92),Enum.Material.Grass,plotModel)
	local front = position.Z > 0 and -1 or 1
	plotModel:SetAttribute("FrontDirection",front)
	local sign = makePart("Sign",Vector3.new(8,6,1),position+Vector3.new(0,4,front*31),Color3.fromRGB(245,245,245),Enum.Material.Wood,plotModel)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name="PropertyPrompt"; prompt.ActionText="Buy Plot"; prompt.ObjectText="Hometown Property"; prompt.HoldDuration=0.4; prompt.MaxActivationDistance=14; prompt.RequiresLineOfSight=false; prompt.Parent=sign
	local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(220,120); gui.StudsOffset=Vector3.new(0,4.5,0); gui.AlwaysOnTop=true; gui.Parent=sign
	local label=Instance.new("TextLabel"); label.Name="TextLabel"; label.Size=UDim2.fromScale(1,1); label.BackgroundColor3=Color3.fromRGB(255,255,255); label.BackgroundTransparency=0.05; label.TextColor3=Color3.fromRGB(30,90,50); label.Font=Enum.Font.GothamBold; label.TextScaled=true; label.Text="FOR SALE\n£2,500"; label.Parent=gui

	prompt.Triggered:Connect(function(player)
		local cash=getPlayerCash(player); if not cash then return end
		local ownerId=plotModel:GetAttribute("OwnerUserId")
		if ownerId == 0 then
			if cash.Value < PLOT_PRICE then propertyNotice:FireClient(player,"You need £2,500 to buy this plot."); return end
			cash.Value -= PLOT_PRICE
			plotModel:SetAttribute("OwnerUserId",player.UserId)
			updateSign(plotModel,player.DisplayName.."'s Plot\nCHOOSE A HOUSE","Choose House")
		elseif ownerId == player.UserId then
			if not plotModel:GetAttribute("HouseBuilt") then openHouseMenu:FireClient(player,plotModel.Name,HOUSE_TYPES)
			else
				local house=plotModel:FindFirstChild("House")
				local info={SalePrice=house and house:GetAttribute("SalePrice") or 0,Rent=house and house:GetAttribute("Rent") or 0,Status=plotModel:GetAttribute("MarketStatus"),TenantName=plotModel:GetAttribute("TenantName"),HouseName=house and house:GetAttribute("DisplayName") or "House"}
				openPropertyMenu:FireClient(player,plotModel.Name,info)
			end
		end
	end)
end

buildHouseRequest.OnServerEvent:Connect(function(player,plotName,houseKey)
	if typeof(plotName)~="string" or typeof(houseKey)~="string" then return end
	local plot=plotsFolder:FindFirstChild(plotName); local info=HOUSE_TYPES[houseKey]; local cash=getPlayerCash(player)
	if not plot or not info or not cash or plot:GetAttribute("OwnerUserId")~=player.UserId or plot:GetAttribute("HouseBuilt") or cash.Value<info.Price then return end
	cash.Value -= info.Price
	local house=createHouse(plot,houseKey)
	if not house then cash.Value += info.Price; return end
	plot:SetAttribute("HouseBuilt",true); plot:SetAttribute("HouseType",houseKey); plot:SetAttribute("MarketStatus","None")
	updateSign(plot,info.Name:upper().."\nVALUE "..formatMoney(info.SalePrice),"Manage Property")
end)

propertyActionRequest.OnServerEvent:Connect(function(player,plotName,action)
	if typeof(plotName)~="string" or typeof(action)~="string" then return end
	local plot=plotsFolder:FindFirstChild(plotName)
	if not plot or plot:GetAttribute("OwnerUserId")~=player.UserId or not plot:GetAttribute("HouseBuilt") then return end
	local status=plot:GetAttribute("MarketStatus")
	if action=="Sell" and status~="ForSale" then startSale(plot,player)
	elseif action=="Rent" and status=="None" then startRental(plot,player)
	elseif action=="CancelListing" and (status=="ForSale" or status=="ToRent") then
		plot:SetAttribute("MarketStatus","None")
		local house=plot:FindFirstChild("House")
		updateSign(plot,(house and house:GetAttribute("DisplayName") or "HOUSE"):upper().."\nVALUE "..formatMoney(house and house:GetAttribute("SalePrice") or 0),"Manage Property")
	elseif action=="EndTenancy" and status=="Rented" then
		local ref=plot:FindFirstChild("TenantNpc"); if ref and ref.Value then ref.Value:Destroy() end; if ref then ref:Destroy() end
		plot:SetAttribute("TenantName",""); plot:SetAttribute("MarketStatus","None")
		local house=plot:FindFirstChild("House")
		updateSign(plot,(house and house:GetAttribute("DisplayName") or "HOUSE"):upper().."\nVALUE "..formatMoney(house and house:GetAttribute("SalePrice") or 0),"Manage Property")
		propertyNotice:FireClient(player,"The tenancy has ended.")
	end
end)

Players.PlayerAdded:Connect(function(player)
	local leaderstats=Instance.new("Folder"); leaderstats.Name="leaderstats"; leaderstats.Parent=player
	local cash=Instance.new("IntValue"); cash.Name="Cash"; cash.Value=STARTING_CASH; cash.Parent=leaderstats
end)
