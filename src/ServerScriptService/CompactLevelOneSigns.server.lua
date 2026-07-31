local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local function makePart(parent, name, size, cframe, colour, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.Color = colour
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addFace(board, face)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "CompactSignGui"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 55
	gui.Parent = board

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(248, 248, 244)
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.fromRGB(32, 103, 62)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Text = "LEVEL 1\nUPGRADE £900"
	label.Parent = gui
end

local function hideOldLevelBoard(plot)
	local sign = plot:FindFirstChild("Sign")
	if not sign then return end

	for _, object in ipairs(sign:GetDescendants()) do
		if object:IsA("SurfaceGui") or object:IsA("BillboardGui") then
			object.Enabled = false
		end
	end
end

local function createCompactSign(plot)
	local old = plot:FindFirstChild("CompactLevelOneSign")
	if old then old:Destroy() end

	local house = plot:FindFirstChild("House")
	if not house then return end
	local tier = plot:GetAttribute("UpgradeTier") or 0
	if tier ~= 1 then return end

	hideOldLevelBoard(plot)

	local boxCFrame, boxSize = house:GetBoundingBox()
	local front = plot:GetAttribute("FrontDirection") or -1
	local side = boxCFrame.Position.X + boxSize.X / 2 + 3.5
	local frontZ = boxCFrame.Position.Z + front * (boxSize.Z / 2 + 2.5)
	local groundY = plot:FindFirstChild("Plot") and plot.Plot.Position.Y + plot.Plot.Size.Y / 2 or 0
	local yaw = front == -1 and 0 or math.rad(180)

	local model = Instance.new("Model")
	model.Name = "CompactLevelOneSign"
	model.Parent = plot

	local post = makePart(model, "Post", Vector3.new(0.35, 4.5, 0.35), CFrame.new(side, groundY + 2.25, frontZ), Color3.fromRGB(70, 70, 70), Enum.Material.Metal)
	local board = makePart(model, "Board", Vector3.new(5.8, 3.1, 0.28), CFrame.new(side, groundY + 4.8, frontZ) * CFrame.Angles(0, yaw, 0), Color3.fromRGB(248, 248, 244), Enum.Material.SmoothPlastic)
	addFace(board, Enum.NormalId.Front)
	addFace(board, Enum.NormalId.Back)
	model.PrimaryPart = post
end

local function watchPlot(plot)
	local function refresh()
		task.wait(0.15)
		createCompactSign(plot)
	end

	plot:GetAttributeChangedSignal("UpgradeTier"):Connect(refresh)
	plot.ChildAdded:Connect(function(child)
		if child.Name == "House" then refresh() end
	end)
	refresh()
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then watchPlot(plot) end
end

plotsFolder.ChildAdded:Connect(function(plot)
	if plot:IsA("Model") then watchPlot(plot) end
end)

print("Compact level one property signs loaded")