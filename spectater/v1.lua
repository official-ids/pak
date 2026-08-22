-- Spectate Script (MM2 Style) by Qwen3.7
-- Запуск: вставь в executor и нажми Execute

local ok, err = pcall(function()
    -- ================= SERVICES =================
    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local UserInputService  = game:GetService("UserInputService")
    local TweenService      = game:GetService("TweenService")

    local LocalPlayer = Players.LocalPlayer
    local Camera      = workspace.CurrentCamera

    -- ================= КОНСТАНТЫ =================
    local SPECTATE_NAME = "MM2_SpectateUI_v1"

    -- ================= ОЧИСТКА СТАРОГО GUI =================
    local function cleanup()
        local old = LocalPlayer:FindFirstChildWhichIsA("PlayerGui"):FindFirstChild(SPECTATE_NAME)
            or game:GetService("CoreGui"):FindFirstChild(SPECTATE_NAME)
        if old then old:Destroy() end
    end
    cleanup()

    -- ================= СОЗДАНИЕ GUI =================
    local Parent = (pcall(function()
        local t = Instance.new("ScreenGui", game:GetService("CoreGui"))
        t.Name = "test"
        t:Destroy()
    end) and game:GetService("CoreGui")) or LocalPlayer:WaitForChild("PlayerGui")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = SPECTATE_NAME
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 10
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = Parent

    -- Основная плашка
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 55)
    MainFrame.Position = UDim2.new(0.5, -160, 1, -80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BackgroundTransparency = 0.4
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(60, 60, 70)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.3
    Stroke.Parent = MainFrame

    -- Кнопка "<"
    local function makeButton(name, text, size, position, parent)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = size
        btn.Position = position
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.BackgroundTransparency = 0.3
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        btn.Parent = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn
        return btn
    end

    local BtnPrev = makeButton("Prev", "<", UDim2.new(0, 45, 0, 40), UDim2.new(0, 8, 0.5, -20), MainFrame)
    local BtnNext = makeButton("Next", ">", UDim2.new(0, 45, 0, 40), UDim2.new(1, -53, 0.5, -20), MainFrame)
    local BtnClose = makeButton("Close", "X", UDim2.new(0, 22, 0, 22), UDim2.new(1, -28, 0, 5), MainFrame)
    BtnClose.TextColor3 = Color3.fromRGB(255, 90, 90)
    BtnClose.BackgroundColor3 = Color3.fromRGB(60, 20, 20)

    -- Имя игрока
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, -120, 1, 0)
    NameLabel.Position = UDim2.new(0, 60, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = "Spectating: —"
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Center
    NameLabel.Parent = MainFrame

    -- ================= ЛОГИКА СПИСКА ИГРОКОВ =================
    local currentIndex = 1
    local spectateList = {}

    local function isAlive(player)
        if player == LocalPlayer then return false end
        local char = player.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return false end
        if hum.Health <= 0 then return false end
        return true
    end

    local function rebuildList()
        local newList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if isAlive(plr) then
                table.insert(newList, plr)
            end
        end
        -- Сортировка по имени для стабильности
        table.sort(newList, function(a, b) return a.Name < b.Name end)
        spectateList = newList
    end

    local function getCurrentTarget()
        if #spectateList == 0 then return nil end
        if currentIndex < 1 or currentIndex > #spectateList then
            currentIndex = 1
        end
        return spectateList[currentIndex]
    end

    -- ================= КАМЕРА =================
    local function focusCameraOnPlayer(player)
        if not player then
            -- Возврат к локальному персонажу
            local myChar = LocalPlayer.Character
            if myChar then
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                if hum then
                    Camera.CameraSubject = hum
                end
            end
            NameLabel.Text = "Spectating: You"
            return
        end

        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
        NameLabel.Text = "Spectating: " .. player.DisplayName .. " (@" .. player.Name .. ")"
    end

    local function updateCamera()
        rebuildList()
        local target = getCurrentTarget()
        if target then
            focusCameraOnPlayer(target)
        else
            focusCameraOnPlayer(nil)
        end
    end

    -- ================= ПЕРЕКЛЮЧЕНИЕ =================
    local function switchPlayer(direction)
        if #spectateList == 0 then return end
        currentIndex = currentIndex + direction
        if currentIndex > #spectateList then currentIndex = 1 end
        if currentIndex < 1 then currentIndex = #spectateList end
        focusCameraOnPlayer(getCurrentTarget())
    end

    -- ================= АНИМАЦИЯ КНОПОК =================
    local function animatePress(btn)
        local tween = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 4, btn.Size.Y.Scale, btn.Size.Y.Offset - 4)
        })
        tween:Play()
        task.delay(0.1, function()
            local restore = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 4, btn.Size.Y.Scale, btn.Size.Y.Offset + 4)
            })
            restore:Play()
        end)
    end

    -- ================= ОБРАБОТЧИКИ =================
    BtnPrev.MouseButton1Click:Connect(function()
        animatePress(BtnPrev)
        switchPlayer(-1)
    end)

    BtnNext.MouseButton1Click:Connect(function()
        animatePress(BtnNext)
        switchPlayer(1)
    end)

    local function destroyAll()
        ScreenGui:Destroy()
        -- Возвращаем камеру к локальному игроку
        local myChar = LocalPlayer.Character
        if myChar then
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end
    end

    BtnClose.MouseButton1Click:Connect(function()
        animatePress(BtnClose)
        task.delay(0.1, destroyAll)
    end)

    -- События игроков
    Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        updateCamera()
    end)

    Players.PlayerRemoving:Connect(function(removed)
        if removed == getCurrentTarget() then
            task.wait(0.1)
            updateCamera()
        end
    end)

    -- Следим за жизнями и спавнами
    local function hookPlayer(player)
        if player == LocalPlayer then return end
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            updateCamera()
        end)
        local function hookChar(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.HealthChanged:Connect(function()
                    if hum.Health <= 0 and player == getCurrentTarget() then
                        task.wait(0.3)
                        updateCamera()
                    end
                end)
            end
        end
        if player.Character then hookChar(player.Character) end
        player.CharacterAdded:Connect(hookChar)
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        hookPlayer(plr)
    end
    Players.PlayerAdded:Connect(hookPlayer)

    -- ================= СТАРТ =================
    updateCamera()
    task.spawn(function()
        while ScreenGui.Parent do
            task.wait(2)
            pcall(updateCamera)
        end
    end)
end)

if not ok then
    warn("[Spectate] Ошибка: " .. tostring(err))
end