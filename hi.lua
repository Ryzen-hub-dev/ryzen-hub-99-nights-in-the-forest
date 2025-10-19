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
    Title = "Ryzen Hub",
    Icon = "rbxassetid://84501312005643",
    Author = (premium and "Premium" or "Fish It") .. " | " .. version,
    Folder = "PhantomFlux",
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
        Callback = function()
        end,
    },
})
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

local Discord = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
local Exclusive = Window:Tab({ Title = "Exclusive", Icon = "star" })
local Main = Window:Tab({ Title = "Main", Icon = "landmark" })
local Quest = Window:Tab({ Title = "Quest", Icon = "rbxassetid://10723415335" })
local Teleport = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
local Shop = Window:Tab({ Title = "Shop", Icon = "store" })
local Config = Window:Tab({ Title = "Config", Icon = "file-cog" })
local Misc = Window:Tab({ Title = "Misc", Icon = "settings" })

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
            Content = "âœ… Link Copied!",
            Duration = 4
        })
    end
})

-- Add Auto Features to Quest Tab
Quest:Section({ Title = "Auto Features" })

local autoLevel = false
local autoPrestige = false
local autoItemFarm = false

Quest:Toggle({
    Title = "Auto Level",
    Desc = "Automatically complete quests and farm levels",
    Callback = function(v)
        autoLevel = v
    end
})

Quest:Toggle({
    Title = "Auto Prestige",
    Desc = "Automatically prestige when level reached (1-3)",
    Callback = function(v)
        autoPrestige = v
    end
})

Quest:Toggle({
    Title = "Auto Item Farm",
    Desc = "Farm items and sell if money low",
    Callback = function(v)
        autoItemFarm = v
    end
})

-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Player and Character
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(newChar)
    character = newChar
end)

-- Noclip Function
local noclip = false
RunService.Stepped:Connect(function()
    if noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Assume some positions (you may need to adjust these based on game map)
local prestigeNPCPosition = CFrame.new(0, 0, 0) -- Replace with actual Prestige NPC position, e.g., CFrame.new(-123, 45, 678)
local sellNPCPosition = CFrame.new(0, 0, 0) -- Replace with actual Item Seller NPC position
local farmArea = CFrame.new(0, 0, 0) -- Replace with vampire farm area or mob area

-- Get Money (assume player has a folder or value for money)
local function getMoney()
    -- In YBA, money is in player.Data.Money or similar; adjust accordingly
    local data = player:FindFirstChild("Data")
    if data then
        local money = data:FindFirstChild("Money")
        if money then return money.Value end
    end
    return 0
end

-- Get Level
local function getLevel()
    -- Adjust to actual
    local data = player:FindFirstChild("Data")
    if data then
        local level = data:FindFirstChild("Level")
        if level then return level.Value end
    end
    return 0
end

-- Get Prestige
local function getPrestige()
    -- Adjust to actual
    local data = player:FindFirstChild("Data")
    if data then
        local prestige = data:FindFirstChild("Prestige")
        if prestige then return prestige.Value end
    end
    return 0
end

-- Auto Item Farm and Sell
local function farmAndSellItems()
    while autoItemFarm do
        -- Find items on map
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then -- Assume items are models/parts with specific names
                if obj.Name == "Mysterious Arrow" or obj.Name == "Rokakaka Fruit" or obj.Name == "Diamond" or obj.Name == "Gold Coin" then -- Add more item names
                    character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    wait(0.1) -- Time to pick up
                end
            end
        end
        wait(0.7) -- Every 0.7 seconds
        -- Sell if needed
        if getMoney() < 5000 then
            character.HumanoidRootPart.CFrame = sellNPCPosition
            wait(0.5)
            -- Invoke sell remote; adjust to actual remote name
            local sellRemote = ReplicatedStorage:FindFirstChild("SellItems") -- Hypothetical
            if sellRemote then
                sellRemote:FireServer() -- Sell all
            end
            wait(1)
        end
    end
end

-- Auto Prestige Logic
spawn(function()
    while true do
        if autoPrestige then
            local currentPrestige = getPrestige()
            local requiredLevel = 0
            if currentPrestige == 0 then requiredLevel = 35 end
            if currentPrestige == 1 then requiredLevel = 40 end
            if currentPrestige == 2 then requiredLevel = 45 end
            if currentPrestige >= 3 then autoPrestige = false end -- Stop at 3

            if getLevel() >= requiredLevel then
                if getMoney() < 5000 then
                    autoItemFarm = true
                    farmAndSellItems()
                else
                    character.HumanoidRootPart.CFrame = prestigeNPCPosition
                    wait(0.5)
                    -- Fire prestige remote; adjust
                    local prestigeRemote = ReplicatedStorage:FindFirstChild("PrestigeEvent") -- Hypothetical
                    if prestigeRemote then
                        prestigeRemote:FireServer()
                    end
                    wait(2)
                end
            end
        end
        wait(1)
    end
end)

-- Auto Level with Pilot Safe Farm
local function autoLevelFunc()
    -- Enable noclip and go underground
    noclip = true
    character.HumanoidRootPart.CFrame = farmArea * CFrame.new(0, -10, 0) -- Underground

    -- Summon Stand (adjust key or remote)
    VirtualInputManager:SendKeyEvent(true, "F", false, game) -- Assume F summons stand
    wait(0.5)
    VirtualInputManager:SendKeyEvent(false, "F", false, game)

    -- Enable Pilot (assume V)
    VirtualInputManager:SendKeyEvent(true, "V", false, game)
    wait(0.5)
    VirtualInputManager:SendKeyEvent(false, "V", false, game)

    while autoLevel do
        -- Find mobs/bosses
        for _, mob in ipairs(Workspace:FindFirstChild("Living"):GetChildren()) do -- Assume mobs in 'Living' folder
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                -- Move stand to mob (in pilot, player controls stand)
                character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5) -- But since pilot, this moves stand?

                -- Attacks: M1, long E, R
                -- M1
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

                -- Long press E
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                wait(1) -- Long press
                VirtualInputManager:SendKeyEvent(false, "E", false, game)

                -- R
                VirtualInputManager:SendKeyEvent(true, "R", false, game)
                wait(0.5)
                VirtualInputManager:SendKeyEvent(false, "R", false, game)
            end
        end
        wait(0.1)
    end
    -- Disable on stop
    noclip = false
    VirtualInputManager:SendKeyEvent(true, "V", false, game)
    wait(0.5)
    VirtualInputManager:SendKeyEvent(false, "V", false, game)
end

-- Auto Quests Logic (Basic: Main then Side based on level)
local function autoQuests()
    -- First, main quests (hypothetical sequence; adjust to actual NPCs and remotes)
    -- Assume main quest NPCs positions
    local mainNPCs = {
        CFrame.new(0, 0, 0), -- NPC1
        -- Add more
    }
    for _, pos in ipairs(mainNPCs) do
        character.HumanoidRootPart.CFrame = pos
        wait(0.5)
        -- Interact remote
        local interact = ReplicatedStorage:FindFirstChild("InteractNPC")
        if interact then interact:FireServer() end
        wait(5) -- Time to complete task
    end

    -- Then side quests based on level
    while true do
        local level = getLevel()
        local sideNPC = nil
        if level < 10 then sideNPC = CFrame.new(0, 0, 0) -- Low level NPC
        elseif level < 20 then sideNPC = CFrame.new(0, 0, 0) -- Mid
        else sideNPC = CFrame.new(0, 0, 0) -- High
        end
        if sideNPC then
            character.HumanoidRootPart.CFrame = sideNPC
            wait(0.5)
            local interact = ReplicatedStorage:FindFirstChild("InteractNPC")
            if interact then interact:FireServer() end
            wait(5) -- Complete
        end
        wait(1)
    end
end

-- Start Auto Level Thread
spawn(function()
    while true do
        if autoLevel then
            -- First complete main quests
            autoQuests()
            -- Then farm levels with pilot
            autoLevelFunc()
        end
        wait(1)
    end
end)

-- Start Item Farm Thread if needed
spawn(function()
    if autoItemFarm then
        farmAndSellItems()
    end
end)
