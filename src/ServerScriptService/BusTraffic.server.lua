local TweenService = game:GetService("TweenService")

local world = workspace:WaitForChild("HometownWorld")
local plotsFolder = world:WaitForChild("Plots")

for _, object in ipairs(world:GetDescendants()) do
	if object:IsA("Model") then
		local n = string.lower(object.Name)
		if string.find(n,"car") or string.find(n,"traffic") or string.find(n,"vehicle") then
			object:Destroy()
		end
	end
end

local trafficFolder = world:FindFirstChild("BusTraffic") or Instance.new("Folder")
trafficFolder.Name = "BusTraffic"
trafficFolder.Parent = world
trafficFolder:ClearAllChildren()

local function makePart(parent,name,size,cf,colour,material,transparency)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cf
	p.Anchored=true
	p.CanCollide=false
	p.Color=colour
	p.Material=material or Enum.Material.SmoothPlastic
	p.Transparency=transparency or 0
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end

local function addText(part,text,face,textColour,bg)
	local gui=Instance.new("SurfaceGui")
	gui.Face=face
	gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud=45
	gui.Parent=part
	local label=Instance.new("TextLabel")
	label.Size=UDim2.fromScale(1,1)
	label.BackgroundColor3=bg or Color3.fromRGB(20,20,20)
	label.BackgroundTransparency=0.1
	label.TextColor3=textColour or Color3.fromRGB(255,210,60)
	label.Font=Enum.Font.GothamBold
	label.TextScaled=true
	label.Text=text
	label.Parent=gui
end

local function wheel(parent,cf)
	local tyre=makePart(parent,"Wheel",Vector3.new(1.3,3.1,3.1),cf,Color3.fromRGB(25,25,28),Enum.Material.Rubber)
	tyre.Shape=Enum.PartType.Cylinder
	local hub=makePart(parent,"WheelHub",Vector3.new(1.35,1.4,1.4),cf,Color3.fromRGB(155,160,165),Enum.Material.Metal)
	hub.Shape=Enum.PartType.Cylinder
end

local function buildBus(name,baseCf,route,destination,colour,doubleDeck)
	local model=Instance.new("Model")
	model.Name=name
	model.Parent=trafficFolder

	local length=34
	local width=9
	local lowerHeight=8
	local upperHeight=doubleDeck and 7 or 0
	local totalHeight=lowerHeight+upperHeight
	local chassis=makePart(model,"Chassis",Vector3.new(width,1.1,length),baseCf*CFrame.new(0,2.2,0),Color3.fromRGB(45,48,52),Enum.Material.Metal)
	model.PrimaryPart=chassis
	makePart(model,"LowerBody",Vector3.new(width,lowerHeight,length),baseCf*CFrame.new(0,6.4,0),colour,Enum.Material.SmoothPlastic)
	if doubleDeck then
		makePart(model,"UpperBody",Vector3.new(width,upperHeight,length-1),baseCf*CFrame.new(0,13.8,0),colour,Enum.Material.SmoothPlastic)
	end
	makePart(model,"Roof",Vector3.new(width+0.3,0.8,length+0.4),baseCf*CFrame.new(0,totalHeight+3,0),Color3.fromRGB(235,235,238),Enum.Material.Metal)

	local glass=Color3.fromRGB(40,78,100)
	local windowY=doubleDeck and {7.5,14.3} or {7.5}
	for _,y in ipairs(windowY) do
		for z=-11,11,5.5 do
			makePart(model,"SideWindow",Vector3.new(0.25,3.4,4.4),baseCf*CFrame.new(width/2+0.15,y,z),glass,Enum.Material.Glass,0.18)
			makePart(model,"SideWindow",Vector3.new(0.25,3.4,4.4),baseCf*CFrame.new(-width/2-0.15,y,z),glass,Enum.Material.Glass,0.18)
		end
	end

	local windscreen=makePart(model,"FrontWindscreen",Vector3.new(width-1,4.2,0.35),baseCf*CFrame.new(0,doubleDeck and 8.2 or 7.9,-length/2-0.18),glass,Enum.Material.Glass,0.15)
	local rearGlass=makePart(model,"RearWindow",Vector3.new(width-1.3,3.3,0.3),baseCf*CFrame.new(0,doubleDeck and 8 or 7.6,length/2+0.16),glass,Enum.Material.Glass,0.2)

	local display=makePart(model,"DestinationDisplay",Vector3.new(width-1.4,1.8,0.3),baseCf*CFrame.new(0,doubleDeck and 11.4 or 10.5,-length/2-0.38),Color3.fromRGB(15,15,15),Enum.Material.SmoothPlastic)
	addText(display,route.."  "..destination,Enum.NormalId.Front,Color3.fromRGB(255,195,45),Color3.fromRGB(12,12,12))

	local sideDisplay=makePart(model,"SideDisplay",Vector3.new(0.22,1.6,7),baseCf*CFrame.new(width/2+0.38,9.8,-4),Color3.fromRGB(15,15,15),Enum.Material.SmoothPlastic)
	addText(sideDisplay,route.."  "..destination,Enum.NormalId.Right,Color3.fromRGB(255,195,45),Color3.fromRGB(12,12,12))

	local doorColour=Color3.fromRGB(30,55,72)
	makePart(model,"FrontDoor",Vector3.new(0.3,6.3,3.6),baseCf*CFrame.new(width/2+0.28,5.8,-10.8),doorColour,Enum.Material.Glass,0.18)
	makePart(model,"MiddleDoor",Vector3.new(0.3,6.3,3.8),baseCf*CFrame.new(width/2+0.28,5.8,4.2),doorColour,Enum.Material.Glass,0.18)

	for _,z in ipairs({-10.5,10.5}) do
		wheel(model,baseCf*CFrame.new(width/2+0.65,2.6,z)*CFrame.Angles(0,0,math.rad(90)))
		wheel(model,baseCf*CFrame.new(-width/2-0.65,2.6,z)*CFrame.Angles(0,0,math.rad(90)))
	end

	for _,x in ipairs({-2.8,2.8}) do
		local lamp=makePart(model,"Headlight",Vector3.new(1.1,0.9,0.35),baseCf*CFrame.new(x,4,-length/2-0.42),Color3.fromRGB(255,245,205),Enum.Material.Neon)
		local light=Instance.new("SpotLight")
		light.Face=Enum.NormalId.Front
		light.Angle=55
		light.Range=26
		light.Brightness=1.5
		light.Parent=lamp
		makePart(model,"RearLight",Vector3.new(1,1.2,0.3),baseCf*CFrame.new(x,4,length/2+0.35),Color3.fromRGB(225,40,40),Enum.Material.Neon)
	end

	makePart(model,"Bumper",Vector3.new(width+0.2,0.8,0.8),baseCf*CFrame.new(0,2.5,-length/2-0.5),Color3.fromRGB(55,58,62),Enum.Material.Metal)
	makePart(model,"RearBumper",Vector3.new(width+0.2,0.8,0.8),baseCf*CFrame.new(0,2.5,length/2+0.5),Color3.fromRGB(55,58,62),Enum.Material.Metal)

	return model
end

local minX,maxX,minZ,maxZ=math.huge,-math.huge,math.huge,-math.huge
for _,plot in ipairs(plotsFolder:GetChildren()) do
	local ground=plot:FindFirstChild("Plot")
	if ground and ground:IsA("BasePart") then
		local p=ground.Position
		minX=math.min(minX,p.X); maxX=math.max(maxX,p.X)
		minZ=math.min(minZ,p.Z); maxZ=math.max(maxZ,p.Z)
	end
end
if minX==math.huge then minX,maxX,minZ,maxZ=-120,120,-80,80 end

local roadZ=(minZ+maxZ)/2
local startX=minX-55
local endX=maxX+55
local laneOffsets={-7,0,7}
local buses={
	{route="7",dest="Town Centre",colour=Color3.fromRGB(220,35,42),doubleDeck=true},
	{route="X24",dest="City Express",colour=Color3.fromRGB(35,95,185),doubleDeck=true},
	{route="39",dest="Hometown",colour=Color3.fromRGB(55,155,85),doubleDeck=false},
}

for i,data in ipairs(buses) do
	local z=roadZ+laneOffsets[i]
	local from=CFrame.new(startX,0,z)*CFrame.Angles(0,math.rad(90),0)
	local bus=buildBus("Service"..data.route,from,data.route,data.dest,data.colour,data.doubleDeck)
	task.spawn(function()
		task.wait((i-1)*5)
		while bus.Parent do
			bus:PivotTo(CFrame.new(startX,0,z)*CFrame.Angles(0,math.rad(90),0))
			local driver=Instance.new("CFrameValue")
			driver.Value=bus:GetPivot()
			local connection=driver:GetPropertyChangedSignal("Value"):Connect(function() if bus.Parent then bus:PivotTo(driver.Value) end end)
			local target=CFrame.new(endX,0,z)*CFrame.Angles(0,math.rad(90),0)
			local tween=TweenService:Create(driver,TweenInfo.new(26+i*2,Enum.EasingStyle.Linear),{Value=target})
			tween:Play(); tween.Completed:Wait(); connection:Disconnect(); driver:Destroy()
			task.wait(2)
		end
	end)
end

print("Detailed bus-only traffic loaded")