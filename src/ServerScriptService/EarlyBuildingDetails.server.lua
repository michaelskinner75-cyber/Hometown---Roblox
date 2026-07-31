local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local function part(parent, name, size, cframe, colour, material, canCollide)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Anchored = true
	item.CanCollide = canCollide == true
	item.Color = colour
	item.Material = material or Enum.Material.SmoothPlastic
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function addTentDetails(plot, house, tier)
	local centre = plot.Plot.Position
	local front = plot:GetAttribute("FrontDirection") or -1
	local width = 12 + tier * 2
	local depth = 10 + tier

	for _, x in ipairs({-width / 2 + 1, width / 2 - 1}) do
		for _, z in ipairs({-depth / 2 + 1, depth / 2 - 1}) do
			part(house, "TentPole", Vector3.new(0.35, 7, 0.35), CFrame.new(centre + Vector3.new(x, 4.5, z)), Color3.fromRGB(75, 55, 35), Enum.Material.Wood, false)
		end
	end

	local flap = part(house, "TentEntrance", Vector3.new(3.8, 5, 0.35), CFrame.new(centre + Vector3.new(0, 3.6, front * (depth / 2 + 0.3))), Color3.fromRGB(55, 95, 60), Enum.Material.Fabric, false)
	flap.Transparency = 0.08

	part(house, "SleepingMat", Vector3.new(5, 0.25, 7), CFrame.new(centre + Vector3.new(-2.5, 1.55, 0)), Color3.fromRGB(135, 65, 55), Enum.Material.Fabric, false)
	part(house, "SupplyCrate", Vector3.new(3, 2.5, 3), CFrame.new(centre + Vector3.new(width / 2 - 2.5, 2.5, -1)), Color3.fromRGB(120, 85, 50), Enum.Material.WoodPlanks, true)
	part(house, "Path", Vector3.new(4, 0.2, 10), CFrame.new(centre + Vector3.new(0, 1.1, front * (depth / 2 + 5))), Color3.fromRGB(125, 105, 80), Enum.Material.Ground, false)

	local fireBase = part(house, "CampfireBase", Vector3.new(3.2, 0.5, 3.2), CFrame.new(centre + Vector3.new(-width / 2 - 4, 1.3, 2)), Color3.fromRGB(70, 65, 60), Enum.Material.Cobblestone, false)
	fireBase.Shape = Enum.PartType.Cylinder
	part(house, "CampfireGlow", Vector3.new(1.5, 1.5, 1.5), CFrame.new(centre + Vector3.new(-width / 2 - 4, 2.2, 2)), Color3.fromRGB(255, 145, 45), Enum.Material.Neon, false)
end

local function addCabinDetails(plot, house, tier)
	local centre = plot.Plot.Position
	local front = plot:GetAttribute("FrontDirection") or -1
	local localLevel = tier - 2
	local width = 18 + localLevel * 3
	local depth = 16 + localLevel * 2
	local height = 8 + localLevel * 1.5

	part(house, "FrontStep", Vector3.new(7, 0.7, 4), CFrame.new(centre + Vector3.new(0, 1.35, front * (depth / 2 + 2))), Color3.fromRGB(110, 80, 55), Enum.Material.WoodPlanks, true)
	part(house, "Path", Vector3.new(4, 0.2, 12), CFrame.new(centre + Vector3.new(0, 1.1, front * (depth / 2 + 7))), Color3.fromRGB(145, 130, 105), Enum.Material.Ground, false)
	part(house, "Chimney", Vector3.new(2.8, 6, 2.8), CFrame.new(centre + Vector3.new(width * 0.3, height + 3.5, -depth * 0.18)), Color3.fromRGB(105, 70, 55), Enum.Material.Brick, true)

	for _, x in ipairs({-width * 0.28, width * 0.28}) do
		local window = part(house, "Window", Vector3.new(4.2, 3.5, 0.4), CFrame.new(centre + Vector3.new(x, height * 0.58 + 1, front * (depth / 2 + 0.25))), Color3.fromRGB(135, 210, 255), Enum.Material.Glass, false)
		window.Transparency = 0.2
		part(house, "WindowFrameV", Vector3.new(0.25, 3.7, 0.55), window.CFrame, Color3.fromRGB(235, 230, 215), Enum.Material.Wood, false)
		part(house, "WindowFrameH", Vector3.new(4.4, 0.25, 0.55), window.CFrame, Color3.fromRGB(235, 230, 215), Enum.Material.Wood, false)
	end

	part(house, "WoodPile", Vector3.new(5, 2.5, 2.5), CFrame.new(centre + Vector3.new(-width / 2 - 2.5, 2.25, 1)), Color3.fromRGB(105, 72, 44), Enum.Material.Wood, true)
	part(house, "FenceLeft", Vector3.new(0.4, 3, 12), CFrame.new(centre + Vector3.new(-width / 2 - 5, 2.5, front * (depth / 2 + 2))), Color3.fromRGB(205, 195, 170), Enum.Material.Wood, false)
	part(house, "FenceRight", Vector3.new(0.4, 3, 12), CFrame.new(centre + Vector3.new(width / 2 + 5, 2.5, front * (depth / 2 + 2))), Color3.fromRGB(205, 195, 170), Enum.Material.Wood, false)
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then
		task.spawn(function()
			while plot.Parent do
				local house = plot:FindFirstChild("House")
				local tier = plot:GetAttribute("UpgradeTier") or 0
				if house and tier > 0 and tier <= 6 and not house:GetAttribute("EarlyDetailsAdded") then
					house:SetAttribute("EarlyDetailsAdded", true)
					if tier <= 2 then
						addTentDetails(plot, house, tier)
					else
						addCabinDetails(plot, house, tier)
					end
				end
				task.wait(0.5)
			end
		end)
	end
end

print("Early building detail upgrade loaded")