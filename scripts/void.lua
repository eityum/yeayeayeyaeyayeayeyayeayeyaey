-- Kill GUI - Player List, Click to Kill - CoreGui
local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LPlate = nil
local Plates = Workspace:FindFirstChild("Plates")
if Plates then
    for _, Plate in pairs(Plates:GetChildren()) do
        local ov = Plate:FindFirstChild("Owner")
        if ov and ov.Value == player then
            LPlate = Plate:FindFirstChild("Plate") or Plate
            break
        end
    end
end

local StampAsset = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("StampAsset")

local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "KillGUI"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 10, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextButton", frame)
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "KILL GUI (drag)"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.AutoButtonColor = false

local list = Instance.new("ScrollingFrame", frame)
list.Size = UDim2.new(1, -10, 1, -58)
list.Position = UDim2.new(0, 5, 0, 28)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new(0, 0, 0, 0)

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 4)

local killAllBtn = Instance.new("TextButton", frame)
killAllBtn.Size = UDim2.new(1, -10, 0, 24)
killAllBtn.Position = UDim2.new(0, 5, 1, -28)
killAllBtn.AnchorPoint = Vector2.new(0, 1)
killAllBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
killAllBtn.Text = "KILL ALL"
killAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killAllBtn.Font = Enum.Font.GothamBold
killAllBtn.TextSize = 11
killAllBtn.BorderSizePixel = 0
Instance.new("UICorner", killAllBtn).CornerRadius = UDim.new(0, 4)

local UIS = game:GetService("UserInputService")
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

local function killTarget(plr)
    if not LPlate or not StampAsset then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        StampAsset:InvokeServer(41324885, LPlate.CFrame - Vector3.new(0, 9e9, 0), "{99ab22df-ca29-4143-a2fd-0a1b79db78c2}", {hrp}, 0)
    end)
end

killAllBtn.MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            killTarget(plr)
        end
    end
end)

local function refreshList()
    for _, v in pairs(list:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    local y = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton", list)
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                killTarget(plr)
                btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                task.wait(0.3)
                if btn and btn.Parent then
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
            end)
            
            y = y + 32
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, y)
end

refreshList()
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
