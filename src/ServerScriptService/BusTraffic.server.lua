local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")
local highStreet = world:WaitForChild("HighStreet")
local busTemplate = ServerStorage:WaitForChild("DetailedBus")

local trafficFolder = world:FindFirstChild("BusTraffic") or Instance.new("Folder")
trafficFolder.Name = "BusTraffic"
trafficFolder.Parent = world
trafficFolder:ClearAllChildren()

local function isLegacyTrafficName(name)
	local n = string.lower(name)
	return string.find(n, "car")
		or string.find(n, "vehicle")
		or string.find(n, "traffic")
		or string.find(n, "service7")
		or string.find(n, "servicex24")
		or string.find(n, "service39")
		or string.find(n, "oldbus")
		or string.find(n, "citybus")
end

local function removeLegacyTraffic()
	for _, object in ipairs(world:GetChildren()) do
		if object ~= trafficFolder and object ~= highStreet and isLegacyTrafficName(object.Name) then
			object:Destroy()
		end
	end

	for _, object in ipairs(world:GetDescendants()) do
		if object ~= trafficFolder and not object:IsDescendantOf(trafficFolder) and not object:IsDescendantOf(highStreet) then
			if (object:IsA("Model") or object:IsA("Folder")) and isLegacyTrafficName(object.Name) then
				object:Destroy()
			end
		end
	end

	for _, object in ipairs(trafficFolder:GetChildren()) do
		if object.Name ~= "DetailedBus1" and object.Name ~= "DetailedBus2" then
			object:Destroy()
		end
	end
end

removeLegacyTraffic()

task.spawn(function()
	while world.Parent do
		removeLegacyTraffic()
		task.wait(1)
	end
end)

local function cleanBus(model)
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
			object:Destroy()
		elseif object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
			object:Destroy()
		elseif object:IsA("BasePart") then
			object.Anchored = true
			object.CanCollide = false
			object.Massless = true
		end
	end
end

local function cloneTemplate(name)
	local bus = busTemplate:Clone()
	bus.Name = name
	bus.Parent = trafficFolder
	cleanBus(bus)
	return bus
end

local minX, maxX = math.huge, -math.huge
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if ground and ground:IsA("BasePart") then
		minX = math.min(minX, ground.Position.X)
		maxX = math.max(maxX, ground.Position.X)
	end
end
if minX == math.huge then
	minX, maxX = -120, 120
end

local roadCentreZ = highStreet:GetAttribute("RoadCentreZ") or 0
local restaurantStopX = highStreet:GetAttribute("RestaurantStopX") or (maxX + 165)
local restaurantStopZ = highStreet:GetAttribute("RestaurantStopZ") or (roadCentreZ + 20)
local stationStopX = highStreet:GetAttribute("StationStopX") or (minX - 95)
local stationStopZ = highStreet:GetAttribute("StationStopZ") or (roadCentreZ + 12)
local outboundLaneZ = roadCentreZ - 10
local returnLaneZ = roadCentreZ + 10

local templateSize = busTemplate:GetExtentsSize()
local baseYaw = (templateSize.Z >= templateSize.X and math.rad(90) or 0) + math.rad(180)

local function groundedCFrame(bus, position, yaw)
	bus:PivotTo(CFrame.new(position.X, 0, position.Z) * CFrame.Angles(0, yaw, 0))
	local boxCFrame, boxSize = bus:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
	local correction = Vector3.new(position.X - boxCFrame.Position.X, 0.45 - bottomY, position.Z - boxCFrame.Position.Z)
	return CFrame.new(correction) * bus:GetPivot()
end

local function headingYaw(fromPosition, toPosition)
	local delta = toPosition - fromPosition
	return baseYaw + math.atan2(-delta.Z, delta.X)
end

local function moveSegment(bus, fromPosition, toPosition, duration)
	if not bus.Parent then return end
	local yaw = headingYaw(fromPosition, toPosition)
	local startCFrame = groundedCFrame(bus, fromPosition, yaw)
	bus:PivotTo(startCFrame)

	local endCFrame = CFrame.new(toPosition.X - fromPosition.X, 0, toPosition.Z - fromPosition.Z) * startCFrame
	local driver = Instance.new("CFrameValue")
	driver.Value = startCFrame
	local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
		if bus.Parent then bus:PivotTo(driver.Value) end
	end)

	local tween = TweenService:Create(driver, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Value = endCFrame})
	tween:Play()
	tween.Completed:Wait()
	connection:Disconnect()
	driver:Destroy()
end

local stationBay = Vector3.new(stationStopX, 0, stationStopZ)
local stationExit = Vector3.new(stationStopX + 35, 0, outboundLaneZ)
local townOutbound = Vector3.new(maxX + 55, 0, outboundLaneZ)
local restaurantEntrance = Vector3.new(restaurantStopX - 35, 0, outboundLaneZ)
local restaurantBay = Vector3.new(restaurantStopX, 0, restaurantStopZ)
local restaurantExit = Vector3.new(restaurantStopX - 25, 0, returnLaneZ)
local townReturn = Vector3.new(minX - 45, 0, returnLaneZ)
local stationEntrance = Vector3.new(stationStopX + 28, 0, returnLaneZ)

local route = {
	{stationBay, stationExit, 6},
	{stationExit, townOutbound, 25},
	{townOutbound, restaurantEntrance, 12},
	{restaurantEntrance, restaurantBay, 6},
	{restaurantBay, restaurantExit, 6},
	{restaurantExit, townReturn, 34},
	{townReturn, stationEntrance, 8},
	{stationEntrance, stationBay, 6},
}

local function runRoute(bus, startIndex)
	local index = startIndex
	while bus.Parent do
		local segment = route[index]
		moveSegment(bus, segment[1], segment[2], segment[3])

		-- Stop for passengers at the restaurant car park and bus station.
		if index == 4 or index == 8 then
			task.wait(7)
		else
			task.wait(0.15)
		end

		index += 1
		if index > #route then index = 1 end
	end
end

local bus1 = cloneTemplate("DetailedBus1")
local bus2 = cloneTemplate("DetailedBus2")

-- One leaves the station while the other begins at the restaurant end.
task.spawn(function()
	runRoute(bus1, 1)
end)

task.spawn(function()
	task.wait(2)
	runRoute(bus2, 5)
end)

print("Two buses now serve the restaurant car park and Hometown bus station")
