local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

local function removeGeneratedHomes()
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") then
			local house = plot:FindFirstChild("House")
			if house then
				house:Destroy()
			end
		end
	end
end

removeGeneratedHomes()

plotsFolder.DescendantAdded:Connect(function(object)
	if object.Name == "House" and object:IsA("Model") then
		task.defer(function()
			if object.Parent then
				object:Destroy()
			end
		end)
	end
end)

print("All generated property homes removed; plots left ready for imported homes")
