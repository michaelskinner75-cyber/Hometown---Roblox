local world = workspace:WaitForChild("HometownWorld")
local plots = world:WaitForChild("Plots")
local interiors = world:WaitForChild("PropertyInteriors")

local function teleport(player, target)
	local character = player.Character
	if character then
		character:PivotTo(target)
	end
end

local function findBestDoor(house)
	local namedDoor
	for _, item in ipairs(house:GetDescendants()) do
		if item:IsA("BasePart") then
			local lower = item.Name:lower()
			if lower:find("door") then
				namedDoor = item
				break
			end
		end
	end
	if namedDoor then return namedDoor end

	-- Fallback: use the lowest front-facing solid part so every generated house is enterable.
	local best
	for _, item in ipairs(house:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 0.8 then
			if not best or item.Position.Y < best.Position.Y then
				best = item
			end
		end
	end
	return best
end

local function attachEntry(plot, index)
	local house = plot:FindFirstChild("House")
	if not house then return end
	local door = findBestDoor(house)
	if not door then return end

	local old = door:FindFirstChild("ReliableEnterPrompt")
	if old then old:Destroy() end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ReliableEnterPrompt"
	prompt.ActionText = "Enter House"
	prompt.ObjectText = "Your Property"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 16
	prompt.RequiresLineOfSight = false
	prompt.Parent = door

	prompt.Triggered:Connect(function(player)
		if plot:GetAttribute("OwnerUserId") ~= player.UserId then return end
		local room = interiors:FindFirstChild(plot.Name .. "Interior")
		if room then
			local floor = room:FindFirstChild("Floor")
			if floor then
				teleport(player, floor.CFrame * CFrame.new(0, 3, -9))
				return
			end
		end
		-- Matches the original interior layout if the room is still being created.
		teleport(player, CFrame.new((index - 1) * 90 - 315, 508, -9))
	end)
end

local function watch(plot, index)
	plot.ChildAdded:Connect(function(child)
		if child.Name == "House" then
			task.wait(1)
			attachEntry(plot, index)
		end
	end)
	plot:GetAttributeChangedSignal("HouseBuilt"):Connect(function()
		if plot:GetAttribute("HouseBuilt") then
			task.wait(1)
			attachEntry(plot, index)
		end
	end)
	if plot:FindFirstChild("House") then
		task.delay(1, function() attachEntry(plot, index) end)
	end
end

for index, plot in ipairs(plots:GetChildren()) do
	watch(plot, index)
end

plots.ChildAdded:Connect(function(plot)
	task.wait()
	watch(plot, #plots:GetChildren())
end)

print("Reliable house entry prompts loaded")