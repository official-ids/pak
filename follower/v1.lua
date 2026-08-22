--[[
    Player Follower UI (Universal)
    Features: Follow by Name/DisplayName/ID, NoClip Included, Anti-Lag, Keyless
    Supported: Delta, Xeno, Wave, Codex, Arceus X
--]]

if game:GetService("CoreGui"):FindFirstChild("UniversalFollower") then
    game:GetService("CoreGui").UniversalFollower:Destroy()
end

local UI = Instance.new("ScreenGui")
UI.Name = "UniversalFollower"
UI.Parent = game:GetService("CoreGui")
UI.ResetOnSpawn = false

-- Главный контейнер
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 210)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = UI

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

-- Шапка
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 9)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -70, 1, 0)
TitleText.Position = UDim2.new(0, 12)
TitleText.BackgroundTransparency = 1
TitleText.Text = "PLAYER FOLLOWER v1.0"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Кнопка Свернуть "_"
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -65, 0, 2)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = TitleBar

-- Кнопка Закрыть "X"
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseButton.TextSize = 15
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = TitleBar

-- Ввод имени
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -24, 0, 35)
TextBox.Position = UDim2.new(0, 12, 0, 50)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TextBox.BorderSizePixel = 0
TextBox.Text = ""
TextBox.PlaceholderText = "Username / Display / UserID"
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 135)
TextBox.TextSize = 14
TextBox.Font = Enum.Font.SourceSans
TextBox.Parent = MainFrame

local TextCorner = Instance.new("UICorner")
TextCorner.CornerRadius = UDim.new(0, 6)
TextCorner.Parent = TextBox

-- Кнопка НАЧАТЬ
local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(1, -24, 0, 40)
StartButton.Position = UDim2.new(0, 12, 0, 100)
StartButton.BackgroundColor3 = Color3.fromRGB(40, 130, 90)
StartButton.BorderSizePixel = 0
StartButton.Text = "START FOLLOW"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 14
StartButton.Font = Enum.Font.SourceSansBold
StartButton.Parent = MainFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 6)
StartCorner.Parent = StartButton

-- Кнопка ЗАКОНЧИТЬ
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(1, -24, 0, 40)
StopButton.Position = UDim2.new(0, 12, 0, 150)
StopButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StopButton.BorderSizePixel = 0
StopButton.Text = "STOP FOLLOW"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.TextSize = 14
StopButton.Font = Enum.Font.SourceSansBold
StopButton.Parent = MainFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 6)
StopCorner.Parent = StopButton

-- Логика скрытия интерфейса
local IsMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 35), "Out", "Quad", 0.2, true)
        TextBox.Visible = false
        StartButton.Visible = false
        StopButton.Visible = false
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 210), "Out", "Quad", 0.2, true)
        task.wait(0.1)
        TextBox.Visible = true
        StartButton.Visible = true
        StopButton.Visible = true
        MinimizeButton.Text = "_"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    UI:Destroy()
end)

-- Логика преследования
local IsFollowing = false
local FollowLoop = nil
local NoclipLoop = nil

local function GetPlayer(search)
    search = string.lower(search)
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            if string.lower(p.Name):find(search) or 
               string.lower(p.DisplayName):find(search) or 
               tostring(p.UserId) == search then
                return p
            end
        end
    end
    return nil
end

StartButton.MouseButton1Click:Connect(function()
    if IsFollowing then return end
    
    local targetText = TextBox.Text
    local target = GetPlayer(targetText)
    
    if not target or targetText == "" then
        StartButton.Text = "PLAYER NOT FOUND!"
        task.wait(1.5)
        StartButton.Text = "START FOLLOW"
        return
    end
    
    IsFollowing = true
    StartButton.Text = "FOLLOWING: " .. target.DisplayName:upper()
    
    -- Включение NoClip (проход сквозь стены, чтобы не застревать)
    NoclipLoop = game:GetService("RunService").Stepped:Connect(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    -- Цикл телепортации
    FollowLoop = game:GetService("RunService").Heartbeat:Connect(function()
        local lp = game.Players.LocalPlayer
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = target.Character.HumanoidRootPart
                lp.Character.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
            end
        else
            target = GetPlayer(targetText)
        end
    end)
end)

StopButton.MouseButton1Click:Connect(function()
    if FollowLoop then FollowLoop:Disconnect() FollowLoop = nil end
    if NoclipLoop then NoclipLoop:Disconnect() NoclipLoop = nil end
    IsFollowing = false
    StartButton.Text = "START FOLLOW"
end)