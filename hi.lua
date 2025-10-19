-- Ultimate Optimized Ryzen Hub YBA Cheat Script
-- Version: v2.0.0 Ultimate (2025 Edition)
-- Features: Auto Level with Main/Side Quests, Auto Prestige 1-3 with Money Check & Auto Item Farm/Sell every 0.7s, Underground Noclip Pilot Farm with Auto Summon Stand, Long E/R/M1 Attacks, Anti-AFK, ESP for Items/Mobs/NPCs, Auto Stand Farm, Server Hop for Better Farms, Configurable Speeds, Error Handling, Smooth Tweens, Discord Webhook Notifications
-- Additions: ESP, Stand Farm, Server Hop, Webhooks for Logs, Better Quest Logic, Multiple Farm Areas

local version = "v2.0.0 Ultimate"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:Popup({
    Title = "Ryzen Hub Ultimate",
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
    Title = "Ryzen Hub Ultimate YBA",
    Icon = "rbxassetid://84501312005643",
    Author = "Ultimate Edition | " .. version,
    Folder = "YBAUltimate",
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
    Desc = "Enable ESP for visibility",
    Callback = function(v) espEnabled = v end
})

QuestTab:Toggle({
    Title = "Server Hop",
    Desc = "Hop servers for better farms",
    Callback = function(v) serverHop = v end
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

-- Character
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(1)
    if autoSummonStand then summonStand() end
end)

-- Noclip
local noclip = false
RunService.Stepped:Connect(function()
    if noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Anti-AFK
spawn(function()
    while true do
        wait(30)
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "W", false, game)
    end
end)

-- Positions (Updated for 2025 Map Changes)
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

-- Get Stats
local function getStat(statName)
    local statsFrame = player.PlayerGui.MainGui.StatsFrame
    if statsFrame then
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
        local data = {
            ["content"] = message
        }
        HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data))
    end
end

-- Interact NPC with Tween
local function interactNPC(pos)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(character.HumanoidRootPart, tweenInfo, {CFrame = pos * CFrame.new(0, 3, -3)})
    tween:Play()
    tween.Completed:Wait()
    local prompt = Workspace:FindFirstChildOfClass("ProximityPrompt", true) or character:FindFirstChildOfClass("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) end
    local interactRemote = ReplicatedStorage:FindFirstChild("Interact") or ReplicatedStorage.Remotes:FindFirstChild("Talk")
    if interactRemote then interactRemote:FireServer() end
    wait(1)
end

-- Auto Item Farm Optimized with Multiple Areas
local function farmAndSellItems()
    while autoItemFarm do
        for _, area in ipairs(npcPositions.ItemSpawnAreas) do
            character.HumanoidRootPart.CFrame = area
            wait(0.15)
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("Part") or item:IsA("MeshPart") and item.Name:match("Arrow") or item.Name:match("Roka") or item.Name:match("Diamond") or item.Name:match("Coin") then
                    character.HumanoidRootPart.CFrame = item.CFrame
                    wait(0.05)
                end
            end
        end
        wait(itemFarmDelay)
        if getMoney() < 5000 then
            interactNPC(npcPositions.ItemSeller)
            local sellRemote = ReplicatedStorage.Remotes:FindFirstChild("Sell")
            if sellRemote then sellRemote:FireServer("All") end
            sendWebhook("Sold items for money!")
            wait(0.5)
        end
    end
end

-- Auto Prestige Optimized
spawn(function()
    while true do
        if autoPrestige then
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
                    wait(8)
                end
            end
        end
        wait(2)
    end
end)

-- Auto Summon Stand
local function summonStand()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    wait(0.15)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    wait(0.5)
end

-- Auto Level Farm with Pilot (Optimized Attacks)
local function autoLevelFarm()
    noclip = true
    character.HumanoidRootPart.CFrame = npcPositions.VampireFarm * CFrame.new(0, -30, 0)
    if autoSummonStand then summonStand() end

    while autoLevel do
        for _, mob in ipairs(Workspace.Living:GetChildren()) do
            if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, -30, 0)

                -- M1 Combo
                for i = 1, 4 do
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    wait(farmSpeed / 4)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    wait(farmSpeed / 4)
                end

                -- Long E
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                wait(2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                wait(farmSpeed)

                -- R
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                wait(0.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                wait(farmSpeed)
            end
        end
        wait(0.05)
    end
    noclip = false
end

-- Auto Stand Farm (New Feature)
local function autoStandFarmFunc()
    while autoStandFarm do
        character.HumanoidRootPart.CFrame = npcPositions.StandFarm
        wait(1)
        -- Use arrow or something; assume remote
        local useItem = ReplicatedStorage.Remotes:FindFirstChild("UseItem")
        if useItem then useItem:FireServer("Mysterious Arrow") end
        wait(5)
    end
end

spawn(function()
    autoStandFarmFunc()
end)

-- Auto Quests Optimized with Better Timing
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
            wait(20) -- More time for battles
        end
        mainQuestsDone = true
        sendWebhook("Main Quests Completed!")
    end

    while autoLevel do
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
            wait(20)
        end
        wait(3)
    end
end

-- ESP (New Feature)
local function createESP(obj, color, text)
    local bb = Instance.new("BillboardGui", obj)
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
        if espEnabled then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    if not obj:FindFirstChild("ESP") then
                        createESP(obj.Head or obj.PrimaryPart, Color3.fromRGB(255, 0, 0), obj.Name .. " [HP: " .. math.floor(obj.Humanoid.Health) .. "]")
                    end
                elseif obj.Name:match("Arrow") or obj.Name:match("Roka") then
                    if not obj:FindFirstChild("ESP") then
                        createESP(obj, Color3.fromRGB(0, 255, 0), obj.Name)
                    end
                end
            end
        else
            for _, esp in ipairs(Workspace:GetDescendants()) do
                if esp.Name == "ESP" then esp:Destroy() end
            end
        end
        wait(1)
    end
end)

-- Server Hop (New Feature)
spawn(function()
    while serverHop do
        wait(300) -- Hop every 5 min
        TeleportService:Teleport(game.PlaceId, player)
    end
end)

-- Main Loops with Error Handling
spawn(function()
    while true do
        pcall(function()
            if autoLevel then
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
            if autoItemFarm then
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
        character.HumanoidRootPart.CFrame = npcPositions.VampireFarm
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
    Title = "Ryzen Ultimate Loaded",
    Content = "Script optimized for 2025 YBA. Enjoy!",
    Duration = 5
})
