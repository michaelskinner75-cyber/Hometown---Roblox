local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local function updatePlot(plot)
	local sign = plot:FindFirstChild("Sign")
	if not sign or not sign:IsA("BasePart") then return end

	local owned = (plot:GetAttribute("OwnerUserId") or 0) ~= 0
	local level = plot:GetAttribute("UpgradeTier") or 0

	-- The large grey block is the physical Sign part. Keep it visible only on empty plots.
	sign.Transparency = owned and 1 or 0
	sign.CanCollide = not owned
	sign.CanTouch = false
	sign.CastShadow = not owned

	local gui = sign:FindFirstChild("BillboardGui")
	if gui and gui:IsA("BillboardGui") then
		gui.Enabled = not owned
	end

	-- Prompts can stay parented to an invisible sign and still work.
	for _, child in ipairs(sign:GetChildren()) do
		if child:IsA("ProximityPrompt") then
			child.Enabled = true
		end
	end

	plot:SetAttribute("VisiblePropertyLevel", level)
end

local function watchPlot(plot)
	if not plot:IsA("Model") then return end

	plot:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		updatePlot(plot)
	end)
	plot:GetAttributeChangedSignal("UpgradeTier"):Connect(function()
		updatePlot(plot)
	end)
	plot.ChildAdded:Connect(function(child)
		if child.Name == "Sign" then
			task.defer(updatePlot, plot)
		end
	end)

	updatePlot(plot)
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	watchPlot(plot)
end

plotsFolder.ChildAdded:Connect(watchPlot)

print("Owned property boards hidden")
