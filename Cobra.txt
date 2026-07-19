-- Cobra Controller - Fixed Kill + Wiggle 45 + W/S Swapped
local UIS,RS,WS,PS=game:GetService("UserInputService"),game:GetService("RunService"),game:GetService("Workspace"),game:GetService("Players")
local LPlayer,char=PS.LocalPlayer,PS.LocalPlayer.Character or PS.LocalPlayer.CharacterAdded:Wait()
local hum,root=char:WaitForChild("Humanoid"),char:WaitForChild("HumanoidRootPart")
local HttpService=game:GetService("HttpService")
local Mouse=LPlayer:GetMouse()

local LPlate,Active
for i,v in pairs(WS.Plates:GetChildren())do
    if v:FindFirstChild("Owner").Value==LPlayer then LPlate=v:FindFirstChild("Plate");Active=v:FindFirstChild("ActiveParts")end
end
local Remotes=game.ReplicatedStorage.Remotes
local StampAsset=Remotes.StampAsset;local DeleteAsset=Remotes.DeleteAsset
local Ids={Black=56453053}

function PlaceBlock(BlockID,CF,Welds,Did,Rotation)
    local result,conn
    conn=Active.ChildAdded:Connect(function(child)if child:IsA("Model")then result=child;child:SetAttribute("did",Did or HttpService:GenerateGUID(true));conn:Disconnect()end end)
    StampAsset:InvokeServer(BlockID,CF,Did or "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}",Welds or{},Rotation or 0)
    repeat task.wait()until result;return result
end

function isFree(p)
    if not p or not p.Parent or not p:IsA("BasePart")or p.Anchored then return false end
    if next(p:GetJoints())~=nil then return false end
    for _,c in pairs(p:GetChildren())do if c:IsA("JointInstance")or c:IsA("Constraint")or c:IsA("Attachment")then return false end end
    local a=p.Parent
    while a do if a:IsA("BasePart")and a.Anchored then return false elseif a:IsA("Tool")or a:IsA("HopperBin")then return false elseif a==WS then break end;a=a.Parent end
    for _,pl in pairs(PS:GetPlayers())do if pl.Character and p:IsDescendantOf(pl.Character)then return false end end
    return true
end

local parts,active,conn,cf={},false,nil,CFrame.new()
local speed,rspeed=30,math.rad(90)
local dirs={Forward=0,Backward=0,Left=0,Right=0,Up=0,Down=0}
local rotL,rotR,cycle,moving=false,false,0,false
local kbd,velConn=false,nil
local wiggleSpeed=45

local mo={}
for x=-4,4,4 do for y=12,20,4 do for z=56,64,4 do table.insert(mo,{pos=Vector3.new(x,y,z),tag="head"})end end end
for y=4,12,4 do for x=-16,16,4 do for z=24,48,4 do table.insert(mo,{pos=Vector3.new(x,y,z),tag="hood"})end end end
for seg=0,10 do local z=8-seg*8;local y=4-seg*2;for x=-8,8,4 do for dy=0,4,4 do table.insert(mo,{pos=Vector3.new(x,y+dy,z),tag="body"})end end end
for seg=0,5 do local z=-80-seg*12;local y=-16-seg*2;local width=(seg<3)and 8 or 4;for x=-width,width,4 do table.insert(mo,{pos=Vector3.new(x,y,z),tag="tail"})end end

local sg=Instance.new("ScreenGui",LPlayer:WaitForChild("PlayerGui"))
sg.Name="CobraController";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local mf=Instance.new("Frame",sg)
mf.Size=UDim2.new(0,250,0,240);mf.Position=UDim2.new(0.5,-125,0.5,-120)
mf.BackgroundColor3=Color3.fromRGB(15,15,15);mf.BorderSizePixel=0
Instance.new("UICorner",mf).CornerRadius=UDim.new(0,10)

local function btn(t,x,y,w,h,c,p)
    local b=Instance.new("TextButton",p or mf)
    b.Size=UDim2.new(0,w,0,h);b.Position=UDim2.new(0,x,0,y);b.BackgroundColor3=c
    b.Text=t;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(255,255,255);Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    return b
end
local function label(t,x,y,w,h,s)
    local l=Instance.new("TextLabel",mf)
    l.Size=UDim2.new(0,w,0,h);l.Position=UDim2.new(0,x,0,y);l.BackgroundTransparency=1
    l.Text=t;l.TextColor3=Color3.fromRGB(255,255,255);l.TextSize=s or 10
    l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left
    return l
end

local tb=btn("COBRA (drag)",0,0,250,28,Color3.fromRGB(25,25,25),mf)
tb.AutoButtonColor=false;tb.TextColor3=Color3.fromRGB(100,255,100)
local drag,dStart,sPos=false,nil,nil
tb.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true;dStart=i.Position;sPos=mf.Position end
end)
UIS.InputChanged:Connect(function(i)
    if not drag then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-dStart;mf.Position=UDim2.new(sPos.X.Scale,sPos.X.Offset+d.X,sPos.Y.Scale,sPos.Y.Offset+d.Y)end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

local stat=label("Cobra: Off",0,205,250,18,9)
stat.TextColor3=Color3.fromRGB(180,180,180)

local assembleBtn=btn("BUILD COBRA",5,33,115,26,Color3.fromRGB(50,200,50))
local disBtn=btn("DISASSEMBLE",125,33,115,26,Color3.fromRGB(255,80,80))
local kbdBtn=btn("KEYBOARD: OFF",5,64,240,26,Color3.fromRGB(100,100,100))

local function dirBtn(t,x,y,c,dir)
    local b=btn(t,x,y,40,30,c)
    b.MouseButton1Down:Connect(function()dirs[dir]=1;b.BackgroundColor3=Color3.fromRGB(255,255,100)end)
    b.MouseButton1Up:Connect(function()dirs[dir]=0;b.BackgroundColor3=c end)
    b.MouseLeave:Connect(function()dirs[dir]=0;b.BackgroundColor3=c end)
end
dirBtn("W",105,100,Color3.fromRGB(255,200,50),"Backward")
dirBtn("S",105,134,Color3.fromRGB(255,200,50),"Forward")
dirBtn("A",60,117,Color3.fromRGB(255,100,100),"Left")
dirBtn("D",150,117,Color3.fromRGB(255,100,100),"Right")
dirBtn("Q",195,100,Color3.fromRGB(100,200,255),"Up")
dirBtn("E",195,134,Color3.fromRGB(100,200,255),"Down")

local function rotBtn(t,x,y,setter)
    local b=btn(t,x,y,40,30,Color3.fromRGB(200,150,255))
    b.MouseButton1Down:Connect(function()setter(true);b.BackgroundColor3=Color3.fromRGB(255,255,100)end)
    b.MouseButton1Up:Connect(function()setter(false);b.BackgroundColor3=Color3.fromRGB(200,150,255)end)
    b.MouseLeave:Connect(function()setter(false);b.BackgroundColor3=Color3.fromRGB(200,150,255)end)
end
rotBtn("Z",5,100,function(v)rotL=v end);rotBtn("X",5,134,function(v)rotR=v end)

local sLabel=label("Speed: 30",5,175,80,18)
local sBox=Instance.new("TextBox",mf)
sBox.Size=UDim2.new(0,50,0,20);sBox.Position=UDim2.new(0,85,0,174)
sBox.BackgroundColor3=Color3.fromRGB(40,40,40);sBox.TextColor3=Color3.fromRGB(255,255,255)
sBox.Text="30";sBox.Font=Enum.Font.Gotham;sBox.TextSize=10;sBox.BorderSizePixel=0
Instance.new("UICorner",sBox).CornerRadius=UDim.new(0,4)
btn("SET",140,173,40,22,Color3.fromRGB(100,200,100)).MouseButton1Click:Connect(function()
    local n=tonumber(sBox.Text);if n and n>0 then speed=n;sLabel.Text="Speed: "..n end
end)

kbdBtn.MouseButton1Click:Connect(function()
    kbd=not kbd
    if kbd then kbdBtn.Text="KEYBOARD: ON (WASD/QE/ZX/F)";kbdBtn.BackgroundColor3=Color3.fromRGB(50,200,50)
        if velConn then velConn:Disconnect();velConn=nil end
    else kbdBtn.Text="KEYBOARD: OFF";kbdBtn.BackgroundColor3=Color3.fromRGB(100,100,100)
        if velConn then velConn:Disconnect()end
        local et=tick()+5
        velConn=RS.Heartbeat:Connect(function()
            if tick()>=et then if velConn then velConn:Disconnect();velConn=nil end return end
            root.Velocity=Vector3.zero;root.RotVelocity=Vector3.zero
        end)
    end
end)

local keyMap={[Enum.KeyCode.W]={"Backward",1},[Enum.KeyCode.S]={"Forward",1},[Enum.KeyCode.A]={"Left",1},[Enum.KeyCode.D]={"Right",1},[Enum.KeyCode.Q]={"Up",1},[Enum.KeyCode.E]={"Down",1}}
local keyTog={[Enum.KeyCode.Z]=function()rotL=true end,[Enum.KeyCode.X]=function()rotR=true end}
local keyTogOff={[Enum.KeyCode.Z]=function()rotL=false end,[Enum.KeyCode.X]=function()rotR=false end}
UIS.InputBegan:Connect(function(i,p)if p or not kbd then return end
    if keyMap[i.KeyCode]then dirs[keyMap[i.KeyCode][1]]=keyMap[i.KeyCode][2]
    elseif keyTog[i.KeyCode]then keyTog[i.KeyCode]()end
end)
UIS.InputEnded:Connect(function(i,p)if p or not kbd then return end
    if keyMap[i.KeyCode]then dirs[keyMap[i.KeyCode][1]]=0
    elseif keyTogOff[i.KeyCode]then keyTogOff[i.KeyCode]()end
end)

local function getTargetPlayer()
    local headPos=cf:PointToWorldSpace(Vector3.new(0,16,60))
    local best=nil
    for _,pl in pairs(PS:GetPlayers())do
        if pl~=LPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")then
            local hrp=pl.Character.HumanoidRootPart
            local dist=(hrp.Position-headPos).Magnitude
            if dist<25 then best=pl end
        end
    end
    return best
end

local function killPlayer(pl)
    if not pl then return end
    if pl:IsA("Player")then pl=pl.Character and pl.Character.PrimaryPart end
    if not pl then return end
    StampAsset:InvokeServer(41324885,LPlate.CFrame-Vector3.new(0,9e9,0),"{99ab22df-ca29-4143-a2fd-0a1b79db78c2}",{pl},0)
end

UIS.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode==Enum.KeyCode.F and active and kbd then
        local target=getTargetPlayer()
        if target then killPlayer(target);stat.Text="Cobra: Killed "..target.Name end
    end
end)

function posCobra()
    if not active then return end
    local bi=1
    for _,d in pairs(mo)do
        if bi>#parts then break end
        local b=parts[bi]
        if b and b.Parent then
            for _,v in pairs(b:GetChildren())do if v:IsA("BodyMover")then v:Destroy()end end
            b.RotVelocity=Vector3.zero;b.CanCollide=false;b.Anchored=false
            local o,t=d.pos,d.tag
            local iw=math.sin(cycle*wiggleSpeed*0.05)*0.8
            local ww=math.sin(cycle*wiggleSpeed*0.1+d.pos.Z*0.03)*(moving and 4 or 1)
            if t=="head"then b.CFrame=cf*CFrame.new(o+Vector3.new(ww,iw+math.sin(cycle*wiggleSpeed*0.07)*1,0))*CFrame.Angles(0,math.rad(ww*3),0)
            elseif t=="hood"then b.CFrame=cf*CFrame.new(o+Vector3.new(ww*1.3,iw,0))*CFrame.Angles(0,math.rad(ww*2),0)
            elseif t=="body"then b.CFrame=cf*CFrame.new(o+Vector3.new(ww,iw*0.5,0))
            elseif t=="tail"then b.CFrame=cf*CFrame.new(o+Vector3.new(ww*0.8,iw*0.3,0))
            end
        end
        bi=bi+1
    end
end

local function assemble()
    for _,b in pairs(parts)do if b and b.Parent then b.Velocity=Vector3.zero;b.CanCollide=true end end
    table.clear(parts);if conn then conn:Disconnect()end;active=false
    local fp={}
    for _,model in pairs(Active:GetChildren())do
        if model:IsA("Model")and model.PrimaryPart then
            local p=model.PrimaryPart
            if isFree(p)and p.Transparency<0.5 then table.insert(fp,{part=p,dist=(p.Position-LPlate.Position).Magnitude})end
        end
    end
    if #fp==0 then stat.Text="No loose parts!"return end
    table.sort(fp,function(a,b)return a.dist<b.dist end)
    for i=1,math.min(#mo,#fp)do table.insert(parts,fp[i].part)end
    if #parts==0 then stat.Text="No blocks"return end
    cf=LPlate.CFrame*CFrame.new(0,5,-10);cycle=0;moving=false
    posCobra();active=true;stat.Text="Cobra: On ("..#parts.." parts)"
    conn=RS.Heartbeat:Connect(function(dt)
        if not active then return end
        if kbd then root.CFrame=CFrame.new(cf.Position+cf:VectorToWorldSpace(Vector3.new(0,40,0)))end
        local mv=Vector3.new(dirs.Right-dirs.Left,dirs.Up-dirs.Down,dirs.Backward-dirs.Forward)
        moving=mv.Magnitude>0
        if moving then cf+=cf:VectorToWorldSpace(mv.Unit)*speed*dt;cycle+=dt*4
        else cycle+=dt*1.5 end
        if rotL then cf*=CFrame.Angles(0,rspeed*dt,0)end
        if rotR then cf*=CFrame.Angles(0,-rspeed*dt,0)end
        posCobra()
    end)
end

local function disassemble()
    active=false
    if conn then conn:Disconnect()end
    if velConn then velConn:Disconnect();velConn=nil end
    for _,b in pairs(parts)do if b and b.Parent then b.Velocity=Vector3.zero;b.CanCollide=true;for _,v in pairs(b:GetChildren())do if v:IsA("BodyMover")then v:Destroy()end end end end
    stat.Text="Cobra: Off"
end

assembleBtn.MouseButton1Click:Connect(assemble)
disBtn.MouseButton1Click:Connect(disassemble)

LPlayer.CharacterAdded:Connect(function(c)
    char=c;hum=char:WaitForChild("Humanoid");root=char:WaitForChild("HumanoidRootPart")
    sg.Parent=LPlayer:WaitForChild("PlayerGui")
    disassemble()
    if velConn then velConn:Disconnect();velConn=nil end
    table.clear(parts)
end)