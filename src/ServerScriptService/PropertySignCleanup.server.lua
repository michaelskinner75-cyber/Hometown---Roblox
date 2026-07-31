local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local function tidyBillboard(gui)
	if not gui:IsA("BillboardGui") then return end

	local parentName = gui.Parent and string.lower(gui.Parent.Name) or ""
	local guiName = string.lower(gui.Name)

	if guiName == "actionlabel" or string.find(parentName, "pad") then
		gui.MaxDistance = 16
		gui.AlwaysOnTop = false
		gui.Size = UDim2.fromOffset(140, 40)
		gui.StudsOffset = Vector3.new(0, 2.2, 0)
	else
		gui.MaxDistance = 32
		gui.AlwaysOnTop = false
		local width = math.min(gui.Size.X.Offset > 0 and gui.Size.X.Offset or 180, 180)
		local height = math.min(gui.Size.Y.Offset > 0 and gui.Size.Y.Offset or 70, 70)
		gui.Size = UDim2.fromOffset(width, height)
	end
end

local function tidyPrompt(prompt)
	if not prompt:IsA("ProximityPrompt") then return end
	prompt.MaxActivationDistance = math.min(prompt.MaxActivationDistance, 7)
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
end

local function tidyObject(object)
	if object:IsA("BillboardGui") then
		tidyBillboard(object)
	elseif object:IsA("ProximityPrompt") then
		tidyPrompt(object)
	end
end

for _, object in ipairs(plotsFolder:GetDescendants()) do
	tidyObject(object)
end

plotsFolder.DescendantAdded:Connect(function(object)
	task.defer(tidyObject, object)
end)

print("Property signs decluttered")
