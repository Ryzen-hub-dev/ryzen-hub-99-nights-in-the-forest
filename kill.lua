local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 定义你想要保留或者显示的合法 UI 名称
local whitelist = { "MainGui", "WelcomeRyzen" } 

playerGui.ChildAdded:Connect(function(child)
    -- 延迟一小会儿，确保脚本已经执行完注入
    task.wait(0.1) 
    
    -- 检查 UI 的名字，或者检查 UI 内部包含的关键字
    if child:IsA("ScreenGui") then
        -- 如果名字匹配关键字，或者不在白名单内，直接销毁
        if string.find(child.Name, "Velocity") or child:FindFirstChild("Watermark", true) then
            child:Destroy()
            print("Welcome")
        end
    end
end)
