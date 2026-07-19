-- Mech Controller - Move/Turn Buttons + Emotes (Hi/Dance/Sit/Offer) + Straight + Keyboard + Spawner
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local mouse = Players.LocalPlayer:GetMouse()

local mechParts, mechActive, mechConnection, mechCFrame = {}, false, nil, CFrame.new()
local moveSpeed, rotSpeed = 30, math.rad(90)
local activeDirs = {Forward = 0, Backward = 0, Left = 0, Right = 0, Up = 0, Down = 0}
local isRotLeft, isRotRight, walkCycle, isMoving = false, false, 0, false
local keyboardActive, pointRArm, pointLArm = false, false, false
local emoteActive, emoteType, emoteTime = false, nil, 0
local spawnActive, spawnConn = false, nil

-- GUI
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "MechController"; sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mf = Instance.new("Frame", sg)
mf.Size = UDim2.new(0, 250, 0, 320); mf.Position = UDim2.new(0.5, -125, 0.5, -160)
mf.BackgroundColor3 = Color3.fromRGB(15, 15, 15); mf.BorderSizePixel = 0
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)

local function btn(t, x, y, w, h, c, p)
	local b = Instance.new("TextButton", p or mf)
	b.Size = UDim2.new(0, w, 0, h); b.Position = UDim2.new(0, x, 0, y); b.BackgroundColor3 = c
	b.Text = t; b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.BorderSizePixel = 0
	b.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end

-- Title
local tb = btn("MECH (drag)", 0, 0, 250, 28, Color3.fromRGB(25, 25, 25), mf)
tb.AutoButtonColor = false; tb.TextColor3 = Color3.fromRGB(255, 150, 50)

local drag, dStart, sPos = false, nil, nil
tb.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag = true; dStart = i.Position; sPos = mf.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if not drag then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local d = i.Position - dStart
		mf.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

-- Row 1: Actions
local assembleBtn = btn("ASSEMBLE", 5, 33, 75, 26, Color3.fromRGB(50, 200, 50))
local disBtn = btn("DISASSEMBLE", 85, 33, 75, 26, Color3.fromRGB(255, 80, 80))
local straightBtn = btn("STRAIGHT", 165, 33, 75, 26, Color3.fromRGB(200, 100, 255))

-- Row 2: Emotes
local hiBtn = btn("HI", 5, 64, 45, 26, Color3.fromRGB(255, 200, 50)); hiBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
local danceBtn = btn("DANCE", 55, 64, 50, 26, Color3.fromRGB(255, 100, 255))
local sitBtn = btn("SIT", 110, 64, 45, 26, Color3.fromRGB(150, 100, 50))
local offerBtn = btn("OFFER", 160, 64, 50, 26, Color3.fromRGB(255, 150, 100))
local stopBtn = btn("STOP", 215, 64, 30, 26, Color3.fromRGB(255, 80, 80))

-- Row 3: Keyboard
local kbdBtn = btn("KEYBOARD: OFF", 5, 95, 240, 26, Color3.fromRGB(100, 100, 100))

-- Row 4: Move buttons
local function dirBtn(t, x, y, c, dir)
	local b = btn(t, x, y, 40, 30, c)
	b.MouseButton1Down:Connect(function() activeDirs[dir] = 1; b.BackgroundColor3 = Color3.fromRGB(255, 255, 100) end)
	b.MouseButton1Up:Connect(function() activeDirs[dir] = 0; b.BackgroundColor3 = c end)
	b.MouseLeave:Connect(function() activeDirs[dir] = 0; b.BackgroundColor3 = c end)
end
dirBtn("↑", 105, 126, Color3.fromRGB(255, 200, 50), "Forward"); dirBtn("↓", 105, 160, Color3.fromRGB(255, 200, 50), "Backward")
dirBtn("←", 60, 143, Color3.fromRGB(255, 100, 100), "Left"); dirBtn("→", 150, 143, Color3.fromRGB(255, 100, 100), "Right")
dirBtn("⇧", 195, 126, Color3.fromRGB(100, 200, 255), "Up"); dirBtn("⇩", 195, 160, Color3.fromRGB(100, 200, 255), "Down")

-- Turn buttons
local rotLBtn = btn("↺", 5, 143, 40, 30, Color3.fromRGB(200, 150, 255))
rotLBtn.MouseButton1Down:Connect(function() isRotLeft = true; rotLBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 100) end)
rotLBtn.MouseButton1Up:Connect(function() isRotLeft = false; rotLBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 255) end)
rotLBtn.MouseLeave:Connect(function() isRotLeft = false; rotLBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 255) end)

local rotRBtn = btn("↻", 5, 178, 40, 30, Color3.fromRGB(200, 150, 255))
rotRBtn.MouseButton1Down:Connect(function() isRotRight = true; rotRBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 100) end)
rotRBtn.MouseButton1Up:Connect(function() isRotRight = false; rotRBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 255) end)
rotRBtn.MouseLeave:Connect(function() isRotRight = false; rotRBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 255) end)

-- Row 5: Spawner
local bIdLabel = Instance.new("TextLabel", mf)
bIdLabel.Size = UDim2.new(0, 55, 0, 18); bIdLabel.Position = UDim2.new(0, 5, 0, 218)
bIdLabel.BackgroundTransparency = 1; bIdLabel.Text = "Block ID:"; bIdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
bIdLabel.TextSize = 9; bIdLabel.Font = Enum.Font.Gotham; bIdLabel.TextXAlignment = Enum.TextXAlignment.Left

local bIdBox = Instance.new("TextBox", mf)
bIdBox.Size = UDim2.new(0, 70, 0, 20); bIdBox.Position = UDim2.new(0, 60, 0, 217)
bIdBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
bIdBox.Text = "56450668"; bIdBox.Font = Enum.Font.Gotham; bIdBox.TextSize = 10; bIdBox.BorderSizePixel = 0
Instance.new("UICorner", bIdBox).CornerRadius = UDim.new(0, 4)

local spawnBtn = btn("SPAWN", 135, 216, 80, 22, Color3.fromRGB(100, 150, 255))

-- Row 6: Speed
local sLabel = Instance.new("TextLabel", mf)
sLabel.Size = UDim2.new(0, 80, 0, 18); sLabel.Position = UDim2.new(0, 5, 0, 248)
sLabel.BackgroundTransparency = 1; sLabel.Text = "Speed: 30"; sLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sLabel.TextSize = 10; sLabel.Font = Enum.Font.GothamBold; sLabel.TextXAlignment = Enum.TextXAlignment.Left

local sBox = Instance.new("TextBox", mf)
sBox.Size = UDim2.new(0, 50, 0, 20); sBox.Position = UDim2.new(0, 85, 0, 247)
sBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sBox.TextColor3 = Color3.fromRGB(255, 255, 255)
sBox.Text = "30"; sBox.Font = Enum.Font.Gotham; sBox.TextSize = 10; sBox.BorderSizePixel = 0
Instance.new("UICorner", sBox).CornerRadius = UDim.new(0, 4)

local sApply = btn("SET", 140, 246, 40, 22, Color3.fromRGB(100, 200, 100))
sApply.MouseButton1Click:Connect(function() local n = tonumber(sBox.Text); if n and n > 0 then moveSpeed = n; sLabel.Text = "Speed: " .. n end end)

local statusLabel = Instance.new("TextLabel", mf)
statusLabel.Size = UDim2.new(1, 0, 0, 18); statusLabel.Position = UDim2.new(0, 0, 0, 275)
statusLabel.BackgroundTransparency = 1; statusLabel.Text = "Mech: Off"; statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 9; statusLabel.Font = Enum.Font.Gotham

-- Handlers
straightBtn.MouseButton1Click:Connect(function() if mechActive then mechCFrame = root.CFrame * CFrame.new(0, 5, -20); posMech() end end)
hiBtn.MouseButton1Click:Connect(function() if mechActive then emoteActive = true; emoteType = "Hi"; emoteTime = 0 end end)
danceBtn.MouseButton1Click:Connect(function() if mechActive then emoteActive = true; emoteType = "Dance"; emoteTime = 0 end end)
sitBtn.MouseButton1Click:Connect(function() if mechActive then emoteActive = true; emoteType = "Sit"; emoteTime = 0 end end)
offerBtn.MouseButton1Click:Connect(function() if mechActive then emoteActive = true; emoteType = "Offer"; emoteTime = 0 end end)
stopBtn.MouseButton1Click:Connect(function() emoteActive = false; emoteType = nil end)
kbdBtn.MouseButton1Click:Connect(function()
	keyboardActive = not keyboardActive
	kbdBtn.Text = keyboardActive and "KEYBOARD: ON (WASD/Z/X/QE/RT)" or "KEYBOARD: OFF"
	kbdBtn.BackgroundColor3 = keyboardActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
	if not keyboardActive then pointRArm = false; pointLArm = false end
end)

-- Keyboard
UserInputService.InputBegan:Connect(function(i, p) if p or not keyboardActive then return end
	local k = i.KeyCode
	if k == Enum.KeyCode.W then activeDirs.Forward = 1 elseif k == Enum.KeyCode.S then activeDirs.Backward = 1
	elseif k == Enum.KeyCode.A then activeDirs.Left = 1 elseif k == Enum.KeyCode.D then activeDirs.Right = 1
	elseif k == Enum.KeyCode.Q then activeDirs.Up = 1 elseif k == Enum.KeyCode.E then activeDirs.Down = 1
	elseif k == Enum.KeyCode.Z then isRotLeft = true elseif k == Enum.KeyCode.X then isRotRight = true
	elseif k == Enum.KeyCode.R then pointRArm = true elseif k == Enum.KeyCode.T then pointLArm = true end
end)
UserInputService.InputEnded:Connect(function(i, p) if p or not keyboardActive then return end
	local k = i.KeyCode
	if k == Enum.KeyCode.W then activeDirs.Forward = 0 elseif k == Enum.KeyCode.S then activeDirs.Backward = 0
	elseif k == Enum.KeyCode.A then activeDirs.Left = 0 elseif k == Enum.KeyCode.D then activeDirs.Right = 0
	elseif k == Enum.KeyCode.Q then activeDirs.Up = 0 elseif k == Enum.KeyCode.E then activeDirs.Down = 0
	elseif k == Enum.KeyCode.Z then isRotLeft = false elseif k == Enum.KeyCode.X then isRotRight = false
	elseif k == Enum.KeyCode.R then pointRArm = false elseif k == Enum.KeyCode.T then pointLArm = false end
end)

-- Spawner
local function stamp(cf, id, g)
	if not g or g == "" then g = "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}" end
	pcall(function() game:GetService("ReplicatedStorage").Remotes.StampAsset:InvokeServer(id, cf, g, {}, 0) end)
	pcall(function() local r = game:GetService("ReplicatedStorage"):FindFirstChild("Stamp"); if r then r:FireServer(id, cf) end end)
end
spawnBtn.MouseButton1Click:Connect(function()
	if spawnActive then spawnActive = false; if spawnConn then spawnConn:Disconnect() end; spawnBtn.Text = "SPAWN"; return end
	local id = tonumber(bIdBox.Text); if not id then return end
	spawnActive = true; spawnBtn.Text = "STOP"; local t = 0
	spawnConn = RunService.Heartbeat:Connect(function(dt)
		if not spawnActive then return end; t = t + dt
		if t >= 0.1 then t = 0; stamp(CFrame.new(root.Position + Vector3.new(math.random()*20-10, math.random()*5, math.random()*20-10)), id) end
	end)
end)

-- Free check
local function isFree(p)
	if not p or not p.Parent or not p:IsA("BasePart") or p.Anchored then return false end
	if next(p:GetJoints()) ~= nil then return false end
	for _, c in pairs(p:GetChildren()) do if c:IsA("JointInstance") or c:IsA("Constraint") or c:IsA("Attachment") then return false end end
	local a = p.Parent
	while a do if a:IsA("BasePart") and a.Anchored then return false elseif a:IsA("Tool") or a:IsA("HopperBin") then return false elseif a == Workspace then break end; a = a.Parent end
	for _, pl in pairs(Players:GetPlayers()) do if pl.Character and p:IsDescendantOf(pl.Character) then return false end end
	return true
end

-- Mech offsets
local mo = {
	{pos = Vector3.new(-2, 10, -2), tag = "t"}, {pos = Vector3.new(0, 10, -2), tag = "t"}, {pos = Vector3.new(2, 10, -2), tag = "t"},
	{pos = Vector3.new(-2, 10, 0), tag = "t"}, {pos = Vector3.new(0, 10, 0), tag = "t"}, {pos = Vector3.new(2, 10, 0), tag = "t"},
	{pos = Vector3.new(-2, 10, 2), tag = "t"}, {pos = Vector3.new(0, 10, 2), tag = "t"}, {pos = Vector3.new(2, 10, 2), tag = "t"},
	{pos = Vector3.new(-2, 14, -2), tag = "t"}, {pos = Vector3.new(0, 14, -2), tag = "t"}, {pos = Vector3.new(2, 14, -2), tag = "t"},
	{pos = Vector3.new(-2, 14, 0), tag = "t"}, {pos = Vector3.new(0, 14, 0), tag = "t"}, {pos = Vector3.new(2, 14, 0), tag = "t"},
	{pos = Vector3.new(-2, 14, 2), tag = "t"}, {pos = Vector3.new(0, 14, 2), tag = "t"}, {pos = Vector3.new(2, 14, 2), tag = "t"},
	{pos = Vector3.new(-2, 18, -2), tag = "t"}, {pos = Vector3.new(0, 18, -2), tag = "t"}, {pos = Vector3.new(2, 18, -2), tag = "t"},
	{pos = Vector3.new(-2, 18, 0), tag = "t"}, {pos = Vector3.new(0, 18, 0), tag = "t"}, {pos = Vector3.new(2, 18, 0), tag = "t"},
	{pos = Vector3.new(-2, 18, 2), tag = "t"}, {pos = Vector3.new(0, 18, 2), tag = "t"}, {pos = Vector3.new(2, 18, 2), tag = "t"},
	{pos = Vector3.new(-2, 22, -2), tag = "t"}, {pos = Vector3.new(0, 22, -2), tag = "t"}, {pos = Vector3.new(2, 22, -2), tag = "t"},
	{pos = Vector3.new(-2, 22, 0), tag = "t"}, {pos = Vector3.new(0, 22, 0), tag = "t"}, {pos = Vector3.new(2, 22, 0), tag = "t"},
	{pos = Vector3.new(-2, 22, 2), tag = "t"}, {pos = Vector3.new(0, 22, 2), tag = "t"}, {pos = Vector3.new(2, 22, 2), tag = "t"},
	{pos = Vector3.new(0, 25, 0), tag = "h"}, {pos = Vector3.new(0, 26, 0), tag = "h"},
	{pos = Vector3.new(-1, 28, -1), tag = "h"}, {pos = Vector3.new(1, 28, -1), tag = "h"}, {pos = Vector3.new(-1, 28, 1), tag = "h"}, {pos = Vector3.new(1, 28, 1), tag = "h"},
	{pos = Vector3.new(-1, 30, -1), tag = "h"}, {pos = Vector3.new(1, 30, -1), tag = "h"}, {pos = Vector3.new(-1, 30, 1), tag = "h"}, {pos = Vector3.new(1, 30, 1), tag = "h"},
	{pos = Vector3.new(-7, 22, -1), tag = "la"}, {pos = Vector3.new(-5, 22, -1), tag = "la"}, {pos = Vector3.new(-7, 22, 1), tag = "la"}, {pos = Vector3.new(-5, 22, 1), tag = "la"},
	{pos = Vector3.new(-7, 19, -1), tag = "la"}, {pos = Vector3.new(-5, 19, -1), tag = "la"}, {pos = Vector3.new(-7, 19, 1), tag = "la"}, {pos = Vector3.new(-5, 19, 1), tag = "la"},
	{pos = Vector3.new(-7, 16, -1), tag = "la"}, {pos = Vector3.new(-5, 16, -1), tag = "la"}, {pos = Vector3.new(-7, 16, 1), tag = "la"}, {pos = Vector3.new(-5, 16, 1), tag = "la"},
	{pos = Vector3.new(-7, 13, -1), tag = "la"}, {pos = Vector3.new(-5, 13, -1), tag = "la"}, {pos = Vector3.new(-7, 13, 1), tag = "la"}, {pos = Vector3.new(-5, 13, 1), tag = "la"},
	{pos = Vector3.new(-7, 10, -1), tag = "la"}, {pos = Vector3.new(-5, 10, -1), tag = "la"}, {pos = Vector3.new(-7, 10, 1), tag = "la"}, {pos = Vector3.new(-5, 10, 1), tag = "la"},
	{pos = Vector3.new(5, 22, -1), tag = "ra"}, {pos = Vector3.new(7, 22, -1), tag = "ra"}, {pos = Vector3.new(5, 22, 1), tag = "ra"}, {pos = Vector3.new(7, 22, 1), tag = "ra"},
	{pos = Vector3.new(5, 19, -1), tag = "ra"}, {pos = Vector3.new(7, 19, -1), tag = "ra"}, {pos = Vector3.new(5, 19, 1), tag = "ra"}, {pos = Vector3.new(7, 19, 1), tag = "ra"},
	{pos = Vector3.new(5, 16, -1), tag = "ra"}, {pos = Vector3.new(7, 16, -1), tag = "ra"}, {pos = Vector3.new(5, 16, 1), tag = "ra"}, {pos = Vector3.new(7, 16, 1), tag = "ra"},
	{pos = Vector3.new(5, 13, -1), tag = "ra"}, {pos = Vector3.new(7, 13, -1), tag = "ra"}, {pos = Vector3.new(5, 13, 1), tag = "ra"}, {pos = Vector3.new(7, 13, 1), tag = "ra"},
	{pos = Vector3.new(5, 10, -1), tag = "ra"}, {pos = Vector3.new(7, 10, -1), tag = "ra"}, {pos = Vector3.new(5, 10, 1), tag = "ra"}, {pos = Vector3.new(7, 10, 1), tag = "ra"},
	{pos = Vector3.new(-5, 6, -1), tag = "ll"}, {pos = Vector3.new(-3, 6, -1), tag = "ll"}, {pos = Vector3.new(-5, 6, 1), tag = "ll"}, {pos = Vector3.new(-3, 6, 1), tag = "ll"},
	{pos = Vector3.new(-5, 2, -1), tag = "ll"}, {pos = Vector3.new(-3, 2, -1), tag = "ll"}, {pos = Vector3.new(-5, 2, 1), tag = "ll"}, {pos = Vector3.new(-3, 2, 1), tag = "ll"},
	{pos = Vector3.new(-5, -2, -1), tag = "ll"}, {pos = Vector3.new(-3, -2, -1), tag = "ll"}, {pos = Vector3.new(-5, -2, 1), tag = "ll"}, {pos = Vector3.new(-3, -2, 1), tag = "ll"},
	{pos = Vector3.new(-5, -6, -1), tag = "ll"}, {pos = Vector3.new(-3, -6, -1), tag = "ll"}, {pos = Vector3.new(-5, -6, 1), tag = "ll"}, {pos = Vector3.new(-3, -6, 1), tag = "ll"},
	{pos = Vector3.new(3, 6, -1), tag = "rl"}, {pos = Vector3.new(5, 6, -1), tag = "rl"}, {pos = Vector3.new(3, 6, 1), tag = "rl"}, {pos = Vector3.new(5, 6, 1), tag = "rl"},
	{pos = Vector3.new(3, 2, -1), tag = "rl"}, {pos = Vector3.new(5, 2, -1), tag = "rl"}, {pos = Vector3.new(3, 2, 1), tag = "rl"}, {pos = Vector3.new(5, 2, 1), tag = "rl"},
	{pos = Vector3.new(3, -2, -1), tag = "rl"}, {pos = Vector3.new(5, -2, -1), tag = "rl"}, {pos = Vector3.new(3, -2, 1), tag = "rl"}, {pos = Vector3.new(5, -2, 1), tag = "rl"},
	{pos = Vector3.new(3, -6, -1), tag = "rl"}, {pos = Vector3.new(5, -6, -1), tag = "rl"}, {pos = Vector3.new(3, -6, 1), tag = "rl"}, {pos = Vector3.new(5, -6, 1), tag = "rl"},
}

local lap = Vector3.new(-6, 22, 0); local rap = Vector3.new(6, 22, 0)
local llp = Vector3.new(-4, 6, 0); local rlp = Vector3.new(4, 6, 0)

function posMech()
	if not mechActive then return end
	local bi = 1
	for _, d in pairs(mo) do
		if bi > #mechParts then break end
		local b = mechParts[bi]
		if b and b.Parent then
			for _, v in pairs(b:GetChildren()) do if v:IsA("BodyMover") or v:IsA("BodyAngularVelocity") or v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro") then v:Destroy() end end
			b.RotVelocity = Vector3.zero; b.CanCollide = false; b.Anchored = false
			local o, t = d.pos, d.tag
			if emoteActive then
				if emoteType == "Hi" and t == "ra" then
					local wp = emoteTime * 3; local au = math.rad(150) * math.abs(math.sin(wp * 0.4)); local ws = math.rad(35) * math.sin(wp * 2.5)
					local rp = CFrame.Angles(0, ws, au) * (o - rap); b.CFrame = mechCFrame * CFrame.new(rap + rp) * CFrame.Angles(0, ws, au)
				elseif emoteType == "Dance" then
					local a, p = 0, Vector3.new()
					if t == "ra" then a = math.rad(50) * math.sin(emoteTime * 3); p = rap
					elseif t == "la" then a = math.rad(50) * math.cos(emoteTime * 3); p = lap
					elseif t == "ll" then a = math.rad(25) * math.sin(emoteTime * 4); p = llp
					elseif t == "rl" then a = math.rad(25) * math.cos(emoteTime * 4); p = rlp
					elseif t == "t" then b.CFrame = mechCFrame * CFrame.new(o + Vector3.new(0, 0.3 * math.abs(math.sin(emoteTime * 6)), 0)); bi = bi + 1; continue
					elseif t == "h" then b.CFrame = mechCFrame * CFrame.new(o) * CFrame.Angles(0, 0, math.rad(10) * math.sin(emoteTime * 3)); bi = bi + 1; continue
					else b.CFrame = mechCFrame * CFrame.new(o); bi = bi + 1; continue end
					local rp = CFrame.Angles(a, 0, 0) * (o - p); b.CFrame = mechCFrame * CFrame.new(p + rp) * CFrame.Angles(a, 0, 0)
				elseif emoteType == "Sit" then
					if t == "ll" then local rp = CFrame.Angles(math.rad(90), 0, 0) * (o - llp); b.CFrame = mechCFrame * CFrame.new(llp + rp + Vector3.new(0, -4, -3)) * CFrame.Angles(math.rad(90), 0, 0)
					elseif t == "rl" then local rp = CFrame.Angles(math.rad(90), 0, 0) * (o - rlp); b.CFrame = mechCFrame * CFrame.new(rlp + rp + Vector3.new(0, -4, -3)) * CFrame.Angles(math.rad(90), 0, 0)
					elseif t == "t" then b.CFrame = mechCFrame * CFrame.new(o + Vector3.new(0, -6, 0))
					elseif t == "la" then local rp = CFrame.Angles(math.rad(90), 0, 0) * (o - lap); b.CFrame = mechCFrame * CFrame.new(lap + rp + Vector3.new(0, -4, 0)) * CFrame.Angles(math.rad(90), 0, 0)
					elseif t == "ra" then local rp = CFrame.Angles(math.rad(90), 0, 0) * (o - rap); b.CFrame = mechCFrame * CFrame.new(rap + rp + Vector3.new(0, -4, 0)) * CFrame.Angles(math.rad(90), 0, 0)
					elseif t == "h" then b.CFrame = mechCFrame * CFrame.new(o + Vector3.new(0, -6, 0))
					else b.CFrame = mechCFrame * CFrame.new(o) end
				elseif emoteType == "Offer" then
					local phase = math.min(emoteTime / 5, 1)
					if t == "ra" then
						if phase < 0.3 then local p = phase / 0.3; local rp = CFrame.Angles(0, 0, math.rad(120 * p)) * (o - rap); b.CFrame = mechCFrame * CFrame.new(rap + rp) * CFrame.Angles(0, 0, math.rad(120 * p))
						elseif phase < 0.6 then local p = (phase - 0.3) / 0.3; local rp = CFrame.Angles(0, 0, math.rad(120 - 60 * p)) * (o - rap); b.CFrame = mechCFrame * CFrame.new(rap + rp + Vector3.new(0, -12 * p, 6 * p)) * CFrame.Angles(0, 0, math.rad(120 - 60 * p))
						else local rp = CFrame.Angles(0, 0, math.rad(60)) * (o - rap); b.CFrame = mechCFrame * CFrame.new(rap + rp + Vector3.new(0, -16, 10)) * CFrame.Angles(0, 0, math.rad(60)) end
					elseif t == "la" then local rp = CFrame.Angles(math.rad(90), 0, 0) * (o - lap); b.CFrame = mechCFrame * CFrame.new(lap + rp + Vector3.new(0, -4, 0)) * CFrame.Angles(math.rad(90), 0, 0)
					elseif t == "h" then
						if phase < 0.3 then b.CFrame = mechCFrame * CFrame.new(o)
						elseif phase < 0.6 then local p = (phase - 0.3) / 0.3; b.CFrame = mechCFrame * CFrame.new(o + Vector3.new(0, -12 * p, 6 * p))
						else b.CFrame = mechCFrame * CFrame.new(o + Vector3.new(0, -20, 12)) end
					elseif t == "t" then b.CFrame = mechCFrame * CFrame.new(o)
					else b.CFrame = mechCFrame * CFrame.new(o) end
				else b.CFrame = mechCFrame * CFrame.new(o) end
			elseif keyboardActive then
				if pointRArm and t == "ra" then b.CFrame = mechCFrame * CFrame.new(rap) * CFrame.lookAt(Vector3.new(), (mouse.Hit.Position - mechCFrame * rap).Unit) * CFrame.new(o - rap)
				elseif pointLArm and t == "la" then b.CFrame = mechCFrame * CFrame.new(lap) * CFrame.lookAt(Vector3.new(), (mouse.Hit.Position - mechCFrame * lap).Unit) * CFrame.new(o - lap)
				else
					local a, p = 0, Vector3.new()
					if t == "la" then a = math.rad(25) * math.sin(walkCycle); p = lap
					elseif t == "ra" then a = math.rad(25) * math.sin(walkCycle + math.pi); p = rap
					elseif t == "ll" then a = math.rad(20) * math.sin(walkCycle + math.pi); p = llp
					elseif t == "rl" then a = math.rad(20) * math.sin(walkCycle); p = rlp end
					if a ~= 0 then local rp = CFrame.Angles(a, 0, 0) * (o - p); b.CFrame = mechCFrame * CFrame.new(p + rp) * CFrame.Angles(a, 0, 0)
					else b.CFrame = mechCFrame * CFrame.new(o) end
				end
			else
				local a, p = 0, Vector3.new()
				if t == "la" then a = math.rad(25) * math.sin(walkCycle); p = lap
				elseif t == "ra" then a = math.rad(25) * math.sin(walkCycle + math.pi); p = rap
				elseif t == "ll" then a = math.rad(20) * math.sin(walkCycle + math.pi); p = llp
				elseif t == "rl" then a = math.rad(20) * math.sin(walkCycle); p = rlp end
				if a ~= 0 then local rp = CFrame.Angles(a, 0, 0) * (o - p); b.CFrame = mechCFrame * CFrame.new(p + rp) * CFrame.Angles(a, 0, 0)
				else b.CFrame = mechCFrame * CFrame.new(o) end
			end
		end
		bi = bi + 1
	end
end

local function assemble()
	for _, b in pairs(mechParts) do if b and b.Parent then b.Velocity = Vector3.zero; b.CanCollide = true end end
	table.clear(mechParts); if mechConnection then mechConnection:Disconnect() end; mechActive = false
	local fp = {}
	for _, p in pairs(Workspace:GetDescendants()) do
		if isFree(p) and p.Transparency < 0.5 and not p:IsDescendantOf(character) then
			local d = (p.Position - root.Position).Magnitude
			if d < 200 then table.insert(fp, {part = p, dist = d}) end
		end
	end
	table.sort(fp, function(a, b) return a.dist < b.dist end)
	for i = 1, math.min(#mo, #fp) do table.insert(mechParts, fp[i].part) end
	if #mechParts == 0 then statusLabel.Text = "No blocks" return end
	mechCFrame = root.CFrame * CFrame.new(0, 5, -20); walkCycle = 0; isMoving = false
	pointRArm = false; pointLArm = false; posMech(); mechActive = true; statusLabel.Text = "Mech: On"
	mechConnection = RunService.Heartbeat:Connect(function(dt)
		if not mechActive then return end
		if keyboardActive then root.CFrame = CFrame.new(mechCFrame.Position + mechCFrame:VectorToWorldSpace(Vector3.new(0, 28, 0))) end
		if emoteActive then
			emoteTime = emoteTime + dt
			local mv = Vector3.new(activeDirs.Right - activeDirs.Left, activeDirs.Up - activeDirs.Down, activeDirs.Backward - activeDirs.Forward)
			isMoving = mv.Magnitude > 0
			if isMoving then mechCFrame = mechCFrame + (mechCFrame:VectorToWorldSpace(mv.Unit) * moveSpeed * dt); walkCycle = walkCycle + (dt * 8) end
		else
			local mv = Vector3.new(activeDirs.Right - activeDirs.Left, activeDirs.Up - activeDirs.Down, activeDirs.Backward - activeDirs.Forward)
			isMoving = mv.Magnitude > 0
			if isMoving then mechCFrame = mechCFrame + (mechCFrame:VectorToWorldSpace(mv.Unit) * moveSpeed * dt); walkCycle = walkCycle + (dt * 8)
			else walkCycle = walkCycle + (0 - walkCycle) * 5 * dt end
		end
		if isRotLeft then mechCFrame = mechCFrame * CFrame.Angles(0, rotSpeed * dt, 0) end
		if isRotRight then mechCFrame = mechCFrame * CFrame.Angles(0, -rotSpeed * dt, 0) end
		posMech()
	end)
end

local function disassemble()
	mechActive = false; emoteActive = false; emoteType = nil
	pointRArm = false; pointLArm = false
	if mechConnection then mechConnection:Disconnect() end
	for _, b in pairs(mechParts) do if b and b.Parent then b.Velocity = Vector3.zero; b.CanCollide = true; for _, v in pairs(b:GetChildren()) do if v:IsA("BodyMover") then v:Destroy() end end end end
	statusLabel.Text = "Mech: Off"
end

assembleBtn.MouseButton1Click:Connect(assemble)
disBtn.MouseButton1Click:Connect(disassemble)

player.CharacterAdded:Connect(function(char)
	character = char; humanoid = character:WaitForChild("Humanoid"); root = character:WaitForChild("HumanoidRootPart")
	sg.Parent = player:WaitForChild("PlayerGui")
	disassemble(); spawnActive = false
	if spawnConn then spawnConn:Disconnect() end
	table.clear(mechParts)
end)