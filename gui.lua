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
    Author = "99 Nights In The Forest | " .. version,
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
local ActiveSpeedBoost, ActiveTreeAura, ActiveAutoPlaceSapling, ActiveAutoTamePet = false, false, false, false
local ActiveAutoCollectResources, ActiveAutoRepairTools, ActiveAutoLightCampfire, ActiveAutoCompleteQuests = false, false, false, false
local DistanceForKillAura = 25
local DistanceForAutoChopTree = 25
local DistanceForTreeAura = 25
local DistanceForSaplingPlace = 20
local DistanceForPetTame = 15
local DistanceForAutoCollect = 30
local ValueSpeed = 16
local OldSpeed = player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.WalkSpeed or 16
local iyflyspeed = 1
local FLYING = false
local QEfly = true
local vehicleflyspeed = 1
local TextBoxText = ""
local isInTheMap = "no"
local HowManyItemCanShowUp = 0
local TreeAuraTypes = {"All", "Small Tree", "TreeBig1", "TreeBig2", "Snow Tree"}
local SelectedTreeType = "All"
local TeleportLocations = {
    {Name = "Main Campfire", Position = function() return workspace.Map.Campground.MainFire.PrimaryPart and workspace.Map.Campground.MainFire.PrimaryPart.CFrame + Vector3.new(0, 10, 0) end},
    {Name = "Pelt Trader", Position = function() 
        local peltTrader = workspace.Characters:FindFirstChild("Pelt Trader")
        return peltTrader and peltTrader.PrimaryPart and peltTrader.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
    end},
    {Name = "Resource Spawn 1", Position = function() return CFrame.new(100, 10, 100) end}, -- Placeholder, adjust based on game
    {Name = "Resource Spawn 2", Position = function() return CFrame.new(-100, 10, -100) end} -- Placeholder
}
local flyKeyDown, flyKeyUp
local mfly1, mfly2
local velocityHandlerName = "BodyVelocity"
local gyroHandlerName = "BodyGyro"

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

local function UnMobileFly()
    pcall(function()
        FLYING = false
        local root = player.Character:WaitForChild("HumanoidRootPart")
        if root:FindFirstChild(velocityHandlerName) then root:FindFirstChild(velocityHandlerName):Destroy() end
        if root:FindFirstChild(gyroHandlerName) then root:FindFirstChild(gyroHandlerName):Destroy() end
        if player.Character:FindFirstChildWhichIsA("Humanoid") then
            player.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        end
        if mfly1 then mfly1:Disconnect() end
        if mfly2 then mfly2:Disconnect() end
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
        local newRoot = player.Character:WaitForChild("HumanoidRootPart")
        local newBv = Instance.new("BodyVelocity")
        newBv.Name = velocityHandlerName
        newBv.Parent = newRoot
        newBv.MaxForce = v3zero
        newBv.Velocity = v3zero

        local newBg = Instance.new("BodyGyro")
        newBg.Name = gyroHandlerName
        newBg.Parent = newRoot
        newBg.MaxTorque = v3inf
        newBg.P = 1000
        newBg.D = 50
    end)

    mfly2 = RunService.RenderStepped:Connect(function()
        local currentRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not currentRoot then return end
        camera = workspace.CurrentCamera
        if player.Character:FindFirstChildWhichIsA("Humanoid") and currentRoot and currentRoot:FindFirstChild(velocityHandlerName) and currentRoot:FindFirstChild(gyroHandlerName) then
            local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = currentRoot:FindFirstChild(velocityHandlerName)
            local GyroHandler = currentRoot:FindFirstChild(gyroHandlerName)

            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            humanoid.PlatformStand = true
            GyroHandler.CFrame = camera.CoordinateFrame
            VelocityHandler.Velocity = v3none

            local direction = controlModule:GetMoveVector()
            if direction.X > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (iyflyspeed * 50))
            end
            if direction.X < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (iyflyspeed * 50))
            end
            if direction.Z > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (iyflyspeed * 50))
            end
            if direction.Z < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (iyflyspeed * 50))
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

local function updateSpeed()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if ActiveSpeedBoost then
            player.Character.Humanoid.WalkSpeed = ValueSpeed
        else
            player.Character.Humanoid.WalkSpeed = OldSpeed
        end
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
local SpeedSlider = Player:Slider({
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
        updateSpeed()
    end
})
local SpeedToggle = Player:Toggle({
    Title = "Active Speed Boost",
    Desc = "Enable/Disable speed modification",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveSpeedBoost = Value
        updateSpeed()
    end
})
local FlySpeedSlider = Player:Slider({
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
        if Value then
            local m = player:GetMouse()
            local connection
            connection = m.KeyDown:Connect(function(k)
                if not ActivateInfiniteJump then
                    connection:Disconnect()
                    return
                end
                if k:byte() == 32 then
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
                    if humanoid then
                        humanoid:ChangeState('Jumping')
                        wait()
                        humanoid:ChangeState('Seated')
                    end
                end
            end)
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
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and workspace.Map.Campground.MainFire.PrimaryPart then
                player.Character.HumanoidRootPart.CFrame = workspace.Map.Campground.MainFire.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
            end
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
    Content = "For Auto Chop Tree, Kill Aura, and Tree Aura, equip any axe to make it work!"
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
                if weapon then
                    for _, bunny in pairs(workspace.Characters:GetChildren()) do
                        if bunny:IsA("Model") and bunny.PrimaryPart and bunny.Name ~= player.Name then
                            local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForKillAura then
                                task.spawn(function()
                                    RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(bunny, weapon, 999, hrp.CFrame)
                                end)
                            end
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
                if weapon then
                    for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                        if tree:IsA("Model") and (tree.Name == "Small Tree" or tree.Name == "TreeBig1" or tree.Name == "TreeBig2") and tree.PrimaryPart then
                            local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForAutoChopTree then
                                task.spawn(function()
                                    RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                                end)
                            end
                        end
                    end
                    for _, tree in pairs(workspace.Map.Landmarks:GetChildren()) do
                        if tree:IsA("Model") and (tree.Name == "Small Tree" or tree.Name == "TreeBig1" or tree.Name == "TreeBig2") and tree.PrimaryPart then
                            local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForAutoChopTree then
                                task.spawn(function()
                                    RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                                end)
                            end
                        end
                    end
                end
                wait(0.01)
            end
        end)
    end
})

-- Advanced Automation Section
Game:Section({ Title = "Advanced Automation" })
Game:Slider({
    Title = "Tree Aura Distance",
    Desc = "Set distance for Tree Aura",
    Min = 10,
    Max = 500,
    Increment = 1,
    Suffix = "Distance",
    Default = 25,
    Save = true,
    Callback = function(Value)
        DistanceForTreeAura = Value
    end
})
local TreeTypeDropdown = Game:Dropdown({
    Title = "Tree Aura Type",
    Desc = "Select tree type for aura",
    Options = TreeAuraTypes,
    Default = "All",
    Save = true,
    Callback = function(Value)
        SelectedTreeType = Value[1]
    end
})
Game:Toggle({
    Title = "Tree Aura",
    Desc = "Automatically chop selected tree types within range",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveTreeAura = Value
        task.spawn(function()
            while ActiveTreeAura do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local weapon = player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw")
                if weapon then
                    local treeNames = {"Small Tree", "TreeBig1", "TreeBig2", "Snow Tree"}
                    if SelectedTreeType ~= "All" then
                        treeNames = {SelectedTreeType}
                    end
                    for _, treeName in pairs(treeNames) do
                        for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                            if tree:IsA("Model") and tree.Name == treeName and tree.PrimaryPart then
                                local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                                if distance <= DistanceForTreeAura then
                                    task.spawn(function()
                                        RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                                    end)
                                end
                            end
                        end
                        for _, tree in pairs(workspace.Map.Landmarks:GetChildren()) do
                            if tree:IsA("Model") and tree.Name == treeName and tree.PrimaryPart then
                                local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                                if distance <= DistanceForTreeAura then
                                    task.spawn(function()
                                        RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                                    end)
                                end
                            end
                        end
                    end
                end
                wait(0.01)
            end
        end)
    end
})
Game:Slider({
    Title = "Auto Place Sapling Distance",
    Desc = "Set range for auto placing saplings around camp",
    Min = 5,
    Max = 50,
    Increment = 1,
    Suffix = "Distance",
    Default = 20,
    Save = true,
    Callback = function(Value)
        DistanceForSaplingPlace = Value
    end
})
Game:Toggle({
    Title = "Auto Place Sapling",
    Desc = "Automatically place saplings within selected range",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoPlaceSapling = Value
        task.spawn(function()
            while ActiveAutoPlaceSapling do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local saplingTool = player.Inventory:FindFirstChild("Seed Box") -- Updated to match game item
                if saplingTool then
                    for angle = 0, 360, 30 do
                        local rad = math.rad(angle)
                        local placePos = hrp.Position + Vector3.new(math.cos(rad) * DistanceForSaplingPlace, 0, math.sin(rad) * DistanceForSaplingPlace)
                        task.spawn(function()
                            -- Placeholder for sapling placement; adjust based on game remote
                            RepStorage.RemoteEvents.PlaceItem:FireServer(saplingTool, CFrame.new(placePos))
                        end)
                        wait(0.1)
                    end
                end
                wait(5)
            end
        end)
    end
})
Game:Slider({
    Title = "Auto Tame Pet Distance",
    Desc = "Set distance for auto taming pets",
    Min = 5,
    Max = 50,
    Increment = 1,
    Suffix = "Distance",
    Default = 15,
    Save = true,
    Callback = function(Value)
        DistanceForPetTame = Value
    end
})
Game:Toggle({
    Title = "Auto Tame Pet",
    Desc = "Automatically tame nearby animals with correct food",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoTamePet = Value
        task.spawn(function()
            while ActiveAutoTamePet do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local flute = player.Inventory:FindFirstChild("Taming Flute") -- Adjust name if needed
                if flute then
                    for _, animal in pairs(workspace.Characters:GetChildren()) do
                        if animal:IsA("Model") and animal.PrimaryPart and animal.Name:find("Animal") then
                            local distance = (animal.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForPetTame then
                                task.spawn(function()
                                    -- Placeholder: Assume animals have an attribute for required food
                                    local requiredFood = animal:GetAttribute("RequiredFood") or "Carrot"
                                    local foodItem = player.Inventory:FindFirstChild(requiredFood)
                                    if foodItem then
                                        RepStorage.RemoteEvents.TameAnimal:FireServer(animal, foodItem)
                                    end
                                end)
                            end
                        end
                    end
                end
                wait(1)
            end
        end)
    end
})
Game:Slider({
    Title = "Auto Collect Distance",
    Desc = "Set range for auto collecting resources",
    Min = 5,
    Max = 100,
    Increment = 1,
    Suffix = "Distance",
    Default = 30,
    Save = true,
    Callback = function(Value)
        DistanceForAutoCollect = Value
    end
})
Game:Toggle({
    Title = "Auto Collect Resources",
    Desc = "Automatically collect nearby resources",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoCollectResources = Value
        task.spawn(function()
            while ActiveAutoCollectResources do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item:IsA("Model") and item.PrimaryPart then
                        local distance = (item.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForAutoCollect then
                            DragItem(item)
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
})
Game:Toggle({
    Title = "Auto Repair Tools",
    Desc = "Automatically repair tools in inventory",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoRepairTools = Value
        task.spawn(function()
            while ActiveAutoRepairTools do
                local character = player.Character or player.CharacterAdded:Wait()
                for _, tool in pairs(player.Inventory:GetChildren()) do
                    if tool:IsA("Model") and tool:GetAttribute("Durability") and tool:GetAttribute("MaxDurability") then
                        if tool:GetAttribute("Durability") < tool:GetAttribute("MaxDurability") then
                            task.spawn(function()
                                -- Placeholder: Assume repair remote
                                RepStorage.RemoteEvents.RepairTool:FireServer(tool)
                            end)
                        end
                    end
                end
                wait(10)
            end
        end)
    end
})
Game:Toggle({
    Title = "Auto Light Campfire",
    Desc = "Keep the main campfire lit",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoLightCampfire = Value
        task.spawn(function()
            while ActiveAutoLightCampfire do
                local campfire = workspace.Map.Campground.MainFire
                if campfire and campfire:GetAttribute("IsLit") == false then
                    task.spawn(function()
                        RepStorage.RemoteEvents.LightCampfire:FireServer(campfire)
                    end)
                end
                wait(5)
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

-- Teleport Tab
local Teleport = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
Teleport:Section({ Title = "Map Exploration" })
Teleport:Dropdown({
    Title = "Teleport Locations",
    Desc = "Select a location to teleport to",
    Options = {TeleportLocations[1].Name, TeleportLocations[2].Name, TeleportLocations[3].Name, TeleportLocations[4].Name},
    Default = TeleportLocations[1].Name,
    Save = true,
    Callback = function(Value)
        local selected = Value[1]
        for _, loc in pairs(TeleportLocations) do
            if loc.Name == selected then
                local pos = loc.Position()
                if pos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = pos
                end
            end
        end
    end
})
Teleport:Toggle({
    Title = "Auto Complete Quests",
    Desc = "Automatically complete active quests",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoCompleteQuests = Value
        task.spawn(function()
            while ActiveAutoCompleteQuests do
                -- Placeholder: Assume quests are stored in player data
                local questData = player:FindFirstChild("QuestData")
                if questData then
                    for _, quest in pairs(questData:GetChildren()) do
                        local objective = quest:GetAttribute("Objective")
                        if objective == "CollectItem" then
                            local itemName = quest:GetAttribute("ItemName")
                            for _, item in pairs(workspace.Items:GetChildren()) do
                                if item.Name == itemName and item:IsA("Model") and item.PrimaryPart then
                                    DragItem(item)
                                end
                            end
                        elseif objective == "InteractNPC" then
                            local npcName = quest:GetAttribute("NPCName")
                            local npc = workspace.Characters:FindFirstChild(npcName)
                            if npc and npc.PrimaryPart then
                                player.Character.HumanoidRootPart.CFrame = npc.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                                task.spawn(function()
                                    RepStorage.RemoteEvents.InteractNPC:FireServer(npc)
                                end)
                            end
                        end
                    end
                end
                wait(2)
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

-- Character Added Handler for Speed
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = OldSpeed
    updateSpeed()
end)

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
