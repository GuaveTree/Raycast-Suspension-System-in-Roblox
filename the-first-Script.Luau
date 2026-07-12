local RunService = game:GetService("RunService")
local car = game.Workspace:FindFirstChild("car")

local wheels = {
	FR = Vector3.new(3,0,4),
	FL = Vector3.new(-3,0,4),
	RR = Vector3.new(3,0,-4),
	RL = Vector3.new(-3,0,-4)
}
local params = RaycastParams.new()
params.FilterDescendantsInstances = {car}

-------------------------
local wheelmax = 1.25
local wheelredice = 0.3
local lastwheellong = {}
local debug = true
local currentLength 
-------------------------
for i, V in wheels do
	lastwheellong[i] = 0.5
end

game:GetService("RunService").Heartbeat:Connect(function(deltatime)
	
	
	for name, orginalpos in pairs(wheels) do
		local rayorigen = car.CFrame:ToWorldSpace(CFrame.new(orginalpos)).Position
		local dirction = -car.CFrame.UpVector * (wheelmax + wheelredice)
		local raycast = workspace:Raycast(rayorigen, dirction, params)
		local direction = -car.CFrame.UpVector * (wheelmax + wheelredice)
		if raycast then
			print("hit")
		end
		
		if debug then
			
			
			if raycast then
				currentLength = raycast.Distance
				
			end
			
			
			local part = Instance.new("Part")
			part.CanQuery = false
			part.CanTouch= false
			part.CanCollide = false
			part.Anchored = true
			
			part.Size = Vector3.new(0.1, 0.1, currentLength)
			part.CFrame = CFrame.lookAt(rayorigen, rayorigen + direction) * CFrame.new(0, 0, -currentLength/2)
			part.Parent = workspace
			
			
			if not raycast then
				part.Color = Color3.fromRGB(255, 0, 0)
			else
				part.Color = Color3.fromRGB(0, 170, 0)
			end
			game.Debris:AddItem(part, deltatime)
			
		end
	end	
end)



	
