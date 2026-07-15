local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local car: Instance = game.Workspace:WaitForChild("Car")

local Wheels = {
    FR = Vector3.new(3,0,4),
    FL = Vector3.new(-3,0,4),
    BR = Vector3.new(3,0,-4),
    BL = Vector3.new(-3,0,-4)
}

local folder = Workspace:FindFirstChild("VisbalDebugPart") or Instance.new("Folder")
folder.Parent = Workspace
folder.Name = "VisbalDebugPart"

--تعليق 

----------------------------------
local SuspensionMaxLength = 1.3
local WheelRadius = 0.5
----------------------------------
local carCFrame:CFrame = car.CFrame
local params = RaycastParams.new()
params.FilterDescendantsInstances = {car, folder}
params.FilterType = Enum.RaycastFilterType.Exclude
----------------------------------
local DebugMode = true
local gravity = Workspace.Gravity
local carMass = car.AssemblyMass
----------------------------------
local springStiffness = (carMass * gravity /4) * 2.5
local dampingStiffness = springStiffness /4
local lateral = 0.85
local downforce = carMass * 5
----------------------------------

pcall(function()
    car:SetNetworkOwner(nil)
end)

function VisualDebug (Raycast: RaycastResult?,RayOrigin, RayDirection, WheelName)

    local Part  =  if not folder:FindFirstChild(WheelName) then Instance.new("Part") else folder:FindFirstChild(WheelName)
    Part.Name = WheelName
    Part.Parent = folder
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanTouch = false
    Part.CanQuery = false
    Part.Material = Enum.Material.Neon
    local currentLength = if Raycast then Raycast.Distance else RayDirection.Magnitude
    currentLength = math.clamp(currentLength, 0, SuspensionMaxLength)
    Part.Size = Vector3.new(0.2, 0.2, currentLength)
    Part.CFrame = CFrame.lookAt(RayOrigin, RayOrigin + RayDirection) * CFrame.new(0, 0, -currentLength / 2)

    if Raycast then
        Part.Color = Color3.fromRGB(0, 75, 180)
        else
        Part.Color = Color3.fromRGB(180, 75, 0)
    end
end


local function GetAllForce(currentLength, WheelName, delatime, damping)
    local spring = (SuspensionMaxLength - currentLength) * springStiffness
    local totalForce = math.max(0, spring + damping)

    
    return totalForce
end

local function GetSuspensionLengt(delatime)
    carCFrame = car.CFrame

    for WheelName, OriginalPosition in pairs(Wheels) do

        local RayOrigin =  carCFrame:ToWorldSpace(CFrame.new(OriginalPosition)).Position
        local RayDirection = -carCFrame.UpVector * (SuspensionMaxLength + WheelRadius)
        local RayCast = Workspace:Raycast(RayOrigin, RayDirection, params)
        if DebugMode then
            VisualDebug(RayCast, RayOrigin, RayDirection, WheelName)
        end

        if RayCast then
             local currentLength = RayCast.Distance - WheelRadius
                currentLength = math.clamp(currentLength, 0, SuspensionMaxLength)
                local WheelUP = car:GetVelocityAtPosition(RayOrigin)
                local SuspensionUP = WheelUP:Dot(carCFrame.UpVector)
                local damp = -SuspensionUP * dampingStiffness

                local totalForce = GetAllForce(currentLength, WheelName, delatime, damp)

                local rigthtCar = carCFrame.RightVector
                local sid = WheelUP:Dot(rigthtCar)
                local Havy = (carMass/4) * 15
                local MaxfrictionForce = totalForce * lateral
                local frictionForce = -sid * Havy
                frictionForce = math.clamp(frictionForce, -MaxfrictionForce, MaxfrictionForce)
                local totalforceV = (carCFrame.UpVector * totalForce) + (rigthtCar * frictionForce)

                car:ApplyImpulseAtPosition(totalforceV * delatime, RayOrigin)
        end
    end
    car:ApplyImpulse(Vector3.new(0, downforce * delatime, 0))
end




RunService.Heartbeat:Connect(function(deltaTime)
    GetSuspensionLengt(deltaTime)
end)

