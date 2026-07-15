--!strict
local CarsModule = {}
local workS = game:GetService("Workspace")
local NormalCar = {
    MaxSpeed = 200,
    WheelRadius = 1.3,
    SuspensionMaxLength = 1,
    Wheels = {
        FR = Vector3.new(3,0,4),
        FL = Vector3.new(-3,0,4),
        BR = Vector3.new(3,0,-4),
        BL = Vector3.new(-3,0,-4)
    },
    CarBody = workS:FindFirstChild("Car")
}
--------------------------------------------------
CarsModule.__index = CarsModule
setmetatable(CarsModule, {__index = NormalCar})
--------------------------------------------------
export type mytype = {
    MaxSpeed: number,
    WheelRadius: number,
    SuspensionMaxLength: number,
    Wheels: {[string]: Vector3},
    CarBody: Instance
}


function CarsModule.CreateNemCar(info): mytype
    local self = setmetatable({}, CarsModule)
    self.WheelRadius = info.WheelRadius
    self.MaxSpeed = info.MaxSpeed
    self.SuspensionMaxLength = info.SuspensionMaxLength
    self.CarBody = info.CarBody
    self.Wheels = info.Wheels
    return self
end


local function simulateSuspensionResponse(deltaTime: number, Wheels: {[string]: Vector3}, info: mytype)
    local SuspensionMaxLength: number = info.SuspensionMaxLength
    local WheelRadius: number = info.WheelRadius
    local Car: Instance = info.CarBody
    -----------------------------------------------------
    local CarCFrame = Car.CFrame
    local CarMass = Car.AssemblyMass
    local gravity = workS.Gravity
    local springStiffness: number = (CarMass * gravity) /4
    local dampingStiffness: number =  springStiffness /4
    -----------------------------------------------------

    --Main Loop! 🤗

    for WheelName, WheelOriginalPosition in pairs(Wheels) do
    ---------------------------------------
    --RayCast Part😉
    local OriginPosition = Car:ToWorldSpace(WheelOriginalPosition)
    local RayDirection = -CarCFrame.UpVector * (SuspensionMaxLength + WheelRadius)

    local RayCast = workS:Raycast(OriginPosition, RayDirection)
        if RayCast then
            local CarVelocity = Car:GetVelocityAtPosition(OriginPosition)

            local UPVelocity = CarVelocity:Dot(CarCFrame.UpVector)
            local dampingForce = (UPVelocity * dampingStiffness)
            ---------------------------------------------------------
            local CurrentLength = (RayCast.Distance - WheelRadius)
            local SuspensionCompression = (CurrentLength - SuspensionMaxLength)
            SuspensionCompression = math.clamp(CurrentLength, 0, SuspensionMaxLength)
            local springForce = (springStiffness * SuspensionCompression)
            ---------------------------------------------------------
            local HookForce = (springForce + dampingForce)
            




        end
    end
end












return CarsModule