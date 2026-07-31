local ServerStorage = game:GetService("ServerStorage")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")
local restaurantTemplate = ServerStorage:WaitForChild("HighStreetRestaurant")

local old = world:FindFirstChild("HighStreet")
if old then old:Destroy() end

local highStreet = Instance.new("Model")
highStreet.Name = "HighStreet"
highStreet.Parent = world

local function makePart(name, size, position, colour, material, parent)
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
	part.Parent = parent or highStreet
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

local streetCentreX = maxX + 150
local streetCentreZ = (minZ + maxZ) / 2
local stationCentreX = minX - 95

local restaurant = restaurantTemplate:Clone()
restaurant.Name = "HighStreetRestaurant"
restaurant.Parent = highStreet
cleanModel(restaurant)
restaurant:PivotTo(CFrame.new(streetCentreX + 20, 0, streetCentreZ) * CFrame.Angles(0, math.rad(90), 0))

local boxCFrame, boxSize = restaurant:GetBoundingBox()
local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
restaurant:PivotTo(CFrame.new(0, 0.45 - bottomY, 0) * restaurant:GetPivot())
boxCFrame, boxSize = restaurant:GetBoundingBox()

-- Ground the full restaurant/car-park area so nothing floats beyond the original map.
local restaurantGround = makePart(
	"HighStreetGround",
	Vector3.new(math.max(180, boxSize.X + 50), 2, math.max(180, boxSize.Z + 50)),
	Vector3.new(boxCFrame.Position.X, -0.75, boxCFrame.Position.Z),
	Color3.fromRGB(75, 120, 65),
	Enum.Material.Grass
)
restaurantGround.CastShadow = false

local connectorLength = math.max(70, streetCentreX - maxX + 30)
local connectorRoad = makePart(
	"HighStreetConnectorRoad",
	Vector3.new(connectorLength, 0.5, 38),
	Vector3.new((maxX + streetCentreX + 10) / 2, 0.2, streetCentreZ),
	Color3.fromRGB(46, 46, 48),
	Enum.Material.Asphalt
)

-- Wide apron/junction at the car park entrance so buses can enter and turn.
makePart(
	"RestaurantBusApron",
	Vector3.new(75, 0.52, 72),
	Vector3.new(streetCentreX + 10, 0.21, streetCentreZ),
	Color3.fromRGB(46, 46, 48),
	Enum.Material.Asphalt
)

for _, side in ipairs({-1, 1}) do
	makePart(
		"HighStreetPavement",
		Vector3.new(connectorLength, 0.65, 8),
		connectorRoad.Position + Vector3.new(0, 0.08, side * 23),
		Color3.fromRGB(145, 145, 145),
		Enum.Material.Concrete
	)
end

for x = maxX + 20, streetCentreX - 20, 38 do
	for _, side in ipairs({-1, 1}) do
		local post = makePart(
			"StreetLightPost",
			Vector3.new(0.8, 12, 0.8),
			Vector3.new(x, 6, streetCentreZ + side * 23),
			Color3.fromRGB(50, 52, 58),
			Enum.Material.Metal
		)

		local lamp = makePart(
			"StreetLight",
			Vector3.new(2.5, 0.6, 1.2),
			post.Position + Vector3.new(0, 6.1, 0),
			Color3.fromRGB(255, 236, 180),
			Enum.Material.Neon
		)
		lamp.CanCollide = false

		local light = Instance.new("PointLight")
		light.Range = 18
		light.Brightness = 1.5
		light.Color = lamp.Color
		light.Parent = lamp
	end
end

-- Bus station at the opposite end of town.
local station = Instance.new("Model")
station.Name = "HometownBusStation"
station.Parent = highStreet

makePart(
	"BusStationGround",
	Vector3.new(100, 2, 105),
	Vector3.new(stationCentreX, -0.75, streetCentreZ),
	Color3.fromRGB(74, 118, 64),
	Enum.Material.Grass,
	station
)
makePart(
	"BusStationRoad",
	Vector3.new(88, 0.55, 62),
	Vector3.new(stationCentreX, 0.22, streetCentreZ),
	Color3.fromRGB(44, 44, 47),
	Enum.Material.Asphalt,
	station
)
makePart(
	"BusStationPlatform",
	Vector3.new(70, 0.8, 11),
	Vector3.new(stationCentreX, 0.45, streetCentreZ + 25),
	Color3.fromRGB(155, 155, 155),
	Enum.Material.Concrete,
	station
)
makePart(
	"BusShelterRoof",
	Vector3.new(28, 1, 10),
	Vector3.new(stationCentreX, 9, streetCentreZ + 29),
	Color3.fromRGB(45, 55, 65),
	Enum.Material.Metal,
	station
)
for _, xOffset in ipairs({-12, 12}) do
	makePart(
		"BusShelterPost",
		Vector3.new(1, 9, 1),
		Vector3.new(stationCentreX + xOffset, 4.5, streetCentreZ + 29),
		Color3.fromRGB(55, 60, 68),
		Enum.Material.Metal,
		station
	)
end

local signPost = makePart(
	"StationSignPost",
	Vector3.new(1, 10, 1),
	Vector3.new(stationCentreX - 30, 5, streetCentreZ + 29),
	Color3.fromRGB(40, 45, 52),
	Enum.Material.Metal,
	station
)
local signGui = Instance.new("BillboardGui")
signGui.Name = "StationSign"
signGui.Size = UDim2.fromOffset(230, 70)
signGui.StudsOffset = Vector3.new(0, 5, 0)
signGui.AlwaysOnTop = false
signGui.MaxDistance = 120
signGui.Parent = signPost
local signLabel = Instance.new("TextLabel")
signLabel.Size = UDim2.fromScale(1, 1)
signLabel.BackgroundColor3 = Color3.fromRGB(35, 55, 80)
signLabel.TextColor3 = Color3.new(1, 1, 1)
signLabel.Font = Enum.Font.GothamBold
signLabel.TextScaled = true
signLabel.Text = "HOMETOWN BUS STATION"
signLabel.Parent = signGui

-- Shared route markers read by BusTraffic.server.lua.
highStreet:SetAttribute("RoadCentreZ", streetCentreZ)
highStreet:SetAttribute("RestaurantStopX", streetCentreX + 18)
highStreet:SetAttribute("RestaurantStopZ", streetCentreZ + 20)
highStreet:SetAttribute("StationStopX", stationCentreX)
highStreet:SetAttribute("StationStopZ", streetCentreZ + 12)

print("Grounded high street and Hometown bus station loaded")
