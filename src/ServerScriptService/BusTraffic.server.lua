local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")
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
		if object ~= trafficFolder and isLegacyTrafficName(object.Name) then
			object:Destroy()
		end
	end

	for _, object in ipairs(world:GetDescendants()) do
		if object ~= trafficFolder and not object:IsDescendantOf(trafficFolder) then
			if (object:IsA("Model") or object:IsA("Folder")) and isLegacyTrafficName(object.Name) then
				object:Destroy()
			end
		end
	end

	for _, object in ipairs(trafficFolder:GetChildren()) do
		if not string.match(object.Name, "^DetailedBus%d+$") then
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

local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if ground and ground:IsA("BasePart") then
		local position = ground.Position
		minX = math.min(minX, position.X)
		maxX = math.max(maxX, position.X)
		minZ = math.min(minZ, position.Z)
		maxZ = math.max(maxZ, position.Z)
	end
end

if minX == math.huge then
	minX, maxX, minZ, maxZ = -120, 120, -80, 80
end

local roadZ = (minZ + maxZ) / 2
local startX = minX - 65
local endX = maxX + 65
local laneOffsets = {-8, 0, 8}

local templateSize = busTemplate:GetExtentsSize()
local yaw = (templateSize.Z >= templateSize.X and math.rad(90) or 0) + math.rad(180)

local function placeBus(bus, x, z)
	bus:PivotTo(CFrame.new(x, 0, z) * CFrame.Angles(0, yaw, 0))
	local boxCFrame, boxSize = bus:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
	local correction = Vector3.new(x - boxCFrame.Position.X, 0.45 - bottomY, z - boxCFrame.Position.Z)
	bus:PivotTo(CFrame.new(correction) * bus:GetPivot())
end

local function moveBus(bus, fromX, toX, z, duration)
	placeBus(bus, fromX, z)
	local startPivot = bus:GetPivot()
	local targetPivot = CFrame.new(toX - fromX, 0, 0) * startPivot

	local driver = Instance.new("CFrameValue")
	driver.Value = startPivot
	local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
		if bus.Parent then
			bus:PivotTo(driver.Value)
		end
	end)

	local tween = TweenService:Create(driver, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Value = targetPivot})
	tween:Play()
	tween.Completed:Wait()
	connection:Disconnect()
	driver:Destroy()
end

for index = 1, 3 do
	local bus = cloneTemplate("DetailedBus" .. index)
	local z = roadZ + laneOffsets[index]

	task.spawn(function()
		task.wait((index - 1) * 7)
		while bus.Parent do
			moveBus(bus, startX, endX, z, 30 + index * 2)
			task.wait(3)
		end
	end)
end

print("Imported detailed bus traffic loaded; legacy traffic removed")
