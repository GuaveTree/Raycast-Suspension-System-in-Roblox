--!strict
local RunService = game:GetService("RunService")
local car = game.Workspace:WaitForChild("car") --عربيه واو


local wheels: {[string]: Vector3} = { -- العجل بنسبه للعربيه
	FR = Vector3.new(3, 0, 4),
	FL = Vector3.new(-3, 0, 4),
	RR = Vector3.new(3, 0, -4),
	RL = Vector3.new(-3, 0, -4)
}

local params: RaycastParams = RaycastParams.new()
params.FilterDescendantsInstances = {car}

-------------------------

local wheelmax: number = 1.25
local wheelredice: number = 0.3
local lastwheellong: {[string]: number} = {}
local debugMode: boolean = true
-------------------------
local calmbaby = 21
local spring = 32

-------------------------


for i, V in wheels do
	lastwheellong[i] = 0.5
end


local function visbleray(rayorigen: Vector3, raycast: RaycastResult?, direction: Vector3)

	local currentLength: number = if raycast then raycast.Distance else (wheelmax + wheelredice) 

	if not rayorigen or not direction then return end


	local part = Instance.new("Part")
	part.CanQuery = false
	part.CanTouch = false
	part.CanCollide = false
	part.Anchored = true

	part.Size = Vector3.new(0.1, 0.1, currentLength)
	part.CFrame = CFrame.lookAt(rayorigen, rayorigen + direction) * CFrame.new(0, 0, -currentLength / 2)
	part.Parent = workspace

	if not raycast then
		part.Color = Color3.fromRGB(85, 255, 255)
	else
		part.Color = Color3.fromRGB(85, 0, 255)
	end

	game.Debris:AddItem(part, 0.001) 
end

-- انا فاقد الشغف اخطر شئ لمبرمج 😒
--حابب افكر نفسي اني حاليا بسمع احمد النفيس متنساش تسمعو عشان ممتعصبش

local function result(deltatime: number):{[string]: number|Vector3|Instance}?
	local founds = {}
	for name, orginalpos in pairs(wheels) do 
		if not orginalpos then continue end


		local rayorigen = car.CFrame:ToWorldSpace(CFrame.new(orginalpos)).Position
		local direction = -car.CFrame.UpVector * (wheelmax + wheelredice)


		local raycast1 = workspace:Raycast(rayorigen, direction, params)




		if raycast1 then
			founds = {instance = raycast1.Instance,
				distance = raycast1.Distance,
				position = raycast1.Position,
				raycast = raycast1
			}
			lastwheellong[name] = raycast1.Distance
		end

		if debugMode then
			visbleray(rayorigen, raycast1, direction)
		end
	end
	return founds
end
-- بحب اشوف الوان مختلفه 🚩🚩🚩🚩🚩🚩
local function getforct(result, deltatime: number)
	if not result.raycast then return end
	--اهم شئ اغير الروتين بلون جديد غير المعفن بتاع الكود 🤗🤗🤗🤗🤗🤗😗😗😖😖😖🤯
	for name, orginalpos in wheels do

		local last = lastwheellong[name]
		if not last then continue end

		local dist: number =  result.Distance
		if not dist then return end 

		local currentlong: number = (dist - last)
		local Speed = currentlong  / deltatime

		local indagit = (last - wheelmax)
		local springforct = (indagit * spring)
		local tahmedforct = Speed * calmbaby
		local allforct = springforct * tahmedforct
		car:ApplyImpulse(car.CFrame:ToWorldSpace(CFrame.new(orginalpos)).Position)
	end
end

--التعليقات بتفصلني شويه عن الجو العفر ده 
RunService.Heartbeat:Connect(function(deltatime: number)
	local red = result(deltatime)
	getforct(red::any, deltatime)
end)


