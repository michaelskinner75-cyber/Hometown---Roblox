local ServerStorage = game:GetService("ServerStorage")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")
local restaurantTemplate = ServerStorage:WaitForChild("HighStreetRestaurant")

local old = world:FindFirstChild("HighStreet")
if old then old:Destroy() end

local highStreet = Instance.new("Model")
highStreet.Name = "HighStreet"
highStreet.Parent = world

local function makePart(parent, name, size, position, colour, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = colour
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function cleanModel(model)
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
			object:Destroy()
		elseif object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
			object:Destroy()
		elseif object:IsA("BasePart") then
			object.Anchored = true
		end
	end
end

local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if ground and ground:IsA("BasePart") then
		local half = ground.Size / 2
		minX = math.min(minX, ground.Position.X - half.X)
		maxX = math.max(maxX, ground.Position.X + half.X)
		minZ = math.min(minZ, ground.Position.Z - half.Z)
		maxZ = math.max(maxZ, ground.Position.Z + half.Z)
	end
end
if minX == math.huge then
	minX, maxX, minZ, maxZ = -150, 150, -100, 100
end

local roadCentreZ = (minZ + maxZ) / 2
local restaurantX = maxX + 205
local stationX = minX - 120

local restaurant = restaurantTemplate:Clone()
restaurant.Name = "HighStreetRestaurant"
restaurant.Parent = highStreet
cleanModel(restaurant)
restaurant:PivotTo(CFrame.new(restaurantX, 0, roadCentreZ) * CFrame.Angles(0, math.rad(90), 0))
local restaurantBox, restaurantSize = restaurant:GetBoundingBox()
local bottomY = restaurantBox.Position.Y - restaurantSize.Y / 2
restaurant:PivotTo(CFrame.new(0, 0.45 - bottomY, 0) * restaurant:GetPivot())
restaurantBox, restaurantSize = restaurant:GetBoundingBox()

-- Only ground the restaurant footprint, leaving the town untouched.
makePart(
	highStreet,
	"RestaurantGround",
	Vector3.new(restaurantSize.X + 24, 2, restaurantSize.Z + 24),
	Vector3.new(restaurantBox.Position.X, -0.8, restaurantBox.Position.Z),
	Color3.fromRGB(74, 120, 66),
	Enum.Material.Grass
)

local eastRoadLength = restaurantX - maxX
makePart(
	highStreet,
	"EastConnectorRoad",
	Vector3.new(eastRoadLength, 0.5, 38),
	Vector3.new((maxX + restaurantX) / 2, 0.2, roadCentreZ),
	Color3.fromRGB(46, 46, 48),
	Enum.Material.Asphalt
)

local westRoadLength = minX - stationX
makePart(
	highStreet,
	"WestConnectorRoad",
	Vector3.new(westRoadLength, 0.5, 38),
	Vector3.new((minX + stationX) / 2, 0.2, roadCentreZ),
	Color3.fromRGB(46, 46, 48),
	Enum.Material.Asphalt
)

for _, roadInfo in ipairs({
	{centre = (maxX + restaurantX) / 2, length = eastRoadLength},
	{centre = (minX + stationX) / 2, length = westRoadLength},
}) do
	for _, side in ipairs({-1, 1}) do
		makePart(
			highStreet,
			"HighStreetPavement",
			Vector3.new(roadInfo.length, 0.65, 8),
			Vector3.new(roadInfo.centre, 0.32, roadCentreZ + side * 23),
			Color3.fromRGB(145, 145, 145),
			Enum.Material.Concrete
		)
	end
end

-- A compact bus turning apron inside the restaurant car park.
makePart(
	highStreet,
	"RestaurantBusApron",
	Vector3.new(54, 0.52, 44),
	Vector3.new(restaurantX - 8, 0.21, roadCentreZ),
	Color3.fromRGB(46, 46, 48),
	Enum.Material.Asphalt
)

-- Bus station is built separately beyond the opposite end of the housing area.
local station = Instance.new("Model")
station.Name = "HometownBusStation"
station.Parent = highStreet
makePart(station, "StationGround", Vector3.new(96, 2, 88), Vector3.new(stationX, -0.8, roadCentreZ), Color3.fromRGB(74, 118, 64), Enum.Material.Grass)
makePart(station, "StationRoad", Vector3.new(82, 0.55, 54), Vector3.new(stationX, 0.22, roadCentreZ), Color3.fromRGB(44, 44, 47), Enum.Material.Asphalt)
makePart(station, "Platform", Vector3.new(66, 0.8, 10), Vector3.new(stationX, 0.45, roadCentreZ + 23), Color3.fromRGB(155, 155, 155), Enum.Material.Concrete)
makePart(station, "ShelterRoof", Vector3.new(28, 1, 9), Vector3.new(stationX, 8.5, roadCentreZ + 27), Color3.fromRGB(45, 55, 65), Enum.Material.Metal)
for _, xOffset in ipairs({-12, 12}) do
	makePart(station, "ShelterPost", Vector3.new(1, 8, 1), Vector3.new(stationX + xOffset, 4, roadCentreZ + 27), Color3.fromRGB(55, 60, 68), Enum.Material.Metal)
end

local signPost = makePart(station, "StationSignPost", Vector3.new(1, 10, 1), Vector3.new(stationX - 30, 5, roadCentreZ + 27), Color3.fromRGB(40, 45, 52), Enum.Material.Metal)
local signGui = Instance.new("BillboardGui")
signGui.Size = UDim2.fromOffset(220, 64)
signGui.StudsOffset = Vector3.new(0, 5, 0)
signGui.AlwaysOnTop = false
signGui.MaxDistance = 110
signGui.Parent = signPost
local signLabel = Instance.new("TextLabel")
signLabel.Size = UDim2.fromScale(1, 1)
signLabel.BackgroundColor3 = Color3.fromRGB(35, 55, 80)
signLabel.TextColor3 = Color3.new(1, 1, 1)
signLabel.Font = Enum.Font.GothamBold
signLabel.TextScaled = true
signLabel.Text = "HOMETOWN BUS STATION"
signLabel.Parent = signGui

highStreet:SetAttribute("RoadCentreZ", roadCentreZ)
highStreet:SetAttribute("RestaurantStopX", restaurantX - 8)
highStreet:SetAttribute("RestaurantStopZ", roadCentreZ + 12)
highStreet:SetAttribute("StationStopX", stationX)
highStreet:SetAttribute("StationStopZ", roadCentreZ + 10)

print("Safe high street ground and separate bus station loaded")