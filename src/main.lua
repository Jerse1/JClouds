local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local TweenService = game:GetService("TweenService");

local Heartbeat = RunService.Heartbeat;

local Player = Players.LocalPlayer;

local JClouds = {};
JClouds.__index = JClouds;
local Clouds = {};

local Cloud = {};
Cloud.__index = Cloud;

function Cloud:Destroy(index)
	self.Object:Destroy();
	self.Appeared = false;
	self.Active = false;
	self = nil;
	Clouds[index] = nil;
end


local Character = Player.Character or Player.CharacterAdded:Wait();

local RootPart = Character:WaitForChild("HumanoidRootPart", 10);

Player.CharacterAdded:Connect(function(_Character)
	Character = _Character;

	RootPart = Character:WaitForChild("HumanoidRootPart", 10);
end)

local function Lerp(Start, Finish, Alpha)
	return Start + Alpha * (Finish - Start)
end

local function calculateDistance(point1 : Vector3, point2 : Vector3)
	local Distance = math.sqrt(
		(point1.X - point2.X)^2
			+
			(point1.Z - point2.Z)^2
	);

	return Distance;
end

function JClouds:getCloudsInDistance()
	local cloudsInDistance = 0;

	for _,Cloud in pairs(Clouds) do
		if Cloud.Appeared then 
			local Distance = calculateDistance(Cloud.Object.Position, RootPart.Position);

			if Distance < self.Range then
				cloudsInDistance += 1;
			end
		end
	end

	return cloudsInDistance;
end

local function generateObject(Parent)
	local Object;

	Object = Instance.new("Part");
	Object.Size = Vector3.new(math.random(10, 30), 2, math.random(10, 30));
	Object.Material = Enum.Material.Neon;
	Object.Massless = true;
	Object.CanCollide = false;
	Object.Anchored = true;
	Object.Transparency = 1;
	Object.Parent = workspace.Clouds;

	return Object;
end

function JClouds:updateTransparency()
	for Index, Cloud in pairs(Clouds) do
		local Distance = calculateDistance(Cloud.Object.Position, RootPart.Position);

		if Cloud.Active and self:getCloudsInDistance() > self.maximumClouds then
			Clouds[Index].Active = false;

			TweenService:Create(Clouds[Index].Object, TweenInfo.new(.5), {Transparency = 1}):Play();

			task.delay(1, function()
				Clouds[Index]:Destroy(Index);
				--Clouds[Index] = nil;
			end)
		end

	if Cloud.Active and (os.clock() - Cloud.appearanceTime) > (Cloud.Lifetime * 0.9) then
			Clouds[Index].Active = false;

			TweenService:Create(Clouds[Index].Object, TweenInfo.new(.5), {Transparency = 1}):Play();

			task.delay(1, function()
				Clouds[Index]:Destroy(Index);
			end)
		end
	end
end

function JClouds:updatePosition(deltaTime : number)
	for _, Cloud in pairs(Clouds) do  
		Cloud.Object.CFrame *= CFrame.new(0, 0, deltaTime * self.Speed);
	end
end

function JClouds:Update(deltaTime : number)

	if RootPart then
		self:updatePosition(deltaTime);
	end

	for Index, Cloud in pairs(Clouds) do
		if not Clouds[Index].Appeared then
			Clouds[Index].Object.Position = Vector3.new(RootPart.Position.X + math.random(-self.Range / 1.5, self.Range / 1.5), Cloud.Height, RootPart.Position.Z + math.random(-self.Range / 2, self.Range / 2));
			Clouds[Index].Object.Parent = self.Folder;

			TweenService:Create(Clouds[Index].Object, TweenInfo.new(1), {Transparency = Cloud.defaultTransparency}):Play();

			Clouds[Index].Appeared = true;

			Clouds[Index].appearanceTime = os.clock();
		end
	end

	local cloudsInDistance = self:getCloudsInDistance();
	
	if self:getCloudsInDistance() < self.maximumClouds and (os.clock() -  self.lastSpawn) > ((1/self.generationSpeed) * math.random(1, 20)/10) then
		self:GenerateClouds(1);
	end

	self:updateTransparency();
end

function JClouds:Start()
	local Folder = Instance.new("Folder");
	Folder.Name = "Clouds";
	Folder.Parent = workspace;

	self.Folder = Folder;

	self.transparentRange = self.Range * 2;

	self:GenerateClouds(2);

	self.Connection = Heartbeat:Connect(function(deltaTime)
		self:Update(deltaTime);
	end)
end

function JClouds:GenerateClouds(Amount : IntValue)
	for i = 1, Amount, 1 do

		local Height = self.defaultHeight + math.random(-self.heightRandomDifference, self.heightRandomDifference);

		local Cloud = setmetatable({
			Height = Height,
			defaultTransparency = 0.7,
			Lifetime = math.random(10, 30),
			appearanceTime = os.clock(),
			Object = generateObject(self.Folder),
			Appeared = false,
			Active = true,
		}, Cloud);

		table.insert(Clouds, Cloud);
	end

	self.lastSpawn = os.clock();
end

function JClouds.new(...)
	local Args = (...) or {};


	local Object = setmetatable({
		minimumClouds = Args.minimumClouds or 10,
		maximumClouds = Args.maximumClouds or 50,
		defaultHeight = Args.defaultHeight or 50,
		heightRandomDifference = Args.heightRandomDifference or 1,
		Speed = Args.Speed or 2.5,
		generationSpeed = Args.generationSpeed or 1,
		Range = Args.Range or 300,
		transparentRange = Args.transparentRange or 600,
	}, JClouds);

	return Object;
end

return JClouds;