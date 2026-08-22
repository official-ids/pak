-- ==========================================
-- Winion Spectate v1 (MM2 Style)
-- С виджетом и корректным сбросом камеры
-- ==========================================

local ok, err = pcall(function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Очистка предыдущих версий
    local function cleanup()
        for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if gui.Name == "WinionSpectateUI" or gui.Name == "WinionSpectateWidget" then
                gui:Destroy()
            end
        end
    end
    cleanup()

    -- Функция ЖЕСТКОГО сброса камеры на локального игрока
    local function resetCamera()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and Camera then
                Camera.CameraSubject = hum
                Camera.CameraType = Enum.CameraType.Custom
            end
        end
    end

    -- ================= СОЗДАНИЕ ВИДЖЕТА (КНОПКА ОТКРЫТИЯ) =================
    local WidgetGui = Instance.new("ScreenGui")
    WidgetGui.Name = "WinionSpectateWidget"
    WidgetGui.ResetOnSpawn = false
    WidgetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WidgetGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local WidgetBtn = Instance.new("TextButton")
    WidgetBtn.Size = UDim2.new(0, 50, 0, 50)
    WidgetBtn.Position = UDim2.new(1, -70, 0.5, -25) -- Справа по центру
    WidgetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    WidgetBtn.BackgroundTransparency = 0.2
    WidgetBtn.Text = "👁️"
    WidgetBtn.TextSize = 24
    WidgetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    WidgetBtn.BorderSizePixel = 0
    WidgetBtn.AutoButtonColor = true
    WidgetBtn.Parent = WidgetGui
    
    local wCorner = Instance.new("UICorner", WidgetBtn)
    wCorner.CornerRadius = UDim.new(1, 0)
    local wStroke = Instance.new("UIStroke", WidgetBtn)
    wStroke.Color = Color3.fromRGB(80, 120, 255)
    wStroke.Thickness = 2

    -- ================= СОЗДАНИЕ ОСНОВНОГО UI (MM2 STYLE) =================
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "WinionSpectateUI"
    MainGui.ResetOnSpawn = false
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 55)
    MainFrame.Position = UDim2.new(0.5, -160, 1, -80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BackgroundTransparency = 0.4
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false -- Скрыто по умолчанию!
    MainFrame.Parent = MainGui

    local mCorner = Instance.new("UICorner", MainFrame)
    mCorner.CornerRadius = UDim.new(0, 12)
    local mStroke = Instance.new("UIStroke", MainFrame)
    mStroke.Color = Color3.fromRGB(60, 60, 70)
    mStroke.Thickness = 1.5
    mStroke.Transparency = 0.3

    -- Кнопки
    local function makeButton(name, text, size, position, parent, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = size
        btn.Position = position
        btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 50)
        btn.BackgroundTransparency = 0.3
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        return btn
    end

    local BtnPrev = makeButton("Prev", "<", UDim2.new(0, 45, 0, 40), UDim2.new(0, 8, 0.5, -20), MainFrame)
    local BtnNext = makeButton("Next", ">", UDim2.new(0, 45, 0, 40), UDim2.new(1, -53, 0.5, -20), MainFrame)
    local BtnClose = makeButton("Close", "✕", UDim2.new(0, 26, 0, 26), UDim2.new(1, -32, 0, 5), MainFrame, Color3.fromRGB(60, 20, 20))
    BtnClose.TextColor3 = Color3.fromRGB(255, 90, 90)

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, -120, 1, 0)
    NameLabel.Position = UDim2.new(0, 60, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = "Spectating: Вы"
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Center
    NameLabel.Parent = MainFrame

    -- ================= ЛОГИКА =================
    local currentIndex = 1
    local spectateList = {}
    local isUIOpen = false

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
            if isAlive(plr) then table.insert(newList, plr) end
        end
        table.sort(newList, function(a, b) return a.Name < b.Name end)
        spectateList = newList
    end

    local function getCurrentTarget()
        if #spectateList == 0 then return nil end
        if currentIndex < 1 or currentIndex > #spectateList then currentIndex = 1 end
        return spectateList[currentIndex]
    end

    local function focusCameraOnPlayer(player)
        if not player then
            resetCamera()
            NameLabel.Text = "Spectating: Вы"
            return
        end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and Camera then
            Camera.CameraSubject = hum
            Camera.CameraType = Enum.CameraType.Watch
        end
        NameLabel.Text = "👁️ " .. player.DisplayName .. " (@" .. player.Name .. ")"
    end

    local function updateCamera()
        if not isUIOpen then 
            resetCamera()
            return 
        end
        rebuildList()
        local target = getCurrentTarget()
        focusCameraOnPlayer(target)
    end

    local function switchPlayer(direction)
        if #spectateList == 0 then return end
        currentIndex = currentIndex + direction
        if currentIndex > #spectateList then currentIndex = 1 end
        if currentIndex < 1 then currentIndex = #spectateList end
        focusCameraOnPlayer(getCurrentTarget())
    end

    -- Анимация кнопок
    local function animatePress(btn)
        local originalSize = btn.Size -- Сохраняем исходный размер ДО изменения
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, originalSize.Y.Scale, originalSize.Y.Offset - 4)}):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = originalSize}):Play() -- Возвращаем сохраненный исходный размер
        end)
    end

    -- ================= ОБРАБОТЧИКИ СОБЫТИЙ =================
    
    -- 1. Открытие/Закрытие через Виджет
    local function toggleUI()
        isUIOpen = not isUIOpen
        MainFrame.Visible = isUIOpen
        
        if isUIOpen then
            updateCamera() -- Начать слежение при открытии
        else
            resetCamera() -- ЖЕСТКИЙ сброс камеры при закрытии
        end
    end

    WidgetBtn.MouseButton1Click:Connect(function()
        animatePress(WidgetBtn)
        toggleUI()
    end)

    -- 2. Кнопки внутри меню
    BtnPrev.MouseButton1Click:Connect(function() animatePress(BtnPrev); switchPlayer(-1) end)
    BtnNext.MouseButton1Click:Connect(function() animatePress(BtnNext); switchPlayer(1) end)
    
    BtnClose.MouseButton1Click:Connect(function()
        animatePress(BtnClose)
        task.delay(0.1, function()
            isUIOpen = false
            MainFrame.Visible = false
            resetCamera() -- Сброс камеры при нажатии X
        end)
    end)

    -- 3. Горячая клавиша (например, F7 или RightShift) для быстрого открытия/закрытия
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F7 or input.KeyCode == Enum.KeyCode.RightShift then
            toggleUI()
        end
    end)

    -- 4. Динамическое обновление (смерть/выход игрока)
    local function onPlayerChanged()
        if isUIOpen then
            task.wait(0.2)
            updateCamera()
        end
    end

    Players.PlayerAdded:Connect(onPlayerChanged)
    Players.PlayerRemoving:Connect(onPlayerChanged)

    local function hookPlayer(player)
        if player == LocalPlayer then return end
        player.CharacterAdded:Connect(onPlayerChanged)
    end
    for _, plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
    Players.PlayerAdded:Connect(hookPlayer)

    -- Фоновая проверка каждые 2 секунды (на случай если игрок умер, а событие не сработало)
    task.spawn(function()
        while MainGui.Parent do
            task.wait(2)
            pcall(updateCamera)
        end
    end)

    -- При уничтожении скрипта (например, реинжекте) всегда сбрасываем камеру
    MainGui.AncestryChanged:Connect(function()
        if not MainGui.Parent then resetCamera() end
    end)

end)

if not ok then
    warn("[Winion Spectate] Критическая ошибка: " .. tostring(err))
end