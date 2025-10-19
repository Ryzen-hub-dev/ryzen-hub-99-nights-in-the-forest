local version = LRM_ScriptVersion and "v" .. table.concat(LRM_ScriptVersion:split(""), ".") or "Dev Version"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:Popup({
    Title = "Ryzen Hub",
    Icon = "rbxassetid://84501312005643",
    Content = "Join our Discord server",
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function()
                setclipboard("https://discord.gg/KG9ADqwT9Q")
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Discord Invite",
                    Text = "Link Copied to Clipboard!",
                    Icon = "rbxassetid://84501312005643",
                    Duration = 4
                })
            end
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "Ryzen Hub - 99 Nights In The Forest",
    Icon = "rbxassetid://84501312005643",
    Author = (premium and "Premium" or "Fish It") .. " | " .. version,
    Folder = "RyzenHub_NITF",
    Size = UDim2.fromOffset(380, 260),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "",
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    },
})

local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local IYMouse = player:GetMouse()

-- Variables for toggles and settings
local ActiveEspItems, ActiveDistanceEsp, ActiveEspEnemy, ActiveEspChildren, ActiveEspPeltTrader = false, false, false, false, false
local ActivateFly, AlrActivatedFlyPC, ActiveNoCooldownPrompt, ActiveNoFog = false, false, false, false
local ActiveAutoChopTree, ActiveKillAura, ActivateInfiniteJump, ActiveNoclip = false, false, false, false
local DistanceForKillAura = 25
local DistanceForAutoChopTree = 25
local ValueSpeed = 16
local OldSpeed = player.Character and player.Character.Humanoid.WalkSpeed or 16
local iyflyspeed = 1
local FLYING = false
local QEfly = true
local vehicleflyspeed = 1
local TextBoxText = ""
local isInTheMap = "no"
local HowManyItemCanShowUp = 0

-- Tabs
local Info = Window:Tab({ Title = "Info", Icon = "info" })
local Player = Window:Tab({ Title = "Player", Icon = "user" })
local Esp = Window:Tab({ Title = "ESP", Icon = "eye" })
local Game = Window:Tab({ Title = "Game", Icon = "gamepad" })
local BringItem = Window:Tab({ Title = "Bring Item", Icon = "package" })
local Discord = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
local Config = Window:Tab({ Title = "Config", Icon = "file-cog" })

-- Helper Functions
local function DragItem(Item)
    task.spawn(function()
        for _, tool in pairs(player.Inventory:GetChildren()) do
            if tool:IsA("Model") and tool:GetAttribute("NumberItems") and tool:GetAttribute("Capacity") and tool:GetAttribute("NumberItems") < tool:GetAttribute("Capacity") then
                task.spawn(function()
                    local args = { tool, Item }
                    RepStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestBagStoreItem"):InvokeServer(unpack(args))
                    wait(0.1)
                end)
            end
            wait(0.25)
        end
    end)
end

local function getServerInfo()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local isStudio = RunService:IsStudio()
    return {
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        IsStudio = isStudio,
        CurrentPlayers = playerCount,
        MaxPlayers = maxPlayers
    }
end

local function sFLY(vfly)
    repeat wait() until player.Character and player.Character:WaitForChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid")
    repeat wait() until IYMouse
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

    local T = player.Character:WaitForChild("HumanoidRootPart")
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            repeat wait()
                if not vfly and player.Character:FindFirstChildOfClass('Humanoid') then
                    player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = 50
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = workspace.CurrentCamera.CoordinateFrame
            until not FLYING
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if player.Character:FindFirstChildOfClass('Humanoid') then
                player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end
    flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
        if KEY:lower() == 'w' then
            CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY:lower() == 's' then
            CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY:lower() == 'a' then
            CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY:lower() == 'd' then 
            CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
        elseif QEfly and KEY:lower() == 'e' then
            CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
        elseif QEfly and KEY:lower() == 'q' then
            CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    end)
    flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
        if KEY:lower() == 'w' then
            CONTROL.F = 0
        elseif KEY:lower() == 's' then
            CONTROL.B = 0
        elseif KEY:lower() == 'a' then
            CONTROL.L = 0
        elseif KEY:lower() == 'd' then
            CONTROL.R = 0
        elseif KEY:lower() == 'e' then
            CONTROL.Q = 0
        elseif KEY:lower() == 'q' then
            CONTROL.E = 0
        end
    end)
    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
    if player.Character:FindFirstChildOfClass('Humanoid') then
        player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = "BodyVelocity"
local gyroHandlerName = "BodyGyro"
local mfly1, mfly2

local function UnMobileFly()
    pcall(function()
        FLYING = false
        local root = player.Character:WaitForChild("HumanoidRootPart")
        root:FindFirstChild(velocityHandlerName):Destroy()
        root:FindFirstChild(gyroHandlerName):Destroy()
        player.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        mfly1:Disconnect()
        mfly2:Disconnect()
    end)
end

local function MobileFly()
    UnMobileFly()
    FLYING = true
    local root = player.Character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    local v3none = Vector3.new()
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3zero
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    mfly1 = player.CharacterAdded:Connect(function()
        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = v3zero
        bv.Velocity = v3zero

        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 50
    end)

    mfly2 = RunService.RenderStepped:Connect(function()
        root = player.Character:WaitForChild("HumanoidRootPart")
        camera = workspace.CurrentCamera
        if player.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
            local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = root:FindFirstChild(velocityHandlerName)
            local GyroHandler = root:FindFirstChild(gyroHandlerName)

            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            humanoid.PlatformStand = true
            GyroHandler.CFrame = camera.CoordinateFrame
            VelocityHandler.Velocity = v3none

            local direction = controlModule:GetMoveVector()
            if direction.X > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((iyflyspeed) * 50))
            end
            if direction.X < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((iyflyspeed) * 50))
            end
            if direction.Z > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((iyflyspeed) * 50))
            end
            if direction.Z < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((iyflyspeed) * 50))
            end
        end
    end)
end

local function CreateEsp(Char, Color, Text, Parent, number)
    if not Char then return end
    if Char:FindFirstChild("ESP") and Char:FindFirstChildOfClass("Highlight") then return end
    local highlight = Char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = Char
    highlight.FillColor = Color
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = Char

    local billboard = Char:FindFirstChild("ESP") or Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 50, 0, 25)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, number, 0)
    billboard.Adornee = Parent
    billboard.Enabled = true
    billboard.Parent = Parent

    local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = Text
    label.TextColor3 = Color
    label.TextScaled = true
    label.Parent = billboard

    task.spawn(function()
        local Camera = workspace.CurrentCamera
        while highlight and billboard and Parent and Parent.Parent do
            local cameraPosition = Camera and Camera.CFrame.Position
            if cameraPosition and Parent and Parent:IsA("BasePart") then
                local distance = (cameraPosition - Parent.Position).Magnitude
                task.spawn(function()
                    if ActiveDistanceEsp then
                        label.Text = Text .. " (" .. math.floor(distance + 0.5) .. " m)"
                    else
                        label.Text = Text
                    end
                end)
            end
            wait(0.1)
        end
    end)
end

local function KeepEsp(Char, Parent)
    if Char and Char:FindFirstChildOfClass("Highlight") and Parent:FindFirstChildOfClass("BillboardGui") then
        Char:FindFirstChildOfClass("Highlight"):Destroy()
        Parent:FindFirstChildOfClass("BillboardGui"):Destroy()
    end
end

-- Info Tab
Info:Section({ Title = "Server Info" })
local ParagraphInfoServer = Info:Paragraph({
    Title = "Info",
    Content = "Loading"
})

-- Player Tab
Player:Section({ Title = "Player Modifications" })
Player:Slider({
    Title = "Player Speed",
    Desc = "Adjust player walk speed",
    Min = 0,
    Max = 500,
    Increment = 1,
    Suffix = "Speeds",
    Default = 16,
    Save = true,
    Callback = function(Value)
        ValueSpeed = Value
    end
})
Player:Toggle({
    Title = "Active Speed Boost",
    Desc = "Enable/Disable speed modification",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveSpeedBoost = Value
        task.spawn(function()
            while ActiveSpeedBoost do
                player.Character.Humanoid.WalkSpeed = ValueSpeed
                task.wait(0.1)
            end
            player.Character.Humanoid.WalkSpeed = OldSpeed
        end)
    end
})
Player:Slider({
    Title = "Fly Speed",
    Desc = "Adjust fly speed (recommended 1-5)",
    Min = 0,
    Max = 10,
    Increment = 0.1,
    Suffix = "Fly Speed",
    Default = 1,
    Save = true,
    Callback = function(Value)
        iyflyspeed = Value
    end
})
Player:Toggle({
    Title = "Fly",
    Desc = "Enable/Disable flying (Press F to toggle)",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActivateFly = Value
        task.spawn(function()
            if not FLYING and ActivateFly then
                if UserInputService.TouchEnabled then
                    MobileFly()
                else
                    if not AlrActivatedFlyPC then 
                        AlrActivatedFlyPC = true
                        WindUI:Notify({
                            Title = "Fly",
                            Icon = "rbxassetid://84501312005643",
                            Content = "Press F to fly/unfly (won't disable toggle)",
                            Duration = 5
                        })
                    end
                    NOFLY()
                    wait()
                    sFLY()
                end
            elseif FLYING and not ActivateFly then
                if UserInputService.TouchEnabled then
                    UnMobileFly()
                else
                    NOFLY()
                end
            end
        end)
    end
})
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if not FLYING and ActivateFly then
            if UserInputService.TouchEnabled then
                MobileFly()
            else
                NOFLY()
                wait()
                sFLY()
            end
        elseif FLYING and ActivateFly then
            if UserInputService.TouchEnabled then
                UnMobileFly()
            else
                NOFLY()
            end
        end
    end
end)
Player:Toggle({
    Title = "Noclip",
    Desc = "Enable/Disable noclip",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveNoclip = Value
        task.spawn(function()
            while ActiveNoclip do
                if player.Character then
                    for _, Parts in pairs(player.Character:GetDescendants()) do
                        if Parts:IsA("BasePart") and Parts.CanCollide then
                            Parts.CanCollide = false
                        end
                    end
                end
                task.wait(0.1)
            end
            if player.Character then
                for _, Parts in pairs(player.Character:GetDescendants()) do
                    if Parts:IsA("BasePart") and not Parts.CanCollide then
                        Parts.CanCollide = true
                    end
                end
            end
        end)
    end
})
Player:Toggle({
    Title = "Infinite Jump",
    Desc = "Enable/Disable infinite jump",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActivateInfiniteJump = Value
        while ActivateInfiniteJump do
            local m = player:GetMouse()
            m.KeyDown:Connect(function(k)
                if ActivateInfiniteJump and k:byte() == 32 then
                    local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
                    humanoid:ChangeState('Jumping')
                    wait()
                    humanoid:ChangeState('Seated')
                end
            end)
            wait(0.1)
        end
    end
})
Player:Toggle({
    Title = "Instant Prompt",
    Desc = "Remove interaction delay",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveNoCooldownPrompt = Value
        task.spawn(function()
            if ActiveNoCooldownPrompt then
                for _, Assets in pairs(workspace:GetDescendants()) do
                    if Assets:IsA("ProximityPrompt") and Assets.HoldDuration ~= 0 then
                        Assets:SetAttribute("HoldDurationOld", Assets.HoldDuration)
                        Assets.HoldDuration = 0
                    end
                end
            else
                for _, Assets in pairs(workspace:GetDescendants()) do
                    if Assets:IsA("ProximityPrompt") and Assets:GetAttribute("HoldDurationOld") and Assets:GetAttribute("HoldDurationOld") ~= 0 then
                        Assets.HoldDuration = Assets:GetAttribute("HoldDurationOld")
                    end
                end
            end
        end)
    end
})
Player:Toggle({
    Title = "No Fog",
    Desc = "Remove fog from the map",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveNoFog = Value
        task.spawn(function()
            while ActiveNoFog do
                for _, part in pairs(workspace.Map.Boundaries:GetChildren()) do
                    if part:IsA("Part") then
                        part:Destroy()
                    end
                end
                wait(0.1)
            end
        end)
    end
})
Player:Button({
    Title = "Teleport to Campfire",
    Desc = "Teleport to main campfire",
    Callback = function()
        task.spawn(function()
            player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.Campground.MainFire.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
        end)
    end
})

-- ESP Tab
Esp:Section({ Title = "ESP Settings" })
Esp:Toggle({
    Title = "Items ESP",
    Desc = "Highlight items in the game",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveEspItems = Value
        task.spawn(function()
            while ActiveEspItems do
                for _, Obj in pairs(workspace.Items:GetChildren()) do
                    if Obj:IsA("Model") and Obj.PrimaryPart and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                        CreateEsp(Obj, Color3.fromRGB(255, 255, 0), Obj.Name, Obj.PrimaryPart, 2)
                        wait(0.15)
                    end
                end
                task.wait(0.1)
            end
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj:IsA("Model") and Obj.PrimaryPart and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    KeepEsp(Obj, Obj.PrimaryPart)
                end
            end
        end)
    end
})
Esp:Toggle({
    Title = "Enemy ESP",
    Desc = "Highlight enemies (excludes Lost Children and Pelt Trader)",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveEspEnemy = Value
        task.spawn(function()
            while ActiveEspEnemy do
                for _, Obj in pairs(workspace.Characters:GetChildren()) do
                    if Obj:IsA("Model") and Obj.PrimaryPart and not (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4" or Obj.Name == "Pelt Trader") and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                        CreateEsp(Obj, Color3.fromRGB(255, 0, 0), Obj.Name, Obj.PrimaryPart, 2)
                        wait(0.15)
                    end
                end
                task.wait(0.1)
            end
            for _, Obj in pairs(workspace.Characters:GetChildren()) do
                if Obj:IsA("Model") and Obj.PrimaryPart and not (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4" or Obj.Name == "Pelt Trader") and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    KeepEsp(Obj, Obj.PrimaryPart)
                end
            end
        end)
    end
})
Esp:Toggle({
    Title = "Children ESP",
    Desc = "Highlight Lost Children",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveEspChildren = Value
        task.spawn(function()
            while ActiveEspChildren do
                for _, Obj in pairs(workspace.Characters:GetChildren()) do
                    if Obj:IsA("Model") and Obj.PrimaryPart and (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4") and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                        CreateEsp(Obj, Color3.fromRGB(0, 255, 0), Obj.Name, Obj.PrimaryPart, 2)
                    end
                end
                task.wait(0.1)
            end
            for _, Obj in pairs(workspace.Characters:GetChildren()) do
                if Obj:IsA("Model") and Obj.PrimaryPart and (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4") and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    KeepEsp(Obj, Obj.PrimaryPart)
                end
            end
        end)
    end
})
Esp:Toggle({
    Title = "Pelt Trader ESP",
    Desc = "Highlight Pelt Trader",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveEspPeltTrader = Value
        task.spawn(function()
            while ActiveEspPeltTrader do
                for _, Obj in pairs(workspace.Characters:GetChildren()) do
                    if Obj:IsA("Model") and Obj.PrimaryPart and Obj.Name == "Pelt Trader" and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                        CreateEsp(Obj, Color3.fromRGB(0, 255, 255), Obj.Name, Obj.PrimaryPart, 2)
                    end
                end
                task.wait(0.1)
            end
            for _, Obj in pairs(workspace.Characters:GetChildren()) do
                if Obj:IsA("Model") and Obj.PrimaryPart and Obj.Name == "Pelt Trader" and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    KeepEsp(Obj, Obj.PrimaryPart)
                end
            end
        end)
    end
})

-- Game Tab
Game:Section({ Title = "Game Modifications" })
Game:Paragraph({
    Title = "Note",
    Content = "For Auto Chop Tree and Kill Aura, equip any axe to make it work!"
})
Game:Slider({
    Title = "Kill Aura Distance",
    Desc = "Set distance for Kill Aura",
    Min = 25,
    Max = 10000,
    Increment = 0.1,
    Suffix = "Distance",
    Default = 25,
    Save = true,
    Callback = function(Value)
        DistanceForKillAura = Value
    end
})
Game:Toggle({
    Title = "Kill Aura",
    Desc = "Automatically attack nearby enemies",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveKillAura = Value
        task.spawn(function()
            while ActiveKillAura do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local weapon = player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw")
                for _, bunny in pairs(workspace.Characters:GetChildren()) do
                    if bunny:IsA("Model") and bunny.PrimaryPart then
                        local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForKillAura then
                            task.spawn(function()
                                RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(bunny, weapon, 999, hrp.CFrame)
                            end)
                        end
                    end
                end
                wait(0.01)
            end
        end)
    end
})
Game:Slider({
    Title = "Auto Chop Tree Distance",
    Desc = "Set distance for auto tree chopping (below 250 recommended for strong axe/chainsaw)",
    Min = 0,
    Max = 1000,
    Increment = 0.1,
    Suffix = "Distance",
    Default = 25,
    Save = true,
    Callback = function(Value)
        DistanceForAutoChopTree = Value
    end
})
Game:Toggle({
    Title = "Auto Chop Tree",
    Desc = "Automatically chop nearby trees",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoChopTree = Value
        task.spawn(function()
            while ActiveAutoChopTree do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local weapon = player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw")
                for _, bunny in pairs(workspace.Map.Foliage:GetChildren()) do
                    if bunny:IsA("Model") and (bunny.Name == "Small Tree" or bunny.Name == "TreeBig1" or bunny.Name == "TreeBig2") and bunny.PrimaryPart then
                        local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForAutoChopTree then
                            task.spawn(function()
                                RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(bunny, weapon, 999, hrp.CFrame)
                            end)
                        end
                    end
                end
                for _, bunny in pairs(workspace.Map.Landmarks:GetChildren()) do
                    if bunny:IsA("Model") and (bunny.Name == "Small Tree" or bunny.Name == "TreeBig1" or bunny.Name == "TreeBig2") and bunny.PrimaryPart then
                        local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForAutoChopTree then
                            task.spawn(function()
                                RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(bunny, weapon, 999, hrp.CFrame)
                            end)
                        end
                    end
                end
                wait(0.01)
            end
        end)
    end
})

-- Bring Item Tab
BringItem:Section({ Title = "Item Collection" })
local ItemLabel = BringItem:Paragraph({
    Title = "Item Status",
    Content = "Item Is In The Map: No (x0)"
})
BringItem:Input({
    Title = "Item Name",
    Desc = "Enter item name to bring (use ESP for names)",
    Placeholder = "Item name",
    Default = "",
    Save = true,
    Callback = function(Text)
        TextBoxText = Text
        isInTheMap = "no"
        HowManyItemCanShowUp = 0
        for _, Obj in pairs(workspace.Items:GetChildren()) do
            if Obj.Name == TextBoxText and Obj:IsA("Model") and Obj.PrimaryPart then
                HowManyItemCanShowUp = HowManyItemCanShowUp + 1
                isInTheMap = "yes"
            end
        end
        ItemLabel:Set({
            Title = "Item Status",
            Content = "Item Is In The Map: " .. isInTheMap .. " (x" .. HowManyItemCanShowUp .. ")"
        })
    end
})
BringItem:Button({
    Title = "Bring Named Item",
    Desc = "Bring all items with the specified name",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == TextBoxText and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Items",
    Desc = "Bring all items to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                    wait(0.05)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Logs",
    Desc = "Bring all logs to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Log" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Coal",
    Desc = "Bring all coal to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Coal" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Fuel Canisters",
    Desc = "Bring all fuel canisters to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Fuel Canister" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Carrots",
    Desc = "Bring all carrots to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Carrot" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Fuel",
    Desc = "Bring all fuel items to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if (Obj.Name == "Log" or Obj.Name == "Fuel Canister" or Obj.Name == "Coal" or Obj.Name == "Oil Barrel") and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Scraps",
    Desc = "Bring all scrap items to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if (Obj.Name == "Tyre" or Obj.Name == "Sheet Metal" or Obj.Name == "Broken Fan" or Obj.Name == "Bolt" or Obj.Name == "Old Radio" or Obj.Name == "UFO Junk" or Obj.Name == "UFO Scrap" or Obj.Name == "Broken Microwave") and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Ammo",
    Desc = "Bring all ammo to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if (Obj.Name == "Rifle Ammo" or Obj.Name == "Revolver Ammo") and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Children",
    Desc = "Bring all Lost Children to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Characters:GetChildren()) do
                if (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4") and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Food",
    Desc = "Bring all food items to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if (Obj.Name == "Cake" or Obj.Name == "Carrot" or Obj.Name == "Morsel" or Obj.Name == "Meat? Sandwich") and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Bandages",
    Desc = "Bring all bandages to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Bandage" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Medkits",
    Desc = "Bring all medkits to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "MedKit" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Old Radios",
    Desc = "Bring all old radios to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Old Radio" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Tyres",
    Desc = "Bring all tyres to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Tyre" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Broken Fans",
    Desc = "Bring all broken fans to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Broken Fan" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Broken Microwaves",
    Desc = "Bring all broken microwaves to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Broken Microwave" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Bolts",
    Desc = "Bring all bolts to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Bolt" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Sheet Metal",
    Desc = "Bring all sheet metal to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Sheet Metal" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Seed Boxes",
    Desc = "Bring all seed boxes to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Seed Box" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})
BringItem:Button({
    Title = "Bring All Chairs",
    Desc = "Bring all chairs to you",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Items:GetChildren()) do
                if Obj.Name == "Chair" and Obj:IsA("Model") and Obj.PrimaryPart then
                    DragItem(Obj)
                end
            end
        end)
    end
})

-- Discord Tab
Discord:Section({ Title = "Join Discord Server" })
Discord:Button({
    Title = "Discord Invite",
    Desc = "Copy Invite Link",
    Locked = false,
    Callback = function()
        setclipboard("https://discord.gg/qZuB7sYdYB")
        WindUI:Notify({
            Title = "Ryzen Notify",
            Icon = "rbxassetid://84501312005643",
            Content = "✅ Link Copied!",
            Duration = 4
        })
    end
})

-- Config Tab
Config:Section({ Title = "Configuration" })
Config:Toggle({
    Title = "ESP Distance Display",
    Desc = "Show distance in ESP labels",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveDistanceEsp = Value
    end
})
Config:Button({
    Title = "Unload Script",
    Desc = "Destroy the script interface",
    Callback = function()
        WindUI:Destroy()
    end
})

-- Server Info Update Loop
task.spawn(function()
    while true do
        task.wait(1)
        local updatedInfo = getServerInfo()
        local updatedContent = string.format(
            "📌 PlaceId: %s\n🔑 JobId: %s\n🧪 IsStudio: %s\n👥 Players: %d/%d",
            updatedInfo.PlaceId,
            updatedInfo.JobId,
            tostring(updatedInfo.IsStudio),
            updatedInfo.CurrentPlayers,
            updatedInfo.MaxPlayers
        )
        ParagraphInfoServer:Set({
            Title = "Info",
            Content = updatedContent
        })
    end
end)

WindUI:Notify({
    Title = "Ryzen Hub",
    Icon = "rbxassetid://84501312005643",
    Content = "Script Loaded! Version: " .. version,
    Duration = 5
})
