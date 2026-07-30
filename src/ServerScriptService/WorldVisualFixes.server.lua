local world = workspace:WaitForChild("HometownWorld")

-- The blue square was the visible SpawnLocation in the middle of the road.
local spawn = world:FindFirstChild("TownSpawn")
if spawn and spawn:IsA("SpawnLocation") then
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Decal.Transparency = 1
end

-- The generated cylinders were rotated onto the wrong axis.
-- Wait for the replacement traffic models, then turn every tyre and hub
-- so the wheel faces out from the side of the vehicle.
task.wait(3)
local ambient = world:FindFirstChild("AmbientTown")
local traffic = ambient and ambient:FindFirstChild("Traffic")
if traffic then
	for _, vehicle in ipairs(traffic:GetChildren()) do
		if vehicle:IsA("Model") then
			for _, item in ipairs(vehicle:GetDescendants()) do
				if item:IsA("BasePart") and (item.Name == "Tyre" or item.Name == "Hub") then
					item.CFrame = item.CFrame * CFrame.Angles(0, 0, math.rad(-90))
				end
			end
		end
	end
end

print("Vehicle wheel and spawn-pad fixes loaded")