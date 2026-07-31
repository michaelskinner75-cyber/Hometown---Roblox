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

local function cloneBus(name)
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
if minX == math.huge then minX, maxX = -120, 120 end

local roadCentreZ = highStreet:GetAttribute("RoadCentreZ") or 0
local restaurantStopX = highStreet:GetAttribute("RestaurantStopX") or (maxX + 190)
local restaurantStopZ = highStreet:GetAttribute("RestaurantStopZ") or (roadCentreZ + 12)
local stationStopX = highStreet:GetAttribute("StationStopX") or (minX - 120)
local stationStopZ = highStreet:GetAttribute("StationStopZ") or (roadCentreZ + 10)
local outwardZ = roadCentreZ - 10
local returnZ = roadCentreZ + 10

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
	local yaw = headingYaw(fromPosition, toPosition)
	local startCFrame = groundedCFrame(bus, fromPosition, yaw)
	bus:PivotTo(startCFrame)
	local finishCFrame = CFrame.new(toPosition.X - fromPosition.X, 0, toPosition.Z - fromPosition.Z) * startCFrame

	local driver = Instance.new("CFrameValue")
	driver.Value = startCFrame
	local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
		if bus.Parent then bus:PivotTo(driver.Value) end
	end)
	local tween = TweenService:Create(driver, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Value = finishCFrame})
	tween:Play()
	tween.Completed:Wait()
	connection:Disconnect()
	driver:Destroy()
end

local stationBay = Vector3.new(stationStopX, 0, stationStopZ)
local stationExit = Vector3.new(stationStopX + 34, 0, outwardZ)
local restaurantApproach = Vector3.new(restaurantStopX - 36, 0, outwardZ)
local restaurantBay = Vector3.new(restaurantStopX, 0, restaurantStopZ)
local restaurantTurn = Vector3.new(restaurantStopX - 12, 0, returnZ)
local stationApproach = Vector3.new(stationStopX + 34, 0, returnZ)

local route = {
	{stationBay, stationExit, 6, false},
	{stationExit, restaurantApproach, 34, false},
	{restaurantApproach, restaurantBay, 6, true},
	{restaurantBay, restaurantTurn, 6, false},
	{restaurantTurn, stationApproach, 34, false},
	{stationApproach, stationBay, 6, true},
}

local function run(bus, startIndex)
	local index = startIndex
	while bus.Parent do
		local segment = route[index]
		moveSegment(bus, segment[1], segment[2], segment[3])
		if segment[4] then task.wait(7) else task.wait(0.2) end
		index += 1
		if index > #route then index = 1 end
	end
end

local bus1 = cloneBus("DetailedBus1")
local bus2 = cloneBus("DetailedBus2")

task.spawn(function() run(bus1, 1) end)
task.spawn(function()
	task.wait(3)
	run(bus2, 4)
end)

print("Two buses now stop in the restaurant car park and Hometown bus station")