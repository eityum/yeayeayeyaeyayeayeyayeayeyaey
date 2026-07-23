-- Eityum Hub - Universal Script Hub (Mobile Friendly)
local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")

local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "EityumHub"
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 200, 0, 450)
frame.Position = UDim2.new(0, 10, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextButton", frame)
title.Size = UDim2.new(0, 170, 0, 24)
title.Position = UDim2.new(0, 8, 0, 6)
title.Text = "Eityum Hub (drag)"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.AutoButtonColor = false

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(0, 170, 0, 7)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Mobile drag
local drag, dStart, sPos = false, nil, nil
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = i.Position; sPos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if not drag then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dStart
        frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

-- Scripts label
local scriptsLabel = Instance.new("TextLabel", frame)
scriptsLabel.Size = UDim2.new(1, -16, 0, 18)
scriptsLabel.Position = UDim2.new(0, 8, 0, 34)
scriptsLabel.Text = "-- SCRIPTS --"
scriptsLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
scriptsLabel.BackgroundTransparency = 1
scriptsLabel.Font = Enum.Font.GothamBold
scriptsLabel.TextSize = 10

local y = 54
local function addButton(name, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -16, 0, 28)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    y = y + 32
end

addButton("Mech", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/robot.lua"))()
end)

addButton("Cobra", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Cobra.lua"))()
end)

addButton("Wiggly Stick", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Stick.lua"))()
end)

addButton("Tornado", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Tornado.lua"))()
end)

addButton("Block Spawner", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/BlockSpawner.lua"))()
end)

addButton("Text Blocks", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/TextManipulate.lua"))()
end)

addButton("Telekinesis", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/TelekinesisByEityum.lua"))()
end)

addButton("F3X", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/F3X%20abuse.lua"))()
end)

addButton("SmileyHub", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/SmileyHub.lua"))()
end)

addButton("Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

-- Credits section
local creditLabel = Instance.new("TextLabel", frame)
creditLabel.Size = UDim2.new(1, -16, 0, 20)
creditLabel.Position = UDim2.new(0, 8, 0, y + 6)
creditLabel.Text = "-- CREDITS --"
creditLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
creditLabel.BackgroundTransparency = 1
creditLabel.Font = Enum.Font.GothamBold
creditLabel.TextSize = 11
y = y + 28

local credits = {
    {name = "Eityum", desc = "Creator & Developer", color = Color3.fromRGB(255, 200, 50)},
    {name = "Claude", desc = "Smiley Hub Original", color = Color3.fromRGB(200, 150, 255)},
    {name = "DeepSeek", desc = "Mech, Cobra, Stick, Tornado", color = Color3.fromRGB(100, 200, 255)},
    {name = "EdgeIY", desc = "Infinite Yield", color = Color3.fromRGB(255, 100, 100)},
}

for _, credit in pairs(credits) do
    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Size = UDim2.new(1, -16, 0, 18)
    nameLabel.Position = UDim2.new(0, 8, 0, y)
    nameLabel.Text = credit.name
    nameLabel.TextColor3 = credit.color
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    y = y + 18
    
    local descLabel = Instance.new("TextLabel", frame)
    descLabel.Size = UDim2.new(1, -16, 0, 14)
    descLabel.Position = UDim2.new(0, 8, 0, y)
    descLabel.Text = credit.desc
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 9
    y = y + 18
end

frame.Size = UDim2.new(0, 200, 0, y + 10)
