local RunService = game:GetService("RunService");
local Player = game:GetService("Players");
local TweenService = game:GetService("TweenService");

local Heartbeat = RunService.Heartbeat;

local JClouds = {};
JClouds.__index = JClouds;
local Clouds = {};

local Cloud = {};
Cloud.__index = Cloud;

function Cloud:Destroy()
    self = nil;
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

local function generateObject()
    local Object;

    Object = Instance.new("Part");
    Object.Size = Vector3.new(5,2, 5);
    Object.Massless = true;
    Object.CanCollide = false;
    Object.Anchored = true;
    Object.Transparency = 1;

    return Object;
end

function JClouds:updateTransparency()
    for _, Cloud in ipairs(Clouds) do
        local Distance = calculateDistance(Cloud.Position, RootPart.Position);

        if Distance > self.Range then
            local LerpResult = Lerp(self.Range, self.transparentRange, Distance);

            --Cloud
        end
     end
end

function JClouds:updatePosition(deltaTime : number)
    for _, Cloud in ipairs(Clouds) do
       Cloud.CFrame *= CFrame.new(0, 0, deltaTime * self.Speed);
    end
end

function JClouds:Connection(deltaTime : number)

    if RootPart then
        self:updatePosition(deltaTime);
    end

    for _, Cloud in ipairs(Clouds) do
        if not Clouds.Appeared then
            Cloud.Position = Vector3.new(RootPart.Position.X, Cloud.Height, RootPart.Position.Z);
            Cloud.Parent = self.Folder;

            TweenService:Create(Cloud.Object, TweenInfo.new(1), {Transparency = Cloud.defaultTransparency}):Play();

            Cloud.Appeared = true;
        end
    end

    self:updateTransparency();
end

function JClouds:Start()
    local Folder = Instance.new("Folder");
    Folder.Name = "Clouds";
    Folder.Parent = workspace;

    self.Folder = Folder;

    self:GenerateClouds(50);

	Heartbeat:Connect(JClouds.Connection);
end

function JClouds:GenerateClouds(Amount : IntValue)
    for i = 1, Amount, 1 do
        local Object = generateObject();

        local Cloud = setmetatable(Cloud, {
            Height = self.defaultHeight + math.random(-self.heightRandomDifference, self.heightRandomDifference),
            defaultTransparency = 0.2,
            Lifetime = 10,
            appearanceTime = 0,
            Object = generateObject(),
            Appeared = false,
        });

        table.insert(Clouds, Cloud);
    end
end

function JClouds.new(...)
    local Args = (...);


	local Object = setmetatable(JClouds, {
        defaultHeight = Args.defaultHeight or 50,
        heightRandomDifference = Args.heightRandomDifference or 1,
        Speed = Args.Speed or 1,
        generationSpeed = Args.generationSpeed or 1,
        Range = Args.Range or 500,
        transparentRange = Args.transparentRange or 600,
    });
	
	return Object;
end

return JClouds;