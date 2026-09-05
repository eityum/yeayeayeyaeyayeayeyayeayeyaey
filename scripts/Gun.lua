-- Block Gun NUKE - E to shoot 4, F to NUKE (all blocks at once)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local mouse = Players.LocalPlayer:GetMouse()

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local ammoBlocks = {}
local maxAmmo = 10000
local shootSpeed = 1000
local reloading = false
local dumping = false

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlockGun"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 90)
mainFrame.Position = UDim2.new(0, 10, 0.8, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 22)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextColor3 = Color3.fromRGB(255, 150, 50)
title.Text = "BLOCK NUKE [E:Shoot F:NUKE R:Reload]"
title.Font = Enum.Font.GothamBold
title.TextSize = 9
title.BorderSizePixel = 0
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local ammoLabel = Instance.new("TextLabel")
ammoLabel.Size = UDim2.new(1, 0, 0, 22)
ammoLabel.Position = UDim2.new(0, 0, 0, 28)
ammoLabel.BackgroundTransparency = 1
ammoLabel.Text = "Ammo: 0 / " .. maxAmmo
ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoLabel.TextSize = 12
ammoLabel.Font = Enum.Font.GothamBold
ammoLabel.Parent = mainFrame

local reloadLabel = Instance.new("TextLabel")
reloadLabel.Size = UDim2.new(1, 0, 0, 18)
reloadLabel.Position = UDim2.new(0, 0, 0, 52)
reloadLabel.BackgroundTransparency = 1
reloadLabel.Text = "Hold R to reload | F = NUKE ALL"
reloadLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
reloadLabel.TextSize = 8
reloadLabel.Font = Enum.Font.Gotham
reloadLabel.Parent = mainFrame

-- Free floating check
local function isFreeFloating(part)
	if not part or not part.Parent then return false end
	if not part:IsA("BasePart") then return false end
	if part.Anchored then return false end
	local joints = part:GetJoints()
	for _ in pairs(joints) do return false end
	for _, child in pairs(part:GetChildren()) do
		if child:IsA("JointInstance") or child:IsA("Constraint") or child:IsA("Attachment") then return false end
	end
	local ancestor = part.Parent
	while ancestor do
		if ancestor:IsA("BasePart") and ancestor.Anchored then return false end
		if ancestor:IsA("Tool") or ancestor:IsA("HopperBin") then return false end
		if ancestor == Workspace then break end
		ancestor = ancestor.Parent
	end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character and part:IsDescendantOf(plr.Character) then return false end
	end
	return true
end

-- Reload
local function reload()
	if reloading then return end
	reloading = true
	reloadLabel.Text = "RELOADING..."
	reloadLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
	
	for _, block in pairs(ammoBlocks) do
		if block and block.Parent then
			block.Velocity = Vector3.zero
			block.CanCollide = true
		end
	end
	table.clear(ammoBlocks)
	
	local foundParts = {}
	for _, part in pairs(Workspace:GetDescendants()) do
		if isFreeFloating(part) and part.Transparency < 0.5 and not part:IsDescendantOf(character) then
			local dist = (part.Position - root.Position).Magnitude
			if dist < 300 then table.insert(foundParts, {part = part, dist = dist}) end
		end
	end
	table.sort(foundParts, function(a, b) return a.dist < b.dist end)
	
	for i = 1, math.min(maxAmmo, #foundParts) do
		table.insert(ammoBlocks, foundParts[i].part)
	end
	
	ammoLabel.Text = "Ammo: " .. #ammoBlocks .. " / " .. maxAmmo
	reloadLabel.Text = "Hold R to reload | F = NUKE ALL"
	reloadLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	reloading = false
end

-- Shoot 4 blocks
local function shoot()
	if #ammoBlocks == 0 then return end
	
	local blocksToFire = math.min(4, #ammoBlocks)
	
	for i = 1, blocksToFire do
		local block = table.remove(ammoBlocks, 1)
		if not block or not block.Parent then break end
		
		block.Velocity = Vector3.zero
		block.RotVelocity = Vector3.zero
		for _, v in pairs(block:GetChildren()) do
			if v:IsA("BodyMover") then v:Destroy() end
		end
		block.CanCollide = true
		block.Anchored = false
		
		local spreadX = (math.random() - 0.5) * 2
		local spreadY = (math.random() - 0.5) * 2
		local shootPos = root.Position + root.CFrame.LookVector * 3 + Vector3.new(spreadX, 1 + spreadY, 0)
		block.CFrame = CFrame.new(shootPos)
		
		local targetPos = mouse.Hit.Position + Vector3.new(spreadX * 2, spreadY * 2, 0)
		local direction = (targetPos - shootPos).Unit
		
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = direction * shootSpeed
		bv.Parent = block
		
		local av = Instance.new("BodyAngularVelocity")
		av.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		av.AngularVelocity = Vector3.new(500, 500, 500)
		av.Parent = block
		
		task.delay(3, function()
			if bv and bv.Parent then bv:Destroy() end
			if av and av.Parent then av:Destroy() end
		end)
	end
	
	ammoLabel.Text = "Ammo: " .. #ammoBlocks .. " / " .. maxAmmo
end

-- NUKE - Fire ALL remaining blocks at once
local function nuke()
	if dumping then return end
	if #ammoBlocks == 0 then return end
	dumping = true
	reloadLabel.Text = "☢️ NUKE INCOMING ☢️"
	reloadLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	
	local totalBlocks = #ammoBlocks
	
	for i = 1, totalBlocks do
		local block = table.remove(ammoBlocks, 1)
		if block and block.Parent then
			block.Velocity = Vector3.zero
			block.RotVelocity = Vector3.zero
			for _, v in pairs(block:GetChildren()) do
				if v:IsA("BodyMover") then v:Destroy() end
			end
			block.CanCollide = true
			block.Anchored = false
			
			-- Spread in a cone
			local spreadX = (math.random() - 0.5) * 20
			local spreadY = (math.random() - 0.5) * 20
			local spreadZ = math.random() * 10
			local shootPos = root.Position + root.CFrame.LookVector * 3 + root.CFrame.RightVector * spreadX + root.CFrame.UpVector * spreadY
			block.CFrame = CFrame.new(shootPos)
			
			local targetPos = mouse.Hit.Position + Vector3.new(spreadX * 3, spreadY * 3, spreadZ * 3)
			local direction = (targetPos - shootPos).Unit
			
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Velocity = direction * (shootSpeed + math.random() * 200)
			bv.Parent = block
			
			local av = Instance.new("BodyAngularVelocity")
			av.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			av.AngularVelocity = Vector3.new(math.random() * 1000, math.random() * 1000, math.random() * 1000)
			av.Parent = block
			
			task.delay(3, function()
				if bv and bv.Parent then bv:Destroy() end
				if av and av.Parent then av:Destroy() end
			end)
		end
	end
	
	ammoLabel.Text = "Ammo: 0 / " .. maxAmmo
	reloadLabel.Text = "☢️ NUKED " .. totalBlocks .. " BLOCKS ☢️"
	reloadLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	
	task.delay(2, function()
		dumping = false
		reloadLabel.Text = "Hold R to reload | F = NUKE ALL"
		reloadLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end)
end

-- Keyboard
local rHeld = false

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.E then
		shoot()
	elseif input.KeyCode == Enum.KeyCode.F then
		nuke()
	elseif input.KeyCode == Enum.KeyCode.R then
		rHeld = true
		reload()
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.R then
		rHeld = false
	end
end)

spawn(function()
	while true do
		if rHeld and not reloading then
			reload()
		end
		task.wait(0.1)
	end
end)

spawn(function()
	while true do
		if not reloading and not dumping then
			ammoLabel.Text = "Ammo: " .. #ammoBlocks .. " / " .. maxAmmo
		end
		task.wait(0.5)
	end
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
	screenGui.Parent = player:WaitForChild("PlayerGui")
	for _, block in pairs(ammoBlocks) do
		if block and block.Parent then
			block.Velocity = Vector3.zero
			block.CanCollide = true
		end
	end
	table.clear(ammoBlocks)
end)