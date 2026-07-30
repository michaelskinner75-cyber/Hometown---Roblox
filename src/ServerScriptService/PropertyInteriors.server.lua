local Players = game:GetService("Players")

local world = workspace:WaitForChild("HometownWorld")
local plots = world:WaitForChild("Plots")

local interiors = Instance.new("Folder")
interiors.Name = "PropertyInteriors"
interiors.Parent = world

local UPGRADE_LEVELS = {
	[1] = {Name="Fresh Decoration", Cost=900, Value=1400, Rent=100},
	[2] = {Name="New Kitchen", Cost=1800, Value=2800, Rent=200},
	[3] = {Name="Luxury Finish", Cost=3200, Value=5000, Rent=350},
}

local function money(value)
	local text=tostring(math.floor(value or 0))
	while true do
		local updated,count=text:gsub("^(-?%d+)(%d%d%d)","%1,%2")
		text=updated
		if count==0 then break end
	end
	return "£"..text
end

local function makePart(name,size,cframe,colour,material,parent,collide)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cframe
	p.Color=colour
	p.Material=material or Enum.Material.SmoothPlastic
	p.Anchored=true
	p.CanCollide=collide~=false
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end

local function addPrompt(parent,action,object)
	local prompt=Instance.new("ProximityPrompt")
	prompt.ActionText=action
	prompt.ObjectText=object
	prompt.HoldDuration=0.4
	prompt.MaxActivationDistance=12
	prompt.RequiresLineOfSight=false
	prompt.Parent=parent
	return prompt
end

local function getCash(player)
	local stats=player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

local function teleport(player,cframe)
	local character=player.Character
	if character and character.PrimaryPart then character:PivotTo(cframe) end
end

local function decorateInterior(model,origin,level)
	for _,item in ipairs(model:GetChildren()) do
		if item:GetAttribute("UpgradeDecoration") then item:Destroy() end
	end
	local function decor(name,size,offset,colour,material)
		local p=makePart(name,size,origin*CFrame.new(offset),colour,material,model,true)
		p:SetAttribute("UpgradeDecoration",true)
		return p
	end
	decor("Sofa",Vector3.new(7,2.4,3),Vector3.new(-7,2,-7),level>=1 and Color3.fromRGB(60,110,155) or Color3.fromRGB(115,95,80),Enum.Material.Fabric)
	decor("CoffeeTable",Vector3.new(4,1,2.5),Vector3.new(-7,1,-2),Color3.fromRGB(120,80,48),Enum.Material.Wood)
	decor("Television",Vector3.new(0.5,4,7),Vector3.new(-14,4,-7),Color3.fromRGB(25,25,28),Enum.Material.SmoothPlastic)
	decor("Bed",Vector3.new(8,2,6),Vector3.new(8,1.5,7),level>=1 and Color3.fromRGB(225,225,235) or Color3.fromRGB(190,185,175),Enum.Material.Fabric)
	if level>=2 then
		decor("KitchenCounter",Vector3.new(12,3,2.5),Vector3.new(7,1.8,-10),Color3.fromRGB(235,235,230),Enum.Material.Marble)
		decor("KitchenIsland",Vector3.new(6,3,3),Vector3.new(7,1.8,-4),Color3.fromRGB(205,205,200),Enum.Material.Marble)
	end
	if level>=3 then
		decor("FeatureWall",Vector3.new(0.4,9,12),Vector3.new(-15,4.5,5),Color3.fromRGB(72,72,78),Enum.Material.Slate)
		decor("LuxuryRug",Vector3.new(10,0.2,7),Vector3.new(-5,0.65,2),Color3.fromRGB(180,145,80),Enum.Material.Fabric)
	end
end

local function buildInterior(plot,index)
	if plot:FindFirstChild("InteriorReady") then return end
	local marker=Instance.new("BoolValue")
	marker.Name="InteriorReady"
	marker.Parent=plot

	local house=plot:FindFirstChild("House")
	if not house then marker:Destroy(); return end

	local room=Instance.new("Model")
	room.Name=plot.Name.."Interior"
	room.Parent=interiors
	local origin=CFrame.new((index-1)*90-315,505,0)
	room:SetAttribute("PlotName",plot.Name)

	makePart("Floor",Vector3.new(34,1,30),origin,Color3.fromRGB(170,135,95),Enum.Material.WoodPlanks,room,true)
	makePart("Ceiling",Vector3.new(34,1,30),origin*CFrame.new(0,10,0),Color3.fromRGB(245,245,240),Enum.Material.SmoothPlastic,room,true)
	makePart("BackWall",Vector3.new(34,10,1),origin*CFrame.new(0,5,15),Color3.fromRGB(230,225,212),Enum.Material.Plaster,room,true)
	makePart("LeftWall",Vector3.new(1,10,30),origin*CFrame.new(-17,5,0),Color3.fromRGB(230,225,212),Enum.Material.Plaster,room,true)
	makePart("RightWall",Vector3.new(1,10,30),origin*CFrame.new(17,5,0),Color3.fromRGB(230,225,212),Enum.Material.Plaster,room,true)
	makePart("Divider",Vector3.new(1,9,14),origin*CFrame.new(2,4.5,8),Color3.fromRGB(230,225,212),Enum.Material.Plaster,room,true)

	local exitPad=makePart("ExitPad",Vector3.new(5,0.4,5),origin*CFrame.new(0,0.8,-12),Color3.fromRGB(70,150,95),Enum.Material.Neon,room,false)
	local exitPrompt=addPrompt(exitPad,"Leave House","Front Door")
	exitPrompt.Triggered:Connect(function(player)
		local front=plot:GetAttribute("FrontDirection") or -1
		teleport(player,CFrame.new(plot.Plot.Position+Vector3.new(0,4,front*38)))
	end)

	local upgradePad=makePart("UpgradeDesk",Vector3.new(6,3,3),origin*CFrame.new(12,1.8,-10),Color3.fromRGB(55,95,70),Enum.Material.Wood,room,true)
	local upgradePrompt=addPrompt(upgradePad,"Upgrade Property","Renovation Desk")

	local board=makePart("UpgradeBoard",Vector3.new(8,5,0.4),origin*CFrame.new(12,5,-11.7),Color3.fromRGB(245,245,235),Enum.Material.SmoothPlastic,room,false)
	local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.Parent=board
	local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.TextColor3=Color3.fromRGB(35,85,55); label.Font=Enum.Font.GothamBold; label.TextScaled=true; label.TextWrapped=true; label.Parent=gui

	local function refresh()
		local level=plot:GetAttribute("UpgradeLevel") or 0
		local nextInfo=UPGRADE_LEVELS[level+1]
		if nextInfo then
			label.Text="LEVEL "..level.."\nNEXT: "..nextInfo.Name.."\n"..money(nextInfo.Cost)
			upgradePrompt.ActionText="Buy "..nextInfo.Name.." "..money(nextInfo.Cost)
		else
			label.Text="LEVEL 3\nFULLY UPGRADED\nMAXIMUM VALUE"
			upgradePrompt.ActionText="Fully Upgraded"
		end
		decorateInterior(room,origin,level)
	end

	upgradePrompt.Triggered:Connect(function(player)
		if plot:GetAttribute("OwnerUserId")~=player.UserId then return end
		local level=plot:GetAttribute("UpgradeLevel") or 0
		local info=UPGRADE_LEVELS[level+1]
		if not info then return end
		local cash=getCash(player)
		if not cash or cash.Value<info.Cost then return end
		cash.Value-=info.Cost
		plot:SetAttribute("UpgradeLevel",level+1)
		house:SetAttribute("SalePrice",(house:GetAttribute("SalePrice") or 0)+info.Value)
		house:SetAttribute("Rent",(house:GetAttribute("Rent") or 0)+info.Rent)
		refresh()
	end)

	local door=house:FindFirstChild("Door") or house:FindFirstChild("CottageDoor") or house:FindFirstChild("ModernDoor")
	if door then
		local enterPrompt=addPrompt(door,"Enter House","Property Interior")
		enterPrompt.Triggered:Connect(function(player)
			if plot:GetAttribute("OwnerUserId")~=player.UserId then return end
			teleport(player,origin*CFrame.new(0,3,-9))
		end)
	end
	refresh()
end

local function watchPlot(plot,index)
	plot.ChildAdded:Connect(function(child)
		if child.Name=="House" then
			task.wait(0.5)
			buildInterior(plot,index)
		end
	end)
	if plot:FindFirstChild("House") then buildInterior(plot,index) end
end

for index,plot in ipairs(plots:GetChildren()) do watchPlot(plot,index) end
plots.ChildAdded:Connect(function(plot)
	task.wait()
	watchPlot(plot,#plots:GetChildren())
end)

print("Enterable property interiors and renovation upgrades loaded")