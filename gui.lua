local version = LRM_ScriptVersion and "v" .. table.concat(LRM_ScriptVersion:split(""), ".") or "Dev Version"

-- 嘗試加載WindUI庫並添加錯誤處理
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success then
    warn("Failed to load WindUI library: " .. WindUI)
    return
end

-- 初始彈出窗口
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

-- 主窗口創建
local Window = WindUI:CreateWindow({
    Title = "Ryzen Hub - 99 Nights In The Forest",
    Icon = "rbxassetid://84501312005643",
    Author = "99 Nights In The Forest | " .. version,
    Folder = "RyzenHub_NITF",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark",
    ThemeSettings = {
        Gradient = true,
        GradientColor1 = Color3.fromRGB(40, 40, 50),
        GradientColor2 = Color3.fromRGB(60, 60, 70),
        BackgroundTransparency = 0.3,
    },
    Resizable = true,
    SideBarWidth = 220,
    Background = "rbxassetid://123456789", -- 需替換為有效背景ID
    BackgroundImageTransparency = 0.5,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    ScrollBarStyle = "Modern",
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    },
})

-- 調試通知，確認窗口加載
WindUI:Notify({
    Title = "Ryzen Hub",
    Icon = "rbxassetid://84501312005643",
    Content = "Window Loaded! Version: " .. version,
    Duration = 5
})

local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local IYMouse = player:GetMouse()

-- Variables
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
    {Name = "Resource Spawn 1", Position = function() return CFrame.new(100, 10, 100) end},
    {Name = "Resource Spawn 2", Position = function() return CFrame.new(-100, 10, -100) end}
}
local flyKeyDown, flyKeyUp
local mfly1, mfly2
local velocityHandlerName = "BodyVelocity"
local gyroHandlerName = "BodyGyro"

-- Helper Functions (unchanged, abbreviated)
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

local function sFLY(vfly) -- ... (unchanged)
end

local function NOFLY() -- ... (unchanged)
end

local function UnMobileFly() -- ... (unchanged)
end

local function MobileFly() -- ... (unchanged)
end

local function CreateEsp(Char, Color, Text, Parent, number) -- ... (unchanged)
end

local function KeepEsp(Char, Parent) -- ... (unchanged)
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

-- Tabs
local Info = Window:Tab({ Title = "Info", Icon = "ℹ️" })
local Player = Window:Tab({ Title = "Player", Icon = "👤" })
local Esp = Window:Tab({ Title = "ESP", Icon = "👁️" })
local Game = Window:Tab({ Title = "Game", Icon = "🎮" })
local Automation = Window:Tab({ Title = "Automation", Icon = "⚙️" })
local Teleport = Window:Tab({ Title = "Teleport", Icon = "🚀" })
local BringItem = Window:Tab({ Title = "Items", Icon = "📦" })
local Discord = Window:Tab({ Title = "Discord", Icon = "💬" })
local Config = Window:Tab({ Title = "Config", Icon = "⚙️" })

-- Info Tab
Info:Section({ Title = "Server Info", Style = "Card" })
local ParagraphInfoServer = Info:Paragraph({
    Title = "Info",
    Content = "Loading...",
    Tooltip = "Displays current server details"
})

-- Player Tab
Player:Section({ Title = "Modifications", Style = "Card" })
local SpeedSlider = Player:Slider({
    Title = "Walk Speed",
    Desc = "Adjust player walk speed",
    Min = 0,
    Max = 500,
    Increment = 1,
    Suffix = "Speed",
    Default = 16,
    Save = true,
    Callback = function(Value)
        ValueSpeed = Value
        updateSpeed()
        WindUI:Notify({ Title = "Speed", Content = "Set to " .. Value, Duration = 2 })
    end,
    Tooltip = "Controls how fast you move"
})
local SpeedToggle = Player:Toggle({
    Title = "Speed Boost",
    Desc = "Enable/Disable speed boost",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveSpeedBoost = Value
        updateSpeed()
    end,
    Tooltip = "Activates the custom walk speed"
})
local FlySpeedSlider = Player:Slider({
    Title = "Fly Speed",
    Desc = "Adjust fly speed (1-5 recommended)",
    Min = 0,
    Max = 10,
    Increment = 0.1,
    Suffix = "Speed",
    Default = 1,
    Save = true,
    Callback = function(Value)
        iyflyspeed = Value
    end,
    Tooltip = "Controls flying speed"
})
Player:Toggle({
    Title = "Fly",
    Desc = "Enable/Disable flying (Press F)",
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
                            Content = "Press F to fly/unfly",
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
    end,
    Tooltip = "Allows flying with F key"
})
-- ... (其余Player Tab内容保持不变，略)

-- Esp Tab (略，保持不变)
-- Game Tab (略，保持不变，但移动部分功能到Automation)
-- Automation Tab
Automation:Section({ Title = "Tree & Sapling", Style = "Card" })
local TreeAuraSlider = Automation:Slider({
    Title = "Tree Aura Distance",
    Desc = "Set range for Tree Aura",
    Min = 10,
    Max = 500,
    Increment = 1,
    Suffix = "Units",
    Default = 25,
    Save = true,
    Callback = function(Value)
        DistanceForTreeAura = Value
    end
})
local TreeTypeDropdown = Automation:Dropdown({
    Title = "Tree Type",
    Desc = "Select tree type for aura",
    Options = TreeAuraTypes,
    Default = "All",
    Save = true,
    Callback = function(Value)
        SelectedTreeType = Value[1]
    end
})
Automation:Toggle({
    Title = "Tree Aura",
    Desc = "Auto chop selected trees",
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
                    if SelectedTreeType ~= "All" then treeNames = {SelectedTreeType} end
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
local SaplingSlider = Automation:Slider({
    Title = "Sapling Place Distance",
    Desc = "Set range for auto placing saplings",
    Min = 5,
    Max = 50,
    Increment = 1,
    Suffix = "Units",
    Default = 20,
    Save = true,
    Callback = function(Value)
        DistanceForSaplingPlace = Value
    end
})
Automation:Toggle({
    Title = "Auto Place Sapling",
    Desc = "Auto place saplings around you",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoPlaceSapling = Value
        task.spawn(function()
            while ActiveAutoPlaceSapling do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local saplingTool = player.Inventory:FindFirstChild("Seed Box")
                if saplingTool then
                    for angle = 0, 360, 30 do
                        local rad = math.rad(angle)
                        local placePos = hrp.Position + Vector3.new(math.cos(rad) * DistanceForSaplingPlace, 0, math.sin(rad) * DistanceForSaplingPlace)
                        task.spawn(function()
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

Automation:Section({ Title = "Pet & Resources", Style = "Card" })
local PetTameSlider = Automation:Slider({
    Title = "Pet Tame Distance",
    Desc = "Set range for auto taming pets",
    Min = 5,
    Max = 50,
    Increment = 1,
    Suffix = "Units",
    Default = 15,
    Save = true,
    Callback = function(Value)
        DistanceForPetTame = Value
    end
})
Automation:Toggle({
    Title = "Auto Tame Pet",
    Desc = "Auto tame nearby animals",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoTamePet = Value
        task.spawn(function()
            while ActiveAutoTamePet do
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local flute = player.Inventory:FindFirstChild("Taming Flute")
                if flute then
                    for _, animal in pairs(workspace.Characters:GetChildren()) do
                        if animal:IsA("Model") and animal.PrimaryPart and animal.Name:find("Animal") then
                            local distance = (animal.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForPetTame then
                                task.spawn(function()
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
local CollectSlider = Automation:Slider({
    Title = "Collect Distance",
    Desc = "Set range for auto collecting",
    Min = 5,
    Max = 100,
    Increment = 1,
    Suffix = "Units",
    Default = 30,
    Save = true,
    Callback = function(Value)
        DistanceForAutoCollect = Value
    end
})
Automation:Toggle({
    Title = "Auto Collect Resources",
    Desc = "Auto collect nearby items",
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
Automation:Toggle({
    Title = "Auto Repair Tools",
    Desc = "Auto repair tools in inventory",
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
Automation:Toggle({
    Title = "Auto Light Campfire",
    Desc = "Keep main campfire lit",
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
Automation:Toggle({
    Title = "Auto Complete Quests",
    Desc = "Auto complete active quests",
    Default = false,
    Save = true,
    Callback = function(Value)
        ActiveAutoCompleteQuests = Value
        task.spawn(function()
            while ActiveAutoCompleteQuests do
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

-- Teleport Tab
Teleport:Section({ Title = "Map Exploration", Style = "Card" })
Teleport:Dropdown({
    Title = "Teleport Locations",
    Desc = "Select a location to teleport",
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

-- BringItem Tab (略，保持不变)
-- Discord Tab (略，保持不变)
-- Config Tab (略，保持不变)

-- Character Added Handler
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = OldSpeed
    updateSpeed()
    WindUI:Notify({ Title = "Character", Content = "Character loaded, speed reset", Duration = 3 })
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

-- 飛行動作監聽
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
