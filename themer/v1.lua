--[[
    ====================================================================
    UI Theme Injector | Rayfield Edition
    Автор: Winion (@Winion)
    Назначение: Профессиональная кастомизация интерфейсов Roblox
    Библиотека: Rayfield UI
    Версия: 2.0.0 (Full Unoptimized Verbose Edition)
    ====================================================================
    
    Данный скрипт предназначен для глубокой и детальной настройки 
    визуального оформления интерфейсов Roblox. 
    Код написан в развернутом, неоптимизированном стиле для максимальной 
    читаемости, простоты модификации и отсутствия скрытых зависимостей.
    
    Структура скрипта:
    1. Подключение библиотеки Rayfield
    2. Объявление сервисов Roblox
    3. Конфигурация тем по умолчанию (Пресеты)
    4. Текущие настройки (Default State)
    5. Система сохранения и загрузки (File I/O)
    6. Утилиты для работы с UI (UIUtils)
    7. Модули кастомизации CoreGui
    8. Модули кастомизации игровых интерфейсов (GameUI)
    9. Система применения тем (ThemeSystem)
    10. Построение интерфейса Rayfield (Window, Tabs, Elements)
    11. Инициализация и обработчики событий
    ====================================================================
]]

-- =========================================================================
-- 1. ПОДКЛЮЧЕНИЕ БИБЛИОТЕКИ RAYFIELD
-- =========================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =========================================================================
-- 2. ОБЪЯВЛЕНИЕ СЕРВИСОВ ROBLOX
-- =========================================================================

local Services = {}

Services.Players = game:GetService("Players")
Services.CoreGui = game:GetService("CoreGui")
Services.TweenService = game:GetService("TweenService")
Services.UserInputService = game:GetService("UserInputService")
Services.StarterGui = game:GetService("StarterGui")
Services.Lighting = game:GetService("Lighting")
Services.RunService = game:GetService("RunService")
Services.Workspace = game:GetService("Workspace")
Services.HttpService = game:GetService("HttpService")
Services.TextService = game:GetService("TextService")
Services.MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================================
-- 3. КОНФИГУРАЦИЯ ТЕМ ПО УМОЛЧАНИЮ (ПРЕСЕТЫ)
-- =========================================================================

local DefaultThemes = {}

DefaultThemes.DarkRed = {
    Name = "Dark Red Neon",
    BackgroundColor = Color3.fromRGB(25, 25, 30),
    AccentColor = Color3.fromRGB(255, 50, 50),
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryColor = Color3.fromRGB(45, 45, 55),
    Transparency = 0.1,
    CornerRadius = 12,
    Font = Enum.Font.GothamBold
}

DefaultThemes.CyberPunk = {
    Name = "Cyberpunk",
    BackgroundColor = Color3.fromRGB(20, 20, 35),
    AccentColor = Color3.fromRGB(0, 255, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryColor = Color3.fromRGB(40, 40, 60),
    Transparency = 0.15,
    CornerRadius = 8,
    Font = Enum.Font.Code
}

DefaultThemes.Minimalist = {
    Name = "Minimalist White",
    BackgroundColor = Color3.fromRGB(250, 250, 250),
    AccentColor = Color3.fromRGB(0, 120, 215),
    TextColor = Color3.fromRGB(30, 30, 30),
    SecondaryColor = Color3.fromRGB(240, 240, 240),
    Transparency = 0.05,
    CornerRadius = 4,
    Font = Enum.Font.Gotham
}

DefaultThemes.Matrix = {
    Name = "Matrix Green",
    BackgroundColor = Color3.fromRGB(0, 10, 0),
    AccentColor = Color3.fromRGB(0, 255, 0),
    TextColor = Color3.fromRGB(0, 255, 0),
    SecondaryColor = Color3.fromRGB(0, 30, 0),
    Transparency = 0.2,
    CornerRadius = 0,
    Font = Enum.Font.Code
}

DefaultThemes.Sunset = {
    Name = "Sunset Orange",
    BackgroundColor = Color3.fromRGB(30, 20, 40),
    AccentColor = Color3.fromRGB(255, 140, 50),
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryColor = Color3.fromRGB(50, 35, 60),
    Transparency = 0.1,
    CornerRadius = 10,
    Font = Enum.Font.GothamMedium
}

DefaultThemes.OceanBlue = {
    Name = "Ocean Blue",
    BackgroundColor = Color3.fromRGB(10, 20, 40),
    AccentColor = Color3.fromRGB(0, 150, 255),
    TextColor = Color3.fromRGB(200, 230, 255),
    SecondaryColor = Color3.fromRGB(20, 40, 70),
    Transparency = 0.12,
    CornerRadius = 14,
    Font = Enum.Font.Gotham
}

DefaultThemes.ForestGreen = {
    Name = "Forest Green",
    BackgroundColor = Color3.fromRGB(15, 30, 15),
    AccentColor = Color3.fromRGB(50, 205, 50),
    TextColor = Color3.fromRGB(220, 255, 220),
    SecondaryColor = Color3.fromRGB(30, 60, 30),
    Transparency = 0.15,
    CornerRadius = 6,
    Font = Enum.Font.GothamMedium
}

DefaultThemes.MidnightPurple = {
    Name = "Midnight Purple",
    BackgroundColor = Color3.fromRGB(20, 10, 30),
    AccentColor = Color3.fromRGB(180, 50, 255),
    TextColor = Color3.fromRGB(240, 220, 255),
    SecondaryColor = Color3.fromRGB(40, 20, 60),
    Transparency = 0.18,
    CornerRadius = 16,
    Font = Enum.Font.GothamBold
}

DefaultThemes.GoldenHour = {
    Name = "Golden Hour",
    BackgroundColor = Color3.fromRGB(40, 30, 10),
    AccentColor = Color3.fromRGB(255, 200, 50),
    TextColor = Color3.fromRGB(255, 240, 200),
    SecondaryColor = Color3.fromRGB(60, 45, 15),
    Transparency = 0.08,
    CornerRadius = 8,
    Font = Enum.Font.Gotham
}

DefaultThemes.Monochrome = {
    Name = "Monochrome",
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    AccentColor = Color3.fromRGB(255, 255, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryColor = Color3.fromRGB(60, 60, 60),
    Transparency = 0.0,
    CornerRadius = 0,
    Font = Enum.Font.Code
}

-- =========================================================================
-- 4. ТЕКУЩИЕ НАСТРОЙКИ (DEFAULT STATE)
-- =========================================================================
-- Примечание: Здесь не вызываются функции UIUtils, чтобы избежать ошибок 
-- порядка инициализации (UIUtils определяется ниже).

local CurrentSettings = {
    ActiveTheme = "DarkRed",
    
    CoreGui = {
        Chat = {
            Enabled = true,
            BackgroundColor = Color3.fromRGB(25, 25, 30),
            TextColor = Color3.fromRGB(255, 255, 255),
            Transparency = 0.1,
            CornerRadius = 12,
            Size = UDim2.new(0, 300, 0, 250)
        },
        PlayerList = {
            Enabled = true,
            BackgroundColor = Color3.fromRGB(25, 25, 30),
            TextColor = Color3.fromRGB(255, 255, 255),
            Transparency = 0.1,
            CornerRadius = 12
        },
        Backpack = {
            Enabled = true,
            BackgroundColor = Color3.fromRGB(25, 25, 30),
            Transparency = 0.1,
            CornerRadius = 8
        },
        HealthBar = {
            Enabled = true,
            BarColor = Color3.fromRGB(255, 50, 50),
            BackgroundColor = Color3.fromRGB(40, 40, 40),
            Transparency = 0.2,
            CornerRadius = 4
        },
        Leaderboard = {
            Enabled = true,
            BackgroundColor = Color3.fromRGB(25, 25, 30),
            TextColor = Color3.fromRGB(255, 255, 255),
            Transparency = 0.1,
            CornerRadius = 8
        },
        Notifications = {
            Enabled = true,
            BackgroundColor = Color3.fromRGB(25, 25, 30),
            TextColor = Color3.fromRGB(255, 255, 255),
            Transparency = 0.15,
            CornerRadius = 10
        }
    },
    
    GameUI = {
        CustomFrames = {
            Enabled = false,
            TargetFrameName = "",
            BackgroundColor = Color3.fromRGB(25, 25, 30),
            Transparency = 0.1,
            CornerRadius = 12
        },
        Buttons = {
            Enabled = false,
            BackgroundColor = Color3.fromRGB(45, 45, 55),
            HoverColor = Color3.fromRGB(55, 55, 70),
            TextColor = Color3.fromRGB(255, 255, 255),
            CornerRadius = 8
        },
        Labels = {
            Enabled = false,
            TextColor = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 14
        },
        ImageLabels = {
            Enabled = false,
            BorderColor = Color3.fromRGB(255, 255, 255),
            BorderThickness = 0,
            CornerRadius = 8
        },
        ScrollFrames = {
            Enabled = false,
            BackgroundColor = Color3.fromRGB(20, 20, 25),
            Transparency = 0.2,
            CornerRadius = 6
        },
        TextBoxes = {
            Enabled = false,
            BackgroundColor = Color3.fromRGB(30, 30, 35),
            TextColor = Color3.fromRGB(255, 255, 255),
            Transparency = 0.1,
            CornerRadius = 6
        }
    },
    
    Advanced = {
        Glassmorphism = {
            Enabled = true,
            BlurSize = 10,
            Transparency = 0.3
        },
        Animations = {
            Enabled = true,
            HoverSpeed = 0.2,
            ClickSpeed = 0.1
        },
        Responsive = {
            Enabled = true,
            MobileScale = 0.8,
            TabletScale = 0.9,
            DesktopScale = 1.0
        },
        Logging = {
            Enabled = true,
            PrintToOutput = true,
            PrintToConsole = false
        }
    }
}

-- =========================================================================
-- 5. СИСТЕМА СОХРАНЕНИЯ И ЗАГРУЗКИ (FILE I/O)
-- =========================================================================

local SaveSystem = {}
SaveSystem.SaveKey = "UIThemeInjector_Settings_v2.json"

SaveSystem.Log = function(message)
    if CurrentSettings.Advanced.Logging.Enabled and CurrentSettings.Advanced.Logging.PrintToOutput then
        print("[UIThemeInjector] " .. tostring(message))
    end
end

SaveSystem.Save = function()
    SaveSystem.Log("Начало процесса сохранения настроек...")
    local success, err = pcall(function()
        local dataToSave = Services.HttpService:JSONEncode(CurrentSettings)
        writefile(SaveSystem.SaveKey, dataToSave)
    end)
    
    if success then
        SaveSystem.Log("Настройки успешно сохранены в файл: " .. SaveSystem.SaveKey)
    else
        SaveSystem.Log("ОШИБКА сохранения настроек: " .. tostring(err))
        warn("[UIThemeInjector] Ошибка сохранения настроек: " .. tostring(err))
    end
end

SaveSystem.Load = function()
    SaveSystem.Log("Попытка загрузки настроек из файла...")
    local success, data = pcall(function()
        if isfile(SaveSystem.SaveKey) then
            local fileContent = readfile(SaveSystem.SaveKey)
            local decodedData = Services.HttpService:JSONDecode(fileContent)
            return decodedData
        end
        return nil
    end)
    
    if success and data ~= nil then
        SaveSystem.Log("Настройки успешно загружены из файла.")
        CurrentSettings = data
        return true
    else
        SaveSystem.Log("Файл сохранений не найден или поврежден. Используются настройки по умолчанию.")
        return false
    end
end

SaveSystem.Reset = function()
    SaveSystem.Log("Сброс настроек до заводских значений...")
    local success = pcall(function()
        if isfile(SaveSystem.SaveKey) then
            delfile(SaveSystem.SaveKey)
            SaveSystem.Log("Файл сохранений успешно удален.")
        end
    end)
    return success
end

-- =========================================================================
-- 6. УТИЛИТЫ ДЛЯ РАБОТЫ С UI (UIUtils)
-- =========================================================================

local UIUtils = {}

UIUtils.GetDeviceType = function()
    local camera = Services.Workspace.CurrentCamera
    if not camera then
        return "Desktop"
    end
    
    local viewportSize = camera.ViewportSize
    if viewportSize.X < 800 then
        return "Mobile"
    elseif viewportSize.X < 1200 then
        return "Tablet"
    else
        return "Desktop"
    end
end

UIUtils.GetScaleFactor = function()
    local deviceType = UIUtils.GetDeviceType()
    if deviceType == "Mobile" then
        return CurrentSettings.Advanced.Responsive.MobileScale
    elseif deviceType == "Tablet" then
        return CurrentSettings.Advanced.Responsive.TabletScale
    else
        return CurrentSettings.Advanced.Responsive.DesktopScale
    end
end

UIUtils.ApplyGlassmorphism = function(instance, blurSize, transparency)
    if not CurrentSettings.Advanced.Glassmorphism.Enabled then
        return
    end
    
    local existingBlur = instance:FindFirstChildWhichIsA("BlurEffect")
    if not existingBlur then
        local blur = Instance.new("BlurEffect")
        blur.Size = blurSize or CurrentSettings.Advanced.Glassmorphism.BlurSize
        blur.Name = "InjectorBlurEffect"
        blur.Parent = instance
    else
        existingBlur.Size = blurSize or CurrentSettings.Advanced.Glassmorphism.BlurSize
    end
    
    instance.BackgroundTransparency = transparency or CurrentSettings.Advanced.Glassmorphism.Transparency
end

UIUtils.ApplyCornerRadius = function(instance, radius)
    local existingCorner = instance:FindFirstChildWhichIsA("UICorner")
    if not existingCorner then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or CurrentSettings.CoreGui.Chat.CornerRadius)
        corner.Name = "InjectorUICorner"
        corner.Parent = instance
    else
        existingCorner.CornerRadius = UDim.new(0, radius or CurrentSettings.CoreGui.Chat.CornerRadius)
    end
end

UIUtils.ApplyStroke = function(instance, color, thickness)
    local existingStroke = instance:FindFirstChildWhichIsA("UIStroke")
    if not existingStroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = color or Color3.fromRGB(60, 60, 70)
        stroke.Thickness = thickness or 1
        stroke.Name = "InjectorUIStroke"
        stroke.Parent = instance
    else
        existingStroke.Color = color or Color3.fromRGB(60, 60, 70)
        existingStroke.Thickness = thickness or 1
    end
end

UIUtils.CreateTween = function(instance, property, value, duration)
    if not CurrentSettings.Advanced.Animations.Enabled then
        instance[property] = value
        return
    end
    
    local tweenInfo = TweenInfo.new(
        duration or CurrentSettings.Advanced.Animations.HoverSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tweenProperties = {}
    tweenProperties[property] = value
    
    local tween = Services.TweenService:Create(instance, tweenInfo, tweenProperties)
    tween:Play()
    return tween
end

UIUtils.ApplyFont = function(instance, fontEnum)
    if instance:IsA("GuiObject") or instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        instance.Font = fontEnum
    end
end

UIUtils.ApplyTextSize = function(instance, size)
    if instance:IsA("GuiObject") or instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        instance.TextSize = size
    end
end

UIUtils.ApplyTextColor = function(instance, color)
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        instance.TextColor3 = color
    end
end

UIUtils.ApplyBackgroundColor = function(instance, color)
    if instance:IsA("GuiObject") then
        instance.BackgroundColor3 = color
    end
end

UIUtils.ApplyBackgroundTransparency = function(instance, transparency)
    if instance:IsA("GuiObject") then
        instance.BackgroundTransparency = transparency
    end
end

-- =========================================================================
-- 7. МОДУЛИ КАСТОМИЗАЦИИ COREGUI
-- =========================================================================

local CoreGuiModules = {}

CoreGuiModules.Chat = {}
CoreGuiModules.Chat.ApplyTheme = function()
    if not CurrentSettings.CoreGui.Chat.Enabled then
        return
    end
    
    local chatFrame = PlayerGui:FindFirstChild("Chat")
    if not chatFrame then
        return
    end
    
    local mainFrame = chatFrame:FindFirstChild("Frame") or chatFrame:FindFirstChild("ChatFrame")
    if mainFrame then
        UIUtils.CreateTween(mainFrame, "BackgroundColor3", CurrentSettings.CoreGui.Chat.BackgroundColor)
        UIUtils.CreateTween(mainFrame, "BackgroundTransparency", CurrentSettings.CoreGui.Chat.Transparency)
        
        if CurrentSettings.Advanced.Glassmorphism.Enabled then
            UIUtils.ApplyGlassmorphism(mainFrame)
        end
        
        UIUtils.ApplyCornerRadius(mainFrame, CurrentSettings.CoreGui.Chat.CornerRadius)
    end
    
    local chatMessages = chatFrame:FindFirstChild("ChatMessages") or chatFrame:FindFirstChild("Messages")
    if chatMessages then
        for _, descendant in pairs(chatMessages:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                UIUtils.CreateTween(descendant, "TextColor3", CurrentSettings.CoreGui.Chat.TextColor)
            end
        end
    end
end

CoreGuiModules.Chat.Reset = function()
    local chatFrame = PlayerGui:FindFirstChild("Chat")
    if chatFrame then
        local mainFrame = chatFrame:FindFirstChild("Frame") or chatFrame:FindFirstChild("ChatFrame")
        if mainFrame then
            mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            mainFrame.BackgroundTransparency = 0.5
            local corner = mainFrame:FindFirstChildWhichIsA("UICorner")
            if corner then corner:Destroy() end
        end
    end
end

CoreGuiModules.PlayerList = {}
CoreGuiModules.PlayerList.ApplyTheme = function()
    if not CurrentSettings.CoreGui.PlayerList.Enabled then
        return
    end
    
    local playerList = PlayerGui:FindFirstChild("PlayerList")
    if not playerList then
        return
    end
    
    local mainFrame = playerList:FindFirstChild("Frame") or playerList:FindFirstChild("PlayerListFrame")
    if mainFrame then
        UIUtils.CreateTween(mainFrame, "BackgroundColor3", CurrentSettings.CoreGui.PlayerList.BackgroundColor)
        UIUtils.CreateTween(mainFrame, "BackgroundTransparency", CurrentSettings.CoreGui.PlayerList.Transparency)
        
        if CurrentSettings.Advanced.Glassmorphism.Enabled then
            UIUtils.ApplyGlassmorphism(mainFrame)
        end
        
        UIUtils.ApplyCornerRadius(mainFrame, CurrentSettings.CoreGui.PlayerList.CornerRadius)
    end
    
    for _, descendant in pairs(playerList:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            UIUtils.CreateTween(descendant, "TextColor3", CurrentSettings.CoreGui.PlayerList.TextColor)
        end
    end
end

CoreGuiModules.PlayerList.Reset = function()
    local playerList = PlayerGui:FindFirstChild("PlayerList")
    if playerList then
        local mainFrame = playerList:FindFirstChild("Frame") or playerList:FindFirstChild("PlayerListFrame")
        if mainFrame then
            mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            mainFrame.BackgroundTransparency = 0.5
            local corner = mainFrame:FindFirstChildWhichIsA("UICorner")
            if corner then corner:Destroy() end
        end
    end
end

CoreGuiModules.Backpack = {}
CoreGuiModules.Backpack.ApplyTheme = function()
    if not CurrentSettings.CoreGui.Backpack.Enabled then
        return
    end
    
    local backpack = PlayerGui:FindFirstChild("Backpack")
    if not backpack then
        return
    end
    
    local mainFrame = backpack:FindFirstChild("Frame") or backpack:FindFirstChild("BackpackFrame")
    if mainFrame then
        UIUtils.CreateTween(mainFrame, "BackgroundColor3", CurrentSettings.CoreGui.Backpack.BackgroundColor)
        UIUtils.CreateTween(mainFrame, "BackgroundTransparency", CurrentSettings.CoreGui.Backpack.Transparency)
        
        if CurrentSettings.Advanced.Glassmorphism.Enabled then
            UIUtils.ApplyGlassmorphism(mainFrame)
        end
        
        UIUtils.ApplyCornerRadius(mainFrame, CurrentSettings.CoreGui.Backpack.CornerRadius)
    end
end

CoreGuiModules.Backpack.Reset = function()
    local backpack = PlayerGui:FindFirstChild("Backpack")
    if backpack then
        local mainFrame = backpack:FindFirstChild("Frame") or backpack:FindFirstChild("BackpackFrame")
        if mainFrame then
            mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            mainFrame.BackgroundTransparency = 0.5
            local corner = mainFrame:FindFirstChildWhichIsA("UICorner")
            if corner then corner:Destroy() end
        end
    end
end

CoreGuiModules.HealthBar = {}
CoreGuiModules.HealthBar.ApplyTheme = function()
    if not CurrentSettings.CoreGui.HealthBar.Enabled then
        return
    end
    
    local healthBar = PlayerGui:FindFirstChild("Health")
    if not healthBar then
        return
    end
    
    local bar = healthBar:FindFirstChild("Bar") or healthBar:FindFirstChild("HealthBar")
    if bar then
        UIUtils.CreateTween(bar, "BackgroundColor3", CurrentSettings.CoreGui.HealthBar.BarColor)
        UIUtils.CreateTween(bar, "BackgroundTransparency", CurrentSettings.CoreGui.HealthBar.Transparency)
        UIUtils.ApplyCornerRadius(bar, CurrentSettings.CoreGui.HealthBar.CornerRadius)
    end
    
    local background = healthBar:FindFirstChild("Background") or healthBar:FindFirstChild("Frame")
    if background then
        UIUtils.CreateTween(background, "BackgroundColor3", CurrentSettings.CoreGui.HealthBar.BackgroundColor)
    end
end

CoreGuiModules.HealthBar.Reset = function()
    local healthBar = PlayerGui:FindFirstChild("Health")
    if healthBar then
        local bar = healthBar:FindFirstChild("Bar") or healthBar:FindFirstChild("HealthBar")
        if bar then
            bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            local corner = bar:FindFirstChildWhichIsA("UICorner")
            if corner then corner:Destroy() end
        end
    end
end

CoreGuiModules.Leaderboard = {}
CoreGuiModules.Leaderboard.ApplyTheme = function()
    if not CurrentSettings.CoreGui.Leaderboard.Enabled then
        return
    end
    
    local leaderboard = PlayerGui:FindFirstChild("Leaderboard")
    if not leaderboard then
        return
    end
    
    local mainFrame = leaderboard:FindFirstChild("Frame") or leaderboard:FindFirstChild("LeaderboardFrame")
    if mainFrame then
        UIUtils.CreateTween(mainFrame, "BackgroundColor3", CurrentSettings.CoreGui.Leaderboard.BackgroundColor)
        UIUtils.CreateTween(mainFrame, "BackgroundTransparency", CurrentSettings.CoreGui.Leaderboard.Transparency)
        UIUtils.ApplyCornerRadius(mainFrame, CurrentSettings.CoreGui.Leaderboard.CornerRadius)
    end
    
    for _, descendant in pairs(leaderboard:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            UIUtils.CreateTween(descendant, "TextColor3", CurrentSettings.CoreGui.Leaderboard.TextColor)
        end
    end
end

CoreGuiModules.Leaderboard.Reset = function()
    local leaderboard = PlayerGui:FindFirstChild("Leaderboard")
    if leaderboard then
        local mainFrame = leaderboard:FindFirstChild("Frame") or leaderboard:FindFirstChild("LeaderboardFrame")
        if mainFrame then
            mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            mainFrame.BackgroundTransparency = 0.5
        end
    end
end

CoreGuiModules.Notifications = {}
CoreGuiModules.Notifications.ApplyTheme = function()
    if not CurrentSettings.CoreGui.Notifications.Enabled then
        return
    end
    
    local notifications = PlayerGui:FindFirstChild("Notifications")
    if not notifications then
        return
    end
    
    for _, descendant in pairs(notifications:GetDescendants()) do
        if descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
            UIUtils.CreateTween(descendant, "BackgroundColor3", CurrentSettings.CoreGui.Notifications.BackgroundColor)
            UIUtils.CreateTween(descendant, "BackgroundTransparency", CurrentSettings.CoreGui.Notifications.Transparency)
            UIUtils.ApplyCornerRadius(descendant, CurrentSettings.CoreGui.Notifications.CornerRadius)
        elseif descendant:IsA("TextLabel") then
            UIUtils.CreateTween(descendant, "TextColor3", CurrentSettings.CoreGui.Notifications.TextColor)
        end
    end
end

CoreGuiModules.Notifications.Reset = function()
    local notifications = PlayerGui:FindFirstChild("Notifications")
    if notifications then
        for _, descendant in pairs(notifications:GetDescendants()) do
            if descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
                descendant.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                descendant.BackgroundTransparency = 0.5
            end
        end
    end
end

-- =========================================================================
-- 8. МОДУЛИ КАСТОМИЗАЦИИ ИГРОВЫХ ИНТЕРФЕЙСОВ (GAMEUI)
-- =========================================================================

local GameUIModules = {}

GameUIModules.CustomFrames = {}
GameUIModules.CustomFrames.ApplyTheme = function()
    if not CurrentSettings.GameUI.CustomFrames.Enabled then
        return
    end
    if CurrentSettings.GameUI.CustomFrames.TargetFrameName == "" then
        return
    end
    
    local targetFrame = PlayerGui:FindFirstChild(CurrentSettings.GameUI.CustomFrames.TargetFrameName)
    if not targetFrame then
        SaveSystem.Log("Фрейм не найден: " .. CurrentSettings.GameUI.CustomFrames.TargetFrameName)
        return
    end
    
    UIUtils.CreateTween(targetFrame, "BackgroundColor3", CurrentSettings.GameUI.CustomFrames.BackgroundColor)
    UIUtils.CreateTween(targetFrame, "BackgroundTransparency", CurrentSettings.GameUI.CustomFrames.Transparency)
    
    if CurrentSettings.Advanced.Glassmorphism.Enabled then
        UIUtils.ApplyGlassmorphism(targetFrame)
    end
    
    UIUtils.ApplyCornerRadius(targetFrame, CurrentSettings.GameUI.CustomFrames.CornerRadius)
end

GameUIModules.CustomFrames.Reset = function()
    if CurrentSettings.GameUI.CustomFrames.TargetFrameName == "" then
        return
    end
    
    local targetFrame = PlayerGui:FindFirstChild(CurrentSettings.GameUI.CustomFrames.TargetFrameName)
    if targetFrame then
        targetFrame.BackgroundTransparency = 0
        local corner = targetFrame:FindFirstChildWhichIsA("UICorner")
        if corner then corner:Destroy() end
    end
end

GameUIModules.Buttons = {}
GameUIModules.Buttons.ApplyTheme = function()
    if not CurrentSettings.GameUI.Buttons.Enabled then
        return
    end
    
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                UIUtils.CreateTween(descendant, "BackgroundColor3", CurrentSettings.GameUI.Buttons.BackgroundColor)
                UIUtils.ApplyCornerRadius(descendant, CurrentSettings.GameUI.Buttons.CornerRadius)
                
                if descendant:IsA("TextButton") then
                    UIUtils.CreateTween(descendant, "TextColor3", CurrentSettings.GameUI.Buttons.TextColor)
                end
                
                descendant.MouseEnter:Connect(function()
                    UIUtils.CreateTween(descendant, "BackgroundColor3", CurrentSettings.GameUI.Buttons.HoverColor)
                end)
                
                descendant.MouseLeave:Connect(function()
                    UIUtils.CreateTween(descendant, "BackgroundColor3", CurrentSettings.GameUI.Buttons.BackgroundColor)
                end)
            end
        end
    end
end

GameUIModules.Buttons.Reset = function()
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                descendant.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                local corner = descendant:FindFirstChildWhichIsA("UICorner")
                if corner then corner:Destroy() end
            end
        end
    end
end

GameUIModules.Labels = {}
GameUIModules.Labels.ApplyTheme = function()
    if not CurrentSettings.GameUI.Labels.Enabled then
        return
    end
    
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("TextLabel") then
                UIUtils.CreateTween(descendant, "TextColor3", CurrentSettings.GameUI.Labels.TextColor)
                UIUtils.ApplyFont(descendant, CurrentSettings.GameUI.Labels.Font)
                UIUtils.ApplyTextSize(descendant, CurrentSettings.GameUI.Labels.TextSize)
            end
        end
    end
end

GameUIModules.Labels.Reset = function()
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("TextLabel") then
                descendant.TextColor3 = Color3.fromRGB(0, 0, 0)
                descendant.Font = Enum.Font.SourceSans
                descendant.TextSize = 14
            end
        end
    end
end

GameUIModules.ImageLabels = {}
GameUIModules.ImageLabels.ApplyTheme = function()
    if not CurrentSettings.GameUI.ImageLabels.Enabled then
        return
    end
    
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("ImageLabel") then
                UIUtils.ApplyCornerRadius(descendant, CurrentSettings.GameUI.ImageLabels.CornerRadius)
                if CurrentSettings.GameUI.ImageLabels.BorderThickness > 0 then
                    UIUtils.ApplyStroke(descendant, CurrentSettings.GameUI.ImageLabels.BorderColor, CurrentSettings.GameUI.ImageLabels.BorderThickness)
                end
            end
        end
    end
end

GameUIModules.ImageLabels.Reset = function()
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("ImageLabel") then
                local corner = descendant:FindFirstChildWhichIsA("UICorner")
                if corner then corner:Destroy() end
                local stroke = descendant:FindFirstChildWhichIsA("UIStroke")
                if stroke then stroke:Destroy() end
            end
        end
    end
end

GameUIModules.ScrollFrames = {}
GameUIModules.ScrollFrames.ApplyTheme = function()
    if not CurrentSettings.GameUI.ScrollFrames.Enabled then
        return
    end
    
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("ScrollingFrame") then
                UIUtils.CreateTween(descendant, "BackgroundColor3", CurrentSettings.GameUI.ScrollFrames.BackgroundColor)
                UIUtils.CreateTween(descendant, "BackgroundTransparency", CurrentSettings.GameUI.ScrollFrames.Transparency)
                UIUtils.ApplyCornerRadius(descendant, CurrentSettings.GameUI.ScrollFrames.CornerRadius)
            end
        end
    end
end

GameUIModules.ScrollFrames.Reset = function()
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("ScrollingFrame") then
                descendant.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                descendant.BackgroundTransparency = 1
                local corner = descendant:FindFirstChildWhichIsA("UICorner")
                if corner then corner:Destroy() end
            end
        end
    end
end

GameUIModules.TextBoxes = {}
GameUIModules.TextBoxes.ApplyTheme = function()
    if not CurrentSettings.GameUI.TextBoxes.Enabled then
        return
    end
    
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("TextBox") then
                UIUtils.CreateTween(descendant, "BackgroundColor3", CurrentSettings.GameUI.TextBoxes.BackgroundColor)
                UIUtils.CreateTween(descendant, "BackgroundTransparency", CurrentSettings.GameUI.TextBoxes.Transparency)
                UIUtils.CreateTween(descendant, "TextColor3", CurrentSettings.GameUI.TextBoxes.TextColor)
                UIUtils.ApplyCornerRadius(descendant, CurrentSettings.GameUI.TextBoxes.CornerRadius)
            end
        end
    end
end

GameUIModules.TextBoxes.Reset = function()
    for _, screenGui in pairs(PlayerGui:GetChildren()) do
        for _, descendant in pairs(screenGui:GetDescendants()) do
            if descendant:IsA("TextBox") then
                descendant.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                descendant.BackgroundTransparency = 0
                descendant.TextColor3 = Color3.fromRGB(0, 0, 0)
                local corner = descendant:FindFirstChildWhichIsA("UICorner")
                if corner then corner:Destroy() end
            end
        end
    end
end

-- =========================================================================
-- 9. СИСТЕМА ПРИМЕНЕНИЯ ТЕМ (THEMESYSTEM)
-- =========================================================================

local ThemeSystem = {}

ThemeSystem.ApplyPreset = function(presetName)
    local preset = DefaultThemes[presetName]
    if not preset then
        SaveSystem.Log("Пресет не найден: " .. tostring(presetName))
        return false
    end
    
    SaveSystem.Log("Применение пресета: " .. preset.Name)
    CurrentSettings.ActiveTheme = presetName
    
    CurrentSettings.CoreGui.Chat.BackgroundColor = preset.BackgroundColor
    CurrentSettings.CoreGui.Chat.TextColor = preset.TextColor
    CurrentSettings.CoreGui.Chat.Transparency = preset.Transparency
    CurrentSettings.CoreGui.Chat.CornerRadius = preset.CornerRadius
    
    CurrentSettings.CoreGui.PlayerList.BackgroundColor = preset.BackgroundColor
    CurrentSettings.CoreGui.PlayerList.TextColor = preset.TextColor
    CurrentSettings.CoreGui.PlayerList.Transparency = preset.Transparency
    CurrentSettings.CoreGui.PlayerList.CornerRadius = preset.CornerRadius
    
    CurrentSettings.CoreGui.Backpack.BackgroundColor = preset.BackgroundColor
    CurrentSettings.CoreGui.Backpack.Transparency = preset.Transparency
    CurrentSettings.CoreGui.Backpack.CornerRadius = preset.CornerRadius
    
    CurrentSettings.CoreGui.HealthBar.BarColor = preset.AccentColor
    CurrentSettings.CoreGui.HealthBar.BackgroundColor = preset.SecondaryColor
    CurrentSettings.CoreGui.HealthBar.Transparency = preset.Transparency
    
    CurrentSettings.CoreGui.Leaderboard.BackgroundColor = preset.BackgroundColor
    CurrentSettings.CoreGui.Leaderboard.TextColor = preset.TextColor
    CurrentSettings.CoreGui.Leaderboard.Transparency = preset.Transparency
    CurrentSettings.CoreGui.Leaderboard.CornerRadius = preset.CornerRadius
    
    CurrentSettings.CoreGui.Notifications.BackgroundColor = preset.BackgroundColor
    CurrentSettings.CoreGui.Notifications.TextColor = preset.TextColor
    CurrentSettings.CoreGui.Notifications.Transparency = preset.Transparency
    CurrentSettings.CoreGui.Notifications.CornerRadius = preset.CornerRadius
    
    CurrentSettings.GameUI.CustomFrames.BackgroundColor = preset.BackgroundColor
    CurrentSettings.GameUI.CustomFrames.Transparency = preset.Transparency
    CurrentSettings.GameUI.CustomFrames.CornerRadius = preset.CornerRadius
    
    CurrentSettings.GameUI.Buttons.BackgroundColor = preset.SecondaryColor
    CurrentSettings.GameUI.Buttons.HoverColor = preset.BackgroundColor
    CurrentSettings.GameUI.Buttons.TextColor = preset.TextColor
    CurrentSettings.GameUI.Buttons.CornerRadius = preset.CornerRadius
    
    CurrentSettings.GameUI.Labels.TextColor = preset.TextColor
    CurrentSettings.GameUI.Labels.Font = preset.Font
    
    CurrentSettings.GameUI.ImageLabels.BorderColor = preset.AccentColor
    CurrentSettings.GameUI.ImageLabels.CornerRadius = preset.CornerRadius
    
    CurrentSettings.GameUI.ScrollFrames.BackgroundColor = preset.SecondaryColor
    CurrentSettings.GameUI.ScrollFrames.Transparency = preset.Transparency
    CurrentSettings.GameUI.ScrollFrames.CornerRadius = preset.CornerRadius
    
    CurrentSettings.GameUI.TextBoxes.BackgroundColor = preset.SecondaryColor
    CurrentSettings.GameUI.TextBoxes.TextColor = preset.TextColor
    CurrentSettings.GameUI.TextBoxes.Transparency = preset.Transparency
    CurrentSettings.GameUI.TextBoxes.CornerRadius = preset.CornerRadius
    
    return true
end

ThemeSystem.ApplyAll = function()
    SaveSystem.Log("Применение всех настроек темы...")
    CoreGuiModules.Chat.ApplyTheme()
    CoreGuiModules.PlayerList.ApplyTheme()
    CoreGuiModules.Backpack.ApplyTheme()
    CoreGuiModules.HealthBar.ApplyTheme()
    CoreGuiModules.Leaderboard.ApplyTheme()
    CoreGuiModules.Notifications.ApplyTheme()
    
    GameUIModules.CustomFrames.ApplyTheme()
    GameUIModules.Buttons.ApplyTheme()
    GameUIModules.Labels.ApplyTheme()
    GameUIModules.ImageLabels.ApplyTheme()
    GameUIModules.ScrollFrames.ApplyTheme()
    GameUIModules.TextBoxes.ApplyTheme()
end

ThemeSystem.ResetAll = function()
    SaveSystem.Log("Сброс всех примененных тем...")
    CoreGuiModules.Chat.Reset()
    CoreGuiModules.PlayerList.Reset()
    CoreGuiModules.Backpack.Reset()
    CoreGuiModules.HealthBar.Reset()
    CoreGuiModules.Leaderboard.Reset()
    CoreGuiModules.Notifications.Reset()
    
    GameUIModules.CustomFrames.Reset()
    GameUIModules.Buttons.Reset()
    GameUIModules.Labels.Reset()
    GameUIModules.ImageLabels.Reset()
    GameUIModules.ScrollFrames.Reset()
    GameUIModules.TextBoxes.Reset()
end

-- =========================================================================
-- 10. ПОСТРОЕНИЕ ИНТЕРФЕЙСА RAYFIELD
-- =========================================================================

local Window = Rayfield:CreateWindow({
    Name = "UI Theme Injector",
    LoadingTitle = "Загрузка интерфейса...",
    LoadingSubtitle = "by Winion (@Winion)",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UIThemeInjector",
        FileName = "Settings_" .. LocalPlayer.Name
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Вкладка 1: Пресеты тем
local PresetsTab = Window:CreateTab("Пресеты тем", 4483362458)

local PresetSection = PresetsTab:CreateSection("Выбор готовой темы")

for presetName, presetData in pairs(DefaultThemes) do
    PresetsTab:CreateButton({
        Name = "Применить: " .. presetData.Name,
        Callback = function()
            if ThemeSystem.ApplyPreset(presetName) then
                ThemeSystem.ApplyAll()
                SaveSystem.Save()
                Rayfield:Notify({
                    Title = "Тема применена",
                    Content = "Успешно применена тема: " .. presetData.Name,
                    Duration = 3,
                    Image = 4483362458
                })
            end
        end
    })
end

local ManagementSection = PresetsTab:CreateSection("Управление")

PresetsTab:CreateButton({
    Name = "Сбросить все настройки",
    Callback = function()
        ThemeSystem.ResetAll()
        SaveSystem.Reset()
        Rayfield:Notify({
            Title = "Настройки сброшены",
            Content = "Все настройки возвращены к значениям по умолчанию",
            Duration = 3,
            Image = 4483362458
        })
    end
})

PresetsTab:CreateButton({
    Name = "Сохранить текущие настройки",
    Callback = function()
        SaveSystem.Save()
        Rayfield:Notify({
            Title = "Сохранено",
            Content = "Текущие настройки успешно сохранены",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Вкладка 2: CoreGui настройки
local CoreGUITab = Window:CreateTab("CoreGui", 4483362458)

local ChatSection = CoreGUITab:CreateSection("Чат")

CoreGUITab:CreateToggle({
    Name = "Включить кастомизацию чата",
    CurrentValue = CurrentSettings.CoreGui.Chat.Enabled,
    Flag = "ChatEnabled",
    Callback = function(value)
        CurrentSettings.CoreGui.Chat.Enabled = value
        if value then
            CoreGuiModules.Chat.ApplyTheme()
        else
            CoreGuiModules.Chat.Reset()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateColorPicker({
    Name = "Цвет фона чата",
    Color = CurrentSettings.CoreGui.Chat.BackgroundColor,
    Flag = "ChatBackgroundColor",
    Callback = function(color)
        CurrentSettings.CoreGui.Chat.BackgroundColor = color
        if CurrentSettings.CoreGui.Chat.Enabled then
            CoreGuiModules.Chat.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateColorPicker({
    Name = "Цвет текста чата",
    Color = CurrentSettings.CoreGui.Chat.TextColor,
    Flag = "ChatTextColor",
    Callback = function(color)
        CurrentSettings.CoreGui.Chat.TextColor = color
        if CurrentSettings.CoreGui.Chat.Enabled then
            CoreGuiModules.Chat.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateSlider({
    Name = "Прозрачность чата",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = CurrentSettings.CoreGui.Chat.Transparency,
    Flag = "ChatTransparency",
    Callback = function(value)
        CurrentSettings.CoreGui.Chat.Transparency = value
        if CurrentSettings.CoreGui.Chat.Enabled then
            CoreGuiModules.Chat.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateSlider({
    Name = "Радиус скругления чата",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = CurrentSettings.CoreGui.Chat.CornerRadius,
    Flag = "ChatCornerRadius",
    Callback = function(value)
        CurrentSettings.CoreGui.Chat.CornerRadius = value
        if CurrentSettings.CoreGui.Chat.Enabled then
            CoreGuiModules.Chat.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

local PlayerListSection = CoreGUITab:CreateSection("Список игроков")

CoreGUITab:CreateToggle({
    Name = "Включить кастомизацию списка игроков",
    CurrentValue = CurrentSettings.CoreGui.PlayerList.Enabled,
    Flag = "PlayerListEnabled",
    Callback = function(value)
        CurrentSettings.CoreGui.PlayerList.Enabled = value
        if value then
            CoreGuiModules.PlayerList.ApplyTheme()
        else
            CoreGuiModules.PlayerList.Reset()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateColorPicker({
    Name = "Цвет фона списка игроков",
    Color = CurrentSettings.CoreGui.PlayerList.BackgroundColor,
    Flag = "PlayerListBackgroundColor",
    Callback = function(color)
        CurrentSettings.CoreGui.PlayerList.BackgroundColor = color
        if CurrentSettings.CoreGui.PlayerList.Enabled then
            CoreGuiModules.PlayerList.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateColorPicker({
    Name = "Цвет текста списка игроков",
    Color = CurrentSettings.CoreGui.PlayerList.TextColor,
    Flag = "PlayerListTextColor",
    Callback = function(color)
        CurrentSettings.CoreGui.PlayerList.TextColor = color
        if CurrentSettings.CoreGui.PlayerList.Enabled then
            CoreGuiModules.PlayerList.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateSlider({
    Name = "Прозрачность списка игроков",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = CurrentSettings.CoreGui.PlayerList.Transparency,
    Flag = "PlayerListTransparency",
    Callback = function(value)
        CurrentSettings.CoreGui.PlayerList.Transparency = value
        if CurrentSettings.CoreGui.PlayerList.Enabled then
            CoreGuiModules.PlayerList.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

local BackpackSection = CoreGUITab:CreateSection("Инвентарь")

CoreGUITab:CreateToggle({
    Name = "Включить кастомизацию инвентаря",
    CurrentValue = CurrentSettings.CoreGui.Backpack.Enabled,
    Flag = "BackpackEnabled",
    Callback = function(value)
        CurrentSettings.CoreGui.Backpack.Enabled = value
        if value then
            CoreGuiModules.Backpack.ApplyTheme()
        else
            CoreGuiModules.Backpack.Reset()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateColorPicker({
    Name = "Цвет фона инвентаря",
    Color = CurrentSettings.CoreGui.Backpack.BackgroundColor,
    Flag = "BackpackBackgroundColor",
    Callback = function(color)
        CurrentSettings.CoreGui.Backpack.BackgroundColor = color
        if CurrentSettings.CoreGui.Backpack.Enabled then
            CoreGuiModules.Backpack.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateSlider({
    Name = "Прозрачность инвентаря",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = CurrentSettings.CoreGui.Backpack.Transparency,
    Flag = "BackpackTransparency",
    Callback = function(value)
        CurrentSettings.CoreGui.Backpack.Transparency = value
        if CurrentSettings.CoreGui.Backpack.Enabled then
            CoreGuiModules.Backpack.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

local HealthBarSection = CoreGUITab:CreateSection("Полоса здоровья")

CoreGUITab:CreateToggle({
    Name = "Включить кастомизацию полосы здоровья",
    CurrentValue = CurrentSettings.CoreGui.HealthBar.Enabled,
    Flag = "HealthBarEnabled",
    Callback = function(value)
        CurrentSettings.CoreGui.HealthBar.Enabled = value
        if value then
            CoreGuiModules.HealthBar.ApplyTheme()
        else
            CoreGuiModules.HealthBar.Reset()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateColorPicker({
    Name = "Цвет полосы здоровья",
    Color = CurrentSettings.CoreGui.HealthBar.BarColor,
    Flag = "HealthBarColor",
    Callback = function(color)
        CurrentSettings.CoreGui.HealthBar.BarColor = color
        if CurrentSettings.CoreGui.HealthBar.Enabled then
            CoreGuiModules.HealthBar.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

CoreGUITab:CreateColorPicker({
    Name = "Цвет фона полосы здоровья",
    Color = CurrentSettings.CoreGui.HealthBar.BackgroundColor,
    Flag = "HealthBarBackgroundColor",
    Callback = function(color)
        CurrentSettings.CoreGui.HealthBar.BackgroundColor = color
        if CurrentSettings.CoreGui.HealthBar.Enabled then
            CoreGuiModules.HealthBar.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

-- Вкладка 3: Игровые интерфейсы
local GameUITab = Window:CreateTab("Игровые UI", 4483362458)

local CustomFramesSection = GameUITab:CreateSection("Кастомные фреймы")

GameUITab:CreateToggle({
    Name = "Включить кастомизацию фреймов",
    CurrentValue = CurrentSettings.GameUI.CustomFrames.Enabled,
    Flag = "CustomFramesEnabled",
    Callback = function(value)
        CurrentSettings.GameUI.CustomFrames.Enabled = value
        if value then
            GameUIModules.CustomFrames.ApplyTheme()
        else
            GameUIModules.CustomFrames.Reset()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateInput({
    Name = "Имя целевого фрейма",
    CurrentValue = CurrentSettings.GameUI.CustomFrames.TargetFrameName or "",
    PlaceholderText = "Например: ShopFrame",
    Flag = "TargetFrameName",
    Callback = function(value)
        CurrentSettings.GameUI.CustomFrames.TargetFrameName = value or ""
        SaveSystem.Save()
    end
})

GameUITab:CreateColorPicker({
    Name = "Цвет фона фрейма",
    Color = CurrentSettings.GameUI.CustomFrames.BackgroundColor,
    Flag = "CustomFrameBackgroundColor",
    Callback = function(color)
        CurrentSettings.GameUI.CustomFrames.BackgroundColor = color
        if CurrentSettings.GameUI.CustomFrames.Enabled then
            GameUIModules.CustomFrames.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateSlider({
    Name = "Прозрачность фрейма",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = CurrentSettings.GameUI.CustomFrames.Transparency,
    Flag = "CustomFrameTransparency",
    Callback = function(value)
        CurrentSettings.GameUI.CustomFrames.Transparency = value
        if CurrentSettings.GameUI.CustomFrames.Enabled then
            GameUIModules.CustomFrames.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

local ButtonsSection = GameUITab:CreateSection("Кнопки")

GameUITab:CreateToggle({
    Name = "Включить кастомизацию кнопок",
    CurrentValue = CurrentSettings.GameUI.Buttons.Enabled,
    Flag = "ButtonsEnabled",
    Callback = function(value)
        CurrentSettings.GameUI.Buttons.Enabled = value
        if value then
            GameUIModules.Buttons.ApplyTheme()
        else
            GameUIModules.Buttons.Reset()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateColorPicker({
    Name = "Цвет фона кнопок",
    Color = CurrentSettings.GameUI.Buttons.BackgroundColor,
    Flag = "ButtonBackgroundColor",
    Callback = function(color)
        CurrentSettings.GameUI.Buttons.BackgroundColor = color
        if CurrentSettings.GameUI.Buttons.Enabled then
            GameUIModules.Buttons.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateColorPicker({
    Name = "Цвет при наведении",
    Color = CurrentSettings.GameUI.Buttons.HoverColor,
    Flag = "ButtonHoverColor",
    Callback = function(color)
        CurrentSettings.GameUI.Buttons.HoverColor = color
        SaveSystem.Save()
    end
})

GameUITab:CreateColorPicker({
    Name = "Цвет текста кнопок",
    Color = CurrentSettings.GameUI.Buttons.TextColor,
    Flag = "ButtonTextColor",
    Callback = function(color)
        CurrentSettings.GameUI.Buttons.TextColor = color
        if CurrentSettings.GameUI.Buttons.Enabled then
            GameUIModules.Buttons.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

local LabelsSection = GameUITab:CreateSection("Текстовые метки")

GameUITab:CreateToggle({
    Name = "Включить кастомизацию меток",
    CurrentValue = CurrentSettings.GameUI.Labels.Enabled,
    Flag = "LabelsEnabled",
    Callback = function(value)
        CurrentSettings.GameUI.Labels.Enabled = value
        if value then
            GameUIModules.Labels.ApplyTheme()
        else
            GameUIModules.Labels.Reset()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateColorPicker({
    Name = "Цвет текста меток",
    Color = CurrentSettings.GameUI.Labels.TextColor,
    Flag = "LabelTextColor",
    Callback = function(color)
        CurrentSettings.GameUI.Labels.TextColor = color
        if CurrentSettings.GameUI.Labels.Enabled then
            GameUIModules.Labels.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateDropdown({
    Name = "Шрифт меток",
    Options = {"Gotham", "GothamBold", "GothamMedium", "SourceSans", "Code"},
    CurrentValue = "GothamBold",
    Flag = "LabelFont",
    Callback = function(value)
        local fontMap = {
            ["Gotham"] = Enum.Font.Gotham,
            ["GothamBold"] = Enum.Font.GothamBold,
            ["GothamMedium"] = Enum.Font.GothamMedium,
            ["SourceSans"] = Enum.Font.SourceSans,
            ["Code"] = Enum.Font.Code
        }
        CurrentSettings.GameUI.Labels.Font = fontMap[value] or Enum.Font.GothamBold
        if CurrentSettings.GameUI.Labels.Enabled then
            GameUIModules.Labels.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateSlider({
    Name = "Размер текста меток",
    Range = {8, 32},
    Increment = 1,
    CurrentValue = CurrentSettings.GameUI.Labels.TextSize,
    Flag = "LabelTextSize",
    Callback = function(value)
        CurrentSettings.GameUI.Labels.TextSize = value
        if CurrentSettings.GameUI.Labels.Enabled then
            GameUIModules.Labels.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

local ImageLabelsSection = GameUITab:CreateSection("Изображения (ImageLabels)")

GameUITab:CreateToggle({
    Name = "Включить кастомизацию изображений",
    CurrentValue = CurrentSettings.GameUI.ImageLabels.Enabled,
    Flag = "ImageLabelsEnabled",
    Callback = function(value)
        CurrentSettings.GameUI.ImageLabels.Enabled = value
        if value then
            GameUIModules.ImageLabels.ApplyTheme()
        else
            GameUIModules.ImageLabels.Reset()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateColorPicker({
    Name = "Цвет рамки изображения",
    Color = CurrentSettings.GameUI.ImageLabels.BorderColor,
    Flag = "ImageLabelBorderColor",
    Callback = function(color)
        CurrentSettings.GameUI.ImageLabels.BorderColor = color
        if CurrentSettings.GameUI.ImageLabels.Enabled then
            GameUIModules.ImageLabels.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

GameUITab:CreateSlider({
    Name = "Толщина рамки изображения",
    Range = {0, 10},
    Increment = 1,
    CurrentValue = CurrentSettings.GameUI.ImageLabels.BorderThickness,
    Flag = "ImageLabelBorderThickness",
    Callback = function(value)
        CurrentSettings.GameUI.ImageLabels.BorderThickness = value
        if CurrentSettings.GameUI.ImageLabels.Enabled then
            GameUIModules.ImageLabels.ApplyTheme()
        end
        SaveSystem.Save()
    end
})

-- Вкладка 4: Расширенные настройки
local AdvancedTab = Window:CreateTab("Расширенные", 4483362458)

local GlassmorphismSection = AdvancedTab:CreateSection("Эффект стекла (Glassmorphism)")

AdvancedTab:CreateToggle({
    Name = "Включить Glassmorphism",
    CurrentValue = CurrentSettings.Advanced.Glassmorphism.Enabled,
    Flag = "GlassmorphismEnabled",
    Callback = function(value)
        CurrentSettings.Advanced.Glassmorphism.Enabled = value
        ThemeSystem.ApplyAll()
        SaveSystem.Save()
    end
})

AdvancedTab:CreateSlider({
    Name = "Размер размытия",
    Range = {0, 30},
    Increment = 1,
    CurrentValue = CurrentSettings.Advanced.Glassmorphism.BlurSize,
    Flag = "BlurSize",
    Callback = function(value)
        CurrentSettings.Advanced.Glassmorphism.BlurSize = value
        ThemeSystem.ApplyAll()
        SaveSystem.Save()
    end
})

AdvancedTab:CreateSlider({
    Name = "Прозрачность стекла",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = CurrentSettings.Advanced.Glassmorphism.Transparency,
    Flag = "GlassTransparency",
    Callback = function(value)
        CurrentSettings.Advanced.Glassmorphism.Transparency = value
        ThemeSystem.ApplyAll()
        SaveSystem.Save()
    end
})

local AnimationsSection = AdvancedTab:CreateSection("Анимации")

AdvancedTab:CreateToggle({
    Name = "Включить анимации",
    CurrentValue = CurrentSettings.Advanced.Animations.Enabled,
    Flag = "AnimationsEnabled",
    Callback = function(value)
        CurrentSettings.Advanced.Animations.Enabled = value
        SaveSystem.Save()
    end
})

AdvancedTab:CreateSlider({
    Name = "Скорость анимации наведения",
    Range = {0.1, 1.0},
    Increment = 0.05,
    CurrentValue = CurrentSettings.Advanced.Animations.HoverSpeed,
    Flag = "HoverSpeed",
    Callback = function(value)
        CurrentSettings.Advanced.Animations.HoverSpeed = value
        SaveSystem.Save()
    end
})

local ResponsiveSection = AdvancedTab:CreateSection("Адаптивность")

AdvancedTab:CreateToggle({
    Name = "Включить адаптивный режим",
    CurrentValue = CurrentSettings.Advanced.Responsive.Enabled,
    Flag = "ResponsiveEnabled",
    Callback = function(value)
        CurrentSettings.Advanced.Responsive.Enabled = value
        SaveSystem.Save()
    end
})

AdvancedTab:CreateSlider({
    Name = "Масштаб для мобильных",
    Range = {0.5, 1.5},
    Increment = 0.1,
    CurrentValue = CurrentSettings.Advanced.Responsive.MobileScale,
    Flag = "MobileScale",
    Callback = function(value)
        CurrentSettings.Advanced.Responsive.MobileScale = value
        SaveSystem.Save()
    end
})

AdvancedTab:CreateSlider({
    Name = "Масштаб для планшетов",
    Range = {0.5, 1.5},
    Increment = 0.1,
    CurrentValue = CurrentSettings.Advanced.Responsive.TabletScale,
    Flag = "TabletScale",
    Callback = function(value)
        CurrentSettings.Advanced.Responsive.TabletScale = value
        SaveSystem.Save()
    end
})

AdvancedTab:CreateSlider({
    Name = "Масштаб для ПК",
    Range = {0.5, 1.5},
    Increment = 0.1,
    CurrentValue = CurrentSettings.Advanced.Responsive.DesktopScale,
    Flag = "DesktopScale",
    Callback = function(value)
        CurrentSettings.Advanced.Responsive.DesktopScale = value
        SaveSystem.Save()
    end
})

local LoggingSection = AdvancedTab:CreateSection("Логирование")

AdvancedTab:CreateToggle({
    Name = "Включить логирование в Output",
    CurrentValue = CurrentSettings.Advanced.Logging.PrintToOutput,
    Flag = "LoggingEnabled",
    Callback = function(value)
        CurrentSettings.Advanced.Logging.PrintToOutput = value
        SaveSystem.Save()
    end
})

-- Вкладка 5: Информация
local InfoTab = Window:CreateTab("Информация", 4483362458)

local InfoSection = InfoTab:CreateSection("О скрипте")

InfoTab:CreateParagraph({
    Title = "UI Theme Injector",
    Content = "Профессиональный инструмент для кастомизации интерфейсов Roblox. Поддерживает настройку CoreGui элементов и игровых интерфейсов с использованием современных эффектов Glassmorphism."
})

InfoTab:CreateParagraph({
    Title = "Возможности",
    Content = "- 10 готовых пресетов тем\n- Детальная настройка цветов и прозрачности\n- Эффект стекла (Glassmorphism)\n- Плавные анимации\n- Адаптация под мобильные устройства\n- Система сохранения настроек\n- Кастомизация игровых интерфейсов"
})

InfoTab:CreateParagraph({
    Title = "Автор",
    Content = "Winion (@Winion)\nВерсия: 2.0.0 (Full Verbose)\nДата: 2026"
})

InfoTab:CreateParagraph({
    Title = "Тип устройства",
    Content = "Текущее устройство: " .. UIUtils.GetDeviceType() .. "\nМасштаб: " .. UIUtils.GetScaleFactor()
})

-- =========================================================================
-- 11. ИНИЦИАЛИЗАЦИЯ И ОБРАБОТЧИКИ СОБЫТИЙ
-- =========================================================================

local function Initialize()
    SaveSystem.Log("Инициализация скрипта UI Theme Injector...")
    
    local loaded = SaveSystem.Load()
    if loaded then
        SaveSystem.Log("Настройки загружены из файла сохранения.")
        ThemeSystem.ApplyAll()
    else
        SaveSystem.Log("Применение темы по умолчанию (DarkRed).")
        ThemeSystem.ApplyPreset("DarkRed")
        ThemeSystem.ApplyAll()
    end
    
    SaveSystem.Log("Интерфейс успешно инициализирован.")
    SaveSystem.Log("Тип устройства: " .. UIUtils.GetDeviceType())
end

task.spawn(Initialize)

if CurrentSettings.GameUI.Buttons.Enabled or CurrentSettings.GameUI.Labels.Enabled or CurrentSettings.GameUI.ImageLabels.Enabled or CurrentSettings.GameUI.ScrollFrames.Enabled or CurrentSettings.GameUI.TextBoxes.Enabled then
    PlayerGui.ChildAdded:Connect(function(child)
        task.wait(0.5)
        if CurrentSettings.GameUI.Buttons.Enabled then
            GameUIModules.Buttons.ApplyTheme()
        end
        if CurrentSettings.GameUI.Labels.Enabled then
            GameUIModules.Labels.ApplyTheme()
        end
        if CurrentSettings.GameUI.ImageLabels.Enabled then
            GameUIModules.ImageLabels.ApplyTheme()
        end
        if CurrentSettings.GameUI.ScrollFrames.Enabled then
            GameUIModules.ScrollFrames.ApplyTheme()
        end
        if CurrentSettings.GameUI.TextBoxes.Enabled then
            GameUIModules.TextBoxes.ApplyTheme()
        end
    end)
end

Services.UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        task.wait(0.1)
        if CurrentSettings.Advanced.Responsive.Enabled then
            local newScale = UIUtils.GetScaleFactor()
            SaveSystem.Log("Масштаб обновлен: " .. tostring(newScale))
        end
    end
end)

SaveSystem.Log("Скрипт полностью загружен и готов к работе.")

-- =========================================================================
-- КОНЕЦ СКРИПТА
-- =========================================================================