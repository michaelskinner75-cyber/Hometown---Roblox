local ServerStorage = game:GetService("ServerStorage")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local templates = {
	ServerStorage:WaitForChild("House01_WoodenShed"),
	ServerStorage:WaitForChild("House02_TreeHouse"),
	ServerStorage:WaitForChild("House03_LogCabin"),
	ServerStorage:WaitForChild("House04_SmallHouse"),
	ServerStorage:WaitForChild("House05_LargeHouse"),
}

local function cleanImportedModel(model)
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

local plots = {}
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if plot:IsA("Model") and ground and ground:IsA("BasePart") and not plot:GetAttribute("CommercialReserved") then
		table.insert(plots, plot)
	end
end

table.sort(plots, function(a, b)
	local aGround = a:FindFirstChild("Plot")
	local bGround = b:FindFirstChild("Plot")
	if math.abs(aGround.Position.X - bGround.Position.X) > 0.1 then
		return aGround.Position.X < bGround.Position.X
	end
	return aGround.Position.Z < bGround.Position.Z
end)

-- Let the original town/property scripts finish first.
task.wait(3)

for index, template in ipairs(templates) do
	local plot = plots[index]
	if not plot then break end

	local ground = plot:FindFirstChild("Plot")
	local oldHouse = plot:FindFirstChild("House")
	if oldHouse then oldHouse:Destroy() end

	local house = template:Clone()
	house.Name = "House"
	house:SetAttribute("ImportedHouseLevel", index)
	house.Parent = plot
	cleanImportedModel(house)

	local _, initialSize = house:GetBoundingBox()
	local availableX = ground.Size.X * 0.82
	local availableZ = ground.Size.Z * 0.82
	local scale = math.min(availableX / math.max(initialSize.X, 0.01), availableZ / math.max(initialSize.Z, 0.01), 1)
	if scale < 1 then
		house:ScaleTo(scale)
	end

	local front = plot:GetAttribute("FrontDirection") or -1
	local yaw = front == 1 and 0 or math.rad(180)
	house:PivotTo(CFrame.new(ground.Position.X, 0, ground.Position.Z) * CFrame.Angles(0, yaw, 0))

	local boxCFrame, boxSize = house:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
	local targetY = ground.Position.Y + ground.Size.Y / 2
	house:PivotTo(CFrame.new(0, targetY - bottomY, 0) * house:GetPivot())

	plot:SetAttribute("HouseBuilt", true)
	plot:SetAttribute("UpgradeTier", index)
end

print("Five imported houses placed on the first five available property plots")
