local version = LRM_ScriptVersion and "v" .. table.concat(LRM_ScriptVersion:split(""), ".") or "Dev Version"
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/WindUI/Source.lua"))()
end)
if not success or not WindUI then
    warn("Primary WindUI load failed, attempting fallback 1...")
    success, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
    end)
    if not success or not WindUI then
        warn("Fallback 1 failed, attempting fallback 2...")
        success, WindUI = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/WindUI/Source.lua"))()
        end)
        if not success or not WindUI then
            warn("All WindUI load attempts failed. Check internet or executor compatibility.")
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Error",
                    Text = "UI Library failed to load. Check console for details.",
                    Duration = 10
                })
            end)
            return
        end
    end
end

if WindUI then
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
                    local success, err = pcall(function() setclipboard("https://discord.gg/KG9ADqwT9Q") end)
                    if success then
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Discord Invite",
                                Text = "Link Copied to Clipboard!",
                                Icon = "rbxassetid://84501312005643",
                                Duration = 4
                            })
                        end)
                    end
                end
            }
        }
    })

    local Window = WindUI:CreateWindow({
        Title = "Ryzen Hub - 99 Nights In The Forest",
        Icon = "rbxassetid://84501312005643",
        Author = "99 Nights In The Forest | " .. version,
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
            Title = "Ryzen Hub - 99 Nights In The Forest",
            Icon = "rbxassetid://84501312005643",
            Author = "99 Nights In The Forest | " .. version,
            Folder = "RyzenHub_NITF",
            Size = UDim2.fromOffset(400, 300),
            Transparent = true,
            Theme = "Dark",
        })
        if not Window then
            warn("UI initialization failed after retry. Script cannot proceed.")
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Error",
                    Text = "UI initialization failed. Check console for details.",
                    Duration = 10
                })
            end)
            return
        end
    end

    -- DRAGGABLE GUI IMPLEMENTATION --
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    if Window.MainFrame then
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
    end

    local Players = game:GetService("Players")
    local RepStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()

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
    local mfly1, mfly2
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
    local ActiveAutoCollectCandles = false
    local ActiveOpenChestsForCandles = false
    local ActiveLightHouses = false
    local ActiveCollectCandies = false
    local ActiveLootHouses = false
    local HouseStats = {loaded = 0, missing = 0, lighted = 0}
    local CandleCount = 0
    local ActiveAutoRepairTools = false
    local ActiveAutoUpgradeTools = false
    local ActiveAutoBuildStructures = false
    local ActiveAutoFish = false
    local ActiveAutoHuntAnimals = false
    local ActiveAutoCraftItems = false

    local petTamingFoodMap = {
        ["Bunny"] = "Carrot",
        ["Wolf"] = "Steak",
        ["Bear"] = "Cake",
        ["Mammoth"] = "Cake"
    }
    local activeTamingAnimals = {}

    local safeZonePos = workspace.Map.Campground.MainFire and workspace.Map.Campground.MainFire.PrimaryPart and workspace.Map.Campground.MainFire.PrimaryPart.Position + Vector3.new(0, 5, 0) or Vector3.new(0, 0, 0)

    -- Wait for character to load
    repeat task.wait(0.1) until player.Character

    -- Ensure Window is fully initialized before creating tabs
    task.wait(1.0)
    local Info = Window:Tab({ Title = "Info", Icon = "info" })
    local Player = Window:Tab({ Title = "Player", Icon = "user" })
    local Esp = Window:Tab({ Title = "ESP", Icon = "eye" })
    local Game = Window:Tab({ Title = "Game", Icon = "gamepad" })
    local BringItem = Window:Tab({ Title = "Items", Icon = "package" })
    local Automation = Window:Tab({ Title = "Automation", Icon = "settings" })
    local Teleport = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
    local Discord = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
    local Config = Window:Tab({ Title = "Config", Icon = "file-cog" })

    if not (Info and Player and Esp and Game and BringItem and Automation and Teleport and Discord and Config) then
        WindUI:Notify({
            Title = "UI Error",
            Content = "Tabs failed to load. Restarting UI...",
            Duration = 5
        })
        Window:Destroy()
        task.wait(0.5)
        Window = WindUI:CreateWindow({
            Title = "Ryzen Hub - 99 Nights In The Forest",
            Icon = "rbxassetid://84501312005643",
            Author = "99 Nights In The Forest | " .. version,
            Folder = "RyzenHub_NITF",
            Size = UDim2.fromOffset(400, 300),
            Transparent = true,
            Theme = "Dark",
        })
        Info = Window:Tab({ Title = "Info", Icon = "info" })
        Player = Window:Tab({ Title = "Player", Icon = "user" })
        Esp = Window:Tab({ Title = "ESP", Icon = "eye" })
        Game = Window:Tab({ Title = "Game", Icon = "gamepad" })
        BringItem = Window:Tab({ Title = "Items", Icon = "package" })
        Automation = Window:Tab({ Title = "Automation", Icon = "settings" })
        Teleport = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
        Discord = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
        Config = Window:Tab({ Title = "Config", Icon = "file-cog" })
        if not (Info and Player and Esp and Game and BringItem and Automation and Teleport and Discord and Config) then
            warn("Tab initialization failed after retry. Script cannot continue.")
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Error",
                    Text = "Tab initialization failed. Check console for details.",
                    Duration = 10
                })
            end)
            return
        end
    end

    local function DragItem(Item)
        spawn(function()
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    local args = {tool, Item}
                    pcall(function() RepStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestBagStoreItem"):InvokeServer(unpack(args)) end)
                    task.wait(0.1)
                end
            end
        end)
    end

    local function getServerInfo()
        local playerCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers or 100
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
        repeat task.wait() until player.Character and player.Character:WaitForChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid")
        repeat task.wait() until mouse
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
            spawn(function()
                repeat task.wait()
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
        flyKeyDown = mouse.KeyDown:Connect(function(KEY)
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
        flyKeyUp = mouse.KeyUp:Connect(function(KEY)
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

    local function MobileFly()
        UnMobileFly()
        FLYING = true
        local root = player.Character:WaitForChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)

        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 1000
        bg.D = 50

        mfly1 = player.CharacterAdded:Connect(function()
            local newRoot = player.Character:WaitForChild("HumanoidRootPart")
            local newBv = Instance.new("BodyVelocity")
            newBv.Name = velocityHandlerName
            newBv.Parent = newRoot
            newBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            newBv.Velocity = Vector3.new(0, 0, 0)

            local newBg = Instance.new("BodyGyro")
            newBg.Name = gyroHandlerName
            newBg.Parent = newRoot
            newBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            newBg.P = 1000
            newBg.D = 50
        end)

        mfly2 = RunService.RenderStepped:Connect(function()
            local currentRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not currentRoot then return end
            local camera = workspace.CurrentCamera
            if player.Character:FindFirstChildWhichIsA("Humanoid") and currentRoot:FindFirstChild(velocityHandlerName) and currentRoot:FindFirstChild(gyroHandlerName) then
                local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
                local VelocityHandler = currentRoot:FindFirstChild(velocityHandlerName)
                local GyroHandler = currentRoot:FindFirstChild(gyroHandlerName)

                VelocityHandler.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                GyroHandler.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                humanoid.PlatformStand = true
                GyroHandler.CFrame = camera.CFrame
                local moveVector = UserInputService:GetMovementDirection()
                VelocityHandler.Velocity = (camera.CFrame.LookVector * moveVector.Z + camera.CFrame.RightVector * moveVector.X) * (iyflyspeed * 50)
            end
        end)
    end

    local function UnMobileFly()
        FLYING = false
        if mfly1 then mfly1:Disconnect() end
        if mfly2 then mfly2:Disconnect() end
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if root:FindFirstChild(velocityHandlerName) then root:FindFirstChild(velocityHandlerName):Destroy() end
                if root:FindFirstChild(gyroHandlerName) then root:FindFirstChild(gyroHandlerName):Destroy() end
            end
            local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end

    local function CreateEsp(Char, Color, Text, Parent, number)
        if not Char or Char:FindFirstChild("ESP") or Char:FindFirstChildOfClass("Highlight") then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = Char
        highlight.FillColor = Color
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = true
        highlight.Parent = Char

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Size = UDim2.new(0, 50, 0, 25)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, number, 0)
        billboard.Adornee = Parent
        billboard.Enabled = true
        billboard.Parent = Parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = Text
        label.TextColor3 = Color
        label.TextScaled = true
        label.Parent = billboard

        spawn(function()
            local Camera = workspace.CurrentCamera
            while highlight and billboard and Parent and Parent.Parent do
                local cameraPosition = Camera and Camera.CFrame.Position
                if cameraPosition and Parent and Parent:IsA("BasePart") then
                    local distance = (cameraPosition - Parent.Position).Magnitude
                    if ActiveDistanceEsp then
                        label.Text = Text .. " (" .. math.floor(distance + 0.5) .. " m)"
                    else
                        label.Text = Text
                    end
                end
                task.wait(0.1)
            end
        end)
    end

    local function KeepEsp(Char, Parent)
        if Char and Char:FindFirstChildOfClass("Highlight") then Char:FindFirstChildOfClass("Highlight"):Destroy() end
        if Parent and Parent:FindFirstChildOfClass("BillboardGui") then Parent:FindFirstChildOfClass("BillboardGui"):Destroy() end
    end

    local function updateSpeed()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = ActiveSpeedBoost and ValueSpeed or OldSpeed
        end
    end

    local function infHealth()
        while ActiveInfHealth do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
            end
            task.wait(0.1)
        end
    end

    local function freeCamoMode()
        while ActiveFreeCamo do
            Lighting.FogEnd = 9999
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1, 1, 1)
            task.wait(1)
        end
        Lighting.FogEnd = 100
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0.2, 0.2, 0.2)
    end

    local function autoSurviveDays()
        while ActiveAutoSurviveDays do
            local campfire = workspace.Map.Campground:FindFirstChild("Campfire")
            if campfire and campfire:FindFirstChild("FuelValue") and campfire.FuelValue.Value < 50 then
                local fuel = player.Backpack:FindFirstChild("Log") or player.Backpack:FindFirstChild("Coal")
                if fuel then pcall(function() RepStorage.RemoteEvents.AddFuel:FireServer(campfire, fuel) end) end
            end
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 75 then
                local food = player.Backpack:FindFirstChild("CookedMeat") or player.Backpack:FindFirstChild("Carrot")
                if food then pcall(function() RepStorage.RemoteEvents.ConsumeItem:FireServer(food) end) end
            end
            task.wait(10)
        end
    end

    local function autoCookFood()
        while ActiveAutoCookFood do
            local campfire = workspace.Map.Campground:FindFirstChild("Campfire")
            local rawFood = player.Backpack:FindFirstChild("RawMeat") or player.Backpack:FindFirstChild("Carrot")
            if campfire and rawFood then pcall(function() RepStorage.RemoteEvents.CookItem:FireServer(rawFood, campfire) end) end
            task.wait(5)
        end
    end

    local function autoEatFood()
        while ActiveAutoEatFood do
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 90 then
                local food = player.Backpack:FindFirstChild("CookedMeat") or player.Backpack:FindFirstChild("Carrot")
                if food then pcall(function() RepStorage.RemoteEvents.ConsumeItem:FireServer(food) end) end
            end
            task.wait(15)
        end
    end

    local function autoMissingFoods()
        while ActiveAutoMissingFoods do
            local foodCount = 0
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item.Name == "Carrot" or item.Name == "CookedMeat" then foodCount = foodCount + 1 end
            end
            if foodCount < 3 then
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if (item.Name == "Carrot" or item.Name == "RawMeat") and item:IsA("Model") and item.PrimaryPart then DragItem(item) end
                end
            end
            task.wait(30)
        end
    end

    local function autoBringOres()
        while ActiveAutoBringOres do
            for _, item in pairs(workspace.Items:GetChildren()) do
                if (item.Name == "Ore" or item.Name == "Coal") and item:IsA("Model") and item.PrimaryPart then DragItem(item) end
            end
            task.wait(10)
        end
    end

    local function autoTpEnemies()
        while ActiveAutoTpEnemies do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            for _, enemy in pairs(workspace.Characters:GetChildren()) do
                if enemy:IsA("Model") and enemy.PrimaryPart and enemy.Name ~= "Pelt Trader" then
                    hrp.CFrame = CFrame.new(enemy.PrimaryPart.Position + Vector3.new(0, 5, 0))
                    task.wait(2)
                end
            end
            task.wait(5)
        end
    end

    local function autoTpTrees()
        while ActiveAutoTpTrees do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                if tree:IsA("Model") and tree.PrimaryPart then
                    hrp.CFrame = CFrame.new(tree.PrimaryPart.Position + Vector3.new(0, 5, 0))
                    task.wait(2)
                end
            end
            task.wait(5)
        end
    end

    local function autoChopSelectedTree()
        while ActiveTreeAura do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local weapon = player.Backpack:FindFirstChild("Old Axe") or player.Backpack:FindFirstChild("Good Axe") or player.Backpack:FindFirstChild("Strong Axe") or player.Backpack:FindFirstChild("Chainsaw")
            if weapon then
                local targetTrees = (SelectedTreeType == "All") and {"Small Tree", "TreeBig1", "TreeBig2", "Snow Tree", "Dead Tree"} or {SelectedTreeType}
                for _, treeName in pairs(targetTrees) do
                    for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                        if tree:IsA("Model") and tree.Name == treeName and tree.PrimaryPart then
                            local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForTreeAura then
                                pcall(function() RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame) end)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end

    local function autoPlantSaplings()
        while ActiveAutoPlaceSapling do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local seedBox = player.Backpack:FindFirstChild("Seed Box")
            if seedBox then
                for i = 1, SaplingAmount do
                    local angle = (2 * math.pi * i) / SaplingAmount
                    local offset = (SaplingShape == "Circle") and Vector3.new(math.cos(angle) * DistanceForSaplingPlace, 0, math.sin(angle) * DistanceForSaplingPlace) or Vector3.new((i % 5 - 2.5) * DistanceForSaplingPlace, 0, math.floor(i / 5 - 2.5) * DistanceForSaplingPlace)
                    local plantPos = hrp.Position + offset
                    pcall(function() RepStorage.RemoteEvents.PlantSapling:FireServer(plantPos, seedBox) end)
                    task.wait(1)
                end
            end
            task.wait(10)
        end
    end

    local function autoTamePet()
        while ActiveAutoTamePet do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local flute = player.Backpack:FindFirstChild("Old Taming Flute") or player.Backpack:FindFirstChild("Good Taming Flute") or player.Backpack:FindFirstChild("Strong Taming Flute")
            if flute then
                for _, animal in pairs(workspace.Characters:GetChildren()) do
                    if animal:IsA("Model") and animal.PrimaryPart and (animal.Name == "Bunny" or animal.Name == "Wolf" or animal.Name == "Bear" or animal.Name == "Mammoth") then
                        local distance = (animal.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForPetTame and not activeTamingAnimals[animal] then
                            activeTamingAnimals[animal] = true
                            pcall(function() RepStorage.RemoteEvents.StartTaming:FireServer(animal, flute) end)
                            task.wait(30)
                            local food = petTamingFoodMap[animal.Name]
                            local foodItem = player.Backpack:FindFirstChild(food)
                            if foodItem then
                                for _ = 1, 5 do
                                    pcall(function() RepStorage.RemoteEvents.FeedAnimal:FireServer(animal, foodItem) end)
                                    task.wait(2)
                                end
                            end
                            activeTamingAnimals[animal] = nil
                        end
                    end
                end
            end
            task.wait(5)
        end
    end

    local function stunMobs()
        while ActiveStunMobs do
            for _, mob in pairs(workspace.Characters:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Name ~= "Pelt Trader" then
                    mob.Humanoid.WalkSpeed = 0
                    mob.Humanoid.JumpPower = 0
                end
            end
            task.wait(1)
        end
    end

    local function autoMinigameTaming()
        while ActiveAutoMinigameTaming do
            local flute = player.Backpack:FindFirstChild("Old Taming Flute") or player.Backpack:FindFirstChild("Good Taming Flute") or player.Backpack:FindFirstChild("Strong Taming Flute")
            if flute then
                for _, animal in pairs(workspace.Characters:GetChildren()) do
                    if animal:IsA("Model") and animal.PrimaryPart and (animal.Name == "Bunny" or animal.Name == "Wolf") then
                        pcall(function() RepStorage.RemoteEvents.StartTaming:FireServer(animal, flute) end)
                        task.wait(30)
                    end
                end
            end
            task.wait(10)
        end
    end

    local function autoFeedTaming()
        while ActiveAutoFeedTaming do
            for _, animal in pairs(workspace.Characters:GetChildren()) do
                if animal:IsA("Model") and animal:FindFirstChild("TamingProgress") and animal.TamingProgress.Value > 0 then
                    local food = player.Backpack:FindFirstChild(petTamingFoodMap[animal.Name])
                    if food then pcall(function() RepStorage.RemoteEvents.FeedAnimal:FireServer(animal, food) end) end
                end
            end
            task.wait(5)
        end
    end

    local function hitboxExpander()
        while ActiveHitboxExpander do
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Parent.Name ~= player.Name and not part:IsDescendantOf(workspace.Characters) then
                    part.Size = part.Size + Vector3.new(2, 2, 2)
                end
            end
            task.wait(1)
        end
    end

    local function fullMapLoader()
        while ActiveFullMapLoader do
            for _, part in pairs(workspace.Map:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency ~= 0.3 then
                    part.Transparency = 0.3
                end
            end
            task.wait(1)
        end
    end

    local function autoEatStew()
        while ActiveAutoEatStew do
            local stew = player.Backpack:FindFirstChild("Stew")
            if stew and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 80 then
                pcall(function() RepStorage.RemoteEvents.ConsumeItem:FireServer(stew) end)
            end
            task.wait(20)
        end
    end

    local function antiAfk()
        while ActiveAntiAfk do
            local vu = game:GetService("VirtualUser")
            pcall(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end)
            task.wait(30)
        end
    end

    local function autoTimeMachine()
        while ActiveAutoTimeMachine do
            pcall(function() RepStorage.RemoteEvents.SkipNight:FireServer() end)
            task.wait(60)
        end
    end

    local function autoCast()
        while ActiveAutoCast do
            local castItem = player.Backpack:FindFirstChild("MagicWand")
            if castItem then pcall(function() RepStorage.RemoteEvents.CastSpell:FireServer(castItem, mouse.Hit.Position) end) end
            task.wait(5)
        end
    end

    local function autoMinigames()
        while ActiveAutoMinigames do
            pcall(function() RepStorage.RemoteEvents.CompleteMinigame:FireServer("Fishing") end)
            task.wait(10)
        end
    end

    local function alwaysBiggerBar()
        while ActiveAlwaysBiggerBar do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.MaxHealth = 200
                player.Character.Humanoid.Health = 200
            end
            task.wait(0.1)
        end
    end

    local function betterAutoCast()
        while ActiveBetterAutoCast do
            local castItem = player.Backpack:FindFirstChild("MagicWand")
            if castItem then pcall(function() RepStorage.RemoteEvents.CastSpell:FireServer(castItem, CFrame.new(mouse.Hit.Position)) end) end
            task.wait(3)
        end
    end

    local function hipHeight()
        while ActiveHipHeight do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, HipHeightValue, 0)
            end
            task.wait(0.5)
        end
    end

    local function autoFarmSnowySmallTree()
        while ActiveAutoFarmSnowySmallTree do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local weapon = player.Backpack:FindFirstChild("Old Axe") or player.Backpack:FindFirstChild("Good Axe") or player.Backpack:FindFirstChild("Strong Axe") or player.Backpack:FindFirstChild("Chainsaw")
            if weapon then
                for _, tree in pairs(workspace.Map.SnowyArea:GetChildren()) do
                    if tree.Name == "SmallTree" and tree:IsA("Model") and tree.PrimaryPart then
                        local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= 30 then pcall(function() RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame) end) end
                    end
                end
            end
            task.wait(0.5)
        end
    end

    local function instaOpenChest()
        while ActiveInstaOpenChest do
            for _, chest in pairs(workspace.Chests:GetChildren()) do
                if chest:IsA("Model") and chest:FindFirstChild("ProximityPrompt") then
                    pcall(function() fireproximityprompt(chest.ProximityPrompt) end)
                end
            end
            task.wait(1)
        end
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
        while ActiveTpToSafeZoneLowHP do
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 20 then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(safeZonePos)
            end
            task.wait(0.5)
        end
    end

    local function autoCollectCandles()
        while ActiveAutoCollectCandles do
            for _, item in pairs(workspace.Items:GetChildren()) do
                if item.Name == "Candle" and item:IsA("Model") and item.PrimaryPart then DragItem(item) end
            end
            task.wait(5)
        end
    end

    local function openChestsForCandles()
        while ActiveOpenChestsForCandles do
            for _, chest in pairs(workspace.Chests:GetChildren()) do
                if chest:IsA("Model") and chest:FindFirstChild("ProximityPrompt") then
                    pcall(function() fireproximityprompt(chest.ProximityPrompt) end)
                    task.wait(0.5)
                end
            end
            task.wait(10)
        end
    end

    local function lightHouses()
        while ActiveLightHouses do
            local candle = player.Backpack:FindFirstChild("Candle")
            if candle then
                for _, house in pairs(workspace.Houses:GetChildren()) do
                    if house:IsA("Model") and house:FindFirstChild("LightPoint") and not house.LightPoint.Value then
                        pcall(function() RepStorage.RemoteEvents.LightHouse:FireServer(house, candle) end)
                        task.wait(1)
                    end
                end
            end
            task.wait(15)
        end
    end

    local function updateHouseStats()
        HouseStats.loaded = 0
        HouseStats.missing = 0
        HouseStats.lighted = 0
        for _, house in pairs(workspace.Houses:GetChildren()) do
            if house:IsA("Model") then
                HouseStats.loaded = HouseStats.loaded + 1
                if house:FindFirstChild("LightPoint") and house.LightPoint.Value then HouseStats.lighted = HouseStats.lighted + 1 end
            end
        end
        HouseStats.missing = #workspace.Houses:GetChildren() - HouseStats.loaded
    end

    local function autoCollectCandies()
        while ActiveCollectCandies do
            for _, item in pairs(workspace.Items:GetChildren()) do
                if item.Name == "Candy" and item:IsA("Model") and item.PrimaryPart then DragItem(item) end
            end
            task.wait(5)
        end
    end

    local function autoLootHouses()
        while ActiveLootHouses do
            for _, house in pairs(workspace.Houses:GetChildren()) do
                if house:IsA("Model") and house:FindFirstChild("ProximityPrompt") then
                    pcall(function() fireproximityprompt(house.ProximityPrompt) end)
                    task.wait(2)
                end
            end
            task.wait(15)
        end
    end

    local function autoRepairTools()
        while ActiveAutoRepairTools do
            local repairKit = player.Backpack:FindFirstChild("Repair Kit")
            if repairKit then
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Durability") and tool.Durability.Value < tool.Durability.MaxValue then
                        pcall(function() RepStorage.RemoteEvents.RepairTool:FireServer(tool, repairKit) end)
                        task.wait(1)
                    end
                end
            end
            task.wait(10)
        end
    end

    local function autoUpgradeTools()
        while ActiveAutoUpgradeTools do
            local upgradeStone = player.Backpack:FindFirstChild("Upgrade Stone")
            if upgradeStone then
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Level") and tool.Level.Value < 5 then
                        pcall(function() RepStorage.RemoteEvents.UpgradeTool:FireServer(tool, upgradeStone) end)
                        task.wait(1)
                    end
                end
            end
            task.wait(10)
        end
    end

    local function autoBuildStructures()
        while ActiveAutoBuildStructures do
            local wood = player.Backpack:FindFirstChild("Log")
            if wood then
                for _, blueprint in pairs(workspace.Blueprints:GetChildren()) do
                    if blueprint:IsA("Model") and blueprint:FindFirstChild("ProximityPrompt") then
                        pcall(function() RepStorage.RemoteEvents.BuildStructure:FireServer(blueprint, wood) end)
                        task.wait(2)
                    end
                end
            end
            task.wait(15)
        end
    end

    local function autoFish()
        while ActiveAutoFish do
            local fishingRod = player.Backpack:FindFirstChild("Fishing Rod")
            if fishingRod then
                pcall(function() RepStorage.RemoteEvents.StartFishing:FireServer(fishingRod, mouse.Hit.Position) end)
                task.wait(10)
            end
            task.wait(15)
        end
    end

    local function autoHuntAnimals()
        while ActiveAutoHuntAnimals do
            local weapon = player.Backpack:FindFirstChild("Old Axe") or player.Backpack:FindFirstChild("Good Axe") or player.Backpack:FindFirstChild("Strong Axe") or player.Backpack:FindFirstChild("Chainsaw")
            if weapon then
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                for _, animal in pairs(workspace.Characters:GetChildren()) do
                    if animal:IsA("Model") and animal.PrimaryPart and (animal.Name == "Deer" or animal.Name == "Boar") then
                        local distance = (animal.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= 20 then pcall(function() RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(animal, weapon, 999, hrp.CFrame) end) end
                    end
                end
            end
            task.wait(1)
        end
    end

    local function autoCraftItems()
        while ActiveAutoCraftItems do
            local workbench = workspace:FindFirstChild("Workbench")
            if workbench and workbench:FindFirstChild("ProximityPrompt") then
                local recipes = {
                    {name = "Arrow", materials = {"Stick", "Feather"}},
                    {name = "Trap", materials = {"Log", "Rope"}}
                }
                for _, recipe in pairs(recipes) do
                    local hasMaterials = true
                    for _, mat in pairs(recipe.materials) do
                        if not player.Backpack:FindFirstChild(mat) then
                            hasMaterials = false
                            break
                        end
                    end
                    if hasMaterials then
                        pcall(function() RepStorage.RemoteEvents.CraftItem:FireServer(workbench, recipe.name, recipe.materials) end)
                        task.wait(2)
                    end
                end
            end
            task.wait(20)
        end
    end

    -- UI Setup
    Info:Section({ Title = "Server Info" })
    local ParagraphInfoServer = Info:Paragraph({
        Title = "Info",
        Content = "Loading..."
    })

    Player:Section({ Title = "Player Modifications" })
    local SpeedSlider = Player:Slider({
        Title = "Player Speed",
        Desc = "Adjust player walk speed",
        Range = {Min = 0, Max = 500, Increment = 1},
        CurrentValue = 16,
        Suffix = "Speeds",
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
        Range = {Min = 0, Max = 10, Increment = 0.1},
        CurrentValue = 1,
        Suffix = "Fly Speed",
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
            if Value and not FLYING then
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
                    task.wait()
                    sFLY()
                end
            elseif not Value and FLYING then
                if UserInputService.TouchEnabled then
                    UnMobileFly()
                else
                    NOFLY()
                end
            end
        end
    })
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.F then
            if ActivateFly then
                if not FLYING then
                    if UserInputService.TouchEnabled then
                        MobileFly()
                    else
                        NOFLY()
                        task.wait()
                        sFLY()
                    end
                else
                    if UserInputService.TouchEnabled then
                        UnMobileFly()
                    else
                        NOFLY()
                    end
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
            while ActiveNoclip do
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
                task.wait(0.1)
            end
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and not part.CanCollide then part.CanCollide = true end
                end
            end
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
                    if k:byte() == 32 then
                        local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
                        if humanoid then
                            humanoid:ChangeState('Jumping')
                            task.wait()
                            humanoid:ChangeState('Seated')
                        end
                    end
                end)
                task.wait(0.1)
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
            if Value then
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.HoldDuration ~= 0 then
                        prompt.HoldDuration = 0
                    end
                end
            else
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.HoldDuration == 0 then
                        prompt.HoldDuration = 1
                    end
                end
            end
        end
    })
    Player:Toggle({
        Title = "No Fog",
        Desc = "Remove fog from the map",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveNoFog = Value
            while ActiveNoFog do
                Lighting.FogEnd = 9999
                task.wait(0.1)
            end
            Lighting.FogEnd = 100
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
        Range = {Min = 0, Max = 20, Increment = 1},
        CurrentValue = 0,
        Suffix = "Height",
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
            if player.Character and player.Character:WaitForChild("HumanoidRootPart") and workspace.Map.Campground.MainFire and workspace.Map.Campground.MainFire.PrimaryPart then
                player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.Campground.MainFire.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
            end
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
            while ActiveEspItems do
                for _, obj in pairs(workspace.Items:GetChildren()) do
                    if obj:IsA("Model") and obj.PrimaryPart and not obj:FindFirstChildOfClass("Highlight") then
                        CreateEsp(obj, Color3.fromRGB(255, 255, 0), obj.Name, obj.PrimaryPart, 2)
                    end
                end
                task.wait(0.1)
            end
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj:IsA("Model") and obj.PrimaryPart and obj:FindFirstChildOfClass("Highlight") then
                    KeepEsp(obj, obj.PrimaryPart)
                end
            end
        end
    })
    Esp:Toggle({
        Title = "Enemy ESP",
        Desc = "Highlight enemies (excludes Lost Children and Pelt Trader)",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveEspEnemy = Value
            while ActiveEspEnemy do
                for _, obj in pairs(workspace.Characters:GetChildren()) do
                    if obj:IsA("Model") and obj.PrimaryPart and not (obj.Name == "Lost Child" or obj.Name == "Pelt Trader") and not obj:FindFirstChildOfClass("Highlight") then
                        CreateEsp(obj, Color3.fromRGB(255, 0, 0), obj.Name, obj.PrimaryPart, 2)
                    end
                end
                task.wait(0.1)
            end
            for _, obj in pairs(workspace.Characters:GetChildren()) do
                if obj:IsA("Model") and obj.PrimaryPart and not (obj.Name == "Lost Child" or obj.Name == "Pelt Trader") and obj:FindFirstChildOfClass("Highlight") then
                    KeepEsp(obj, obj.PrimaryPart)
                end
            end
        end
    })
    Esp:Toggle({
        Title = "Children ESP",
        Desc = "Highlight Lost Children",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveEspChildren = Value
            while ActiveEspChildren do
                for _, obj in pairs(workspace.Characters:GetChildren()) do
                    if obj:IsA("Model") and obj.PrimaryPart and obj.Name == "Lost Child" and not obj:FindFirstChildOfClass("Highlight") then
                        CreateEsp(obj, Color3.fromRGB(0, 255, 0), obj.Name, obj.PrimaryPart, 2)
                    end
                end
                task.wait(0.1)
            end
            for _, obj in pairs(workspace.Characters:GetChildren()) do
                if obj:IsA("Model") and obj.PrimaryPart and obj.Name == "Lost Child" and obj:FindFirstChildOfClass("Highlight") then
                    KeepEsp(obj, obj.PrimaryPart)
                end
            end
        end
    })
    Esp:Toggle({
        Title = "Pelt Trader ESP",
        Desc = "Highlight Pelt Trader",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveEspPeltTrader = Value
            while ActiveEspPeltTrader do
                for _, obj in pairs(workspace.Characters:GetChildren()) do
                    if obj:IsA("Model") and obj.PrimaryPart and obj.Name == "Pelt Trader" and not obj:FindFirstChildOfClass("Highlight") then
                        CreateEsp(obj, Color3.fromRGB(0, 255, 255), obj.Name, obj.PrimaryPart, 2)
                    end
                end
                task.wait(0.1)
            end
            for _, obj in pairs(workspace.Characters:GetChildren()) do
                if obj:IsA("Model") and obj.PrimaryPart and obj.Name == "Pelt Trader" and obj:FindFirstChildOfClass("Highlight") then
                    KeepEsp(obj, obj.PrimaryPart)
                end
            end
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
        Range = {Min = 25, Max = 10000, Increment = 0.1},
        CurrentValue = 25,
        Suffix = "Distance",
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
            while ActiveKillAura do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local weapon = player.Backpack:FindFirstChild("Old Axe") or player.Backpack:FindFirstChild("Good Axe") or player.Backpack:FindFirstChild("Strong Axe") or player.Backpack:FindFirstChild("Chainsaw")
                for _, enemy in pairs(workspace.Characters:GetChildren()) do
                    if enemy:IsA("Model") and enemy.PrimaryPart and enemy.Name ~= "Pelt Trader" then
                        local distance = (enemy.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForKillAura then
                            pcall(function() RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(enemy, weapon, 999, hrp.CFrame) end)
                        end
                    end
                end
                task.wait(0.01)
            end
        end
    })
    local AutoChopSlider = Game:Slider({
        Title = "Distance For Auto Chop Tree",
        Desc = "Set distance for auto tree chopping",
        Range = {Min = 0, Max = 1000, Increment = 0.1},
        CurrentValue = 25,
        Suffix = "Distance",
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
            while ActiveAutoChopTree do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local weapon = player.Backpack:FindFirstChild("Old Axe") or player.Backpack:FindFirstChild("Good Axe") or player.Backpack:FindFirstChild("Strong Axe") or player.Backpack:FindFirstChild("Chainsaw")
                for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                    if tree:IsA("Model") and (tree.Name == "Small Tree" or tree.Name == "TreeBig1" or tree.Name == "TreeBig2") and tree.PrimaryPart then
                        local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForAutoChopTree then
                            pcall(function() RepStorage.RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame) end)
                        end
                    end
                end
                task.wait(0.01)
            end
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
        Range = {Min = 10, Max = 50, Increment = 5},
        CurrentValue = 25,
        Suffix = "Distance",
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
        Placeholder = "Put a name only 1 for bring it on you",
        Default = "",
        Save = true,
        Callback = function(Text)
            TextBoxText = Text
            isInTheMap = "no"
            HowManyItemCanShowUp = 0
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == TextBoxText and obj:IsA("Model") and obj.PrimaryPart then
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
        Desc = "Bring all the item with the name you chose",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == TextBoxText and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Items",
        Desc = "Bring all items to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Logs",
        Desc = "Bring all logs to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Log" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Coal",
        Desc = "Bring all coal to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Coal" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Fuel Canister",
        Desc = "Bring all fuel canisters to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Fuel Canister" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Carrot",
        Desc = "Bring all carrots to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Carrot" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Fuel",
        Desc = "Bring all fuel items to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if (obj.Name == "Log" or obj.Name == "Fuel Canister" or obj.Name == "Coal" or obj.Name == "Oil Barrel") and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Scraps",
        Desc = "Bring all scrap items to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if (obj.Name == "Tyre" or obj.Name == "Sheet Metal" or obj.Name == "Broken Fan" or obj.Name == "Bolt" or obj.Name == "Old Radio" or obj.Name == "UFO Junk" or obj.Name == "UFO Scrap" or obj.Name == "Broken Microwave") and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Ammo",
        Desc = "Bring all ammo to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if (obj.Name == "Rifle Ammo" or obj.Name == "Revolver Ammo") and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Children",
        Desc = "Bring all Lost Children to you",
        Callback = function()
            for _, obj in pairs(workspace.Characters:GetChildren()) do
                if (obj.Name == "Lost Child" or obj.Name == "Lost Child2" or obj.Name == "Lost Child3" or obj.Name == "Lost Child4") and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Foods",
        Desc = "Bring all food items to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if (obj.Name == "Cake" or obj.Name == "Carrot" or obj.Name == "Morsel" or obj.Name == "Meat? Sandwich") and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Bandage",
        Desc = "Bring all bandages to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Bandage" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Medkit",
        Desc = "Bring all medkits to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "MedKit" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Old Radio",
        Desc = "Bring all old radios to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Old Radio" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Tyre",
        Desc = "Bring all tyres to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Tyre" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Broken Fan",
        Desc = "Bring all broken fans to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Broken Fan" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Broken Microwave",
        Desc = "Bring all broken microwaves to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Broken Microwave" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Bolt",
        Desc = "Bring all bolts to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Bolt" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Sheet Metal",
        Desc = "Bring all sheet metal to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Sheet Metal" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Seed Box",
        Desc = "Bring all seed boxes to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Seed Box" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Chair",
        Desc = "Bring all chairs to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Chair" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Table",
        Desc = "Bring all tables to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Table" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })
    BringItem:Button({
        Title = "Bring All Bed",
        Desc = "Bring all beds to you",
        Callback = function()
            for _, obj in pairs(workspace.Items:GetChildren()) do
                if obj.Name == "Bed" and obj:IsA("Model") and obj.PrimaryPart then DragItem(obj) end
            end
        end
    })

    Automation:Section({ Title = "Automation Settings" })
    Automation:Slider({
        Title = "Sapling Distance",
        Desc = "Set distance for sapling placement",
        Range = {Min = 5, Max = 50, Increment = 1},
        CurrentValue = 20,
        Suffix = "Distance",
        Save = true,
        Callback = function(Value)
            DistanceForSaplingPlace = Value
        end
    })
    Automation:Slider({
        Title = "Sapling Amount",
        Desc = "Set number of saplings to plant",
        Range = {Min = 1, Max = 20, Increment = 1},
        CurrentValue = 10,
        Suffix = "Saplings",
        Save = true,
        Callback = function(Value)
            SaplingAmount = Value
        end
    })
    Automation:Dropdown({
        Title = "Sapling Shape",
        Options = {"Circle", "Square"},
        CurrentOption = "Circle",
        Save = true,
        Callback = function(Option)
            SaplingShape = Option
        end
    })
    Automation:Toggle({
        Title = "Auto Place Saplings",
        Desc = "Automatically plant saplings around player",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoPlaceSapling = Value
            autoPlantSaplings()
        end
    })
    Automation:Toggle({
        Title = "Auto Tame Pet",
        Desc = "Automatically tame nearby pets",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoTamePet = Value
            autoTamePet()
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
        Desc = "Skip to next day",
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
        Title = "Better Auto Cast",
        Desc = "Improved auto casting with CFrame",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveBetterAutoCast = Value
            betterAutoCast()
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
        Title = "Instant Open Chest",
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
        Desc = "Create a safe area at campfire",
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
    Automation:Toggle({
        Title = "Auto Collect Candles",
        Desc = "Automatically collect candles",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoCollectCandles = Value
            autoCollectCandles()
        end
    })
    Automation:Toggle({
        Title = "Open Chests for Candles",
        Desc = "Automatically open chests for candles",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveOpenChestsForCandles = Value
            openChestsForCandles()
        end
    })
    Automation:Toggle({
        Title = "Light Houses",
        Desc = "Automatically light houses with candles",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveLightHouses = Value
            lightHouses()
        end
    })
    Automation:Toggle({
        Title = "Auto Collect Candies",
        Desc = "Automatically collect candies",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveCollectCandies = Value
            autoCollectCandies()
        end
    })
    Automation:Toggle({
        Title = "Auto Loot Houses",
        Desc = "Automatically loot houses",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveLootHouses = Value
            autoLootHouses()
        end
    })
    Automation:Toggle({
        Title = "Auto Repair Tools",
        Desc = "Automatically repair tools with repair kits",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoRepairTools = Value
            autoRepairTools()
        end
    })
    Automation:Toggle({
        Title = "Auto Upgrade Tools",
        Desc = "Automatically upgrade tools with upgrade stones",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoUpgradeTools = Value
            autoUpgradeTools()
        end
    })
    Automation:Toggle({
        Title = "Auto Build Structures",
        Desc = "Automatically build structures with logs",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoBuildStructures = Value
            autoBuildStructures()
        end
    })
    Automation:Toggle({
        Title = "Auto Fish",
        Desc = "Automatically fish with rod",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoFish = Value
            autoFish()
        end
    })
    Automation:Toggle({
        Title = "Auto Hunt Animals",
        Desc = "Automatically hunt deer and boars",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoHuntAnimals = Value
            autoHuntAnimals()
        end
    })
    Automation:Toggle({
        Title = "Auto Craft Items",
        Desc = "Automatically craft items at workbench",
        Default = false,
        Save = true,
        Callback = function(Value)
            ActiveAutoCraftItems = Value
            autoCraftItems()
        end
    })

    Teleport:Section({ Title = "Teleport Options" })
    Teleport:Button({
        Title = "Teleport to Campfire",
        Desc = "Teleport to main campfire",
        Callback = function()
            if player.Character and player.Character:WaitForChild("HumanoidRootPart") and workspace.Map.Campground.MainFire and workspace.Map.Campground.MainFire.PrimaryPart then
                player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.Campground.MainFire.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
            end
        end
    })
    Teleport:Button({
        Title = "Teleport to Snowy Area",
        Desc = "Teleport to snowy area",
        Callback = function()
            if player.Character and player.Character:WaitForChild("HumanoidRootPart") and workspace.Map.SnowyArea and workspace.Map.SnowyArea.PrimaryPart then
                player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.SnowyArea.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
            end
        end
    })
    Teleport:Button({
        Title = "Teleport to Forest",
        Desc = "Teleport to forest area",
        Callback = function()
            if player.Character and player.Character:WaitForChild("HumanoidRootPart") and workspace.Map.Forest and workspace.Map.Forest.PrimaryPart then
                player.Character:WaitForChild("HumanoidRootPart").CFrame = workspace.Map.Forest.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
            end
        end
    })

    Discord:Section({ Title = "Community" })
    Discord:Button({
        Title = "Copy Discord Link",
        Desc = "Join our Discord server",
        Callback = function()
            local success, err = pcall(function() setclipboard("https://discord.gg/KG9ADqwT9Q") end)
            if success then
                WindUI:Notify({
                    Title = "Discord Invite",
                    Content = "Link copied to clipboard!",
                    Duration = 4
                })
            end
        end
    })

    Config:Section({ Title = "Configuration" })
    Config:Button({
        Title = "Save Config",
        Desc = "Save current settings",
        Callback = function()
            WindUI:Save()
            WindUI:Notify({
                Title = "Config Saved",
                Content = "Settings have been saved successfully!",
                Duration = 3
            })
        end
    })
    Config:Button({
        Title = "Load Config",
        Desc = "Load saved settings",
        Callback = function()
            WindUI:Load()
            WindUI:Notify({
                Title = "Config Loaded",
                Content = "Settings have been loaded successfully!",
                Duration = 3
            })
        end
    })
    Config:Button({
        Title = "Reset Config",
        Desc = "Reset all settings to default",
        Callback = function()
            WindUI:Reset()
            WindUI:Notify({
                Title = "Config Reset",
                Content = "Settings have been reset to default!",
                Duration = 3
            })
        end
    })

    -- Cleanup function for all toggles
    local function cleanup()
        if ActivateFly then
            if UserInputService.TouchEnabled then
                UnMobileFly()
            else
                NOFLY()
            end
        end
        ActiveEspItems, ActiveDistanceEsp, ActiveEspEnemy, ActiveEspChildren, ActiveEspPeltTrader = false, false, false, false, false
        ActivateFly, AlrActivatedFlyPC, ActiveNoCooldownPrompt, ActiveNoFog = false, false, false, false
        ActiveAutoChopTree, ActiveKillAura, ActivateInfiniteJump, ActiveNoclip = false, false, false, false
        ActiveSpeedBoost = false
        ActiveInfHealth, ActiveFreeCamo, ActiveAutoSurviveDays, ActiveAutoCookFood = false, false, false, false
        ActiveAutoEatFood, ActiveAutoMissingFoods, ActiveAutoBringOres, ActiveAutoTpEnemies = false, false, false, false
        ActiveAutoTpTrees, ActiveStunMobs, ActiveAutoMinigameTaming, ActiveAutoFeedTaming = false, false, false, false
        ActiveHitboxExpander, ActiveFullMapLoader, ActiveAutoEatStew, ActiveAntiAfk = false, false, false, false
        ActiveAutoTimeMachine, ActiveAutoCast, ActiveAutoMinigames, ActiveAlwaysBiggerBar = false, false, false, false
        ActiveBetterAutoCast, ActiveHipHeight, ActiveAutoFarmSnowySmallTree, ActiveInstaOpenChest = false, false, false, false
        ActiveCreateSafeZone, ActiveTpToSafeZoneLowHP, ActiveAutoCollectCandles, ActiveOpenChestsForCandles = false, false, false, false
        ActiveLightHouses, ActiveCollectCandies, ActiveLootHouses, ActiveAutoRepairTools = false, false, false, false
        ActiveAutoUpgradeTools, ActiveAutoBuildStructures, ActiveAutoFish, ActiveAutoHuntAnimals = false, false, false, false
        ActiveAutoCraftItems, ActiveAutoPlaceSapling, ActiveTreeAura, ActiveAutoTamePet = false, false, false, false
        if player.Character then
            player.Character.Humanoid.WalkSpeed = OldSpeed
            if player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character:FindFirstChildOfClass("Humanoid").MaxHealth = 100
                player.Character:FindFirstChildOfClass("Humanoid").Health = 100
            end
        end
        for _, obj in pairs(workspace.Items:GetDescendants()) do
            if obj:IsA("Highlight") or obj:IsA("BillboardGui") then obj:Destroy() end
        end
        for _, obj in pairs(workspace.Characters:GetDescendants()) do
            if obj:IsA("Highlight") or obj:IsA("BillboardGui") then obj:Destroy() end
        end
        if workspace:FindFirstChild("SafeZone") then workspace.SafeZone:Destroy() end
        Lighting.FogEnd = 100
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0.2, 0.2, 0.2)
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.HoldDuration == 0 then
                prompt.HoldDuration = 1
            end
        end
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and not part.CanCollide then part.CanCollide = true end
            end
        end
    end

    -- Handle character removal
    player.CharacterRemoving:Connect(function()
        cleanup()
    end)

    -- Initialize UI and start update loops
    Window:Init()

    -- Update server info periodically
    spawn(function()
        while true do
            local info = getServerInfo()
            ParagraphInfoServer:Set({
                Title = "Info",
                Content = "PlaceId: " .. info.PlaceId .. "\nJobId: " .. info.JobId .. "\nPlayers: " .. info.CurrentPlayers .. "/" .. info.MaxPlayers .. "\nStudio: " .. tostring(info.IsStudio)
            })
            task.wait(5)
        end
    end)

    -- Update house stats periodically
    spawn(function()
        while true do
            updateHouseStats()
            task.wait(10)
        end
    end)
end
