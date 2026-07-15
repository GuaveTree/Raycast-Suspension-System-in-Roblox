--!strict
local CarsModule = {}
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService") -- Coming soon
local workspace = game:GetService("Workspace")
local NormalCar = {
	MaxSpeed = 200,
	WheelRadius = 3,
	SuspensionMaxLength = 1,
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
export type mytype = {
	MaxSpeed: number,
	WheelRadius: number,
	SuspensionMaxLength: number,
	Wheels: {[string]: Vector3},
	CarBody: Part
}


function CarsModule.CreateNewCar(info): mytype
	local self = setmetatable({}, CarsModule)
	self.WheelRadius = info.WheelRadius
	self.MaxSpeed = info.MaxSpeed
	self.SuspensionMaxLength = info.SuspensionMaxLength
	self.CarBody = info.CarBody
	self.Wheels = info.Wheels
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

local function simulateSuspensionResponse(deltaTime: number, Wheels: {[string]: Vector3}, info: mytype)
	local SuspensionMaxLength: number = info.SuspensionMaxLength
	local WheelRadius: number = info.WheelRadius
	local Car: BasePart = info.CarBody
	-----------------------------------------------------
	local CarCFrame: CFrame = Car.CFrame
	local CarMass: number = Car.AssemblyMass
	local gravity: number = workS.Gravity
	local springStiffness: number = (CarMass * gravity) /4
	local dampingStiffness: number =  springStiffness /2

	-----------------------------------------------------

	--Main Loop! 🤗

	for WheelName: string, WheelOriginalPosition: Vector3 in pairs(Wheels) do
		---------------------------------------
		--RayCast Part😉
		local OriginPosition: Vector3 = CarCFrame:ToWorldSpace(CFrame.new(WheelOriginalPosition)).Position
		local RayDirection: Vector3 = -CarCFrame.UpVector * (SuspensionMaxLength + WheelRadius)
		-------------------------------------------------------------
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {Car, folder}
		------------------------------------------------------------
		local RayCast: RaycastResult? = workspace:Raycast(OriginPosition, RayDirection, raycastParams)
		VisualDebug(RayCast, OriginPosition, RayDirection, WheelName, info)
		------------------------------------------------------------
		if RayCast then
			--Physics Part 😎
			---------------------------------------------------------

			local CarVelocity = Car:GetVelocityAtPosition(OriginPosition)
			local UPVelocity: number = CarVelocity:Dot(CarCFrame.UpVector)
			local MaxHookForce = springStiffness * SuspensionMaxLength * 3
			local dampingForce: number = math.clamp((-UPVelocity * dampingStiffness), 0, MaxHookForce)

			---------------------------------------------------------

			local CurrentLength: number = math.clamp((RayCast.Distance - WheelRadius),0 ,SuspensionMaxLength)
			local SuspensionCompression: number = math.clamp(SuspensionMaxLength - CurrentLength , 0, SuspensionMaxLength)
			local springForce: number = (springStiffness * SuspensionCompression)

			---------------------------------------------------------

			local HookForce: number = math.clamp((springForce + dampingForce), 0, MaxHookForce)
			local MaxFriction = HookForce * 0.5

			---------------------------------------------------------

			local SideVelocity: number = CarVelocity:Dot(CarCFrame.RightVector)
			local TireGrip = CarMass * 5
			local NormalLateralFriction: number = -(SideVelocity * TireGrip)
			NormalLateralFriction = math.clamp(NormalLateralFriction, -MaxFriction, MaxFriction)

			---------------------------------------------------------

			local NetForce: Vector3 = (CarCFrame.UpVector * HookForce) + (CarCFrame.RightVector * NormalLateralFriction)
			local AppliedImpulse: Vector3 = (NetForce * deltaTime)
			Car:ApplyImpulseAtPosition(AppliedImpulse, OriginPosition)

			---------------------------------------------------------
		end
	end
end

function CarsModule.stepPhysics(info)
	RunService.Heartbeat:Connect(function(deltaTime)
		simulateSuspensionResponse(deltaTime, info.Wheels, info)
	end)
end

return CarsModule
