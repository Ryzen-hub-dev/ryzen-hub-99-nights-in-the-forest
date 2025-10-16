local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RayfieldFolder = "RyzenHubConfig"
local ConfigFolder = RayfieldFolder.."/Configs"

if not isfolder(RayfieldFolder) then
    makefolder(RayfieldFolder)
    makefolder(ConfigFolder)
end

local Rayfield = {
    CurrentTab = nil,
    Library = nil,
    Opened = false,
    NotificationTween = nil,
    Notifications = {}
}

local function Tween(instance, properties, duration, ...)
    local tweenInfo = TweenInfo.new(duration or 1, ...)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateNotification(title, content, duration, image)
    local Notification = Instance.new("TextButton")
    Notification.Name = "Notification"
    Notification.Parent = Rayfield.Library.Notifications
    Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Notification.BorderSizePixel = 0
    Notification.Size = UDim2.new(0, 300, 0, 100)
    Notification.AutoButtonColor = false
    Notification.Text = ""
    Notification.BackgroundTransparency = 1
    Notification.ZIndex = 50

    local NotificationUIStroke = Instance.new("UIStroke")
    NotificationUIStroke.Name = "NotificationUIStroke"
    NotificationUIStroke.Parent = Notification
    NotificationUIStroke.Color = Color3.fromRGB(0, 255, 150)
    NotificationUIStroke.Thickness = 2
    NotificationUIStroke.Transparency = 0.5

    local NotificationUICorner = Instance.new("UICorner")
    NotificationUICorner.Name = "NotificationUICorner"
    NotificationUICorner.CornerRadius = UDim.new(0, 6)
    NotificationUICorner.Parent = Notification

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Notification
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Size = UDim2.new(0, 280, 0, 30)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = title or "Ryzen Hub Notification"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Content = Instance.new("TextLabel")
    Content.Name = "Content"
    Content.Parent = Notification
    Content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 10, 0, 35)
    Content.Size = UDim2.new(0, 280, 0, 60)
    Content.Font = Enum.Font.Gotham
    Content.Text = content or "No content provided."
    Content.TextColor3 = Color3.fromRGB(200, 200, 200)
    Content.TextSize = 16
    Content.TextWrapped = true
    Content.TextXAlignment = Enum.TextXAlignment.Left

    if image then
        local ImageLabel = Instance.new("ImageLabel")
        ImageLabel.Name = "Image"
        ImageLabel.Parent = Notification
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.Position = UDim2.new(0, 260, 0, 5)
        ImageLabel.Size = UDim2.new(0, 30, 0, 30)
        ImageLabel.Image = image
    end

    Notification.Position = UDim2.new(0, 50, 0, -100)
    Tween(Notification, {BackgroundTransparency = 0, Position = UDim2.new(0, 50, 0, 10)}, 0.5)

    table.insert(Rayfield.Notifications, Notification)
    if Rayfield.NotificationTween then Rayfield.NotificationTween:Cancel() end
    Rayfield.NotificationTween = Tween(Notification, {Position = UDim2.new(0, 50, 0, -100)}, duration or 5):Play()

    Notification.MouseButton1Click:Connect(function()
        if Rayfield.NotificationTween then Rayfield.NotificationTween:Cancel() end
        Tween(Notification, {BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, -100)}, 0.5)
        task.wait(0.5)
        Notification:Destroy()
    end)

    task.wait(duration or 5)
    if table.find(Rayfield.Notifications, Notification) then
        table.remove(Rayfield.Notifications, table.find(Rayfield.Notifications, Notification))
        if Rayfield.NotificationTween then Rayfield.NotificationTween:Cancel() end
        Tween(Notification, {BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, -100)}, 0.5)
        task.wait(0.5)
        Notification:Destroy()
    end
end

function Rayfield:Notify(Properties)
    spawn(function()
        CreateNotification(Properties.Title, Properties.Content, Properties.Duration, Properties.Image)
    end)
end

function Rayfield:CreateWindow(Settings)
    local windowName = Settings.Name or "Ryzen Hub"
    local LoadingTitle = Settings.LoadingTitle or "Ryzen Hub Loading"
    local LoadingSubtitle = Settings.LoadingSubtitle or "by Ryzen Team"
    local ConfigurationSaving = Settings.ConfigurationSaving or { Enabled = false, FolderName = nil, FileName = "RyzenHubConfig" }
    local Discord = Settings.Discord or { Enabled = false, Invite = "nil", RememberJoins = true }
    local KeySystem = Settings.KeySystem or false

    if Rayfield.Library then
        return Rayfield.Library
    end

    local Lib = {}

    if ConfigurationSaving.Enabled then
        if not pcall(function() readfile(ConfigFolder.."/"..ConfigurationSaving.FileName..".rf") end) and not ConfigurationSaving.Global then
            writefile(ConfigFolder.."/"..ConfigurationSaving.FileName..".rf", HttpService:JSONEncode({KeySystem = {Key = KeySystem and "nil" or nil}}))
        elseif not pcall(function() readfile(ConfigFolder.."/"..ConfigurationSaving.FileName..".rf") end) and ConfigurationSaving.Global then
            writefile("rf"..ConfigurationSaving.FileName..".rf", HttpService:JSONEncode({KeySystem = {Key = KeySystem and "nil" or nil}}))
        end
    end

    local NotificationHolder = Instance.new("ScreenGui")
    NotificationHolder.Name = "RyzenHubNotifications"
    NotificationHolder.Parent = PlayerGui
    NotificationHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = NotificationHolder
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BackgroundTransparency = 1
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Active = true
    Main.Draggable = true

    local MainCorner = Instance.new("UICorner")
    MainCorner.Name = "MainCorner"
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Name = "MainStroke"
    MainStroke.Color = Color3.fromRGB(0, 255, 150)
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.5
    MainStroke.Parent = Main

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TopBar.BackgroundTransparency = 0.2
    TopBar.Size = UDim2.new(0, 400, 0, 30)

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.Name = "TopBarCorner"
    TopBarCorner.CornerRadius = UDim.new(0, 6)
    TopBarCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(0, 200, 0, 30)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = windowName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Position = UDim2.new(0, 370, 0, 5)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14

    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.Name = "CloseButtonCorner"
    CloseButtonCorner.CornerRadius = UDim.new(0, 4)
    CloseButtonCorner.Parent = CloseButton

    local TabHolder = Instance.new("Frame")
    TabHolder.Name = "TabHolder"
    TabHolder.Parent = Main
    TabHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabHolder.BackgroundTransparency = 0.2
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.Size = UDim2.new(0, 100, 0, 270)

    local TabHolderCorner = Instance.new("UICorner")
    TabHolderCorner.Name = "TabHolderCorner"
    TabHolderCorner.CornerRadius = UDim.new(0, 6)
    TabHolderCorner.Parent = TabHolder

    local TabHolderList = Instance.new("UIListLayout")
    TabHolderList.Name = "TabHolderList"
    TabHolderList.Parent = TabHolder
    TabHolderList.FillDirection = Enum.FillDirection.Vertical
    TabHolderList.SortOrder = Enum.SortOrder.LayoutOrder
    TabHolderList.Padding = UDim.new(0, 2)

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Container.BackgroundTransparency = 0.1
    Container.Position = UDim2.new(0, 100, 0, 30)
    Container.Size = UDim2.new(0, 300, 0, 270)

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.Name = "ContainerCorner"
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container

    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Name = "ContainerStroke"
    ContainerStroke.Color = Color3.fromRGB(0, 255, 150)
    ContainerStroke.Thickness = 2
    ContainerStroke.Transparency = 0.5
    ContainerStroke.Parent = Container

    local ContainerLayout = Instance.new("UIListLayout")
    ContainerLayout.Name = "ContainerLayout"
    ContainerLayout.Parent = Container
    ContainerLayout.FillDirection = Enum.FillDirection.Vertical
    ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerLayout.Padding = UDim.new(0, 10)

    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingFrame"
    LoadingFrame.Parent = Main
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    LoadingFrame.BackgroundTransparency = 0
    LoadingFrame.Size = UDim2.new(0, 400, 0, 300)
    LoadingFrame.BorderSizePixel = 0

    local LoadingTitle = Instance.new("TextLabel")
    LoadingTitle.Name = "LoadingTitle"
    LoadingTitle.Parent = LoadingFrame
    LoadingTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LoadingTitle.BackgroundTransparency = 1
    LoadingTitle.Position = UDim2.new(0, 0, 0, 100)
    LoadingTitle.Size = UDim2.new(0, 400, 0, 50)
    LoadingTitle.Font = Enum.Font.GothamBlack
    LoadingTitle.Text = LoadingTitle
    LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingTitle.TextSize = 30
    LoadingTitle.TextStrokeTransparency = 0

    local LoadingSubtitle = Instance.new("TextLabel")
    LoadingSubtitle.Name = "LoadingSubtitle"
    LoadingSubtitle.Parent = LoadingFrame
    LoadingSubtitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LoadingSubtitle.BackgroundTransparency = 1
    LoadingSubtitle.Position = UDim2.new(0, 0, 0, 155)
    LoadingSubtitle.Size = UDim2.new(0, 400, 0, 50)
    LoadingSubtitle.Font = Enum.Font.Gotham
    LoadingSubtitle.Text = LoadingSubtitle
    LoadingSubtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    LoadingSubtitle.TextSize = 20

    local LoadingImage = Instance.new("ImageLabel")
    LoadingImage.Name = "LoadingImage"
    LoadingImage.Parent = LoadingFrame
    LoadingImage.BackgroundTransparency = 1
    LoadingImage.Position = UDim2.new(0, 170, 0, 50)
    LoadingImage.Size = UDim2.new(0, 60, 0, 60)
    LoadingImage.Image = "rbxassetid://14854175684"
    LoadingImage.ImageColor3 = Color3.fromRGB(0, 255, 150)

    local LoadTween = Tween(LoadingImage, {Rotation = 360}, 1):Play()
    LoadTween.Completed:Connect(function()
        LoadTween = Tween(LoadingImage, {Rotation = 0}, 1):Play()
    end)
    LoadTween:Play()

    Rayfield.Library = {
        Main = Main,
        LoadingFrame = LoadingFrame,
        Notifications = NotificationHolder
    }

    CloseButton.MouseButton1Click:Connect(function()
        if Rayfield.Opened then
            Rayfield:Destroy()
        end
    end)

    function Lib:CreateTab(Name, Image)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Parent = TabHolder
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = Name
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 14
        TabButton.BackgroundTransparency = 0.2

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.Name = "TabButtonCorner"
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton

        local Tab = Instance.new("ScrollingFrame")
        Tab.Name = "Tab"
        Tab.Parent = Container
        Tab.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        Tab.BackgroundTransparency = 0.1
        Tab.Size = UDim2.new(0, 300, 0, 270)
        Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.ScrollBarThickness = 4
        Tab.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
        Tab.Visible = false
        Tab.BorderSizePixel = 0

        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Name = "TabLayout"
        TabLayout.Parent = Tab
        TabLayout.FillDirection = Enum.FillDirection.Vertical
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 10)

        if Rayfield.CurrentTab then
            Rayfield.CurrentTab.Visible = false
        end
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in ipairs(Container:GetChildren()) do
                if tab:IsA("ScrollingFrame") then
                    tab.Visible = false
                end
            end
            Tab.Visible = true
            Rayfield.CurrentTab = Tab
            for _, button in ipairs(TabHolder:GetChildren()) do
                if button:IsA("TextButton") then
                    Tween(button, {BackgroundTransparency = 0.2}, 0.2)
                    button.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            Tween(TabButton, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end)

        Tween(TabButton, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        TabButton.MouseEnter:Connect(function()
            if TabButton ~= Rayfield.CurrentTab then
                Tween(TabButton, {BackgroundTransparency = 0.1}, 0.2)
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if TabButton ~= Rayfield.CurrentTab then
                Tween(TabButton, {BackgroundTransparency = 0.2}, 0.2)
            end
        end)
        Rayfield.CurrentTab = Tab

        task.wait(0.1)
        LoadingFrame:Destroy()
        Main.BackgroundTransparency = 0

        local TabLib = {}

        function TabLib:CreateButton(ButtonSettings)
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Parent = Tab
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Button.Size = UDim2.new(0, 290, 0, 30)
            Button.Font = Enum.Font.Gotham
            Button.Text = ButtonSettings.Name
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            Button.TextSize = 14

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.Name = "ButtonCorner"
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button

            Button.MouseButton1Click:Connect(ButtonSettings.Callback)

            Tab.CanvasSize = UDim2.new(0, 0, TabLayout.AbsoluteContentSize.Y + 10, 0)
        end

        function TabLib:CreateToggle(ToggleSettings)
            local Toggle = Instance.new("TextButton")
            Toggle.Name = "Toggle"
            Toggle.Parent = Tab
            Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Toggle.Size = UDim2.new(0, 290, 0, 30)
            Toggle.Font = Enum.Font.Gotham
            Toggle.Text = ToggleSettings.Name.." "..(ToggleSettings.CurrentValue and "ON" or "OFF")
            Toggle.TextColor3 = Color3.fromRGB(200, 200, 200)
            Toggle.TextSize = 14

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.Name = "ToggleCorner"
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = Toggle

            Toggle.MouseButton1Click:Connect(function()
                ToggleSettings.CurrentValue = not ToggleSettings.CurrentValue
                Toggle.Text = ToggleSettings.Name.." "..(ToggleSettings.CurrentValue and "ON" or "OFF")
                if ToggleSettings.CurrentValue then
                    Tween(Toggle, {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}, 0.2)
                else
                    Tween(Toggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}, 0.2)
                end
                pcall(ToggleSettings.Callback, ToggleSettings.CurrentValue)
            end)

            if ToggleSettings.CurrentValue then
                Tween(Toggle, {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}, 0.2)
            end

            Tab.CanvasSize = UDim2.new(0, 0, TabLayout.AbsoluteContentSize.Y + 10, 0)
        end

        return TabLib
    end

    return Lib
end

function Rayfield:Destroy()
    Rayfield.Opened = false
    Tween(Rayfield.Library.Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.5):Play()
    task.wait(0.5)
    Rayfield.Library.Main:Destroy()
    for _, Notification in ipairs(Rayfield.Notifications) do
        if Notification then
            Notification:Destroy()
        end
    end
end

return Ryzen Hub

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Window Setup
local Window = Rayfield:CreateWindow({
    Name = "Ryzen Hub : 99 Night In The Forset",
    LoadingTitle = "Ryzen Hub : 99 Night In The Forset Script",
    LoadingSubtitle = "by Raygull",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "99NightsSettings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Variables
local teleportTargets = {
    "Alien", "Alien Chest", "Alien Shelf", "Alpha Wolf", "Alpha Wolf Pelt", "Anvil Base", "Apple", "Bandage", "Bear", "Berry",
    "Bolt", "Broken Fan", "Broken Microwave", "Bunny", "Bunny Foot", "Cake", "Carrot", "Chair Set", "Chest", "Chilli",
    "Coal", "Coin Stack", "Crossbow Cultist", "Cultist", "Cultist Gem", "Deer", "Fuel Canister", "Giant Sack", "Good Axe", "Iron Body",
    "Item Chest", "Item Chest2", "Item Chest3", "Item Chest4", "Item Chest6", "Laser Fence Blueprint", "Laser Sword", "Leather Body", "Log", "Lost Child",
    "Lost Child2", "Lost Child3", "Lost Child4", "Medkit", "Meat? Sandwich", "Morsel", "Old Car Engine", "Old Flashlight", "Old Radio", "Oil Barrel",
    "Raygun", "Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo", "Riot Shield", "Sapling", "Seed Box", "Sheet Metal", "Spear",
    "Steak", "Stronghold Diamond Chest", "Tyre", "UFO Component", "UFO Junk", "Washing Machine", "Wolf", "Wolf Corpse", "Wolf Pelt"
}
local AimbotTargets = {"Alien", "Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist", "Bunny", "Bear", "Polar Bear"}
local espEnabled = false
local npcESPEnabled = false
local ignoreDistanceFrom = Vector3.new(0, 0, 0)
local minDistance = 50
local AutoTreeFarmEnabled = false

-- Click simulation
local VirtualInputManager = game:GetService("VirtualInputManager")
function mouse1click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Aimbot FOV Circle
local AimbotEnabled = false
local FOVRadius = 100
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(128, 255, 0)
FOVCircle.Thickness = 1
FOVCircle.Radius = FOVRadius
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- ESP Function
local function createESP(item)
    local adorneePart
    if item:IsA("Model") then
        if item:FindFirstChildWhichIsA("Humanoid") then return end
        adorneePart = item:FindFirstChildWhichIsA("BasePart")
    elseif item:IsA("BasePart") then
        adorneePart = item
    else
        return
    end

    if not adorneePart then return end

    local distance = (adorneePart.Position - ignoreDistanceFrom).Magnitude
    if distance < minDistance then return end

    if not item:FindFirstChild("ESP_Billboard") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Adornee = adorneePart
        billboard.Size = UDim2.new(0, 50, 0, 20)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 2, 0)

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = item.Name
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        billboard.Parent = item
    end

    if not item:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 85, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 100, 0)
        highlight.FillTransparency = 0.25
        highlight.OutlineTransparency = 0
        highlight.Adornee = item:IsA("Model") and item or adorneePart
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = item
    end
end


local function toggleESP(state)
    espEnabled = state
    for _, item in pairs(workspace:GetDescendants()) do
        if table.find(teleportTargets, item.Name) then
            if espEnabled then
                createESP(item)
            else
                if item:FindFirstChild("ESP_Billboard") then item.ESP_Billboard:Destroy() end
                if item:FindFirstChild("ESP_Highlight") then item.ESP_Highlight:Destroy() end
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if espEnabled and table.find(teleportTargets, desc.Name) then
        task.wait(0.1)
        createESP(desc)
    end
end)

-- ESP for NPCs
local npcBoxes = {}

local function createNPCESP(npc)
    if not npc:IsA("Model") or npc:FindFirstChild("HumanoidRootPart") == nil then return end

    local root = npc:FindFirstChild("HumanoidRootPart")
    if npcBoxes[npc] then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 85, 0)
    box.Filled = false
    box.Visible = true

    local nameText = Drawing.new("Text")
    nameText.Text = npc.Name
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 16
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = true

    npcBoxes[npc] = {box = box, name = nameText}

    -- Cleanup on remove
    npc.AncestryChanged:Connect(function(_, parent)
        if not parent and npcBoxes[npc] then
            npcBoxes[npc].box:Remove()
            npcBoxes[npc].name:Remove()
            npcBoxes[npc] = nil
        end
    end)
end

local function toggleNPCESP(state)
    npcESPEnabled = state
    if not state then
        for npc, visuals in pairs(npcBoxes) do
            if visuals.box then visuals.box:Remove() end
            if visuals.name then visuals.name:Remove() end
        end
        npcBoxes = {}
    else
        -- Show NPC ESP for already existing NPCs
        for _, obj in ipairs(workspace:GetDescendants()) do
            if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
                createNPCESP(obj)
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if table.find(AimbotTargets, desc.Name) and desc:IsA("Model") then
        task.wait(0.1)
        if npcESPEnabled then
            createNPCESP(desc)
        end
    end
end)

-- Auto Tree Farm Logic with timeout
local badTrees = {}

task.spawn(function()
    while true do
        if AutoTreeFarmEnabled then
            local trees = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Trunk" and obj.Parent and obj.Parent.Name == "Small Tree" then
                    local distance = (obj.Position - ignoreDistanceFrom).Magnitude
                    if distance > minDistance and not badTrees[obj:GetFullName()] then
                        table.insert(trees, obj)
                    end
                end
            end

            table.sort(trees, function(a, b)
                return (a.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
                       (b.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)

            for _, trunk in ipairs(trees) do
                if not AutoTreeFarmEnabled then break end
                LocalPlayer.Character:PivotTo(trunk.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.2)
                local startTime = tick()
                while AutoTreeFarmEnabled and trunk and trunk.Parent and trunk.Parent.Name == "Small Tree" do
                    mouse1click()
                    task.wait(0.2)
                    if tick() - startTime > 12 then
                        badTrees[trunk:GetFullName()] = true
                        break
                    end
                end
                task.wait(0.3)
            end
        end
        task.wait(1.5)
    end
end)

-- Optimized Aimbot Logic
local lastAimbotCheck = 0
local aimbotCheckInterval = 0.02 -- Faster reaction time
local smoothness = 0.2 -- Smooth camera interpolation

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        FOVCircle.Visible = false
        return
    end

    local currentTime = tick()
    if currentTime - lastAimbotCheck < aimbotCheckInterval then return end
    lastAimbotCheck = currentTime

    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget, shortestDistance = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
            local head = obj:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDistance and dist <= FOVRadius then
                        shortestDistance = dist
                        closestTarget = head
                    end
                end
            end
        end
    end

    if closestTarget then
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(camera.CFrame.Position, closestTarget.Position)
        camera.CFrame = currentCF:Lerp(targetCF, smoothness) -- Smoothly rotate camera
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)


-- Fly Logic
local flying, flyConnection = false, nil
local speed = 60

local function startFlying()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyGyro = Instance.new("BodyGyro", hrp)
    local bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConnection = RunService.RenderStepped:Connect(function()
        local moveVec = Vector3.zero
        local camCF = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += camCF.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec -= camCF.UpVector end
        bodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * speed or Vector3.zero
        bodyGyro.CFrame = camCF
    end)
end

local function stopFlying()
    if flyConnection then flyConnection:Disconnect() end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

local function toggleFly(state)
    flying = state
    if flying then startFlying() else stopFlying() end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        toggleFly(not flying)
    end
end)

RunService.RenderStepped:Connect(function()
    for npc, visuals in pairs(npcBoxes) do
        local box = visuals.box
        local name = visuals.name

        if npc and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local size = Vector2.new(60, 80)
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
                box.Size = size
                box.Visible = true

                name.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y / 2 - 15)
                name.Visible = true
            else
                box.Visible = false
                name.Visible = false
            end
        else
            box:Remove()
            name:Remove()
            npcBoxes[npc] = nil
        end
    end
end)

-- GUI Tabs
local HomeTab = Window:CreateTab("🏠Home🏠", 4483362458)

HomeTab:CreateButton({
    Name = "Teleport to Campfire",
    Callback = function()
        LocalPlayer.Character:PivotTo(CFrame.new(0, 10, 0))
    end
})

HomeTab:CreateButton({
    Name = "Teleport to Grinder",
    Callback = function()
        LocalPlayer.Character:PivotTo(CFrame.new(16.1,4,-4.6))
    end
})

HomeTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Callback = toggleESP
})

HomeTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Callback = function(value)
        toggleNPCESP(value)
        Rayfield:Notify({
            Title = "NPC ESP",
            Content = value and "NPC ESP Enabled" or "NPC ESP Disabled",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

HomeTab:CreateToggle({
    Name = "Auto Tree Farm (Small Tree)",
    CurrentValue = false,
    Callback = function(value)
        AutoTreeFarmEnabled = value
    end
})

HomeTab:CreateToggle({
    Name = "Aimbot (Right Click)",
    CurrentValue = false,
    Callback = function(value)
        AimbotEnabled = value
        Rayfield:Notify({
            Title = "Aimbot",
            Content = value and "Enabled - Hold Right Click to aim." or "Disabled.",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

HomeTab:CreateToggle({
    Name = "Fly (WASD + Space + Shift)",
    CurrentValue = false,
    Callback = function(value)
        toggleFly(value)
        Rayfield:Notify({
            Title = "Fly",
            Content = value and "Fly Enabled" or "Fly Disabled",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

-- Teleport Tab
local TeleTab = Window:CreateTab("🧲Teleport🧲", 4483362458)
for _, itemName in ipairs(teleportTargets) do
    TeleTab:CreateButton({
        Name = "Teleport to " .. itemName,
        Callback = function()
            local closest, shortest = nil, math.huge
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == itemName and obj:IsA("Model") then
                    local cf = nil
                    if pcall(function() cf = obj:GetPivot() end) then
                        -- success
                    else
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part then cf = part.CFrame end
                    end
                    if cf then
                        local dist = (cf.Position - ignoreDistanceFrom).Magnitude
                        if dist >= minDistance and dist < shortest then
                            closest = obj
                            shortest = dist
                        end
                    end
                end
            end
            if closest then
                local cf = nil
                if pcall(function() cf = closest:GetPivot() end) then
                    -- success
                else
                    local part = closest:FindFirstChildWhichIsA("BasePart")
                    if part then cf = part.CFrame end
                end
                if cf then
                    LocalPlayer.Character:PivotTo(cf + Vector3.new(0, 5, 0))
                else
                    Rayfield:Notify({
                        Title = "Teleport Failed",
                        Content = "Could not find a valid position to teleport.",
                        Duration = 5,
                        Image = 4483362458,
                    })
                end
            else
                Rayfield:Notify({
                    Title = "Item Not Found",
                    Content = itemName .. " not found or too close to origin.",
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        end
    })
end
