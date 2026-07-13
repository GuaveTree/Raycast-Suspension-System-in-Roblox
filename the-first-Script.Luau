local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local car: Instance = game.Workspace:WaitForChild("Car")

local Wheels = {
    FR = Vector3.new(3,0,4),
    FL = Vector3.new(-3,0,4),
    BR = Vector3.new(3,0,-4),
    BL = Vector3.new(-3,0,-4)
}

local folder = game.ReplicatedStorage:FindFirstChild("VisbalDebugPart") or Instance.new("Folder")
folder.Parent = Workspace
folder.Name = "VisbalDebugPart"
local WheelSuspensionLengtMemory = {}
local WheelRayCasts = {}

for name, OriginalPosition in pairs(Wheels) do
    WheelSuspensionLengtMemory[name] = 0.5
end
----------------------------------
local SuspensionMaxLength = 1.3
local WheelRadius = 0.5
----------------------------------
local carCFrame:CFrame = car.CFrame
local params = RaycastParams.new()
params.FilterDescendantsInstances = {car, folder}
----------------------------------
local DebugMode = true
local springforce = 1500
local damping = 120
----------------------------------
function VisbalDebug (Raycast: RaycastResult,RayOrigin, RayDirection, WheelName)

    local Part  =  if not folder:FindFirstChild(WheelName) then Instance.new("Part") else folder:FindFirstChild(WheelName)
    Part.Name = WheelName
    Part.Parent = folder
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanTouch = false
    Part.CanQuery = false
    Part.Material = Enum.Material.Neon
    local currentLength = if Raycast then Raycast.Distance else RayDirection.Magnitude
    math.clamp(currentLength, 0, SuspensionMaxLength)
    Part.Size = Vector3.new(0.2, 0.2, currentLength)
    Part.CFrame = CFrame.lookAt(RayOrigin, RayOrigin + RayDirection) * CFrame.new(0, 0, -currentLength / 2)

    if Raycast then
        Part.Color = Color3.fromRGB(0, 75, 180)
        else
        Part.Color = Color3.fromRGB(180, 75, 0)
    end
end


local function GetAllForce(currentLength, WheelName, delatime)
    local spring = (SuspensionMaxLength - currentLength) * springforce
    local damp = ((WheelSuspensionLengtMemory[WheelName] - currentLength)/ delatime) * damping
    local totalForce = spring + damp
    WheelSuspensionLengtMemory[WheelName] = currentLength
    return totalForce
end


local function ForceApply(totalForce, deltatime , RayOrigin)
    if totalForce > 0 then
        local forceVector = carCFrame.UpVector * totalForce
        car:ApplyImpulseAtPosition(forceVector * deltatime, RayOrigin)
    end
end


local function GetSuspensionLengt(delatime)
    carCFrame = car.CFrame

    for WheelName, OriginalPosition in pairs(Wheels) do
       
        local RayOrigin =  carCFrame:ToWorldSpace(CFrame.new(OriginalPosition)).Position
        local RayDirection = -carCFrame.UpVector * (SuspensionMaxLength + WheelRadius)
        local RayCast = Workspace:Raycast(RayOrigin, RayDirection, params)
        if DebugMode then
            VisbalDebug(RayCast, RayOrigin, RayDirection, WheelName)
        end

            local currentLength = if RayCast then RayCast.Distance - WheelRadius else SuspensionMaxLength
            math.clamp(currentLength, 0, SuspensionMaxLength)
            local totalForce = GetAllForce(currentLength, WheelName, delatime)
            ForceApply(totalForce, delatime, RayOrigin)
    end
end




RunService.Heartbeat:Connect(function(deltaTime)
    GetSuspensionLengt(deltaTime)
end)

