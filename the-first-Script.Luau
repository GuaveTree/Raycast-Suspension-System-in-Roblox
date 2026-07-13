local Workspace = game:GetService("Workspace")
local car: Instance = game.Workspace:WaitForChild("Car")

local Wheels = {
    FR = Vector3.new(3,0,4),
    FL = Vector3.new(-3,0,4),
    BR = Vector3.new(3,0,-4),
    BL = Vector3.new(-3,0,-4)
}


local WheelSuspensionLengtMemory = {}
for name, OriginalPosition in pairs(Wheels) do
    WheelSuspensionLengtMemory[name] = 0.5
end
----------------------------------
local SuspensionMaxLengt = 1.3
local WheelRadius = 0.5
----------------------------------
local carCFrame:CFrame = car.CFrame
local params = RaycastParams.new()
params.FilterDescendantsInstances = {car}
----------------------------------
local DebugMode = true
----------------------------------
function VisbalDebug (Raycast: RaycastResult)
    local folder = game.ReplicatedStorage:FindFirstChild("VisbalDebugPart") or Instance.new("Folder")
    folder.Parent = game:GetService("ReplicatedStorage")
    folder.Name = "VisbalDebugPart"

    local Part  =  if not folder:FindFirstChild("Part") then Instance.new("Part") else folder:FindFirstChild("Part")
    Part.Parent = folder
    if Raycast then
        Part.Color = Color3.fromRGB(0, 75, 180)
        else
        Part.Color = Color3.fromRGB(180, 75, 0)
    end


end




local function GetSuspensionLengt()
    carCFrame = car.CFrame
    local WheelRayCasts = {}
    for WheelName, OriginalPosition in pairs(Wheels) do

        local RayOrigin =  carCFrame:ToWorldSpace(CFrame.new(OriginalPosition)).Position
        local RayDirection = -carCFrame.UpVector * (SuspensionMaxLengt + WheelRadius)
        local RayCast = Workspace:Raycast(RayOrigin, RayDirection, params)
        WheelRayCasts[WheelName] = RayCast
    end

    return WheelRayCasts
end

