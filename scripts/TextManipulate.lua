-- Text Block Shaper - 4x4x4 BLOCKS - NO GAPS - NO RESIZE - CHAR SPACING - RUSSIAN - COREGUI
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local grabbedBlocks = {}
local shapeActive = false
local shapeConnection = nil
local allOffsets = {}
local maxBlocks = 9999

local textPosition = Vector3.new(-4, 147, -296)
local textLookDirection = Vector3.new(0, 0, -1)

local font = {
	-- English
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
	["0"] = {" XXX ","X   X","X  XX","X   X"," XXX "},
	["1"] = {"  X  "," XX  ","  X  ","  X  ","XXXXX"},
	["2"] = {" XXX ","X   X","  XX "," X   ","XXXXX"},
	["3"] = {"XXXXX","    X"," XXXX","    X","XXXXX"},
	["4"] = {"X   X","X   X","XXXXX","    X","    X"},
	["5"] = {"XXXXX","X    ","XXXX ","    X","XXXX "},
	["6"] = {" XXXX","X    ","XXXX ","X   X"," XXX "},
	["7"] = {"XXXXX","    X","   X ","  X  "," X   "},
	["8"] = {" XXX ","X   X"," XXX ","X   X"," XXX "},
	["9"] = {" XXX ","X   X"," XXXX","    X"," XXX "},
	["!"] = {"  X  ","  X  ","  X  ","     ","  X  "},
	["?"] = {" XXX ","X   X","  XX ","     ","  X  "},
	["."] = {"     ","     ","     ","     ","  X  "},
	[":"] = {"     ","  X  ","     ","  X  ","     "},
	["/"] = {"    X","   X ","  X  "," X   ","X    "},
	["@"] = {" XXX ","X   X","X X X","X    "," XXXX"},
	["-"] = {"     ","     ","XXXXX","     ","     "},
	["_"] = {"     ","     ","     ","     ","XXXXX"},
	["#"] = {" X X ","XXXXX"," X X ","XXXXX"," X X "},
	["="] = {"     ","XXXXX","     ","XXXXX","     "},
	["+"] = {"     ","  X  ","XXXXX","  X  ","     "},
	["*"] = {" X X ","  X  ","XXXXX","  X  "," X X "},
	["("] = {"  X  "," X   ","X    "," X   ","  X  "},
	[")"] = {"  X  ","   X ","    X","   X ","  X  "},
	["'"] = {"  X  ","  X  ","     ","     ","     "},
	['"'] = {" X X "," X X ","     ","     ","     "},
	[","] = {"     ","     ","     ","  X  "," X   "},
	[";"] = {"     ","  X  ","     ","  X  "," X   "},
	["<"] = {"   X ","  X  "," X   ","  X  ","   X "},
	[">"] = {" X   ","  X  ","   X ","  X  "," X   "},
	["["] = {" XXX "," X   "," X   "," X   "," XXX "},
	["]"] = {" XXX ","   X ","   X ","   X "," XXX "},
	["{"] = {"  XX "," X   ","XX   "," X   ","  XX "},
	["}"] = {"XX   ","  X  ","  XX ","  X  ","XX   "},
	["|"] = {"  X  ","  X  ","  X  ","  X  ","  X  "},
	["\\"] = {"X    "," X   ","  X  ","   X ","    X"},
	["^"] = {"  X  "," X X ","X   X","     ","     "},
	["`"] = {" X   ","  X  ","     ","     ","     "},
	["~"] = {"     "," X X ","X X X","     ","     "},
	-- Russian uppercase
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
	["У"] = {"X   X"," X X ","  X  ","  X  ","  X  "},
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
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "TextShaper"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0.5, -140, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local titleBar = Instance.new("TextButton", frame)
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.Text = "TEXT SHAPER (-4, 147, -296)"
titleBar.TextColor3 = Color3.fromRGB(255, 150, 50)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 10
titleBar.AutoButtonColor = false
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local textBox = Instance.new("TextBox", frame)
textBox.Size = UDim2.new(1, -20, 0, 30)
textBox.Position = UDim2.new(0, 10, 0, 32)
textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textBox.PlaceholderText = "Enter text (EN/RU)..."
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.Font = Enum.Font.GothamBold
textBox.TextSize = 14
textBox.BorderSizePixel = 0
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 5)

local sizeBox = Instance.new("TextBox", frame)
sizeBox.Size = UDim2.new(0, 60, 0, 24)
sizeBox.Position = UDim2.new(0, 10, 0, 70)
sizeBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sizeBox.Text = "20"
sizeBox.PlaceholderText = "Res"
sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeBox.Font = Enum.Font.GothamBold
sizeBox.TextSize = 12
sizeBox.BorderSizePixel = 0
Instance.new("UICorner", sizeBox).CornerRadius = UDim.new(0, 4)

local grabBtn = Instance.new("TextButton", frame)
grabBtn.Size = UDim2.new(0, 90, 0, 28)
grabBtn.Position = UDim2.new(0, 80, 0, 68)
grabBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
grabBtn.Text = "GRAB"
grabBtn.Font = Enum.Font.GothamBold
grabBtn.TextSize = 12
grabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
grabBtn.BorderSizePixel = 0
Instance.new("UICorner", grabBtn).CornerRadius = UDim.new(0, 5)

local formBtn = Instance.new("TextButton", frame)
formBtn.Size = UDim2.new(0, 90, 0, 28)
formBtn.Position = UDim2.new(0, 178, 0, 68)
formBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
formBtn.Text = "FORM"
formBtn.Font = Enum.Font.GothamBold
formBtn.TextSize = 12
formBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
formBtn.BorderSizePixel = 0
Instance.new("UICorner", formBtn).CornerRadius = UDim.new(0, 5)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 0, 18)
status.Position = UDim2.new(0, 0, 0, 105)
status.BackgroundTransparency = 1
status.Text = "Ready | 4x4x4 | Char gap 4s"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 9

local disBtn = Instance.new("TextButton", frame)
disBtn.Size = UDim2.new(1, -20, 0, 24)
disBtn.Position = UDim2.new(0, 10, 0, 125)
disBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
disBtn.Text = "DISASSEMBLE"
disBtn.Font = Enum.Font.GothamBold
disBtn.TextSize = 11
disBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
disBtn.BorderSizePixel = 0
Instance.new("UICorner", disBtn).CornerRadius = UDim.new(0, 5)

-- Dragging
local drag, dStart, sPos = false, nil, nil
titleBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag = true; dStart = i.Position; sPos = frame.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if not drag then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local d = i.Position - dStart
		frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

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

local function startHolding()
	if shapeConnection then shapeConnection:Disconnect() end
	if #allOffsets == 0 then return end
	shapeActive = true
	shapeConnection = RunService.Heartbeat:Connect(function()
		if not shapeActive then return end
		for _, data in pairs(allOffsets) do
			if data.block and data.block.Parent then
				data.block.CFrame = data.worldPos
			end
		end
	end)
end

local function stopHolding()
	shapeActive = false
	if shapeConnection then shapeConnection:Disconnect() shapeConnection = nil end
end

grabBtn.MouseButton1Click:Connect(function()
	stopHolding()
	
	for _, block in pairs(grabbedBlocks) do
		if block and block.Parent then
			block.Velocity = Vector3.zero
			block.RotVelocity = Vector3.zero
			for _, v in pairs(block:GetChildren()) do
				if v:IsA("BodyMover") then v:Destroy() end
			end
			block.CanCollide = true
		end
	end
	table.clear(grabbedBlocks)
	allOffsets = {}

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
	for i = 1, math.min(maxBlocks, #foundParts) do
		table.insert(grabbedBlocks, foundParts[i].part)
	end
	status.Text = "Grabbed: " .. #grabbedBlocks .. " parts"
end)

formBtn.MouseButton1Click:Connect(function()
	stopHolding()
	
	local text = textBox.Text
	if text == "" then return end
	if #grabbedBlocks == 0 then
		status.Text = "Grab parts first!"
		return
	end

	local resolution = tonumber(sizeBox.Text) or 20
	local scale = resolution / 20
	local cellSize = 4

	local upperText = text:upper()

	local pixels = {}
	local totalChars = 0

	for _, codepoint in utf8.codes(upperText) do
		local char = utf8.char(codepoint)
		local glyph = font[char] or font[" "]
		for row = 1, 5 do
			for col = 1, 5 do
				if glyph[row]:sub(col, col) == "X" then
					for sy = 0, scale - 1 do
						for sx = 0, scale - 1 do
							table.insert(pixels, {
								row = (row - 1) * scale + sy + 1,
								col = (col - 1 + totalChars * 6) * scale + sx + 1
							})
						end
					end
				end
			end
		end
		totalChars = totalChars + 1
	end

	local totalWidth = totalChars * 6 * scale
	if #pixels == 0 then return end

	local blockIndex = 1
	allOffsets = {}
	local baseCF = CFrame.new(textPosition, textPosition + textLookDirection)

	for i = 1, #pixels do
		if blockIndex > #grabbedBlocks then break end
		local pixel = pixels[i]
		local worldX = (pixel.col - totalWidth / 2) * cellSize
		local worldY = (5 * scale - pixel.row) * cellSize

		local block = grabbedBlocks[blockIndex]
		if block and block.Parent then
			block.Velocity = Vector3.zero
			block.RotVelocity = Vector3.zero
			for _, v in pairs(block:GetChildren()) do
				if v:IsA("BodyMover") then v:Destroy() end
			end
			block.CanCollide = false
			block.Anchored = false
			local worldPos = baseCF * CFrame.new(worldX, worldY, 0)
			block.CFrame = worldPos
			table.insert(allOffsets, {block = block, worldPos = worldPos})
		end
		blockIndex = blockIndex + 1
	end

	startHolding()
	status.Text = "Formed: " .. upperText .. " | Res " .. resolution .. " | " .. #pixels .. " blocks"
end)

disBtn.MouseButton1Click:Connect(function()
	stopHolding()
	
	for _, block in pairs(grabbedBlocks) do
		if block and block.Parent then
			block.Velocity = Vector3.zero
			block.RotVelocity = Vector3.zero
			for _, v in pairs(block:GetChildren()) do
				if v:IsA("BodyMover") then v:Destroy() end
			end
			block.CanCollide = true
		end
	end
	table.clear(grabbedBlocks)
	allOffsets = {}
	status.Text = "Dissasembled"
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
end)

startHolding()
