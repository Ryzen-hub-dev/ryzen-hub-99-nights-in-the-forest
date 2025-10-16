-- Ryzen Hub UI Library
-- Version: Custom Ryzen Hub Edition
-- Ryzen Hub : 99 Night In The Forset

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
