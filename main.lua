-- Ryzen Hub - 99 Nights In The Forest (v2.2 - October 19, 2025)
-- Fixed UI Loading Issues with Enhanced Error Handling and Fallback

local version = "v2.2 (October 19, 2025)"
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

-- Fallback if primary URL fails
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
    Title = "Ryzen Hub",
    Icon = "rbxassetid://84501312005643",
    Content = "UI loaded. Join our Discord for support!",
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function()
                setclipboard("https://discord.gg/KG9ADqwT9Q")
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Discord Invite",
                    Text = "Link copied to clipboard!",
                    Duration = 4
                })
            end
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "Ryzen Hub - 99 Nights In The Forest",
    Icon = "rbxassetid://84501312005643",
    Author = "Ryzen Team | " .. version,
    Folder = "RyzenHub_NITF",
    Size = UDim2.fromOffset(450, 350),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 220,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = true,
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
        Author = "Ryzen Team | " .. version,
        Folder = "RyzenHub_NITF",
        Size = UDim2.fromOffset(450, 350),
        Transparent = true,
        Theme = "Dark",
    })
    if not Window then
        error("UI initialization failed. Script cannot proceed.")
        return
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables
local ActiveEspItems, ActiveEspEnemy, ActiveEspChildren, ActiveEspPeltTrader = false, false, false, false
local ActivateFly = false
local ActiveNoclip = false
local ActiveSpeedBoost = false
local ValueSpeed = 16
local OldSpeed = 16
local iyflyspeed = 1
local FLYING = false
local QEfly = true
local TextBoxText = ""
local ActiveAutoChopTree = false
local DistanceForAutoChopTree = 25
local ActiveTreeAura = false
local TreeAuraTypes = {"All", "Small Tree", "TreeBig1", "TreeBig2", "Snow Tree", "Dead Tree"}
local SelectedTreeType = "All"
local ActiveAutoPlaceSapling = false
local DistanceForSaplingPlace = 20
local SaplingAmount = 10
local SaplingShape = "Circle"
local ActiveAutoTamePet = false
local DistanceForPetTame = 15
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
local flyKeyDown, flyKeyUp
local mfly1, mfly2
local velocityHandlerName = "BodyVelocity"
local gyroHandlerName = "BodyGyro"

-- Pet Taming Data
local petTamingFoodMap = {
    ["Bunny"] = "Carrot",
    ["Wolf"] = "Steak",
    ["Bear"] = "Cake",
    ["Mammoth"] = "Cake"
}
local activeTamingAnimals = {}

-- Safe Zone Position
local safeZonePos = workspace.Map.Campground.MainFire.PrimaryPart.Position + Vector3.new(0, 5, 0)

-- Tabs
local Info = Window:Tab({ Title = "Info", Icon = "info" })
local Player = Window:Tab({ Title = "Player", Icon = "user" })
local Esp = Window:Tab({ Title = "ESP", Icon = "eye" })
local Game = Window:Tab({ Title = "Game", Icon = "gamepad" })
local Items = Window:Tab({ Title = "Items", Icon = "package" })
local Automation = Window:Tab({ Title = "Automation", Icon = "settings" })
local Teleport = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
local Discord = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
local Config = Window:Tab({ Title = "Config", Icon = "file-cog" })

-- Helper Functions
local function DragItem(Item)
    task.spawn(function()
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                local args = {tool, Item}
                ReplicatedStorage.RemoteEvents.RequestBagStoreItem:InvokeServer(unpack(args))
                wait(0.1)
            end
        end
    end)
end

local function getServerInfo()
    return {
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        Players = #Players:GetPlayers(),
        MaxPlayers = Players.MaxPlayers
    }
end

-- Fly Functions
local function sFLY()
    repeat wait() until player.Character and player.Character:WaitForChild("HumanoidRootPart")
    repeat wait() until mouse
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

    local T = player.Character.HumanoidRootPart
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local BG = Instance.new("BodyGyro")
    local BV = Instance.new("BodyVelocity")
    BG.P = 9e4
    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BG.Parent = T
    BV.Parent = T

    FLYING = true
    task.spawn(function()
        while FLYING do
            wait()
            if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                SPEED = 50
            elseif SPEED ~= 0 then
                SPEED = 0
            end
            if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                BV.Velocity = ((workspace.CurrentCamera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0)).Position - workspace.CurrentCamera.CFrame.Position)) * SPEED * iyflyspeed
                lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
            elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                BV.Velocity = ((workspace.CurrentCamera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0)).Position - workspace.CurrentCamera.CFrame.Position)) * SPEED * iyflyspeed
            else
                BV.Velocity = Vector3.new(0, 0.1, 0)
            end
            BG.CFrame = workspace.CurrentCamera.CFrame
        end
        BG:Destroy()
        BV:Destroy()
        player.Character.Humanoid.PlatformStand = false
    end)

    flyKeyDown = mouse.KeyDown:Connect(function(KEY)
        if KEY:lower() == 'w' then CONTROL.F = iyflyspeed
        elseif KEY:lower() == 's' then CONTROL.B = -iyflyspeed
        elseif KEY:lower() == 'a' then CONTROL.L = -iyflyspeed
        elseif KEY:lower() == 'd' then CONTROL.R = iyflyspeed
        elseif QEfly and KEY:lower() == 'e' then CONTROL.Q = iyflyspeed * 2
        elseif QEfly and KEY:lower() == 'q' then CONTROL.E = -iyflyspeed * 2 end
    end)
    flyKeyUp = mouse.KeyUp:Connect(function(KEY)
        if KEY:lower() == 'w' then CONTROL.F = 0 elseif KEY:lower() == 's' then CONTROL.B = 0
        elseif KEY:lower() == 'a' then CONTROL.L = 0 elseif KEY:lower() == 'd' then CONTROL.R = 0
        elseif KEY:lower() == 'e' then CONTROL.Q = 0 elseif KEY:lower() == 'q' then CONTROL.E = 0 end
    end)
end

local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local T = player.Character.HumanoidRootPart
        if T:FindFirstChild("BodyVelocity") then T:FindFirstChild("BodyVelocity"):Destroy() end
        if T:FindFirstChild("BodyGyro") then T:FindFirstChild("BodyGyro"):Destroy() end
        player.Character.Humanoid.PlatformStand = false
    end
end

-- ESP Functions
local function CreateEsp(Char, Color, Text, Parent)
    if Char:FindFirstChild("ESP") or Char:FindFirstChildOfClass("Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.Adornee = Char
    highlight.FillColor = Color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color
    highlight.OutlineTransparency = 0
    highlight.Parent = Char

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = Parent
    billboard.Parent = Char

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = Text
    label.TextColor3 = Color
    label.BackgroundTransparency = 1
    label.Parent = billboard
end

local function RemoveEsp(Char)
    if Char:FindFirstChild("ESP") then Char:FindFirstChild("ESP"):Destroy() end
    if Char:FindFirstChildOfClass("Highlight") then Char:FindFirstChildOfClass("Highlight"):Destroy() end
end

-- Update Speed
local function updateSpeed()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = ActiveSpeedBoost and ValueSpeed or OldSpeed
    end
end

-- Auto Functions
local function autoChopTree()
    task.spawn(function()
        while ActiveAutoChopTree do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local axe = player.Backpack:FindFirstChild("Axe") or player.Backpack:FindFirstChild("Chainsaw")
            if axe then
                for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                    if tree:IsA("Model") and tree:FindFirstChild("TreePart") and (tree.Name == "Small Tree" or tree.Name == "TreeBig1" or tree.Name == "TreeBig2") then
                        local distance = (tree.TreePart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForAutoChopTree then
                            ReplicatedStorage.RemoteEvents.ChopTree:FireServer(tree, axe)
                        end
                    end
                end
            end
            wait(0.5)
        end
    end)
end

local function autoChopSelectedTree()
    task.spawn(function()
        while ActiveTreeAura do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local axe = player.Backpack:FindFirstChild("Axe") or player.Backpack:FindFirstChild("Chainsaw")
            if axe then
                local targetTrees = (SelectedTreeType == "All") and {"Small Tree", "TreeBig1", "TreeBig2", "Snow Tree", "Dead Tree"} or {SelectedTreeType}
                for _, treeName in pairs(targetTrees) do
                    for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                        if tree:IsA("Model") and tree:FindFirstChild("TreePart") and tree.Name == treeName then
                            local distance = (tree.TreePart.Position - hrp.Position).Magnitude
                            if distance <= 25 then
                                ReplicatedStorage.RemoteEvents.ChopTree:FireServer(tree, axe)
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
            local seedBox = player.Backpack:FindFirstChild("SeedBox")
            if seedBox then
                for i = 1, SaplingAmount do
                    local angle = (2 * math.pi * i) / SaplingAmount
                    local offset = (SaplingShape == "Circle") and Vector3.new(math.cos(angle) * DistanceForSaplingPlace, 0, math.sin(angle) * DistanceForSaplingPlace) or Vector3.new((i % 5 - 2.5) * DistanceForSaplingPlace, 0, math.floor(i / 5 - 2.5) * DistanceForSaplingPlace)
                    local plantPos = hrp.Position + offset
                    ReplicatedStorage.RemoteEvents.PlantSapling:FireServer(plantPos, seedBox)
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
            local flute = player.Backpack:FindFirstChild("TamingFlute")
            if flute then
                for _, animal in pairs(workspace.NPCs:GetChildren()) do
                    if animal.Name == "Bunny" or animal.Name == "Wolf" or animal.Name == "Bear" or animal.Name == "Mammoth" then
                        local distance = (animal.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForPetTame and not activeTamingAnimals[animal] then
                            activeTamingAnimals[animal] = true
                            ReplicatedStorage.RemoteEvents.StartTaming:FireServer(animal, flute)
                            wait(30) -- Real taming duration
                            local food = petTamingFoodMap[animal.Name]
                            local foodItem = player.Backpack:FindFirstChild(food)
                            if foodItem then
                                for _ = 1, 5 do
                                    ReplicatedStorage.RemoteEvents.FeedAnimal:FireServer(animal, foodItem)
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
                local fuel = player.Backpack:FindFirstChild("Log") or player.Backpack:FindFirstChild("Coal")
                if fuel then
                    ReplicatedStorage.RemoteEvents.AddFuel:FireServer(campfire, fuel)
                end
            end
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 75 then
                local food = player.Backpack:FindFirstChild("CookedMeat") or player.Backpack:FindFirstChild("Carrot")
                if food then
                    ReplicatedStorage.RemoteEvents.ConsumeItem:FireServer(food)
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
            local rawFood = player.Backpack:FindFirstChild("RawMeat") or player.Backpack:FindFirstChild("Carrot")
            if campfire and rawFood then
                ReplicatedStorage.RemoteEvents.CookItem:FireServer(rawFood, campfire)
            end
            wait(5)
        end
    end)
end

local function autoEatFood()
    task.spawn(function()
        while ActiveAutoEatFood do
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 90 then
                local food = player.Backpack:FindFirstChild("CookedMeat") or player.Backpack:FindFirstChild("Carrot")
                if food then
                    ReplicatedStorage.RemoteEvents.ConsumeItem:FireServer(food)
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
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item.Name == "Carrot" or item.Name == "CookedMeat" then foodCount = foodCount + 1 end
            end
            if foodCount < 3 then
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if (item.Name == "Carrot" or item.Name == "RawMeat") and item:FindFirstChild("Handle") then
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
                if item.Name == "Ore" or item.Name == "Coal" and item:FindFirstChild("Handle") then
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
            for _, enemy in pairs(workspace.NPCs:GetChildren()) do
                if enemy.Name ~= "PeltTrader" and enemy:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = CFrame.new(enemy.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
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
                if tree:FindFirstChild("TreePart") then
                    hrp.CFrame = CFrame.new(tree.TreePart.Position + Vector3.new(0, 5, 0))
                    wait(2)
                end
            end
            wait(5)
        end
    end)
end

local function stunMobs()
    task.spawn(function()
        while ActiveStunMobs do
            for _, mob in pairs(workspace.NPCs:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob.Name ~= "PeltTrader" then
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
            local flute = player.Backpack:FindFirstChild("TamingFlute")
            if flute then
                for _, animal in pairs(workspace.NPCs:GetChildren()) do
                    if animal.Name == "Bunny" or animal.Name == "Wolf" then
                        ReplicatedStorage.RemoteEvents.StartTaming:FireServer(animal, flute)
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
            for _, animal in pairs(workspace.NPCs:GetChildren()) do
                if animal:FindFirstChild("TamingProgress") and animal.TamingProgress.Value > 0 then
                    local food = player.Backpack:FindFirstChild(petTamingFoodMap[animal.Name])
                    if food then
                        ReplicatedStorage.RemoteEvents.FeedAnimal:FireServer(animal, food)
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
                if part:IsA("BasePart") and part.Parent.Name ~= player.Name then
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
                if part:IsA("BasePart") then
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
            local stew = player.Backpack:FindFirstChild("Stew")
            if stew and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health < 80 then
                ReplicatedStorage.RemoteEvents.ConsumeItem:FireServer(stew)
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
            ReplicatedStorage.RemoteEvents.SkipNight:FireServer()
            wait(60) -- Real night skip duration
        end
    end)
end

local function autoCast()
    task.spawn(function()
        while ActiveAutoCast do
            local castItem = player.Backpack:FindFirstChild("MagicWand")
            if castItem then
                ReplicatedStorage.RemoteEvents.CastSpell:FireServer(castItem, mouse.Hit.Position)
            end
            wait(5)
        end
    end)
end

local function autoMinigames()
    task.spawn(function()
        while ActiveAutoMinigames do
            ReplicatedStorage.RemoteEvents.CompleteMinigame:FireServer("Fishing")
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
            local castItem = player.Backpack:FindFirstChild("MagicWand")
            if castItem then
                ReplicatedStorage.RemoteEvents.CastSpell:FireServer(castItem, CFrame.new(mouse.Hit.Position))
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
            local axe = player.Backpack:FindFirstChild("Axe") or player.Backpack:FindFirstChild("Chainsaw")
            if axe then
                for _, tree in pairs(workspace.Map.SnowyArea:GetChildren()) do
                    if tree.Name == "SmallTree" and tree:FindFirstChild("TreePart") then
                        local distance = (tree.TreePart.Position - hrp.Position).Magnitude
                        if distance <= 30 then
                            ReplicatedStorage.RemoteEvents.ChopTree:FireServer(tree, axe)
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
                if chest:FindFirstChild("ProximityPrompt") then
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

-- UI Setup
Info:Section({ Title = "Server Info" })
local ServerInfo = Info:Paragraph({ Title = "Info", Content = "Loading..." })

Player:Section({ Title = "Player Mods" })
Player:Toggle({
    Title = "Infinite Health",
    CurrentValue = false,
    Flag = "InfHealth",
    Callback = function(Value) ActiveInfHealth = Value infHealth() end
})
Player:Slider({
    Title = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value) ValueSpeed = Value updateSpeed() end
})
Player:Toggle({
    Title = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(Value) ActiveSpeedBoost = Value updateSpeed() end
})
Player:Slider({
    Title = "Fly Speed",
    Range = {1, 10},
    Increment = 0.1,
    Suffix = "Speed",
    CurrentValue = 1,
    Flag = "FlySpeed",
    Callback = function(Value) iyflyspeed = Value end
})
Player:Toggle({
    Title = "Fly (Press F)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        ActivateFly = Value
        if Value then sFLY() else NOFLY() end
    end
})
Player:Toggle({
    Title = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        ActiveNoclip = Value
        task.spawn(function()
            while ActiveNoclip do
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                wait(0.1)
            end
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end)
    end
})
Player:Toggle({
    Title = "Free Camo Mode",
    CurrentValue = false,
    Flag = "FreeCamo",
    Callback = function(Value) ActiveFreeCamo = Value freeCamoMode() end
})
Player:Slider({
    Title = "Hip Height",
    Range = {0, 20},
    Increment = 1,
    Suffix = "Height",
    CurrentValue = 0,
    Flag = "HipHeight",
    Callback = function(Value) HipHeightValue = Value end
})
Player:Toggle({
    Title = "Hip Height Active",
    CurrentValue = false,
    Flag = "HipHeightActive",
    Callback = function(Value) ActiveHipHeight = Value hipHeight() end
})

Esp:Section({ Title = "ESP" })
Esp:Toggle({
    Title = "Items ESP",
    CurrentValue = false,
    Flag = "ItemsESP",
    Callback = function(Value)
        ActiveEspItems = Value
        task.spawn(function()
            while ActiveEspItems do
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item:FindFirstChild("Handle") then
                        CreateEsp(item, Color3.fromRGB(255, 255, 0), item.Name, item.Handle)
                    end
                end
                wait(0.5)
            end
            for _, item in pairs(workspace.Items:GetChildren()) do RemoveEsp(item) end
        end)
    end
})
Esp:Toggle({
    Title = "Enemy ESP",
    CurrentValue = false,
    Flag = "EnemyESP",
    Callback = function(Value)
        ActiveEspEnemy = Value
        task.spawn(function()
            while ActiveEspEnemy do
                for _, npc in pairs(workspace.NPCs:GetChildren()) do
                    if npc.Name ~= "PeltTrader" and npc:FindFirstChild("HumanoidRootPart") then
                        CreateEsp(npc, Color3.fromRGB(255, 0, 0), npc.Name, npc.HumanoidRootPart)
                    end
                end
                wait(0.5)
            end
            for _, npc in pairs(workspace.NPCs:GetChildren()) do RemoveEsp(npc) end
        end)
    end
})
Esp:Toggle({
    Title = "Children ESP",
    CurrentValue = false,
    Flag = "ChildrenESP",
    Callback = function(Value)
        ActiveEspChildren = Value
        task.spawn(function()
            while ActiveEspChildren do
                for _, child in pairs(workspace.NPCs:GetChildren()) do
                    if child.Name == "LostChild" and child:FindFirstChild("HumanoidRootPart") then
                        CreateEsp(child, Color3.fromRGB(0, 255, 0), child.Name, child.HumanoidRootPart)
                    end
                end
                wait(0.5)
            end
            for _, child in pairs(workspace.NPCs:GetChildren()) do RemoveEsp(child) end
        end)
    end
})
Esp:Toggle({
    Title = "Pelt Trader ESP",
    CurrentValue = false,
    Flag = "PeltESP",
    Callback = function(Value)
        ActiveEspPeltTrader = Value
        task.spawn(function()
            while ActiveEspPeltTrader do
                for _, trader in pairs(workspace.NPCs:GetChildren()) do
                    if trader.Name == "PeltTrader" and trader:FindFirstChild("HumanoidRootPart") then
                        CreateEsp(trader, Color3.fromRGB(0, 255, 255), trader.Name, trader.HumanoidRootPart)
                    end
                end
                wait(0.5)
            end
            for _, trader in pairs(workspace.NPCs:GetChildren()) do RemoveEsp(trader) end
        end)
    end
})

Game:Section({ Title = "Game Mods" })
Game:Slider({
    Title = "Auto Chop Distance",
    Range = {10, 50},
    Increment = 5,
    Suffix = "m",
    CurrentValue = 25,
    Flag = "ChopDist",
    Callback = function(Value) DistanceForAutoChopTree = Value end
})
Game:Toggle({
    Title = "Auto Chop Tree",
    CurrentValue = false,
    Flag = "AutoChop",
    Callback = function(Value) ActiveAutoChopTree = Value autoChopTree() end
})
Game:Dropdown({
    Title = "Tree Type",
    Options = TreeAuraTypes,
    CurrentOption = "All",
    Flag = "TreeType",
    Callback = function(Option) SelectedTreeType = Option[1] end
})
Game:Toggle({
    Title = "Auto Chop Selected Tree",
    CurrentValue = false,
    Flag = "TreeAura",
    Callback = function(Value) ActiveTreeAura = Value autoChopSelectedTree() end
})

Items:Section({ Title = "Item Management" })
local ItemStatus = Items:Paragraph({ Title = "Status", Content = "No item selected" })
Items:Input({
    Title = "Item Name",
    PlaceholderText = "Enter item name",
    RemoveTextAfterFocusLost = false,
    Flag = "ItemInput",
    Callback = function(Text)
        TextBoxText = Text
        local count = 0
        for _, item in pairs(workspace.Items:GetChildren()) do
            if item.Name == Text and item:FindFirstChild("Handle") then count = count + 1 end
        end
        ItemStatus:Set("Found: " .. count .. " " .. Text)
    end
})
Items:Button({
    Title = "Bring Item",
    Callback = function()
        for _, item in pairs(workspace.Items:GetChildren()) do
            if item.Name == TextBoxText and item:FindFirstChild("Handle") then DragItem(item) end
        end
    end
})
Items:Button({
    Title = "Bring All Items",
    Callback = function()
        for _, item in pairs(workspace.Items:GetChildren()) do
            if item:FindFirstChild("Handle") then DragItem(item) end
        end
    end
})

Automation:Section({ Title = "Automation" })
Automation:Toggle({
    Title = "Auto Survive Days",
    CurrentValue = false,
    Flag = "AutoSurvive",
    Callback = function(Value) ActiveAutoSurviveDays = Value autoSurviveDays() end
})
Automation:Toggle({
    Title = "Auto Cook Food",
    CurrentValue = false,
    Flag = "AutoCook",
    Callback = function(Value) ActiveAutoCookFood = Value autoCookFood() end
})
Automation:Toggle({
    Title = "Auto Eat Food",
    CurrentValue = false,
    Flag = "AutoEat",
    Callback = function(Value) ActiveAutoEatFood = Value autoEatFood() end
})
Automation:Toggle({
    Title = "Auto Missing Foods",
    CurrentValue = false,
    Flag = "AutoMissing",
    Callback = function(Value) ActiveAutoMissingFoods = Value autoMissingFoods() end
})
Automation:Toggle({
    Title = "Auto Eat Stew",
    CurrentValue = false,
    Flag = "AutoStew",
    Callback = function(Value) ActiveAutoEatStew = Value autoEatStew() end
})
Automation:Slider({
    Title = "Sapling Distance",
    Range = {5, 30},
    Increment = 5,
    Suffix = "m",
    CurrentValue = 20,
    Flag = "SaplingDist",
    Callback = function(Value) DistanceForSaplingPlace = Value end
})
Automation:Dropdown({
    Title = "Sapling Shape",
    Options = {"Circle", "Square"},
    CurrentOption = "Circle",
    Flag = "SaplingShape",
    Callback = function(Option) SaplingShape = Option[1] end
})
Automation:Slider({
    Title = "Sapling Amount",
    Range = {1, 20},
    Increment = 1,
    Suffix = "Count",
    CurrentValue = 10,
    Flag = "SaplingAmt",
    Callback = function(Value) SaplingAmount = Value end
})
Automation:Toggle({
    Title = "Auto Plant Saplings",
    CurrentValue = false,
    Flag = "AutoPlant",
    Callback = function(Value) ActiveAutoPlaceSapling = Value autoPlantSaplings() end
})
Automation:Slider({
    Title = "Tame Distance",
    Range = {5, 30},
    Increment = 5,
    Suffix = "m",
    CurrentValue = 15,
    Flag = "TameDist",
    Callback = function(Value) DistanceForPetTame = Value end
})
Automation:Toggle({
    Title = "Auto Tame Pet",
    CurrentValue = false,
    Flag = "AutoTame",
    Callback = function(Value) ActiveAutoTamePet = Value autoTamePet() end
})
Automation:Toggle({
    Title = "Auto Minigame Taming",
    CurrentValue = false,
    Flag = "AutoMinigame",
    Callback = function(Value) ActiveAutoMinigameTaming = Value autoMinigameTaming() end
})
Automation:Toggle({
    Title = "Auto Feed Taming",
    CurrentValue = false,
    Flag = "AutoFeed",
    Callback = function(Value) ActiveAutoFeedTaming = Value autoFeedTaming() end
})
Automation:Toggle({
    Title = "Stun Mobs",
    CurrentValue = false,
    Flag = "StunMobs",
    Callback = function(Value) ActiveStunMobs = Value stunMobs() end
})
Automation:Toggle({
    Title = "Hitbox Expander",
    CurrentValue = false,
    Flag = "Hitbox",
    Callback = function(Value) ActiveHitboxExpander = Value hitboxExpander() end
})
Automation:Toggle({
    Title = "Full Map Loader",
    CurrentValue = false,
    Flag = "MapLoader",
    Callback = function(Value) ActiveFullMapLoader = Value fullMapLoader() end
})
Automation:Toggle({
    Title = "Insta Open Chest",
    CurrentValue = false,
    Flag = "InstaChest",
    Callback = function(Value) ActiveInstaOpenChest = Value instaOpenChest() end
})
Automation:Toggle({
    Title = "Create Safe Zone",
    CurrentValue = false,
    Flag = "SafeZone",
    Callback = function(Value) ActiveCreateSafeZone = Value createSafeZone() end
})
Automation:Toggle({
    Title = "TP to Safe Zone (Low HP)",
    CurrentValue = false,
    Flag = "SafeTP",
    Callback = function(Value) ActiveTpToSafeZoneLowHP = Value tpToSafeZoneLowHP() end
})
Automation:Toggle({
    Title = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value) ActiveAntiAfk = Value antiAfk() end
})
Automation:Toggle({
    Title = "Auto Time Machine",
    CurrentValue = false,
    Flag = "AutoTime",
    Callback = function(Value) ActiveAutoTimeMachine = Value autoTimeMachine() end
})
Automation:Toggle({
    Title = "Auto Cast",
    CurrentValue = false,
    Flag = "AutoCast",
    Callback = function(Value) ActiveAutoCast = Value autoCast() end
})
Automation:Toggle({
    Title = "Better Auto Cast",
    CurrentValue = false,
    Flag = "BetterCast",
    Callback = function(Value) ActiveBetterAutoCast = Value betterAutoCast() end
})
Automation:Toggle({
    Title = "Auto Minigames",
    CurrentValue = false,
    Flag = "AutoMinigame",
    Callback = function(Value) ActiveAutoMinigames = Value autoMinigames() end
})
Automation:Toggle({
    Title = "Always Bigger Bar",
    CurrentValue = false,
    Flag = "BiggerBar",
    Callback = function(Value) ActiveAlwaysBiggerBar = Value alwaysBiggerBar() end
})
Automation:Toggle({
    Title = "Auto Farm Snowy Small Tree",
    CurrentValue = false,
    Flag = "SnowyTree",
    Callback = function(Value) ActiveAutoFarmSnowySmallTree = Value autoFarmSnowySmallTree() end
})

Teleport:Section({ Title = "Teleport" })
Teleport:Toggle({
    Title = "Auto TP to Enemies",
    CurrentValue = false,
    Flag = "TPEnemies",
    Callback = function(Value) ActiveAutoTpEnemies = Value autoTpEnemies() end
})
Teleport:Toggle({
    Title = "Auto TP to Trees",
    CurrentValue = false,
    Flag = "TPTrees",
    Callback = function(Value) ActiveAutoTpTrees = Value autoTpTrees() end
})
Teleport:Button({
    Title = "TP to Campfire",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = workspace.Map.Campground.Campfire.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

Discord:Section({ Title = "Discord" })
Discord:Button({
    Title = "Copy Invite",
    Callback = function()
        setclipboard("https://discord.gg/KG9ADqwT9Q")
        WindUI:Notify({Title = "Copied", Content = "Discord invite copied!", Duration = 3})
    end
})

Config:Section({ Title = "Config" })
Config:Button({
    Title = "Unload Script",
    Callback = function() WindUI:Destroy() end
})

-- Server Info Update
task.spawn(function()
    while wait(1) do
        local info = getServerInfo()
        ServerInfo:Set("Server: " .. info.Players .. "/" .. info.MaxPlayers .. " | Place: " .. info.PlaceId)
    end
end)

-- Character Added Handler
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = OldSpeed
    updateSpeed()
end)

-- Load Configuration
WindUI:LoadConfiguration()

WindUI:Notify({
    Title = "Ryzen Hub",
    Content = "Script loaded at 08:13 PM +08, October 19, 2025. UI should now be visible!",
    Duration = 5
})
