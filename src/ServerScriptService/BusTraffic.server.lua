local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")
local busTemplate = ServerStorage:WaitForChild("DetailedBus")

-- Remove the old generic road-traffic systems and their spawned vehicles.
local blockedTrafficNames = {
	RoadTraffic = true,
	Traffic = true,
	Cars = true,
	CarTraffic = true,
	Vehicles = true,
	NPCVehicles = true,
}

local function removeOldTraffic()
	for _, child in ipairs(world:GetChildren()) do
		if blockedTrafficNames[child.Name] then
			child:Destroy()
		elseif child:IsA("Model") and child:GetAttribute("GenericRoadTraffic") == true then
			child:Destroy()
		end
	end
end

removeOldTraffic()
world.ChildAdded:Connect(function(child)
	if blockedTrafficNames[child.Name] or (child:IsA("Model") and child:GetAttribute("GenericRoadTraffic") == true) then
		task.defer(function()
			if child.Parent then child:Destroy() end
		end)
	end
end)

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
	bus:SetAttribute("StagecoachBus", true)
	bus.Parent = trafficFolder
	cleanBus(bus)
	return bus
end

local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if ground and ground:IsA("BasePart") then
		minX = math.min(minX, ground.Position.X)
		maxX = math.max(maxX, ground.Position.X)
		minZ = math.min(minZ, ground.Position.Z)
		maxZ = math.max(maxZ, ground.Position.Z)
	end
end
if minX == math.huge then
	minX, maxX, minZ, maxZ = -120, 120, -80, 80
end

local roadCentreZ = (minZ + maxZ) / 2
local startX = minX - 65
local endX = maxX + 65
local leftLaneZ = roadCentreZ - 10
local rightLaneZ = roadCentreZ + 10

local templateSize = busTemplate:GetExtentsSize()
local baseYaw = (templateSize.Z >= templateSize.X and math.rad(90) or 0) + math.rad(180)

local function placeBus(bus, x, z, yaw)
	bus:PivotTo(CFrame.new(x, 0, z) * CFrame.Angles(0, yaw, 0))
	local boxCFrame, boxSize = bus:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
	local correction = Vector3.new(x - boxCFrame.Position.X, 0.45 - bottomY, z - boxCFrame.Position.Z)
	bus:PivotTo(CFrame.new(correction) * bus:GetPivot())
end

local function moveBus(bus, fromX, toX, z, yaw, duration)
	placeBus(bus, fromX, z, yaw)
	local startPivot = bus:GetPivot()
	local targetPivot = CFrame.new(toX - fromX, 0, 0) * startPivot
	local driver = Instance.new("CFrameValue")
	driver.Value = startPivot
	local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
		if bus.Parent then bus:PivotTo(driver.Value) end
	end)
	local tween = TweenService:Create(driver, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Value = targetPivot})
	tween:Play()
	tween.Completed:Wait()
	connection:Disconnect()
	driver:Destroy()
end

local bus1 = cloneBus("StagecoachBus1")
local bus2 = cloneBus("StagecoachBus2")

task.spawn(function()
	while bus1.Parent do
		moveBus(bus1, startX, endX, leftLaneZ, baseYaw, 32)
		task.wait(3)
	end
end)

task.spawn(function()
	task.wait(5)
	while bus2.Parent do
		moveBus(bus2, endX, startX, rightLaneZ, baseYaw + math.rad(180), 32)
		task.wait(3)
	end
end)

print("Only the two Stagecoach buses are running on the road")
