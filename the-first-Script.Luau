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
local WheelSuspensionLengtMemory = {}
local WheelRayCasts = {}

for name, OriginalPosition in pairs(Wheels) do
    WheelSuspensionLengtMemory[name] = 0.5
end
----------------------------------
local SuspensionMaxLengt = 1.3
local WheelRadius = 0.5
----------------------------------
local carCFrame:CFrame = car.CFrame
local params = RaycastParams.new()
params.FilterDescendantsInstances = {car, folder}
----------------------------------
local DebugMode = true

----------------------------------
function VisbalDebug (Raycast: RaycastResult,RayOrigin, RayDirection, WheelName)

    folder.Parent = game:GetService("ReplicatedStorage")
    folder.Name = "VisbalDebugPart"

    local Part  =  if not folder:FindFirstChild(WheelName) then Instance.new("Part") else folder:FindFirstChild(WheelName)
    Part.Name = WheelName
    Part.Parent = Workspace
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanTouch = false
    local currentLength = if Raycast then Raycast.Distance else RayDirection.Magnitude
    Part.Size = Vector3.new(0.2, 0.2, currentLength)
    Part.CFrame = CFrame.lookAt(RayOrigin, RayOrigin + RayDirection) * CFrame.new(0, 0, -currentLength / 2)

    if Raycast then
        Part.Color = Color3.fromRGB(0, 75, 180)
        else
        Part.Color = Color3.fromRGB(180, 75, 0)
    end

    task.delay(0.01, function()
        Part.Parent = folder
    end)
end


local function GetSuspensionLengt()
    carCFrame = car.CFrame
    
    for WheelName, OriginalPosition in pairs(Wheels) do

        local RayOrigin =  carCFrame:ToWorldSpace(CFrame.new(OriginalPosition)).Position
        local RayDirection = -carCFrame.UpVector * (SuspensionMaxLengt + WheelRadius)
        local RayCast = Workspace:Raycast(RayOrigin, RayDirection, params)
        if DebugMode then
            VisbalDebug(RayCast, RayOrigin, RayDirection, WheelName)
        end
        WheelRayCasts[WheelName] = RayCast
    end
    return WheelRayCasts
end






