-- Telekinesis V7 Multi-Grab Ring G Freeze GUI Spin Control
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local CFnew = CFrame.new
local CFAng = CFrame.Angles
local V3new = Vector3.new
local V3zero = V3new(0, 0, 0)
local huge = math.huge
local rad = math.rad
local max = math.max
local pi = math.pi
local Ins = Instance.new
local Smooth = Enum.SurfaceType.Smooth
local Sphere = Enum.MeshType.Sphere
local White = BrickColor.new("Institutional white")
local Blue = BrickColor.new("Blue")
local wait = task.wait
local delay = task.delay
local spawn = task.spawn
local pcall = pcall

local sandbox = function(var, func)
    local env = getfenv(func)
    local newenv = setmetatable({}, {
        __index = function(self, k)
            if k == "script" then return var else return env[k] end
        end,
    })
    setfenv(func, newenv)
    return func
end

local cors = {}
local _Name = "Telekinesis V7"
local mas = Ins("Model", Lighting)
local con = getfenv().sethiddenproperty

local Tool0 = Ins("Tool")
local Part1 = Ins("Part")
local Script2 = Ins("Script")
local light = Ins("Highlight", Tool0)
light.FillTransparency = 1
local LocalScript3 = Ins("LocalScript")

Tool0.Name = _Name
Tool0.Parent = mas
Tool0.Grip = CFnew(0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1)
Tool0.GripPos = V3new(0, 0, 1)

Part1.Name = "Handle"
Part1.Parent = Tool0
Part1.Size = V3new(1, 1, 1)
Part1.Transparency = 1
Part1.Locked = true
Part1.CanCollide = false
Part1.BottomSurface = Smooth
Part1.TopSurface = Smooth
Part1.BrickColor = White

Script2.Name = "LineConnect"
Script2.Parent = Tool0
light.Adornee = nil

local speed = 55
local mb = UserInputService.TouchEnabled

local Sound = Ins("Sound", Workspace)
Sound.SoundId = "rbxassetid://1092093337"
Sound.Volume = 0.5
Sound:Play()

RunService.RenderStepped:Connect(function()
    if con then con(player, "SimulationRadius", speed) end
end)

table.insert(cors, sandbox(Script2, function()
    local check = script.Part2
    local part1 = script.Part1.Value
    local part2 = script.Part2.Value
    local parent = script.Par.Value
    local color = script.Color
    local line = Ins("Part")
    line.TopSurface = 0
    line.BottomSurface = 0
    line.Reflectance = 0.5
    line.Name = "Laser"
    line.Locked = true
    line.CanCollide = false
    line.Anchored = true
    line.formFactor = 0
    line.Size = V3new(1, 1, 1)
    local mesh = Ins("BlockMesh")
    mesh.Parent = line
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not check.Value or not part1 or not part2 or not parent then
            connection:Disconnect()
            line:Destroy()
            script:Destroy()
            return
        end
        if not part1.Parent or not part2.Parent or not parent.Parent then
            connection:Disconnect()
            line:Destroy()
            script:Destroy()
            return
        end
        local lv = CFnew(part1.Position, part2.Position)
        local dist = (part1.Position - part2.Position).Magnitude
        line.Parent = parent
        line.BrickColor = color.Value.BrickColor
        line.Reflectance = color.Value.Reflectance
        line.Transparency = color.Value.Transparency
        line.CFrame = CFnew(part1.Position + lv.LookVector * dist / 2)
        line.CFrame = CFnew(line.Position, part2.Position)
        mesh.Scale = V3new(0.25, 0.25, dist)
    end)
end))

Script2.Disabled = true
LocalScript3.Name = "MainScript"
LocalScript3.Parent = Tool0

table.insert(cors, sandbox(LocalScript3, function()
    local tool = script.Parent
    local lineconnect = tool.LineConnect
    local object = nil
    local mousedown = false
    local BP = nil
    local dist = 20
    local currentMouse = nil
    local isLevitating = false
    local levitateConnection = nil
    local levitateBG = nil
    local isFrozen = false
    local objval = nil
    local front = tool.Handle
    local color = tool.Handle
    
    local multiObjects = {}
    local multiBPs = {}
    local isMultiMode = false
    local multiFrozen = false
    local gHeld = false
    
    -- Spin value
    local spinSpeed = 500
    
    local point = Ins("Part")
    point.Locked = true
    point.Anchored = true
    point.formFactor = 0
    point.Shape = 0
    point.BrickColor = Blue
    point.Size = V3new(0, 0, 0)
    point.CanCollide = false
    local mesh = Ins("SpecialMesh", point)
    mesh.MeshType = Sphere
    mesh.Scale = V3new(0.7, 0.7, 0.7)
    
    local BPForce = V3new(999999, 999999, 999999)
    local BGTorque = V3new(huge, huge, huge)
    local BVForceHuge = V3new(huge, huge, huge)
    
    -- Spin GUI
    local SpinGui = Ins("ScreenGui")
    SpinGui.Name = "SpinControl"
    SpinGui.Parent = player.PlayerGui
    
    local SpinFrame = Ins("Frame")
    SpinFrame.Name = "SpinFrame"
    SpinFrame.Size = UDim2.new(0, 180, 0, 80)
    SpinFrame.Position = UDim2.new(0, 10, 0, 10)
    SpinFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SpinFrame.BorderSizePixel = 0
    SpinFrame.Active = true
    SpinFrame.Draggable = true
    SpinFrame.Parent = SpinGui
    
    local SpinCorner = Ins("UICorner")
    SpinCorner.CornerRadius = UDim.new(0, 6)
    SpinCorner.Parent = SpinFrame
    
    local SpinTitle = Ins("TextLabel")
    SpinTitle.Name = "SpinTitle"
    SpinTitle.Size = UDim2.new(1, 0, 0, 22)
    SpinTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpinTitle.BorderSizePixel = 0
    SpinTitle.Text = "Spin Speed: " .. spinSpeed
    SpinTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpinTitle.TextSize = 13
    SpinTitle.Font = Enum.Font.GothamBold
    SpinTitle.Parent = SpinFrame
    
    local SpinTitleCorner = Ins("UICorner")
    SpinTitleCorner.CornerRadius = UDim.new(0, 6)
    SpinTitleCorner.Parent = SpinTitle
    
    local SpinInput = Ins("TextBox")
    SpinInput.Name = "SpinInput"
    SpinInput.Size = UDim2.new(0, 100, 0, 25)
    SpinInput.Position = UDim2.new(0, 10, 0, 30)
    SpinInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpinInput.BorderSizePixel = 0
    SpinInput.PlaceholderText = "Enter speed..."
    SpinInput.Text = ""
    SpinInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpinInput.TextSize = 13
    SpinInput.Font = Enum.Font.Gotham
    SpinInput.Parent = SpinFrame
    
    local SpinInputCorner = Ins("UICorner")
    SpinInputCorner.CornerRadius = UDim.new(0, 4)
    SpinInputCorner.Parent = SpinInput
    
    local SetBtn = Ins("TextButton")
    SetBtn.Name = "SetBtn"
    SetBtn.Size = UDim2.new(0, 55, 0, 25)
    SetBtn.Position = UDim2.new(0, 115, 0, 30)
    SetBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SetBtn.BorderSizePixel = 0
    SetBtn.Text = "Set"
    SetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SetBtn.TextSize = 13
    SetBtn.Font = Enum.Font.GothamBold
    SetBtn.Parent = SpinFrame
    
    local SetBtnCorner = Ins("UICorner")
    SetBtnCorner.CornerRadius = UDim.new(0, 4)
    SetBtnCorner.Parent = SetBtn
    
    local CurrentLabel = Ins("TextLabel")
    CurrentLabel.Name = "CurrentLabel"
    CurrentLabel.Size = UDim2.new(1, -20, 0, 18)
    CurrentLabel.Position = UDim2.new(0, 10, 0, 58)
    CurrentLabel.BackgroundTransparency = 1
    CurrentLabel.Text = "Current: " .. spinSpeed
    CurrentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    CurrentLabel.TextSize = 11
    CurrentLabel.Font = Enum.Font.Gotham
    CurrentLabel.Parent = SpinFrame
    
    SetBtn.MouseButton1Click:Connect(function()
        local newSpeed = tonumber(SpinInput.Text)
        if newSpeed then
            spinSpeed = newSpeed
            SpinTitle.Text = "Spin Speed: " .. spinSpeed
            CurrentLabel.Text = "Current: " .. spinSpeed
            SpinInput.Text = ""
        end
    end)
    
    SpinInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(SpinInput.Text)
            if newSpeed then
                spinSpeed = newSpeed
                SpinTitle.Text = "Spin Speed: " .. spinSpeed
                CurrentLabel.Text = "Current: " .. spinSpeed
                SpinInput.Text = ""
            end
        end
    end)
    
    local function createBP()
        local newBP = Ins("BodyPosition")
        newBP.MaxForce = BPForce
        newBP.P = 100000
        newBP.D = 100
        return newBP
    end
    
    local function cleanupMulti()
        for _, bp in pairs(multiBPs) do
            if bp and bp.Parent then
                bp.Parent = nil
                bp:Destroy()
            end
        end
        for _, obj in pairs(multiObjects) do
            if obj and obj.Parent then
                obj.Anchored = false
            end
        end
        multiBPs = {}
        multiObjects = {}
        isMultiMode = false
        multiFrozen = false
    end
    
    local function freezeMulti()
        if not isMultiMode then return end
        multiFrozen = true
        for _, bp in pairs(multiBPs) do
            if bp and bp.Parent then
                bp.Parent = nil
                bp:Destroy()
            end
        end
        multiBPs = {}
        for _, obj in pairs(multiObjects) do
            if obj and obj.Parent then
                obj.Anchored = true
            end
        end
    end
    
    local function unfreezeMulti()
        if not isMultiMode then return end
        multiFrozen = false
        for _, obj in pairs(multiObjects) do
            if obj and obj.Parent then
                obj.Anchored = false
            end
        end
        multiBPs = {}
        for i, obj in pairs(multiObjects) do
            if obj and obj.Parent then
                local bp = createBP()
                pcall(function() bp.Parent = obj end)
                multiBPs[i] = bp
            end
        end
    end
    
    local function addToMulti(obj)
        if not obj or not obj.Parent then return end
        if #multiObjects >= 15 then return end
        if multiFrozen then
            obj.Anchored = true
        end
        multiObjects[#multiObjects + 1] = obj
        if not multiFrozen then
            local bp = createBP()
            pcall(function() bp.Parent = obj end)
            multiBPs[#multiBPs + 1] = bp
        else
            multiBPs[#multiBPs + 1] = nil
        end
        isMultiMode = true
    end
    
    local function rotateObject(axis, degrees)
        if not object or not object.Parent then return end
        if isFrozen then return end
        local bg = Ins("BodyGyro")
        bg.MaxTorque = BGTorque
        bg.CFrame = object.CFrame * CFAng(
            axis == "X" and rad(degrees) or 0,
            axis == "Y" and rad(degrees) or 0,
            axis == "Z" and rad(degrees) or 0
        )
        bg.Parent = object
        delay(0.1, function() if bg and bg.Parent then bg:Destroy() end end)
    end
    
    local function spinSingle(obj)
        if not obj or not obj.Parent then return end
        for _, v in pairs(obj:GetChildren()) do
            if v.ClassName == "BodyAngularVelocity" then v:Destroy() end
        end
        local av = Ins("BodyAngularVelocity")
        av.MaxTorque = BGTorque
        av.AngularVelocity = V3new(0, spinSpeed, 0)
        av.Parent = obj
    end
    
    local function spinObject()
        if isMultiMode and #multiObjects > 0 then
            for _, obj in pairs(multiObjects) do
                spinSingle(obj)
            end
            return
        end
        if object and object.Parent then
            spinSingle(object)
        end
    end
    
    local function freezeObject()
        if not object or not object.Parent then return end
        if isFrozen then
            isFrozen = false
            object.Anchored = false
            for _, v in pairs(object:GetChildren()) do
                if v.ClassName == "BodyPosition" or v.ClassName == "BodyGyro" or v.ClassName == "BodyVelocity" or v.ClassName == "BodyAngularVelocity" then
                    v:Destroy()
                end
            end
            object.Velocity = V3zero
            object.RotVelocity = V3zero
            return
        end
        isFrozen = true
        stopLevitating()
        cleanupBP()
        for _, v in pairs(object:GetChildren()) do
            if v.ClassName == "BodyPosition" or v.ClassName == "BodyGyro" or v.ClassName == "BodyVelocity" or v.ClassName == "BodyAngularVelocity" then
                v:Destroy()
            end
        end
        object.Velocity = V3zero
        object.RotVelocity = V3zero
        object.Anchored = true
    end
    
    local function balanceObject()
        if not object or not object.Parent then return end
        if isFrozen then return end
        for _, v in pairs(object:GetChildren()) do
            if v.ClassName == "BodyGyro" then v:Destroy() end
        end
        object.Velocity = V3zero
        object.RotVelocity = V3zero
        local bg = Ins("BodyGyro")
        bg.MaxTorque = BGTorque
        bg.CFrame = CFnew(object.Position)
        bg.D = 500
        bg.P = 100000
        bg.Parent = object
    end
    
    local function cleanupBP()
        if BP and BP.Parent then
            BP.Parent = nil
            BP:Destroy()
        end
        BP = nil
    end
    
    local function stopLevitating()
        if levitateConnection then
            levitateConnection:Disconnect()
            levitateConnection = nil
        end
        if levitateBG and levitateBG.Parent then
            levitateBG:Destroy()
            levitateBG = nil
        end
        if object and object.Parent then
            object.Anchored = false
        end
        isLevitating = false
    end
    
    local function levitateObject()
        if not object or not object.Parent then return end
        if isLevitating then return end
        if isFrozen then return end
        isLevitating = true
        cleanupBP()
        object.Anchored = true
        levitateBG = Ins("BodyGyro")
        levitateBG.MaxTorque = BGTorque
        levitateBG.CFrame = CFnew(object.Position)
        levitateBG.D = 500
        levitateBG.P = 100000
        levitateBG.Parent = object
        local levitateHeight = object.Position.Y
        levitateConnection = RunService.RenderStepped:Connect(function()
            if not object or not object.Parent then
                stopLevitating()
                return
            end
            levitateHeight = levitateHeight + 0.02
            object.CFrame = CFnew(object.Position.X, levitateHeight, object.Position.Z)
        end)
    end
    
    local function throwObject()
        if not object or not object.Parent then return end
        if isFrozen then
            object.Anchored = false
            isFrozen = false
        end
        stopLevitating()
        cleanupBP()
        local aimPos = front.Position + front.CFrame.LookVector * 100
        if currentMouse and currentMouse.Hit and currentMouse.Hit.Position then
            aimPos = currentMouse.Hit.Position
        end
        local bv = Ins("BodyVelocity")
        bv.MaxForce = BVForceHuge
        bv.Velocity = (aimPos - front.Position).Unit * 300
        bv.Parent = object
        delay(0.5, function() if bv and bv.Parent then bv:Destroy() end end)
        if objval then objval.Value = nil end
        object = nil
        light.Adornee = nil
        mousedown = false
    end
    
    local function launchObject()
        if isMultiMode and #multiObjects > 0 then
            if multiFrozen then unfreezeMulti() end
            local aimPos = front.Position + front.CFrame.LookVector * 100
            if currentMouse and currentMouse.Hit and currentMouse.Hit.Position then
                aimPos = currentMouse.Hit.Position
            end
            local direction = (aimPos - front.Position).Unit
            for i, obj in pairs(multiObjects) do
                if obj and obj.Parent then
                    if obj.Anchored then obj.Anchored = false end
                    local bv = Ins("BodyVelocity")
                    bv.MaxForce = BVForceHuge
                    bv.Velocity = direction * 500
                    bv.Parent = obj
                    delay(0.5, function() if bv and bv.Parent then bv:Destroy() end end)
                end
            end
            cleanupMulti()
            object = nil
            light.Adornee = nil
            mousedown = false
            return
        end
        if not object or not object.Parent then return end
        if isFrozen then
            object.Anchored = false
            isFrozen = false
        end
        stopLevitating()
        cleanupBP()
        local aimPos = object.Position + front.CFrame.LookVector * 100
        if currentMouse and currentMouse.Hit and currentMouse.Hit.Position then
            aimPos = currentMouse.Hit.Position
        end
        local bv = Ins("BodyVelocity")
        bv.MaxForce = BVForceHuge
        bv.Velocity = (aimPos - object.Position).Unit * 500
        bv.Parent = object
        delay(0.5, function() if bv and bv.Parent then bv:Destroy() end end)
        if objval then objval.Value = nil end
        object = nil
        light.Adornee = nil
        mousedown = false
    end
    
    local function positionMultiObjects()
        if not isMultiMode or #multiObjects == 0 then return end
        if multiFrozen then return end
        local count = #multiObjects
        
        if count <= 6 then
            local aimPos = front.Position + front.CFrame.LookVector * dist
            if currentMouse and currentMouse.Hit and currentMouse.Hit.Position then
                aimPos = currentMouse.Hit.Position
            end
            local direction = (aimPos - front.Position).Unit
            local rightVec = front.CFrame.RightVector
            for i, obj in pairs(multiObjects) do
                if obj and obj.Parent and multiBPs[i] and multiBPs[i].Parent then
                    local offset = (i - (count - 1) / 2) * 10
                    multiBPs[i].Position = front.Position + direction * dist + rightVec * offset
                end
            end
        else
            local ringRadius = 10
            local centerPos = front.Position
            local lookDir = front.CFrame.LookVector
            local rightDir = front.CFrame.RightVector
            local upDir = front.CFrame.UpVector
            
            for i, obj in pairs(multiObjects) do
                if obj and obj.Parent and multiBPs[i] and multiBPs[i].Parent then
                    local angle = (i - 1) * (2 * pi / count)
                    local ringPos = centerPos + rightDir * math.cos(angle) * ringRadius + upDir * math.sin(angle) * ringRadius + lookDir * dist
                    multiBPs[i].Position = ringPos
                end
            end
        end
    end
    
    local LineConnect = function(part1, part2, parent)
        local p1 = Ins("ObjectValue")
        p1.Value = part1
        p1.Name = "Part1"
        local p2 = Ins("ObjectValue")
        p2.Value = part2
        p2.Name = "Part2"
        local par = Ins("ObjectValue")
        par.Value = parent
        par.Name = "Par"
        local col = Ins("ObjectValue")
        col.Value = color
        col.Name = "Color"
        local s = lineconnect:Clone()
        s.Disabled = false
        p1.Parent = s
        p2.Parent = s
        par.Parent = s
        col.Parent = s
        s.Parent = Workspace
        if part2 == object then objval = p2 end
    end
    
    local onButton1Down = function(mouse)
        if mousedown then return end
        if isFrozen then return end
        if isMultiMode then return end
        mousedown = true
        spawn(function()
            local p = point:Clone()
            p.Parent = tool
            LineConnect(front, p, Workspace)
            while mousedown do
                p.Parent = tool
                if not object then
                    if mouse.Target then
                        p.CFrame = CFnew(mouse.Hit.Position)
                    else
                        local lv = CFnew(front.Position, mouse.Hit.Position)
                        p.CFrame = CFnew(front.Position + (lv.LookVector * 1000))
                    end
                else
                    LineConnect(front, object, Workspace)
                    break
                end
                wait()
            end
            p:Destroy()
        end)
        while mousedown do
            if mouse.Target and not mouse.Target.Anchored and mouse.Target ~= Workspace.Terrain then
                object = mouse.Target
                light.Adornee = object
                dist = (object.Position - front.Position).Magnitude
                break
            end
            wait()
        end
        if not object or not object.Parent then
            mousedown = false
            return
        end
        if not isLevitating and not isFrozen then
            BP = createBP()
            pcall(function() BP.Parent = object end)
        end
        while mousedown and object and object.Parent and BP and BP.Parent and not isFrozen do
            local lv = CFnew(front.Position, mouse.Hit.Position)
            BP.Position = front.Position + lv.LookVector * dist
            wait()
        end
        if not isLevitating and not isFrozen then
            cleanupBP()
            if objval then objval.Value = nil end
            object = nil
            light.Adornee = nil
        end
    end
    
    local onKeyDown = function(key, mouse)
        key = key:lower()
        if key == "q" then dist = max(5, dist - 5)
        elseif key == "e" then dist = dist + 5
        elseif key == "x" then dist = 15
        elseif key == "y" then throwObject()
        elseif key == "j" then dist = 5000
        elseif key == "u" and object and object.Parent then rotateObject("Y", 45)
        elseif key == "i" and object and object.Parent then rotateObject("Y", -45)
        elseif key == "o" and object and object.Parent then rotateObject("X", 45)
        elseif key == "k" and object and object.Parent then rotateObject("X", -45)
        elseif key == "p" and object and object.Parent then levitateObject()
        elseif key == "l" then balanceObject()
        elseif key == "f" then launchObject()
        elseif key == "h" then spinObject()
        elseif key == "r" and object and object.Parent then freezeObject()
        elseif key == "t" then
            if mouse.Target and not mouse.Target.Anchored and mouse.Target ~= Workspace.Terrain then
                addToMulti(mouse.Target)
            end
        elseif key == "z" then
            if isMultiMode then cleanupMulti() end
            if object and object.Parent then
                stopLevitating()
                isFrozen = false
                object.Anchored = false
                object.Velocity = V3zero
                object.RotVelocity = V3zero
                for _, v in pairs(object:GetChildren()) do
                    if v.ClassName == "BodyGyro" or v.ClassName == "BodyVelocity" or v.ClassName == "BodyAngularVelocity" then v:Destroy() end
                end
            end
        end
    end
    
    spawn(function()
        while true do
            if isMultiMode and #multiObjects > 0 then
                positionMultiObjects()
            end
            wait()
        end
    end)
    
    local onEquipped = function(mouse)
        currentMouse = mouse
        local char = tool.Parent
        local human = char:FindFirstChildOfClass("Humanoid")
        if human then
            human.Died:Connect(function()
                mousedown = false
                stopLevitating()
                cleanupBP()
                cleanupMulti()
                point:Destroy()
                tool:Destroy()
                SpinGui:Destroy()
            end)
        end
        mouse.Button1Down:Connect(function() onButton1Down(mouse) end)
        mouse.KeyDown:Connect(function(key) onKeyDown(key, mouse) end)
        if mb then
            UserInputService.TouchLongPress:Connect(function() onKeyDown("y", mouse) end)
            UserInputService.TouchEnded:Connect(function() mousedown = false end)
        else
            mouse.Button1Up:Connect(function() mousedown = false end)
        end
    end
    
    tool.Equipped:Connect(onEquipped)
    tool.Unequipped:Connect(function()
        mousedown = false
        stopLevitating()
        cleanupBP()
        cleanupMulti()
        currentMouse = nil
        isFrozen = false
        gHeld = false
        if object then object = nil light.Adornee = nil end
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.G then
            gHeld = true
            if isMultiMode and not multiFrozen then
                freezeMulti()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.G then
            gHeld = false
            if isMultiMode and multiFrozen then
                unfreezeMulti()
            end
        end
    end)
end))

for i, v in pairs(mas:GetChildren()) do
    v.Parent = player.Backpack
    pcall(function() v:MakeJoints() end)
end
mas:Destroy()

for i, v in pairs(cors) do
    spawn(function() pcall(v) end)
end