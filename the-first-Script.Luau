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
-------------------------
for i, V in wheels do
	lastwheellong[i] = 0.5
end

while task.wait(0.3) do
	local deltatime = RunService.Heartbeat:Wait()
	
	for name, orginalpos in pairs(wheels) do
		local rayorigen = car.CFrame:ToWorldSpace(CFrame.new(orginalpos)).Position
		local dirction = -car.CFrame.UpVector * (wheelmax + wheelredice)
		local raycast = workspace:Raycast(rayorigen, dirction, params)
		
		if raycast then
			print("hit")
		end
		
		if debug then
			local sizeY = wheelmax + wheelredice
			
			if raycast then
				sizeY = (raycast.Position - rayorigen).Magnitude
			end
			
			local part = Instance.new("Part")
			part.CanQuery = false
			part.CanTouch= false
			part.Anchored = true
			
			part.Size = Vector3.new(0.1 , sizeY, 0.1)
			part.Position = Vector3.new(rayorigen.X,rayorigen.Y*0.5,rayorigen.Z)
			part.Parent = workspace
			
			
			if not raycast then
				part.Color = Color3.fromRGB(255, 0, 0)
			else
				part.Color = Color3.fromRGB(0, 170, 0)
			end
			game.Debris:AddItem(part, 0.3)
			
		end
	end	
end