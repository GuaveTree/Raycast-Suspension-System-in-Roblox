--!strict
local CarsModule = {}
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService") -- Coming soon
local workspace = game:GetService("Workspace")
local NormalCar = {
	MaxSpeed = 200,
	WheelRadius = 0.5,
	SuspensionMaxLength = 3,
	Wheels = {              --Noraml Car Wheels Positions
		FR = Vector3.new(3,0,4),
		FL = Vector3.new(-3,0,4),
		BR = Vector3.new(3,0,-4),
		BL = Vector3.new(-3,0,-4)
	},
	CarBody = workspace:FindFirstChild("Car")
}
--------------------------------------------------
CarsModule.__index = CarsModule
setmetatable(CarsModule, {__index = NormalCar})
--------------------------------------------------
local folder = workspace:FindFirstChild("VisbalDebugPart") or Instance.new("Folder")
folder.Parent = workspace
folder.Name = "VisbalDebugPart"
--------------------------------------------------
local gravity = workspace.Gravity
--------------------------------------------------
export type mytype = {
	MaxSpeed: number,
	WheelRadius: number,
	SuspensionMaxLength: number,
	Wheels: {[string]: Vector3},
	CarBody: Part,
    is_work: nil | thread
}


function CarsModule.CreateNewCar(info): mytype
	local self = setmetatable({}, CarsModule)
	self.WheelRadius = info.WheelRadius
	self.MaxSpeed = info.MaxSpeed
	self.SuspensionMaxLength = info.SuspensionMaxLength
	self.CarBody = info.CarBody
	self.Wheels = info.Wheels
    self.is_work = nil
	return self
end


function VisualDebug (Raycast: RaycastResult?,RayOrigin, RayDirection:Vector3, WheelName, info)
	local SuspensionMaxLength = info.SuspensionMaxLength
	local Part:Part  =  if not folder:FindFirstChild(WheelName) then Instance.new("Part") else folder:FindFirstChild(WheelName)::Part
	if not Part then
		return
	end
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


function simulateSuspensionResponse(info, daltatime)
    local Car = info.Body ::BasePart
    local CarMass: number = Car.AssemblyMass
    local Wheels: {[string]: Vector3} = info.Wheels
    ------------------------------------------------
    local SuspensionMaxLength: number = info.SuspensionMaxLength or 3
    local WheelRadius: number = info.WheelRadius or 1
    ------------------------------------------------
    local zipzipzip = 0.7
    local springStiffness = (CarMass * gravity) /4
    local dampingStiffness = math.sqrt(springStiffness * (CarMass /4)) * 2 * zipzipzip
    local MaxHookForce = (SuspensionMaxLength * springStiffness)
    local CarVelocity = Car:GetVelocityAtPosition()
    ------------------------------------------------
    for WheelName, WheelOriginal in pairs(Wheels) do
        local OriginPosition: Vector3 = Car.CFrame:ToWorldSpace(CFrame.new(WheelOriginal)).Position
        local RayDirection: Vector3 = -Car.CFrame.UpVector * (SuspensionMaxLength + WheelRadius)
        local RayPramas: RaycastParams = RaycastParams.new()
        RayPramas.FilterType = Enum.RaycastFilterType.Exclude
        RayPramas.FilterDescendantsInstances = {Car, folder}
        local Raycast: RaycastResult = workspace:Raycast(OriginPosition, RayDirection, RayPramas)

        if Raycast then
           local CarVelocity = Car:GetVelocityAtPosition(OriginPosition)
           local CurrentLength = math.clamp((Raycast.Distance - WheelRadius) - SuspensionMaxLength,0 , SuspensionMaxLength)
           local SpringForce = math.clamp(CurrentLength * springStiffness, 0, MaxHookForce)
           local dampingForce = math.clamp(CarVelocity:Dot(Raycast.Normal) * dampingStiffness, -MaxHookForce, MaxHookForce)
           local HookForce = math.clamp((SpringForce + dampingForce), 0, MaxHookForce)

        end
    end
end