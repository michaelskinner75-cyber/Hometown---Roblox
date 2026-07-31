local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local function isImportedHouse(house)
	return house:GetAttribute("ImportedHouseLevel") ~= nil
end

local function removeGeneratedHomes()
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") then
			local house = plot:FindFirstChild("House")
			if house and not isImportedHouse(house) then
				house:Destroy()
			end
		end
	end
end

removeGeneratedHomes()

plotsFolder.DescendantAdded:Connect(function(object)
	if object.Name == "House" and object:IsA("Model") then
		task.defer(function()
			if object.Parent and not isImportedHouse(object) then
				object:Destroy()
			end
		end)
	end
end)

print("Generated homes removed; imported house models are preserved")
