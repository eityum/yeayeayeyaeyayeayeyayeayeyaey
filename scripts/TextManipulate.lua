-- Text Block Manipulator - Bigger GUI, Bright Buttons, All Direction Buttons
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local grabbedBlocks = {}
local shapeActive = false
local shapeConnection = nil
local textSize = 20
local textRotation = 0
local textOffsetX = 0
local textOffsetY = 3
local textOffsetZ = -40
local allOffsets = {}
local increment = 1

-- 5x5 font
local font = {
	A = {"  X  "," X X ","XXXXX","X   X","X   X"},
	B = {"XXXX ","X   X","XXXX ","X   X","XXXX "},
	C = {" XXXX","X    ","X    ","X    "," XXXX"},
	D = {"XXXX ","X   X","X   X","X   X","XXXX "},
	E = {"XXXXX","X    ","XXXXX","X    ","XXXXX"},
	F = {"XXXXX","X    ","XXXXX","X    ","X    "},
	G = {" XXXX","X    ","X  XX","X   X"," XXXX"},
	H = {"X   X","X   X","XXXXX","X   X","X   X"},
	I = {"XXXXX","  X  ","  X  ","  X  ","XXXXX"},
	J = {"XXXXX","    X","    X","X   X"," XXX "},
	K = {"X   X","X  X ","XXX  ","X  X ","X   X"},
	L = {"X    ","X    ","X    ","X    ","XXXXX"},
	M = {"X   X","XX XX","X X X","X   X","X   X"},
	N = {"X   X","XX  X","X X X","X  XX","X   X"},
	O = {" XXX ","X   X","X   X","X   X"," XXX "},
	P = {"XXXX ","X   X","XXXX ","X    ","X    "},
	Q = {" XXX ","X   X","X   X","X  XX"," XXXX"},
	R = {"XXXX ","X   X","XXXX ","X  X ","X   X"},
	S = {" XXXX","X    "," XXX ","    X","XXXX "},
	T = {"XXXXX","  X  ","  X  ","  X  ","  X  "},
	U = {"X   X","X   X","X   X","X   X"," XXX "},
	V = {"X   X","X   X","X   X"," X X ","  X  "},
	W = {"X   X","X   X","X X X","XX XX","X   X"},
	X = {"X   X"," X X ","  X  "," X X ","X   X"},
	Y = {"X   X"," X X ","  X  ","  X  ","  X  "},
	Z = {"XXXXX","   X ","  X  "," X   ","XXXXX"},
	[" "] = {"     ","     ","     ","     ","     "},
	["А"] = {"  X  "," X X ","XXXXX","X   X","X   X"},
	["Б"] = {"XXXXX","X    ","XXXX ","X   X","XXXX "},
	["В"] = {"XXXX ","X   X","XXXX ","X   X","XXXX "},
	["Г"] = {"XXXXX","X    ","X    ","X    ","X    "},
	["Д"] = {" XXXX","X   X","X   X","XXXXX","X   X"},
	["Е"] = {"XXXXX","X    ","XXXXX","X    ","XXXXX"},
	["Ё"] = {"XXXXX","X    ","XXXXX","X    ","XXXXX"},
	["Ж"] = {"X X X"," X X ","  X  "," X X ","X X X"},
	["З"] = {" XXX ","X   X","  XX ","X   X"," XXX "},
	["И"] = {"X   X","X   X","X  XX","X X X","XX  X"},
	["Й"] = {" X X ","X   X","X  XX","X X X","XX  X"},
	["К"] = {"X   X","X  X ","XXX  ","X  X ","X   X"},
	["Л"] = {" XXXX","X   X","X   X","X   X","X   X"},
	["М"] = {"X   X","XX XX","X X X","X   X","X   X"},
	["Н"] = {"X   X","X   X","XXXXX","X   X","X   X"},
	["О"] = {" XXX ","X   X","X   X","X   X"," XXX "},
	["П"] = {"XXXXX","X   X","X   X","X   X","X   X"},
	["Р"] = {"XXXX ","X   X","XXXX ","X    ","X    "},
	["С"] = {" XXXX","X    ","X    ","X    "," XXXX"},
	["Т"] = {"XXXXX","  X  ","  X  ","  X  ","  X  "},
	["У"] = {"X   X","X   X","X   X"," XXXX","    X"},
	["Ф"] = {"  X  ","X X X","X X X","X X X"," X X "},
	["Х"] = {"X   X"," X X ","  X  "," X X ","X   X"},
	["Ц"] = {"X   X","X   X","X   X","XXXXX","    X"},
	["Ч"] = {"X   X","X   X"," XXXX","    X","    X"},
	["Ш"] = {"X X X","X X X","X X X","X X X","XXXXX"},
	["Щ"] = {"X X X","X X X","X X X","XXXXX","    X"},
	["Ъ"] = {"XX   "," X   "," XXX "," X  X"," XXX "},
	["Ы"] = {"X   X","X   X","XX  X","X X X","XX  X"},
	["Ь"] = {"X    ","X    ","XXXX ","X   X","XXXX "},
	["Э"] = {" XXX ","X   X","  XXX","X   X"," XXX "},
	["Ю"] = {"X   X","X X X","XX  X","X X X","X   X"},
	["Я"] = {" XXXX","X   X"," XXXX","X  X ","X   X"},
}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TextBlock"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 320)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Text = "TEXT BLOCK MANIPULATOR"
titleBar.TextColor3 = Color3.fromRGB(255, 150, 50)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 11
titleBar.AutoButtonColor = false
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

titleBar.InputEnded:Connect(function() dragging = false end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Text input
local textInput = Instance.new("TextBox")
textInput.Size = UDim2.new(1, -20, 0, 35)
textInput.Position = UDim2.new(0, 10, 0, 38)
textInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textInput.BorderSizePixel = 0
textInput.PlaceholderText = "Type text here..."
textInput.Text = ""
textInput.TextColor3 = Color3.fromRGB(255, 255, 255)
textInput.TextSize = 16
textInput.Font = Enum.Font.GothamBold
textInput.Parent = mainFrame
Instance.new("UICorner", textInput).CornerRadius = UDim.new(0, 6)

-- Size
local sizeInput = Instance.new("TextBox")
sizeInput.Size = UDim2.new(0, 60, 0, 25)
sizeInput.Position = UDim2.new(0, 10, 0, 82)
sizeInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sizeInput.BorderSizePixel = 0
sizeInput.Text = "20"
sizeInput.PlaceholderText = "Size"
sizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeInput.TextSize = 12
sizeInput.Font = Enum.Font.GothamBold
sizeInput.Parent = mainFrame
Instance.new("UICorner", sizeInput).CornerRadius = UDim.new(0, 4)

-- Increment
local incLabel = Instance.new("TextLabel")
incLabel.Size = UDim2.new(0, 60, 0, 15)
incLabel.Position = UDim2.new(0, 80, 0, 80)
incLabel.BackgroundTransparency = 1
incLabel.Text = "Inc: " .. increment
incLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
incLabel.TextSize = 10
incLabel.Font = Enum.Font.GothamBold
incLabel.Parent = mainFrame

local incDownBtn = Instance.new("TextButton")
incDownBtn.Size = UDim2.new(0, 28, 0, 22)
incDownBtn.Position = UDim2.new(0, 80, 0, 97)
incDownBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
incDownBtn.Text = "-"
incDownBtn.Font = Enum.Font.GothamBold
incDownBtn.TextSize = 14
incDownBtn.BorderSizePixel = 0
incDownBtn.Parent = mainFrame
Instance.new("UICorner", incDownBtn).CornerRadius = UDim.new(0, 4)

local incUpBtn = Instance.new("TextButton")
incUpBtn.Size = UDim2.new(0, 28, 0, 22)
incUpBtn.Position = UDim2.new(0, 112, 0, 97)
incUpBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
incUpBtn.Text = "+"
incUpBtn.Font = Enum.Font.GothamBold
incUpBtn.TextSize = 14
incUpBtn.BorderSizePixel = 0
incUpBtn.Parent = mainFrame
Instance.new("UICorner", incUpBtn).CornerRadius = UDim.new(0, 4)

incUpBtn.MouseButton1Click:Connect(function()
	increment = increment + 1
	incLabel.Text = "Inc: " .. increment
end)

incDownBtn.MouseButton1Click:Connect(function()
	increment = math.max(1, increment - 1)
	incLabel.Text = "Inc: " .. increment
end)

-- Rotation
local rotLabel = Instance.new("TextLabel")
rotLabel.Size = UDim2.new(0, 70, 0, 15)
rotLabel.Position = UDim2.new(0, 155, 0, 80)
rotLabel.BackgroundTransparency = 1
rotLabel.Text = "Rot: " .. textRotation
rotLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rotLabel.TextSize = 10
rotLabel.Font = Enum.Font.GothamBold
rotLabel.Parent = mainFrame

local rotLeftBtn = Instance.new("TextButton")
rotLeftBtn.Size = UDim2.new(0, 35, 0, 25)
rotLeftBtn.Position = UDim2.new(0, 155, 0, 95)
rotLeftBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
rotLeftBtn.Text = "◀"
rotLeftBtn.Font = Enum.Font.GothamBold
rotLeftBtn.TextSize = 14
rotLeftBtn.BorderSizePixel = 0
rotLeftBtn.Parent = mainFrame
Instance.new("UICorner", rotLeftBtn).CornerRadius = UDim.new(0, 4)

local rotRightBtn = Instance.new("TextButton")
rotRightBtn.Size = UDim2.new(0, 35, 0, 25)
rotRightBtn.Position = UDim2.new(0, 195, 0, 95)
rotRightBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
rotRightBtn.Text = "▶"
rotRightBtn.Font = Enum.Font.GothamBold
rotRightBtn.TextSize = 14
rotRightBtn.BorderSizePixel = 0
rotRightBtn.Parent = mainFrame
Instance.new("UICorner", rotRightBtn).CornerRadius = UDim.new(0, 4)

rotLeftBtn.MouseButton1Click:Connect(function()
	textRotation = textRotation - 15
	rotLabel.Text = "Rot: " .. textRotation
end)

rotRightBtn.MouseButton1Click:Connect(function()
	textRotation = textRotation + 15
	rotLabel.Text = "Rot: " .. textRotation
end)

-- Position display
local posLabel = Instance.new("TextLabel")
posLabel.Size = UDim2.new(0, 120, 0, 15)
posLabel.Position = UDim2.new(0, 245, 0, 80)
posLabel.BackgroundTransparency = 1
posLabel.Text = "X:" .. textOffsetX .. " Y:" .. textOffsetY .. " Z:" .. textOffsetZ
posLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
posLabel.TextSize = 9
posLabel.Font = Enum.Font.GothamBold
posLabel.Parent = mainFrame

-- Direction buttons in a cross pattern
local function createDirBtn(text, x, y, color, dx, dy, dz)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 45, 0, 30)
	btn.Position = UDim2.new(0, x, 0, y)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Parent = mainFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	btn.MouseButton1Click:Connect(function()
		textOffsetX = textOffsetX + (dx * increment)
		textOffsetY = textOffsetY + (dy * increment)
		textOffsetZ = textOffsetZ + (dz * increment)
		posLabel.Text = "X:" .. textOffsetX .. " Y:" .. textOffsetY .. " Z:" .. textOffsetZ
	end)
	return btn
end

-- Row 1: Forward, Up, Backward
createDirBtn("↑ UP", 145, 130, Color3.fromRGB(255, 200, 50), 0, 1, 0)
createDirBtn("FWD", 80, 165, Color3.fromRGB(50, 200, 255), 0, 0, -1)
createDirBtn("BACK", 195, 165, Color3.fromRGB(50, 200, 255), 0, 0, 1)

-- Row 2: Left, Down, Right
createDirBtn("LEFT", 80, 200, Color3.fromRGB(255, 100, 100), -1, 0, 0)
createDirBtn("↓ DOWN", 145, 200, Color3.fromRGB(255, 200, 50), 0, -1, 0)
createDirBtn("RIGHT", 195, 200, Color3.fromRGB(255, 100, 100), 1, 0, 0)

-- Action buttons
local grabBtn = Instance.new("TextButton")
grabBtn.Size = UDim2.new(0, 100, 0, 35)
grabBtn.Position = UDim2.new(0, 10, 0, 245)
grabBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
grabBtn.Text = "GRAB"
grabBtn.Font = Enum.Font.GothamBold
grabBtn.TextSize = 14
grabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
grabBtn.BorderSizePixel = 0
grabBtn.Parent = mainFrame
Instance.new("UICorner", grabBtn).CornerRadius = UDim.new(0, 6)

local formBtn = Instance.new("TextButton")
formBtn.Size = UDim2.new(0, 100, 0, 35)
formBtn.Position = UDim2.new(0, 120, 0, 245)
formBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
formBtn.Text = "FORM"
formBtn.Font = Enum.Font.GothamBold
formBtn.TextSize = 14
formBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
formBtn.BorderSizePixel = 0
formBtn.Parent = mainFrame
Instance.new("UICorner", formBtn).CornerRadius = UDim.new(0, 6)

local updateBtn = Instance.new("TextButton")
updateBtn.Size = UDim2.new(0, 100, 0, 35)
updateBtn.Position = UDim2.new(0, 230, 0, 245)
updateBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
updateBtn.Text = "UPDATE"
updateBtn.Font = Enum.Font.GothamBold
updateBtn.TextSize = 14
updateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
updateBtn.BorderSizePixel = 0
updateBtn.Parent = mainFrame
Instance.new("UICorner", updateBtn).CornerRadius = UDim.new(0, 6)

local disBtn = Instance.new("TextButton")
disBtn.Size = UDim2.new(1, -20, 0, 30)
disBtn.Position = UDim2.new(0, 10, 0, 285)
disBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
disBtn.Text = "DISASSEMBLE"
disBtn.Font = Enum.Font.GothamBold
disBtn.TextSize = 12
disBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
disBtn.BorderSizePixel = 0
disBtn.Parent = mainFrame
Instance.new("UICorner", disBtn).CornerRadius = UDim.new(0, 6)

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

-- GRAB
grabBtn.MouseButton1Click:Connect(function()
	for _, block in pairs(grabbedBlocks) do
		if block and block.Parent then
			block.Velocity = Vector3.zero
			for _, v in pairs(block:GetChildren()) do
				if v:IsA("BodyMover") then v:Destroy() end
			end
			block.CanCollide = true
		end
	end
	table.clear(grabbedBlocks)
	if shapeConnection then shapeConnection:Disconnect() shapeConnection = nil end
	shapeActive = false
	
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local foundParts = {}
	for _, part in pairs(Workspace:GetDescendants()) do
		if isFreeFloating(part) and part.Transparency < 0.5 then
			local dist = (part.Position - root.Position).Magnitude
			if dist < 200 then table.insert(foundParts, {part = part, dist = dist}) end
		end
	end
	table.sort(foundParts, function(a, b) return a.dist < b.dist end)
	for i = 1, math.min(300, #foundParts) do
		table.insert(grabbedBlocks, foundParts[i].part)
	end
end)

-- FORM
local function formText()
	local text = textInput.Text
	if text == "" then return end
	if #grabbedBlocks == 0 then return end
	if shapeConnection then shapeConnection:Disconnect() shapeConnection = nil end
	
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local rad = tonumber(sizeInput.Text) or textSize
	textSize = rad
	
	local upperText = ""
	for _, codepoint in utf8.codes(text) do
		upperText = upperText .. utf8.char(codepoint):upper()
	end
	
	local pixels = {}
	local totalChars = 0
	
	for _, codepoint in utf8.codes(upperText) do
		local char = utf8.char(codepoint)
		local glyph = font[char] or font[" "]
		for row = 1, 5 do
			for col = 1, 5 do
				local c = glyph[row]:sub(col, col)
				if c == "X" then
					table.insert(pixels, {row = row, col = col + (totalChars * 6)})
				end
			end
		end
		totalChars = totalChars + 1
	end
	
	local totalWidth = totalChars * 6
	if #pixels == 0 then return end
	
	local blockIndex = 1
	allOffsets = {}
	local pixelsPerBlock = math.max(1, math.floor(#pixels / #grabbedBlocks))
	local rotAngle = math.rad(textRotation)
	
	for i = 1, #pixels do
		if blockIndex > #grabbedBlocks then break end
		if i % pixelsPerBlock == 1 or pixelsPerBlock == 1 then
			local pixel = pixels[i]
			local worldX = (pixel.col - totalWidth / 2) * (textSize / 5)
			local worldY = (5 - pixel.row) * (textSize / 5)
			
			local cosA = math.cos(rotAngle)
			local sinA = math.sin(rotAngle)
			local rotatedX = worldX * cosA - (-textSize * 2) * sinA
			local rotatedZ = worldX * sinA + (-textSize * 2) * cosA
			
			local finalPos = Vector3.new(rotatedX + textOffsetX, worldY + textOffsetY, rotatedZ + textOffsetZ)
			
			local block = grabbedBlocks[blockIndex]
			if block and block.Parent then
				block.Velocity = Vector3.zero
				for _, v in pairs(block:GetChildren()) do
					if v:IsA("BodyMover") then v:Destroy() end
				end
				block.CanCollide = false
				local targetPos = root.Position + root.CFrame:VectorToWorldSpace(finalPos)
				table.insert(allOffsets, {block = block, offset = targetPos - root.Position})
			end
			blockIndex = blockIndex + 1
		end
	end
	
	if #allOffsets == 0 then return end
	
	shapeActive = true
	shapeConnection = RunService.Heartbeat:Connect(function()
		if not shapeActive then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for _, data in pairs(allOffsets) do
			if data.block and data.block.Parent then
				data.block.Velocity = (root.Position + data.offset - data.block.Position) * 15
			end
		end
	end)
end

formBtn.MouseButton1Click:Connect(formText)

-- UPDATE
updateBtn.MouseButton1Click:Connect(function()
	if #allOffsets == 0 then formText() return end
	if shapeConnection then shapeConnection:Disconnect() shapeConnection = nil end
	
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local rotAngle = math.rad(textRotation)
	local pixels = {}
	local upperText = ""
	for _, codepoint in utf8.codes(textInput.Text) do
		upperText = upperText .. utf8.char(codepoint):upper()
	end
	
	local totalChars = 0
	for _, codepoint in utf8.codes(upperText) do
		local char = utf8.char(codepoint)
		local glyph = font[char] or font[" "]
		for row = 1, 5 do
			for col = 1, 5 do
				if glyph[row]:sub(col, col) == "X" then
					table.insert(pixels, {row = row, col = col + (totalChars * 6)})
				end
			end
		end
		totalChars = totalChars + 1
	end
	
	local totalWidth = totalChars * 6
	local blockIndex = 1
	local newOffsets = {}
	
	for i = 1, #pixels do
		if blockIndex > #grabbedBlocks then break end
		local pixel = pixels[i]
		local worldX = (pixel.col - totalWidth / 2) * (textSize / 5)
		local worldY = (5 - pixel.row) * (textSize / 5)
		
		local cosA = math.cos(rotAngle)
		local sinA = math.sin(rotAngle)
		local rotatedX = worldX * cosA - (-textSize * 2) * sinA
		local rotatedZ = worldX * sinA + (-textSize * 2) * cosA
		
		local finalPos = Vector3.new(rotatedX + textOffsetX, worldY + textOffsetY, rotatedZ + textOffsetZ)
		local block = grabbedBlocks[blockIndex]
		if block and block.Parent then
			local targetPos = root.Position + root.CFrame:VectorToWorldSpace(finalPos)
			table.insert(newOffsets, {block = block, offset = targetPos - root.Position})
		end
		blockIndex = blockIndex + 1
	end
	
	allOffsets = newOffsets
	
	shapeActive = true
	shapeConnection = RunService.Heartbeat:Connect(function()
		if not shapeActive then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for _, data in pairs(allOffsets) do
			if data.block and data.block.Parent then
				data.block.Velocity = (root.Position + data.offset - data.block.Position) * 15
			end
		end
	end)
end)

-- DISASSEMBLE
disBtn.MouseButton1Click:Connect(function()
	shapeActive = false
	if shapeConnection then shapeConnection:Disconnect() shapeConnection = nil end
	for _, block in pairs(grabbedBlocks) do
		if block and block.Parent then
			block.Velocity = Vector3.zero
			for _, v in pairs(block:GetChildren()) do
				if v:IsA("BodyMover") then v:Destroy() end
			end
			block.CanCollide = true
		end
	end
	table.clear(grabbedBlocks)
	allOffsets = {}
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	screenGui.Parent = player:WaitForChild("PlayerGui")
	shapeActive = false
	if shapeConnection then shapeConnection:Disconnect() shapeConnection = nil end
	for _, block in pairs(grabbedBlocks) do
		if block and block.Parent then
			block.Velocity = Vector3.zero
			block.CanCollide = true
			for _, v in pairs(block:GetChildren()) do
				if v:IsA("BodyMover") then v:Destroy() end
			end
		end
	end
	table.clear(grabbedBlocks)
	allOffsets = {}
end)