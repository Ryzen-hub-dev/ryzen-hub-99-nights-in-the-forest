local version = LRM_ScriptVersion and "v" .. table.concat(LRM_ScriptVersion:split(""), ".") or "Dev Version"
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success or not WindUI then
    warn("Primary WindUI load failed, attempting fallback...")
    success, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
    end)
    if not success or not WindUI then
        error("WindUI library failed to load. Check your internet connection or executor compatibility.")
        return
    end
end

WindUI:Popup({
    Title = "99 Night In The Forest | Beta",
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
    Title = "99 Night In The Forest | Beta",
    Icon = "rbxassetid://84501312005643",
    Author = "99 Night In The Forest | " .. version,
    Folder = "RyzenHub_NITF",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 220,
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
if not Window then
    warn("Window creation failed. Attempting to reinitialize UI...")
    Window = WindUI:CreateWindow({
        Title = "99 Night In The Forest | Beta",
        Icon = "rbxassetid://84501312005643",
        Author = "99 Night In The Forest | " .. version,
        Folder = "RyzenHub_NITF",
        Size = UDim2.fromOffset(400, 300),
        Transparent = true,
        Theme = "Dark",
    })
    if not Window then
        error("UI initialization failed. Script cannot proceed.")
        return
    end
end

-- DRAGGABLE GUI IMPLEMENTATION --
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

Window.MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Window.MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Window.MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Window.MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local IYMouse = player:GetMouse()

local ActiveEspItems, ActiveDistanceEsp, ActiveEspEnemy, ActiveEspChildren, ActiveEspPeltTrader = false, false, false, false, false
local ActivateFly, AlrActivatedFlyPC, ActiveNoCooldownPrompt, ActiveNoFog = false, false, false, false
local ActiveAutoChopTree, ActiveKillAura, ActivateInfiniteJump, ActiveNoclip = false, false, false, false
local ActiveSpeedBoost = false
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
local ActiveAutoPlaceSapling = false
local ActiveTreeAura = false
local TreeAuraTypes = {"All", "Small Tree", "TreeBig1", "TreeBig2", "Snow Tree", "Dead Tree"}
local SelectedTreeType = "All"
local ActiveAutoTamePet = false
local flyKeyDown, flyKeyUp
local velocityHandlerName = "BodyVelocity"
local gyroHandlerName = "BodyGyro"
local ActiveInfHealth = false
local ActiveFreeCamo = false
local ActiveAutoSurviveDays = false
local ActiveAutoCookFood = false
local ActiveAutoEatFood = false
local ActiveAutoMissingFoods = false
local ActiveAutoBringOres = false
local ActiveAutoTpEnemies = false
local ActiveAutoTpTrees = false
local ActiveStunMobs = false
local ActiveAutoMinigameTaming = false
local ActiveAutoFeedTaming = false
local ActiveHitboxExpander = false
local ActiveFullMapLoader = false
local ActiveAutoEatStew = false
local ActiveAntiAfk = false
local ActiveAutoTimeMachine = false
local ActiveAutoCast = false
local ActiveAutoMinigames = false
local ActiveAlwaysBiggerBar = false
local ActiveBetterAutoCast = false
local HipHeightValue = 0
local ActiveHipHeight = false
local ActiveAutoFarmSnowySmallTree = false
local ActiveInstaOpenChest = false
local ActiveCreateSafeZone = false
local ActiveTpToSafeZoneLowHP = false
local SaplingAmount = 10
local SaplingShape = "Circle"

local petTamingFoodMap = {
    ["Bunny"] = "Carrot",
    ["Wolf"] = "Steak",
    ["Bear"] = "Cake",
    ["Mammoth"] = "Cake"
}
local activeTamingAnimals = {}

local safeZonePos = workspace.Map.Campground.MainFire.PrimaryPart.Position + Vector3.new(0, 5, 0)

local Info = Window:Tab({ Title = "Info", Icon = "info" })
local Player = Window:Tab({ Title = "Player", Icon = "user" })
local Esp = Window:Tab({ Title = "ESP", Icon = "eye" })
local Game = Window:Tab({ Title = "Game", Icon = "gamepad" })
local BringItem = Window:Tab({ Title = "Items", Icon = "package" })
local Automation = Window:Tab({ Title = "Automation", Icon = "settings" })
local Teleport = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
local Discord = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
local Config = Window:Tab({ Title = "Config", Icon = "file-cog" })

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

local function updateSpeed()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if ActiveSpeedBoost then
            player.Character.Humanoid.WalkSpeed = ValueSpeed
        else
            player.Character.Humanoid.WalkSpeed = OldSpeed
        end
    end
end

local function infHealth()
    task.spawn(function()
        while ActiveInfHealth do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                humanoid.Health = humanoid.MaxHealth
            end
            wait(0.1)
        end
    end)
end

local function freeCamoMode()
    task.spawn(function()
        while ActiveFreeCamo do
            Lighting.FogEnd = 9999
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1, 1, 1)
            wait(1)
        end
        Lighting.FogEnd = 100
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0.2, 0.2, 0.2)
    end)
end

local function autoSurviveDays()
    task.spawn(function()
        while ActiveAutoSurviveDays do
            local campfire = workspace.Map.Campground:FindFirstChild("Campfire")
            if campfire and campfire:FindFirstChild("FuelValue") and campfire.FuelValue.Value < 50 then
                local fuel = player.Inventory:FindFirstChild("Log") or player.Inventory:FindFirstChild("Coal")
                if fuel then
                    RepStorage.RemoteEvents.AddFuel:FireServer(campfire, fuel)
                end
            end
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 75 then
                local food = player.Inventory:FindFirstChild("CookedMeat") or player.Inventory:FindFirstChild("Carrot")
                if food then
                    RepStorage.RemoteEvents.ConsumeItem:FireServer(food)
                end
            end
            wait(10)
        end
    end)
end

local function autoCookFood()
    task.spawn(function()
        while ActiveAutoCookFood do
            local campfire = workspace.Map.Campground:FindFirstChild("Campfire")
            local rawFood = player.Inventory:FindFirstChild("RawMeat") or player.Inventory:FindFirstChild("Carrot")
            if campfire and rawFood then
                RepStorage.RemoteEvents.CookItem:FireServer(rawFood, campfire)
            end
            wait(5)
        end
    end)
end

local function autoEatFood()
    task.spawn(function()
        while ActiveAutoEatFood do
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 90 then
                local food = player.Inventory:FindFirstChild("CookedMeat") or player.Inventory:FindFirstChild("Carrot")
                if food then
                    RepStorage.RemoteEvents.ConsumeItem:FireServer(food)
                end
            end
            wait(15)
        end
    end)
end

local function autoMissingFoods()
    task.spawn(function()
        while ActiveAutoMissingFoods do
            local foodCount = 0
            for _, item in pairs(player.Inventory:GetChildren()) do
                if item.Name == "Carrot" or item.Name == "CookedMeat" then foodCount = foodCount + 1 end
            end
            if foodCount < 3 then
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if (item.Name == "Carrot" or item.Name == "RawMeat") and item:IsA("Model") and item.PrimaryPart then
                        DragItem(item)
                    end
                end
            end
            wait(30)
        end
    end)
end

local function autoBringOres()
    task.spawn(function()
        while ActiveAutoBringOres do
            for _, item in pairs(workspace.Items:GetChildren()) do
                if (item.Name == "Ore" or item.Name == "Coal") and item:IsA("Model") and item.PrimaryPart then
                    DragItem(item)
                end
            end
            wait(10)
        end
    end)
end

local function autoTpEnemies()
    task.spawn(function()
        while ActiveAutoTpEnemies do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            for _, enemy in pairs(workspace.Characters:GetChildren()) do
                if enemy:IsA("Model") and enemy.PrimaryPart and enemy.Name ~= "Pelt Trader" then
                    hrp.CFrame = CFrame.new(enemy.PrimaryPart.Position + Vector3.new(0, 5, 0))
                    wait(2)
                end
            end
            wait(5)
        end
    end)
end

local function autoTpTrees()
    task.spawn(function()
        while ActiveAutoTpTrees do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                if tree:IsA("Model") and tree.PrimaryPart then
                    hrp.CFrame = CFrame.new(tree.PrimaryPart.Position + Vector3.new(0, 5, 0))
                    wait(2)
                end
            end
            wait(5)
        end
    end)
end

local function autoChopSelectedTree()
    task.spawn(function()
        while ActiveTreeAura do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local weapon = player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw")
            if weapon then
                local targetTrees = (SelectedTreeType == "All") and {"Small Tree", "TreeBig1", "TreeBig2", "Snow Tree", "Dead Tree"} or {SelectedTreeType}
                for _, treeName in pairs(targetTrees) do
                    for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                        if tree:IsA("Model") and tree.Name == treeName and tree.PrimaryPart then
                            local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForTreeAura then
                                RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                            end
                        end
                    end
                end
            end
            wait(0.5)
        end
    end)
end

local function autoPlantSaplings()
    task.spawn(function()
        while ActiveAutoPlaceSapling do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local seedBox = player.Inventory:FindFirstChild("Seed Box")
            if seedBox then
                for i = 1, SaplingAmount do
                    local angle = (2 * math.pi * i) / SaplingAmount
                    local offset = (SaplingShape == "Circle") and Vector3.new(math.cos(angle) * DistanceForSaplingPlace, 0, math.sin(angle) * DistanceForSaplingPlace) or Vector3.new((i % 5 - 2.5) * DistanceForSaplingPlace, 0, math.floor(i / 5 - 2.5) * DistanceForSaplingPlace)
                    local plantPos = hrp.Position + offset
                    RepStorage.RemoteEvents.PlantSapling:FireServer(plantPos, seedBox)
                    wait(1)
                end
            end
            wait(10)
        end
    end)
end

local function autoTamePet()
    task.spawn(function()
        while ActiveAutoTamePet do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local flute = player.Inventory:FindFirstChild("Old Taming Flute") or player.Inventory:FindFirstChild("Good Taming Flute") or player.Inventory:FindFirstChild("Strong Taming Flute")
            if flute then
                for _, animal in pairs(workspace.Characters:GetChildren()) do
                    if animal:IsA("Model") and animal.PrimaryPart and (animal.Name == "Bunny" or animal.Name == "Wolf" or animal.Name == "Bear" or animal.Name == "Mammoth") then
                        local distance = (animal.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForPetTame and not activeTamingAnimals[animal] then
                            activeTamingAnimals[animal] = true
                            RepStorage.RemoteEvents.StartTaming:FireServer(animal, flute)
                            wait(30) -- Real taming duration
                            local food = petTamingFoodMap[animal.Name]
                            local foodItem = player.Inventory:FindFirstChild(food)
                            if foodItem then
                                for _ = 1, 5 do
                                    RepStorage.RemoteEvents.FeedAnimal:FireServer(animal, foodItem)
                                    wait(2)
                                end
                            end
                            activeTamingAnimals[animal] = nil
                        end
                    end
                end
            end
            wait(5)
        end
    end)
end

local function stunMobs()
    task.spawn(function()
        while ActiveStunMobs do
            for _, mob in pairs(workspace.Characters:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Name ~= "Pelt Trader" then
                    mob.Humanoid.WalkSpeed = 0
                    mob.Humanoid.JumpPower = 0
                end
            end
            wait(1)
        end
    end)
end

local function autoMinigameTaming()
    task.spawn(function()
        while ActiveAutoMinigameTaming do
            local flute = player.Inventory:FindFirstChild("Old Taming Flute") or player.Inventory:FindFirstChild("Good Taming Flute") or player.Inventory:FindFirstChild("Strong Taming Flute")
            if flute then
                for _, animal in pairs(workspace.Characters:GetChildren()) do
                    if animal:IsA("Model") and animal.PrimaryPart and (animal.Name == "Bunny" or animal.Name == "Wolf") then
                        RepStorage.RemoteEvents.StartTaming:FireServer(animal, flute)
                        wait(30) -- Real minigame completion via server
                    end
                end
            end
            wait(10)
        end
    end)
end

local function autoFeedTaming()
    task.spawn(function()
        while ActiveAutoFeedTaming do
            for _, animal in pairs(workspace.Characters:GetChildren()) do
                if animal:IsA("Model") and animal:FindFirstChild("TamingProgress") and animal.TamingProgress.Value > 0 then
                    local food = player.Inventory:FindFirstChild(petTamingFoodMap[animal.Name])
                    if food then
                        RepStorage.RemoteEvents.FeedAnimal:FireServer(animal, food)
                    end
                end
            end
            wait(5)
        end
    end)
end

local function hitboxExpander()
    task.spawn(function()
        while ActiveHitboxExpander do
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Parent.Name ~= player.Name and not part:IsDescendantOf(workspace.Characters) then
                    part.Size = part.Size + Vector3.new(2, 2, 2)
                end
            end
            wait(1)
        end
    end)
end

local function fullMapLoader()
    task.spawn(function()
        while ActiveFullMapLoader do
            for _, part in pairs(workspace.Map:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency ~= 0.3 then
                    part.Transparency = 0.3
                end
            end
            wait(1)
        end
    end)
end

local function autoEatStew()
    task.spawn(function()
        while ActiveAutoEatStew do
            local stew = player.Inventory:FindFirstChild("Stew")
            if stew and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 80 then
                RepStorage.RemoteEvents.ConsumeItem:FireServer(stew)
            end
            wait(20)
        end
    end)
end

local function antiAfk()
    task.spawn(function()
        while ActiveAntiAfk do
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            wait(30)
        end
    end)
end

local function autoTimeMachine()
    task.spawn(function()
        while ActiveAutoTimeMachine do
            RepStorage.RemoteEvents.SkipNight:FireServer()
            wait(60) -- Real night skip duration
        end
    end)
end

local function autoCast()
    task.spawn(function()
        while ActiveAutoCast do
            local castItem = player.Inventory:FindFirstChild("MagicWand")
            if castItem then
                RepStorage.RemoteEvents.CastSpell:FireServer(castItem, IYMouse.Hit.Position)
            end
            wait(5)
        end
    end)
end

local function autoMinigames()
    task.spawn(function()
        while ActiveAutoMinigames do
            RepStorage.RemoteEvents.CompleteMinigame:FireServer("Fishing")
            wait(10)
        end
    end)
end

local function alwaysBiggerBar()
    task.spawn(function()
        while ActiveAlwaysBiggerBar do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.MaxHealth = 200
                player.Character.Humanoid.Health = 200
            end
            wait(0.1)
        end
    end)
end

local function betterAutoCast()
    task.spawn(function()
        while ActiveBetterAutoCast do
            local castItem = player.Inventory:FindFirstChild("MagicWand")
            if castItem then
                RepStorage.RemoteEvents.CastSpell:FireServer(castItem, CFrame.new(IYMouse.Hit.Position))
            end
            wait(3)
        end
    end)
end

local function hipHeight()
    task.spawn(function()
        while ActiveHipHeight do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, HipHeightValue, 0)
            end
            wait(0.5)
        end
    end)
end

local function autoFarmSnowySmallTree()
    task.spawn(function()
        while ActiveAutoFarmSnowySmallTree do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local weapon = player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw")
            if weapon then
                for _, tree in pairs(workspace.Map.SnowyArea:GetChildren()) do
                    if tree.Name == "SmallTree" and tree:IsA("Model") and tree.PrimaryPart then
                        local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= 30 then
                            RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                        end
                    end
                end
            end
            wait(0.5)
        end
    end)
end

local function instaOpenChest()
    task.spawn(function()
        while ActiveInstaOpenChest do
            for _, chest in pairs(workspace.Chests:GetChildren()) do
                if chest:IsA("Model") and chest:FindFirstChild("ProximityPrompt") then
                    fireproximityprompt(chest.ProximityPrompt)
                end
            end
            wait(1)
        end
    end)
end

local function createSafeZone()
    if ActiveCreateSafeZone and not workspace:FindFirstChild("SafeZone") then
        local safePart = Instance.new("Part")
        safePart.Name = "SafeZone"
        safePart.Size = Vector3.new(50, 5, 50)
        safePart.Position = safeZonePos
        safePart.Anchored = true
        safePart.CanCollide = false
        safePart.Transparency = 0.5
        safePart.BrickColor = BrickColor.new("Bright green")
        safePart.Parent = workspace
    end
end

local function tpToSafeZoneLowHP()
    task.spawn(function()
        while ActiveTpToSafeZoneLowHP do
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 20 then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(safeZonePos)
            end
            wait(0.5)
        end
    end)
end

Info:Section({ Title = "Server Info" })
local ParagraphInfoServer = Info:Paragraph({
    Title = "Info",
    Content = "Loading"
})

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
            m.KeyDown:connect(function(k)
                if ActivateInfiniteJump then
                    if k:byte() == 32 then
                        local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
                        if humanoid then
                            humanoid:ChangeState('Jumping')
                            wait()
                            humanoid:ChangeState('Seated')
                        end
                    end
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
Player:Toggle({
    Title = "Infinite Health",
    Desc = "Keep health at maximum",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveInfHealth = Value
        infHealth()
    end
})
Player:Toggle({
    Title = "Free Camo Mode",
    Desc = "Enhance visibility",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveFreeCamo = Value
        freeCamoMode()
    end
})
Player:Slider({
    Title = "Hip Height",
    Desc = "Adjust height to avoid hits",
    Min = 0,
    Max = 20,
    Increment = 1,
    Suffix = "Height",
    Default = 0,
    Save = true,
    Callback = function(Value)
        HipHeightValue = Value
    end
})
Player:Toggle({
    Title = "Hip Height Active",
    Desc = "Enable height adjustment",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveHipHeight = Value
        hipHeight()
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

Game:Section({ Title = "Game Modifications" })
Game:Paragraph({
    Title = "Note",
    Content = "For Auto Chop Tree and Kill Aura, equip an axe or chainsaw!"
})
local KillAuraSlider = Game:Slider({
    Title = "Distance For Kill Aura",
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
                for _, enemy in pairs(workspace.Characters:GetChildren()) do
                    if enemy:IsA("Model") and enemy.PrimaryPart and enemy.Name ~= "Pelt Trader" then
                        local distance = (enemy.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForKillAura then
                            RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(enemy, weapon, 999, hrp.CFrame)
                        end
                    end
                end
                wait(0.01)
            end
        end)
    end
})
local AutoChopSlider = Game:Slider({
    Title = "Distance For Auto Chop Tree",
    Desc = "Set distance for auto tree chopping",
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
                for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                    if tree:IsA("Model") and (tree.Name == "Small Tree" or tree.Name == "TreeBig1" or tree.Name == "TreeBig2") and tree.PrimaryPart then
                        local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForAutoChopTree then
                            RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                        end
                    end
                end
                wait(0.01)
            end
        end)
    end
})
Game:Dropdown({
    Title = "Tree Type",
    Options = TreeAuraTypes,
    CurrentOption = "All",
    MultiSelect = true,
    Save = true,
    Callback = function(Option)
        SelectedTreeType = Option
    end
})
Game:Slider({
    Title = "Distance For Tree Aura",
    Desc = "Set distance for auto chop selected tree",
    Min = 10,
    Max = 50,
    Increment = 5,
    Suffix = "Distance",
    Default = 25,
    Save = true,
    Callback = function(Value)
        DistanceForTreeAura = Value
    end
})
Game:Toggle({
    Title = "Auto Chop Selected Tree",
    Desc = "Automatically chop selected tree types",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveTreeAura = Value
        autoChopSelectedTree()
    end
})

BringItem:Section({ Title = "Item Collection" })
local ItemLabel = BringItem:Paragraph({
    Title = "Item Status",
    Content = "Item Is In The Map: No (x0)"
})
local ItemInput = BringItem:Input({
    Title = "Item Name",
    Desc = "Enter item name to bring (use ESP for names)",
    Placeholder = "Put a name only 1 for bring it on you(use the esp for the name)",
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
    Desc = "Bring all the item with the name you choosed",
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
    Title = "Bring All Fuel Canister",
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
    Title = "Bring All Carrot",
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
    Title = "Bring All Foods",
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
    Title = "Bring All Bandage",
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
    Title = "Bring All Medkit",
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
    Title = "Bring All Old Radio",
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
    Title = "Bring All Tyre",
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
    Title = "Bring All Broken Fan",
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
    Title = "Bring All Broken Microwave",
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
    Title = "Bring All Bolt",
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
    Title = "Bring All Seed Box",
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
    Title = "Bring All Chair",
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
BringItem:Button({
    Title = "Bring Frog Key",
    Desc = "Bring Frog Key (spawns after killing frogs)",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(workspace.Characters:GetChildren()) do
                if Obj.Name == "Frog" and Obj:IsA("Model") and Obj.PrimaryPart then
                    RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(Obj, player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe"), 999, player.Character.HumanoidRootPart.CFrame)
                    wait(1)
                    local key = workspace.Items:FindFirstChild("Frog Key")
                    if key and key:IsA("Model") and key.PrimaryPart then
                        DragItem(key)
                    end
                end
            end
        end)
    end
})

Automation:Section({ Title = "Advanced Automation" })
local PetTameSlider = Automation:Slider({
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
Automation:Toggle({
    Title = "Auto Tame Pet",
    Desc = "Automatically tame nearby animals with correct food (requires Taming Flute)",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoTamePet = Value
        autoTamePet()
    end
})
Automation:Slider({
    Title = "Sapling Distance",
    Desc = "Set distance for auto planting saplings",
    Min = 5,
    Max = 30,
    Increment = 5,
    Suffix = "m",
    Default = 20,
    Save = true,
    Callback = function(Value)
        DistanceForSaplingPlace = Value
    end
})
Automation:Dropdown({
    Title = "Sapling Shape",
    Options = {"Circle", "Square"},
    CurrentOption = "Circle",
    Save = true,
    Callback = function(Option)
        SaplingShape = Option[1]
    end
})
Automation:Slider({
    Title = "Sapling Amount",
    Desc = "Set number of saplings to plant",
    Min = 1,
    Max = 20,
    Increment = 1,
    Suffix = "Count",
    Default = 10,
    Save = true,
    Callback = function(Value)
        SaplingAmount = Value
    end
})
Automation:Toggle({
    Title = "Auto Plant Saplings",
    Desc = "Automatically plant saplings",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoPlaceSapling = Value
        autoPlantSaplings()
    end
})
Automation:Toggle({
    Title = "Auto Survive Days",
    Desc = "Auto maintain campfire and eat food",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoSurviveDays = Value
        autoSurviveDays()
    end
})
Automation:Toggle({
    Title = "Auto Cook Food",
    Desc = "Automatically cook food at campfire",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoCookFood = Value
        autoCookFood()
    end
})
Automation:Toggle({
    Title = "Auto Eat Food",
    Desc = "Automatically eat food when health is low",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoEatFood = Value
        autoEatFood()
    end
})
Automation:Toggle({
    Title = "Auto Missing Foods",
    Desc = "Automatically collect missing food items",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoMissingFoods = Value
        autoMissingFoods()
    end
})
Automation:Toggle({
    Title = "Auto Bring Ores",
    Desc = "Automatically collect ores",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoBringOres = Value
        autoBringOres()
    end
})
Automation:Toggle({
    Title = "Auto Minigame Taming",
    Desc = "Automatically complete taming minigames",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoMinigameTaming = Value
        autoMinigameTaming()
    end
})
Automation:Toggle({
    Title = "Auto Feed Taming",
    Desc = "Automatically feed taming animals",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoFeedTaming = Value
        autoFeedTaming()
    end
})
Automation:Toggle({
    Title = "Stun Mobs",
    Desc = "Prevent mobs from moving",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveStunMobs = Value
        stunMobs()
    end
})
Automation:Toggle({
    Title = "Hitbox Expander",
    Desc = "Expand hitboxes for easier hits",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveHitboxExpander = Value
        hitboxExpander()
    end
})
Automation:Toggle({
    Title = "Full Map Loader",
    Desc = "Make map partially transparent",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveFullMapLoader = Value
        fullMapLoader()
    end
})
Automation:Toggle({
    Title = "Auto Eat Stew",
    Desc = "Automatically eat stew when health is low",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoEatStew = Value
        autoEatStew()
    end
})
Automation:Toggle({
    Title = "Anti AFK",
    Desc = "Prevent AFK kick",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAntiAfk = Value
        antiAfk()
    end
})
Automation:Toggle({
    Title = "Auto Time Machine",
    Desc = "Automatically skip night",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoTimeMachine = Value
        autoTimeMachine()
    end
})
Automation:Toggle({
    Title = "Auto Cast",
    Desc = "Automatically cast spells",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoCast = Value
        autoCast()
    end
})
Automation:Toggle({
    Title = "Better Auto Cast",
    Desc = "Improved automatic spell casting",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveBetterAutoCast = Value
        betterAutoCast()
    end
})
Automation:Toggle({
    Title = "Auto Minigames",
    Desc = "Automatically complete minigames",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoMinigames = Value
        autoMinigames()
    end
})
Automation:Toggle({
    Title = "Always Bigger Bar",
    Desc = "Increase max health to 200",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAlwaysBiggerBar = Value
        alwaysBiggerBar()
    end
})
Automation:Toggle({
    Title = "Auto Farm Snowy Small Tree",
    Desc = "Automatically farm snowy small trees",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoFarmSnowySmallTree = Value
        autoFarmSnowySmallTree()
    end
})
Automation:Toggle({
    Title = "Insta Open Chest",
    Desc = "Instantly open chests",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveInstaOpenChest = Value
        instaOpenChest()
    end
})
Automation:Toggle({
    Title = "Create Safe Zone",
    Desc = "Create a safe zone at campground",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveCreateSafeZone = Value
        createSafeZone()
    end
})
Automation:Toggle({
    Title = "TP to Safe Zone Low HP",
    Desc = "Teleport to safe zone when health is low",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveTpToSafeZoneLowHP = Value
        tpToSafeZoneLowHP()
    end
})

Teleport:Section({ Title = "Teleport Options" })
Teleport:Button({
    Title = "Teleport to Campfire",
    Desc = "Teleport to main campfire",
    Callback = function()
        task.spawn(function()
            player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.Campground.MainFire.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
        end)
    end
})
Teleport:Button({
    Title = "Teleport to Snowy Area",
    Desc = "Teleport to snowy area",
    Callback = function()
        task.spawn(function()
            player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.SnowyArea.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
        end)
    end
})
Teleport:Button({
    Title = "Teleport to Desert",
    Desc = "Teleport to desert area",
    Callback = function()
        task.spawn(function()
            player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.DesertArea.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
        end)
    end
})

Discord:Section({ Title = "Community" })
Discord:Button({
    Title = "Join Discord",
    Desc = "Join our community server",
    Callback = function()
        setclipboard("https://discord.gg/KG9ADqwT9Q")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Discord Invite",
            Text = "Link Copied to Clipboard!",
            Icon = "rbxassetid://84501312005643",
            Duration = 4
        })
    end
})

Config:Section({ Title = "Configuration" })
Config:Button({
    Title = "Reset All Settings",
    Desc = "Reset all saved settings",
    Callback = function()
        WindUI:ResetAll()
        WindUI:Notify({
            Title = "Reset",
            Content = "All settings have been reset!",
            Duration = 5
        })
    end
})

-- Update server info periodically
RunService.RenderStepped:Connect(function()
    local updatedInfo = getServerInfo()
    local updatedContent = string.format(
        "📌 PlaceId: %d\n📌 JobId: %s\n📌 IsStudio: %s\n📌 Players: %d/%d",
        updatedInfo.PlaceId,
        updatedInfo.JobId,
        updatedInfo.IsStudio and "Yes" or "No",
        updatedInfo.CurrentPlayers,
        updatedInfo.MaxPlayers
    )
    ParagraphInfoServer:Set({
        Title = "Info",
        Content = updatedContent
    })
end)
