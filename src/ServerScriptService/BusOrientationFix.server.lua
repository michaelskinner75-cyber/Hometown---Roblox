local RunService = game:GetService("RunService")

local world = workspace:WaitForChild("HometownWorld")
local ambient = world:WaitForChild("AmbientTown")
local traffic = ambient:WaitForChild("Traffic")

-- VisualPolish builds each bus lengthways on its local X axis, while CFrame.lookAt
-- points the local -Z axis along the road. This correction turns the model 90°
-- so its windscreen faces the direction in which it is moving.
task.wait(2)

local previousPositions = {}

RunService.Heartbeat:Connect(function()
	for _, bus in ipairs(traffic:GetChildren()) do
		if bus:IsA("Model") and bus.Name:find("ModernBus") and bus.PrimaryPart then
			local position = bus.PrimaryPart.Position
			local previous = previousPositions[bus]

			if previous then
				local movement = position - previous
				if movement.Magnitude > 0.001 then
					local travelFacing = CFrame.lookAt(position, position + movement.Unit)
					bus:PivotTo(travelFacing * CFrame.Angles(0, math.rad(90), 0))
				end
			end

			previousPositions[bus] = position
		end
	end

	for bus in pairs(previousPositions) do
		if not bus.Parent then
			previousPositions[bus] = nil
		end
	end
end)

print("Bus direction alignment fix loaded")