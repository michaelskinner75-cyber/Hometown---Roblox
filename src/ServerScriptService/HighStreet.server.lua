local ServerStorage = game:GetService("ServerStorage")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")
local restaurantTemplate = ServerStorage:WaitForChild("HighStreetRestaurant")

local old = world:FindFirstChild("HighStreet")
if old then old:Destroy() end

local highStreet = Instance.new("Model")
highStreet.Name = "HighStreet"
highStreet.Parent = world

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

local streetCentreX = maxX + 220
local streetCentreZ = (minZ + maxZ) / 2

local restaurant = restaurantTemplate:Clone()
restaurant.Name = "HighStreetRestaurant"
restaurant.Parent = highStreet
cleanModel(restaurant)

restaurant:PivotTo(CFrame.new(streetCentreX, 0, streetCentreZ) * CFrame.Angles(0, math.rad(90), 0))
local boxCFrame, boxSize = restaurant:GetBoundingBox()
local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
restaurant:PivotTo(CFrame.new(0, 0.4 - bottomY, 0) * restaurant:GetPivot())

local connectorRoad = Instance.new("Part")
connectorRoad.Name = "HighStreetConnectorRoad"
connectorRoad.Anchored = true
connectorRoad.CanCollide = true
connectorRoad.Material = Enum.Material.Asphalt
connectorRoad.Color = Color3.fromRGB(46, 46, 48)
connectorRoad.Size = Vector3.new(math.max(80, streetCentreX - maxX), 0.5, 38)
connectorRoad.Position = Vector3.new((maxX + streetCentreX) / 2, 0.2, streetCentreZ)
connectorRoad.Parent = highStreet

for _, side in ipairs({-1, 1}) do
	local pavement = Instance.new("Part")
	pavement.Name = "HighStreetPavement"
	pavement.Anchored = true
	pavement.CanCollide = true
	pavement.Material = Enum.Material.Concrete
	pavement.Color = Color3.fromRGB(145, 145, 145)
	pavement.Size = Vector3.new(connectorRoad.Size.X, 0.65, 8)
	pavement.Position = connectorRoad.Position + Vector3.new(0, 0.08, side * 23)
	pavement.Parent = highStreet
end

for x = maxX + 25, streetCentreX - 25, 38 do
	for _, side in ipairs({-1, 1}) do
		local post = Instance.new("Part")
		post.Name = "StreetLightPost"
		post.Anchored = true
		post.CanCollide = true
		post.Material = Enum.Material.Metal
		post.Color = Color3.fromRGB(50, 52, 58)
		post.Size = Vector3.new(0.8, 12, 0.8)
		post.Position = Vector3.new(x, 6, streetCentreZ + side * 23)
		post.Parent = highStreet

		local lamp = Instance.new("Part")
		lamp.Name = "StreetLight"
		lamp.Anchored = true
		lamp.CanCollide = false
		lamp.Material = Enum.Material.Neon
		lamp.Color = Color3.fromRGB(255, 236, 180)
		lamp.Size = Vector3.new(2.5, 0.6, 1.2)
		lamp.Position = post.Position + Vector3.new(0, 6.1, 0)
		lamp.Parent = highStreet

		local light = Instance.new("PointLight")
		light.Range = 18
		light.Brightness = 1.5
		light.Color = lamp.Color
		light.Parent = lamp
	end
end

print("High street restaurant area loaded")
