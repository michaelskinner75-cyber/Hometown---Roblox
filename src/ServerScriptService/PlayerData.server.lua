local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local cashStore = DataStoreService:GetDataStore("HometownCash_v1")
local AUTOSAVE_INTERVAL = 60
local MAX_RETRIES = 3

local loadedPlayers = {}
local savingPlayers = {}

local function getCash(player)
	local leaderstats = player:FindFirstChild("leaderstats") or player:WaitForChild("leaderstats", 15)
	if not leaderstats then
		return nil
	end
	return leaderstats:FindFirstChild("Cash") or leaderstats:WaitForChild("Cash", 15)
end

local function retry(callback)
	local lastError
	for attempt = 1, MAX_RETRIES do
		local success, result = pcall(callback)
		if success then
			return true, result
		end
		lastError = result
		task.wait(attempt * 2)
	end
	return false, lastError
end

local function loadPlayer(player)
	local cash = getCash(player)
	if not cash then
		warn("Hometown data: Cash value was not created for " .. player.Name)
		return
	end

	local key = "player_" .. player.UserId
	local success, savedCash = retry(function()
		return cashStore:GetAsync(key)
	end)

	if success then
		if typeof(savedCash) == "number" then
			cash.Value = math.max(0, math.floor(savedCash))
		end
		loadedPlayers[player] = true
	else
		warn("Hometown data: Failed to load " .. player.Name .. ": " .. tostring(savedCash))
	end
end

local function savePlayer(player)
	if not loadedPlayers[player] or savingPlayers[player] then
		return
	end

	local cash = getCash(player)
	if not cash then
		return
	end

	savingPlayers[player] = true
	local key = "player_" .. player.UserId
	local amount = math.max(0, math.floor(cash.Value))

	local success, err = retry(function()
		return cashStore:UpdateAsync(key, function()
			return amount
		end)
	end)

	if not success then
		warn("Hometown data: Failed to save " .. player.Name .. ": " .. tostring(err))
	end
	savingPlayers[player] = nil
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(loadPlayer, player)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	loadedPlayers[player] = nil
	savingPlayers[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(loadPlayer, player)
end

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(savePlayer, player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(savePlayer, player)
	end

	local deadline = os.clock() + 25
	while next(savingPlayers) and os.clock() < deadline do
		task.wait(0.1)
	end
end)
