local RunService = game:GetService("RunService");
local Player = game:GetService("Players");

local Heartbeat = RunService.Heartbeat;

local JClouds = {};
JClouds.__index = JClouds;

local Cloud = {};
Cloud.__index = Cloud;

local Clouds = {};

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

    Object = Instance.new("Part")

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

    self:updateTransparency();
end

function JClouds:Start()
	Heartbeat:Connect(JClouds.Connection);
end

function JClouds:GenerateClouds(Amount : IntValue)
    for i = 1, Amount, 1 do
        local Object = generateObject();

        local Cloud = setmetatable(Cloud, {
            defaultTransparency = 0.6,
            Lifetime = 5,
            Object = generateObject(),
            Appeared = false,
        });

        table.insert(Clouds, Cloud);
    end
end

function JClouds.new(...)
    local Args = (...);


	local Object = setmetatable(JClouds, {
        Speed = Args.Speed or 1,
        generationSpeed = Args.generationSpeed or 1,
        Range = Args.Range or 500,
        transparentRange = Args.transparentRange or 600,
    });
	
	return Object;
end

return JClouds;