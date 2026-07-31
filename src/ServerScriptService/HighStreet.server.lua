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

-- Use the property lot furthest along the road for the restaurant.
local chosenPlot
local chosenGround
for _, plot in ipairs(plotsFolder:GetChildren()) do
	local ground = plot:FindFirstChild("Plot")
	if plot:IsA("Model") and ground and ground:IsA("BasePart") then
		if not chosenGround or ground.Position.X > chosenGround.Position.X then
			chosenPlot = plot
			chosenGround = ground
		end
	end
end

if not chosenPlot or not chosenGround then
	warn("No property plot found for restaurant")
	return
end

chosenPlot:SetAttribute("CommercialReserved", true)
chosenPlot:SetAttribute("OwnerUserId", -1)
chosenPlot:SetAttribute("UpgradeTier", 0)
chosenPlot:SetAttribute("HouseBuilt", false)
chosenPlot:SetAttribute("MarketStatus", "Commercial")

local oldHouse = chosenPlot:FindFirstChild("House")
if oldHouse then oldHouse:Destroy() end

-- Remove all property signs, pads and prompts from this one commercial lot.
for _, object in ipairs(chosenPlot:GetDescendants()) do
	if object:IsA("ProximityPrompt") then
		object:Destroy()
	elseif object:IsA("BillboardGui") then
		object.Enabled = false
	elseif object:IsA("BasePart") and object ~= chosenGround then
		local lowerName = string.lower(object.Name)
		if string.find(lowerName, "pad") or string.find(lowerName, "sign") then
			object:Destroy()
		end
	end
end

local restaurant = restaurantTemplate:Clone()
restaurant.Name = "HighStreetRestaurant"
restaurant.Parent = highStreet
cleanModel(restaurant)

-- Scale the full model down so it fits neatly inside one property lot.
local _, originalSize = restaurant:GetBoundingBox()
local maxRestaurantDimension = math.max(originalSize.X, originalSize.Z)
local maxPlotDimension = math.min(chosenGround.Size.X, chosenGround.Size.Z) * 0.92
if maxRestaurantDimension > maxPlotDimension then
	restaurant:ScaleTo(maxPlotDimension / maxRestaurantDimension)
end

local front = chosenPlot:GetAttribute("FrontDirection") or -1
local yaw = front == 1 and 0 or math.rad(180)
restaurant:PivotTo(CFrame.new(chosenGround.Position.X, 0, chosenGround.Position.Z) * CFrame.Angles(0, yaw, 0))

local boxCFrame, boxSize = restaurant:GetBoundingBox()
local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
restaurant:PivotTo(CFrame.new(0, chosenGround.Position.Y + chosenGround.Size.Y / 2 - bottomY, 0) * restaurant:GetPivot())

-- Keep the lot reserved even if other property scripts initialise later.
task.spawn(function()
	while chosenPlot.Parent do
		chosenPlot:SetAttribute("CommercialReserved", true)
		chosenPlot:SetAttribute("OwnerUserId", -1)
		for _, object in ipairs(chosenPlot:GetDescendants()) do
			if object:IsA("ProximityPrompt") then object.Enabled = false end
		end
		task.wait(1)
	end
end)

print("Restaurant placed on one reserved property lot")