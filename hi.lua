-- Ultimate Optimized Ryzen Hub YBA Cheat Script with Anti-Detection
-- Version: v3.0.0 Ultimate Secure (2025 Edition)
-- Features: Auto Level with Main/Side Quests, Auto Prestige 1-3 with Money Check & Auto Item Farm/Sell every 0.7s + Random Delays, Underground Noclip Pilot Farm with Auto Summon Stand, Long E/R/M1 Attacks, Anti-AFK, ESP for Items/Mobs/NPCs (Toggleable, with Detection Bypass), Auto Stand Farm, Server Hop for Better Farms, Configurable Speeds, Error Handling, Smooth Tweens, Discord Webhook Notifications
-- Anti-Detection: Random Delays, Humanized Movements (Random Jumps/Walks), Strike Monitoring (Stop if Detected), Code Obfuscation Elements, Metatable Hooks for Anti-Kick, Avoid Direct Remotes When Possible, Simulate Inputs

local version = "v3.0.0 Ultimate Secure"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:Popup({
    Title = "Ryzen Hub Ultimate Secure",
    Icon = "rbxassetid://84501312005643",
    Content = "Join our Discord for updates and support",
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function()
                setclipboard("https://discord.gg/KG9ADqwT9Q")
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Discord Invite",
                    Text = "Link Copied!",
                    Icon = "rbxassetid://84501312005643",
                    Duration = 4
                })
            end
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "Ryzen Hub Ultimate Secure YBA",
    Icon = "rbxassetid://84501312005643",
    Author = "Secure Edition | " .. version,
    Folder = "YBAUltimateSecure",
    Size = UDim2.fromOffset(420, 320),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 240,
    Background = "",
    BackgroundImageTransparency = 0.3,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
        end,
    },
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local DiscordTab = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
local ExclusiveTab = Window:Tab({ Title = "Exclusive", Icon = "star" })
local MainTab = Window:Tab({ Title = "Main", Icon = "landmark" })
local QuestTab = Window:Tab({ Title = "Quest", Icon = "rbxassetid://10723415335" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
local ShopTab = Window:Tab({ Title = "Shop", Icon = "store" })
local ConfigTab = Window:Tab({ Title = "Config", Icon = "file-cog" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

DiscordTab:Section({ Title = "Join Discord Server" })
DiscordTab:Button({
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

-- Quest Tab Auto Features
QuestTab:Section({ Title = "Auto Features" })

local autoLevel = false
local autoPrestige = false
local autoItemFarm = false
local autoStandFarm = false
local autoSummonStand = true
local espEnabled = false
local serverHop = false
local antiDetection = true  -- New: Toggle Anti-Detection Features
local farmSpeed = 0.1
local itemFarmDelay = 0.7
local webhookUrl = ""

QuestTab:Toggle({
    Title = "Auto Level",
    Desc = "Auto quests and farm levels with pilot",
    Callback = function(v) autoLevel = v end
})

QuestTab:Toggle({
    Title = "Auto Prestige",
    Desc = "Auto prestige 1-3, check money",
    Callback = function(v) autoPrestige = v end
})

QuestTab:Toggle({
    Title = "Auto Item Farm",
    Desc = "Farm/sell items every 0.7s if low money",
    Callback = function(v) autoItemFarm = v end
})

QuestTab:Toggle({
    Title = "Auto Stand Farm",
    Desc = "Auto farm stands",
    Callback = function(v) autoStandFarm = v end
})

QuestTab:Toggle({
    Title = "Auto Summon Stand",
    Desc = "Summon stand automatically",
    Default = true,
    Callback = function(v) autoSummonStand = v end
})

QuestTab:Toggle({
    Title = "ESP (Items/Mobs/NPCs)",
    Desc = "Enable ESP for visibility (with bypass)",
    Callback = function(v) espEnabled = v end
})

QuestTab:Toggle({
    Title = "Server Hop",
    Desc = "Hop servers for better farms",
    Callback = function(v) serverHop = v end
})

QuestTab:Toggle({
    Title = "Anti-Detection",
    Desc = "Enable random delays, human movements, strike monitoring",
    Default = true,
    Callback = function(v) antiDetection = v end
})

-- Config Tab
ConfigTab:Section({ Title = "Farm Settings" })
ConfigTab:Slider({
    Title = "Attack Speed",
    Desc = "Delay between attacks",
    Min = 0.05,
    Max = 0.5,
    Default = 0.1,
    Step = 0.05,
    Callback = function(v) farmSpeed = v end
})

ConfigTab:Slider({
    Title = "Item Farm Delay",
    Desc = "Time between picks",
    Min = 0.1,
    Max = 2,
    Default = 0.7,
    Step = 0.1,
    Callback = function(v) itemFarmDelay = v end
})

ConfigTab:Textbox({
    Title = "Discord Webhook URL",
    Desc = "For notifications (prestige, etc.)",
    Callback = function(v) webhookUrl = v end
})

-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

-- Character
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(math.random(1, 3))  -- Random delay on respawn
    if autoSummonStand then summonStand() end
end)

-- Anti-Detection: Metatable Hook for Anti-Kick (from references)
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
    if key == "Kick" then return nil end  -- Bypass kick
    return oldIndex(self, key)
end)
setreadonly(mt, true)

-- Noclip with Anti-Detection (Random Toggle)
local noclip = false
RunService.Stepped:Connect(function()
    if noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        if antiDetection and math.random(1, 50) == 1 then  -- Random human jump
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti-AFK Enhanced
spawn(function()
    while true do
        wait(math.random(30, 60))  -- Random anti-AFK interval
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        wait(math.random(0.05, 0.15))
        VirtualInputManager:SendKeyEvent(false, "W", false, game)
    end
end)

-- Positions (Updated for 2025 Map Changes, with Random Offsets for Anti-Detection)
local function randomOffset(cf)
    return cf * CFrame.new(math.random(-2, 2), math.random(-1, 1), math.random(-2, 2))
end

local npcPositions = {
    PrestigeMaster = CFrame.new(-237, 49, -112),
    ItemSeller = CFrame.new(-223, 49, -71),
    GiornoGiovanna = CFrame.new(-153, 49, -144),
    KoichiHirose = CFrame.new(-143, 49, -144),
    BrunoBucciarati = CFrame.new(-295, 49, -90),
    PannacottaFugo = CFrame.new(-252, 49, -95),
    GuidoMista = CFrame.new(-282, 49, -122),
    NaranciaGhirga = CFrame.new(-270, 49, -105),
    LeoneAbbacchio = CFrame.new(-265, 49, -115),
    TrishUna = CFrame.new(-320, 49, -140),
    Diavolo = CFrame.new(-500, 100, -350),
    OfficerSam = CFrame.new(-200, 49, -50),
    DeputyBertrude = CFrame.new(-210, 49, -60),
    AbbacchiosPartner = CFrame.new(-220, 49, -70),
    Dracula = CFrame.new(-300, 30, -300),
    WillZeppeli = CFrame.new(-310, 30, -310),
    DariusTheExecutioner = CFrame.new(-100, 100, -200),
    Kars = CFrame.new(-320, 30, -320),
    Doppio = CFrame.new(-110, 100, -210),
    Pucci = CFrame.new(-500, 50, -340),
    VampireFarm = CFrame.new(-310, 30, -310),
    StandFarm = CFrame.new(-250, 49, -80), -- Adjust for stand farm area
    ItemSpawnAreas = {
        CFrame.new(-200, 49, -100),
        CFrame.new(-300, 49, -200),
        CFrame.new(-400, 49, -300),
        CFrame.new(-100, 49, -50),
        CFrame.new(-500, 49, -400),
    }
}

-- Get Stats with Error Handling
local function getStat(statName)
    local success, statsFrame = pcall(function()
        return player.PlayerGui.MainGui.StatsFrame
    end)
    if success and statsFrame then
        local label = statsFrame:FindFirstChild(statName)
        if label then return tonumber(label.Text:match("%d+")) or 0 end
    end
    return 0
end

local getMoney = function() return getStat("Money") end
local getLevel = function() return getStat("Level") end
local getPrestige = function() return getStat("Prestige") end

-- Send Webhook
local function sendWebhook(message)
    if webhookUrl ~= "" then
        local data = { ["content"] = message }
        local success, err = pcall(function()
            HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data))
        end)
        if not success then print("Webhook error: " .. err) end
    end
end

-- Interact NPC with Tween and Random Offset
local function interactNPC(pos)
    pos = randomOffset(pos)  -- Anti-Detection Offset
    local tweenInfo = TweenInfo.new(math.random(0.4, 0.6), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(character.HumanoidRootPart, tweenInfo, {CFrame = pos * CFrame.new(0, 3, -3)})
    tween:Play()
    tween.Completed:Wait()
    wait(math.random(0.1, 0.3))  -- Random delay
    local prompt = Workspace:FindFirstChildOfClass("ProximityPrompt", true) or character:FindFirstChildOfClass("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) end
    local interactRemote = ReplicatedStorage:FindFirstChild("Interact") or ReplicatedStorage.Remotes:FindFirstChild("Talk")
    if interactRemote then interactRemote:FireServer() end
    wait(math.random(0.5, 1.5))
end

-- Strike Monitoring (Anti-Detection: Stop if TP Strike Detected)
local strikeDetected = false
player.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name:match("Strike") or child.Text:match("TP STRIKED") then  -- From references
        strikeDetected = true
        autoLevel = false
        autoItemFarm = false
        autoPrestige = false
        sendWebhook("TP Strike Detected! Stopping autos.")
        WindUI:Notify({
            Title = "Anti-Detection Alert",
            Content = "TP Strike detected. Stopping features for safety.",
            Duration = 10
        })
    end
end)

-- Auto Item Farm with Anti-Detection (Random Areas, Delays)
local function farmAndSellItems()
    while autoItemFarm and not strikeDetected do
        for _, area in ipairs(npcPositions.ItemSpawnAreas) do
            character.HumanoidRootPart.CFrame = randomOffset(area)
            wait(math.random(0.1, 0.3))
            for _, item in ipairs(Workspace:GetDescendants()) do
                if (item:IsA("Part") or item:IsA("MeshPart")) and (item.Name:match("Arrow") or item.Name:match("Roka") or item.Name:match("Diamond") or item.Name:match("Coin")) then
                    character.HumanoidRootPart.CFrame = randomOffset(item.CFrame)
                    wait(math.random(0.05, 0.15))
                end
            end
        end
        wait(itemFarmDelay + math.random(-0.2, 0.2))  -- Varied delay
        if getMoney() < 5000 then
            interactNPC(npcPositions.ItemSeller)
            local sellRemote = ReplicatedStorage.Remotes:FindFirstChild("Sell")
            if sellRemote then sellRemote:FireServer("All") end
            sendWebhook("Sold items for money!")
            wait(math.random(0.5, 1))
        end
    end
end

-- Auto Prestige with Anti-Detection
spawn(function()
    while true do
        if autoPrestige and not strikeDetected then
            local prestige = getPrestige()
            if prestige >= 3 then autoPrestige = false sendWebhook("Max Prestige Reached!") end
            local reqLevel = 35 + (prestige * 5)
            if getLevel() >= reqLevel then
                if getMoney() < 5000 then
                    autoItemFarm = true
                    farmAndSellItems()
                else
                    interactNPC(npcPositions.PrestigeMaster)
                    local prestigeRemote = ReplicatedStorage.Remotes:FindFirstChild("Prestige")
                    if prestigeRemote then prestigeRemote:FireServer() end
                    sendWebhook("Prestiged to " .. (prestige + 1) .. "!")
                    wait(math.random(5, 10))
                end
            end
        end
        wait(math.random(1, 3))
    end
end)

-- Auto Summon Stand with Random Delay
local function summonStand()
    wait(math.random(0.1, 0.3))
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    wait(math.random(0.1, 0.2))
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    wait(math.random(0.5, 1))
end

-- Auto Level Farm with Pilot and Anti-Detection (Random Attacks, Movements)
local function autoLevelFarm()
    noclip = true
    character.HumanoidRootPart.CFrame = randomOffset(npcPositions.VampireFarm) * CFrame.new(0, -30, 0)
    if autoSummonStand then summonStand() end

    while autoLevel and not strikeDetected do
        for _, mob in ipairs(Workspace.Living:GetChildren()) do
            if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                character.HumanoidRootPart.CFrame = randomOffset(mob.HumanoidRootPart.CFrame) * CFrame.new(0, -30, 0)

                -- Random M1 Combo
                local comboCount = math.random(3, 5)
                for i = 1, comboCount do
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    wait(farmSpeed / math.random(3, 5))
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    wait(farmSpeed / math.random(3, 5))
                end

                -- Long E with Random Hold
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                wait(math.random(1, 2.5))
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                wait(farmSpeed + math.random(-0.1, 0.1))

                -- R with Random
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                wait(math.random(0.3, 0.6))
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                wait(farmSpeed + math.random(-0.1, 0.1))
            end
        end
        wait(math.random(0.05, 0.15))
        if antiDetection and math.random(1, 20) == 1 then  -- Random walk
            VirtualInputManager:SendKeyEvent(true, "A", false, game)
            wait(0.2)
            VirtualInputManager:SendKeyEvent(false, "A", false, game)
        end
    end
    noclip = false
end

-- Auto Stand Farm (From References: Use Arrow)
local function autoStandFarmFunc()
    while autoStandFarm and not strikeDetected do
        character.HumanoidRootPart.CFrame = randomOffset(npcPositions.StandFarm)
        wait(math.random(0.5, 1.5))
        -- Simulate Use Item
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)  -- Assume 1 for Arrow
        wait(0.2)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        wait(math.random(4, 6))
    end
end

spawn(function()
    autoStandFarmFunc()
end)

-- Auto Quests with Anti-Detection
local mainQuestsDone = false
local function autoQuests()
    if not mainQuestsDone then
        local mainSequence = {
            npcPositions.GiornoGiovanna,
            npcPositions.KoichiHirose,
            npcPositions.BrunoBucciarati,
            npcPositions.PannacottaFugo,
            npcPositions.GuidoMista,
            npcPositions.NaranciaGhirga,
            npcPositions.LeoneAbbacchio,
            npcPositions.TrishUna,
            npcPositions.Diavolo,
        }
        for _, pos in ipairs(mainSequence) do
            interactNPC(pos)
            wait(math.random(15, 25))  -- Varied battle time
        end
        mainQuestsDone = true
        sendWebhook("Main Quests Completed!")
    end

    while autoLevel and not strikeDetected do
        local level = getLevel()
        local sidePos = nil
        if level < 10 then sidePos = npcPositions.OfficerSam
        elseif level < 15 then sidePos = npcPositions.DeputyBertrude
        elseif level < 20 then sidePos = npcPositions.AbbacchiosPartner
        elseif level < 25 then sidePos = npcPositions.Dracula
        elseif level < 30 then sidePos = npcPositions.WillZeppeli
        elseif level < 35 then sidePos = npcPositions.DariusTheExecutioner
        elseif level < 40 then sidePos = npcPositions.Kars
        else sidePos = npcPositions.Pucci
        end
        if sidePos then
            interactNPC(sidePos)
            wait(math.random(15, 25))
        end
        wait(math.random(2, 4))
    end
end

-- ESP with Bypass (No Direct Highlight, Use Billboard with Random Updates)
local function createESP(obj, color, text)
    if not espEnabled then return end
    local bb = Instance.new("BillboardGui", obj)
    bb.Name = "ESP" .. math.random(1, 1000)  -- Random name for obfuscation
    bb.Adornee = obj
    bb.Size = UDim2.new(0, 100, 0, 50)
    bb.AlwaysOnTop = true
    local tl = Instance.new("TextLabel", bb)
    tl.Text = text
    tl.BackgroundTransparency = 1
    tl.TextColor3 = color
    tl.Size = UDim2.new(1, 0, 1, 0)
    return bb
end

spawn(function()
    while true do
        if espEnabled and not strikeDetected then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    if not obj:FindFirstChildOfClass("BillboardGui") then
                        createESP(obj.Head or obj.PrimaryPart, Color3.fromRGB(255, 0, 0), obj.Name .. " [HP: " .. math.floor(obj.Humanoid.Health) .. "]")
                    end
                elseif obj.Name:match("Arrow") or obj.Name:match("Roka") then
                    if not obj:FindFirstChildOfClass("BillboardGui") then
                        createESP(obj, Color3.fromRGB(0, 255, 0), obj.Name)
                    end
                end
            end
        else
            for _, esp in ipairs(Workspace:GetDescendants()) do
                if esp:IsA("BillboardGui") and esp.Name:match("ESP") then esp:Destroy() end
            end
        end
        wait(math.random(1, 2))  -- Random update interval
    end
end)

-- Server Hop with Delay
spawn(function()
    while serverHop and not strikeDetected do
        wait(math.random(180, 360))  -- Hop every 3-6 min
        TeleportService:Teleport(game.PlaceId, player)
    end
end)

-- Main Loops with pcall for Error Handling
spawn(function()
    while true do
        pcall(function()
            if autoLevel and not strikeDetected then
                autoQuests()
                autoLevelFarm()
            end
        end)
        wait(1)
    end
end)

spawn(function()
    while true do
        pcall(function()
            if autoItemFarm and not strikeDetected then
                farmAndSellItems()
            end
        end)
        wait(1)
    end
end)

-- Misc Utilities
MiscTab:Section({ Title = "Utilities" })
MiscTab:Button({
    Title = "Teleport to Vampire Farm",
    Callback = function()
        character.HumanoidRootPart.CFrame = randomOffset(npcPositions.VampireFarm)
    end
})

MiscTab:Button({
    Title = "Summon Stand",
    Callback = function()
        summonStand()
    end
})

MiscTab:Button({
    Title = "Server Hop Now",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end
})

-- Notification on Load
WindUI:Notify({
    Title = "Ryzen Ultimate Secure Loaded",
    Content = "Script optimized with anti-detection for 2025 YBA. Stay safe!",
    Duration = 5
})
