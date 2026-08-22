--[[
    ====================================================================
    UI Theme Injector | Rayfield Edition
    Автор: Winion (@Winion)
    Назначение: Профессиональная кастомизация интерфейсов Roblox
    Библиотека: Rayfield UI
    ====================================================================
]]

-- // 1. Подключение Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // 2. Сервисы и переменные
local Services = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    StarterGui = game:GetService("StarterGui"),
    Lighting = game:GetService("Lighting"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // 3. Конфигурация тем по умолчанию
local DefaultThemes = {
    DarkRed = {
        Name = "Dark Red Neon",
        BackgroundColor = Color3.fromRGB(25, 25, 30),
        AccentColor = Color3.fromRGB(255, 50, 50),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryColor = Color3.fromRGB(45, 45, 55),
        Transparency = 0.1,
        CornerRadius = 12,
        Font = Enum.Font.GothamBold
    },
    CyberPunk = {
        Name = "Cyberpunk",
        BackgroundColor = Color3.fromRGB(20, 20, 35),
        AccentColor = Color3.fromRGB(0, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryColor = Color3.fromRGB(40, 40, 60),
        Transparency = 0.15,
        CornerRadius = 8,
        Font = Enum.Font.Code
    },
    Minimalist = {
        Name = "Minimalist White",
        BackgroundColor = Color3.fromRGB(250, 250, 250),
        AccentColor = Color3.fromRGB(0, 120, 215),
        TextColor = Color3.fromRGB(30, 30, 30),
        SecondaryColor = Color3.fromRGB(240, 240, 240),
        Transparency = 0.05,
        CornerRadius = 4,
        Font = Enum.Font.Gotham
    },
    Matrix = {
        Name = "Matrix Green",
        BackgroundColor = Color3.fromRGB(0, 10, 0),
        AccentColor = Color3.fromRGB(0, 255, 0),
        TextColor = Color3.fromRGB(0, 255, 0),
        SecondaryColor = Color3.fromRGB(0, 30, 0),
        Transparency = 0.2,
        CornerRadius = 0,
        Font = Enum.Font.Code
    },
    Sunset = {
        Name = "Sunset Orange",
        BackgroundColor = Color3.fromRGB(30, 20, 40),
        AccentColor = Color3.fromRGB(255, 140, 50),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryColor = Color3.fromRGB(50, 35, 60),
        Transparency = 0.1,
        CornerRadius = 10,
        Font = Enum.Font.GothamMedium
    }
}

-- // 4. Текущие настройки (загружаются из сохранений или defaults)
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
            DesktopScale = 1.0
        }
    }
}

-- // 5. Система сохранения настроек
local SaveSystem = {
    SaveKey = "UIThemeInjector_Settings_v1",
    
    -- Найдите функцию Save и замените:
Save = function()
    local success, err = pcall(function()
        local data = Services.HttpService:JSONEncode(CurrentSettings)
        writefile(SaveSystem.SaveKey, data)
    end)
    if not success then
        warn("[UIThemeInjector] Ошибка сохранения настроек: " .. tostring(err))
    end
end,

-- И функцию Load:
Load = function()
    local success, data = pcall(function()
        if isfile(SaveSystem.SaveKey) then
            local fileContent = readfile(SaveSystem.SaveKey)
            return Services.HttpService:JSONDecode(fileContent)
        end
        return nil
    end)
    
    if success and data then
        CurrentSettings = data
        return true
    end
    return false
end,
    
    Reset = function()
        local success = pcall(function()
            if isfile(SaveSystem.SaveKey) then
                delfile(SaveSystem.SaveKey)
            end
        end)
        return success
    end
}

-- // 6. Утилиты для работы с UI
local UIUtils = {
    GetDeviceType = function()
        local viewportSize = Services.Workspace.CurrentCamera.ViewportSize
        if viewportSize.X < 800 then
            return "Mobile"
        elseif viewportSize.X < 1200 then
            return "Tablet"
        else
            return "Desktop"
        end
    end,
    
    GetScaleFactor = function()
        local deviceType = UIUtils.GetDeviceType()
        if deviceType == "Mobile" then
            return CurrentSettings.Advanced.Responsive.MobileScale
        else
            return CurrentSettings.Advanced.Responsive.DesktopScale
        end
    end,
    
    ApplyGlassmorphism = function(instance, blurSize, transparency)
        if not CurrentSettings.Advanced.Glassmorphism.Enabled then return end
        
        local blur = Instance.new("BlurEffect")
        blur.Size = blurSize or CurrentSettings.Advanced.Glassmorphism.BlurSize
        blur.Parent = instance
        
        instance.BackgroundTransparency = transparency or CurrentSettings.Advanced.Glassmorphism.Transparency
    end,
    
    ApplyCornerRadius = function(instance, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or CurrentSettings.CoreGui.Chat.CornerRadius)
        corner.Parent = instance
    end,
    
    ApplyStroke = function(instance, color, thickness)
        local stroke = Instance.new("UIStroke")
        stroke.Color = color or Color3.fromRGB(60, 60, 70)
        stroke.Thickness = thickness or 1
        stroke.Parent = instance
    end,
    
    CreateTween = function(instance, property, value, duration)
        if not CurrentSettings.Advanced.Animations.Enabled then
            instance[property] = value
            return
        end
        
        local tweenInfo = TweenInfo.new(
            duration or CurrentSettings.Advanced.Animations.HoverSpeed,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local tween = Services.TweenService:Create(instance, tweenInfo, {[property] = value})
        tween:Play()
        return tween
    end
}

-- // 7. Модули кастомизации CoreGui
local CoreGuiModules = {
    Chat = {
        ApplyTheme = function()
            if not CurrentSettings.CoreGui.Chat.Enabled then return end
            
            local chatFrame = PlayerGui:FindFirstChild("Chat")
            if not chatFrame then return end
            
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
                for _, label in pairs(chatMessages:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        UIUtils.CreateTween(label, "TextColor3", CurrentSettings.CoreGui.Chat.TextColor)
                    end
                end
            end
        end,
        
        Reset = function()
            local chatFrame = PlayerGui:FindFirstChild("Chat")
            if chatFrame then
                local mainFrame = chatFrame:FindFirstChild("Frame") or chatFrame:FindFirstChild("ChatFrame")
                if mainFrame then
                    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    mainFrame.BackgroundTransparency = 0.5
                end
            end
        end
    },
    
    PlayerList = {
        ApplyTheme = function()
            if not CurrentSettings.CoreGui.PlayerList.Enabled then return end
            
            local playerList = PlayerGui:FindFirstChild("PlayerList")
            if not playerList then return end
            
            local mainFrame = playerList:FindFirstChild("Frame") or playerList:FindFirstChild("PlayerListFrame")
            if mainFrame then
                UIUtils.CreateTween(mainFrame, "BackgroundColor3", CurrentSettings.CoreGui.PlayerList.BackgroundColor)
                UIUtils.CreateTween(mainFrame, "BackgroundTransparency", CurrentSettings.CoreGui.PlayerList.Transparency)
                
                if CurrentSettings.Advanced.Glassmorphism.Enabled then
                    UIUtils.ApplyGlassmorphism(mainFrame)
                end
                
                UIUtils.ApplyCornerRadius(mainFrame, CurrentSettings.CoreGui.PlayerList.CornerRadius)
            end
            
            for _, label in pairs(playerList:GetDescendants()) do
                if label:IsA("TextLabel") then
                    UIUtils.CreateTween(label, "TextColor3", CurrentSettings.CoreGui.PlayerList.TextColor)
                end
            end
        end,
        
        Reset = function()
            local playerList = PlayerGui:FindFirstChild("PlayerList")
            if playerList then
                local mainFrame = playerList:FindFirstChild("Frame") or playerList:FindFirstChild("PlayerListFrame")
                if mainFrame then
                    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    mainFrame.BackgroundTransparency = 0.5
                end
            end
        end
    },
    
    Backpack = {
        ApplyTheme = function()
            if not CurrentSettings.CoreGui.Backpack.Enabled then return end
            
            local backpack = PlayerGui:FindFirstChild("Backpack")
            if not backpack then return end
            
            local mainFrame = backpack:FindFirstChild("Frame") or backpack:FindFirstChild("BackpackFrame")
            if mainFrame then
                UIUtils.CreateTween(mainFrame, "BackgroundColor3", CurrentSettings.CoreGui.Backpack.BackgroundColor)
                UIUtils.CreateTween(mainFrame, "BackgroundTransparency", CurrentSettings.CoreGui.Backpack.Transparency)
                
                if CurrentSettings.Advanced.Glassmorphism.Enabled then
                    UIUtils.ApplyGlassmorphism(mainFrame)
                end
                
                UIUtils.ApplyCornerRadius(mainFrame, CurrentSettings.CoreGui.Backpack.CornerRadius)
            end
        end,
        
        Reset = function()
            local backpack = PlayerGui:FindFirstChild("Backpack")
            if backpack then
                local mainFrame = backpack:FindFirstChild("Frame") or backpack:FindFirstChild("BackpackFrame")
                if mainFrame then
                    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    mainFrame.BackgroundTransparency = 0.5
                end
            end
        end
    },
    
    HealthBar = {
        ApplyTheme = function()
            if not CurrentSettings.CoreGui.HealthBar.Enabled then return end
            
            local healthBar = PlayerGui:FindFirstChild("Health")
            if not healthBar then return end
            
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
        end,
        
        Reset = function()
            local healthBar = PlayerGui:FindFirstChild("Health")
            if healthBar then
                local bar = healthBar:FindFirstChild("Bar") or healthBar:FindFirstChild("HealthBar")
                if bar then
                    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    }
}

-- // 8. Модули кастомизации игровых интерфейсов
local GameUIModules = {
    CustomFrames = {
        ApplyTheme = function()
            if not CurrentSettings.GameUI.CustomFrames.Enabled then return end
            if CurrentSettings.GameUI.CustomFrames.TargetFrameName == "" then return end
            
            local targetFrame = PlayerGui:FindFirstChild(CurrentSettings.GameUI.CustomFrames.TargetFrameName)
            if not targetFrame then
                warn("[UIThemeInjector] Фрейм не найден: " .. CurrentSettings.GameUI.CustomFrames.TargetFrameName)
                return
            end
            
            UIUtils.CreateTween(targetFrame, "BackgroundColor3", CurrentSettings.GameUI.CustomFrames.BackgroundColor)
            UIUtils.CreateTween(targetFrame, "BackgroundTransparency", CurrentSettings.GameUI.CustomFrames.Transparency)
            
            if CurrentSettings.Advanced.Glassmorphism.Enabled then
                UIUtils.ApplyGlassmorphism(targetFrame)
            end
            
            UIUtils.ApplyCornerRadius(targetFrame, CurrentSettings.GameUI.CustomFrames.CornerRadius)
        end,
        
        Reset = function()
            if CurrentSettings.GameUI.CustomFrames.TargetFrameName == "" then return end
            
            local targetFrame = PlayerGui:FindFirstChild(CurrentSettings.GameUI.CustomFrames.TargetFrameName)
            if targetFrame then
                targetFrame.BackgroundTransparency = 0
            end
        end
    },
    
    Buttons = {
        ApplyTheme = function()
            if not CurrentSettings.GameUI.Buttons.Enabled then return end
            
            for _, screenGui in pairs(PlayerGui:GetChildren()) do
                for _, button in pairs(screenGui:GetDescendants()) do
                    if button:IsA("TextButton") or button:IsA("ImageButton") then
                        UIUtils.CreateTween(button, "BackgroundColor3", CurrentSettings.GameUI.Buttons.BackgroundColor)
                        UIUtils.ApplyCornerRadius(button, CurrentSettings.GameUI.Buttons.CornerRadius)
                        
                        if button:IsA("TextButton") then
                            UIUtils.CreateTween(button, "TextColor3", CurrentSettings.GameUI.Buttons.TextColor)
                        end
                        
                        button.MouseEnter:Connect(function()
                            UIUtils.CreateTween(button, "BackgroundColor3", CurrentSettings.GameUI.Buttons.HoverColor)
                        end)
                        
                        button.MouseLeave:Connect(function()
                            UIUtils.CreateTween(button, "BackgroundColor3", CurrentSettings.GameUI.Buttons.BackgroundColor)
                        end)
                    end
                end
            end
        end,
        
        Reset = function()
            for _, screenGui in pairs(PlayerGui:GetChildren()) do
                for _, button in pairs(screenGui:GetDescendants()) do
                    if button:IsA("TextButton") or button:IsA("ImageButton") then
                        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
    },
    
    Labels = {
        ApplyTheme = function()
            if not CurrentSettings.GameUI.Labels.Enabled then return end
            
            for _, screenGui in pairs(PlayerGui:GetChildren()) do
                for _, label in pairs(screenGui:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        UIUtils.CreateTween(label, "TextColor3", CurrentSettings.GameUI.Labels.TextColor)
                        label.Font = CurrentSettings.GameUI.Labels.Font
                        label.TextSize = CurrentSettings.GameUI.Labels.TextSize
                    end
                end
            end
        end,
        
        Reset = function()
            for _, screenGui in pairs(PlayerGui:GetChildren()) do
                for _, label in pairs(screenGui:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        label.TextColor3 = Color3.fromRGB(0, 0, 0)
                        label.Font = Enum.Font.SourceSans
                        label.TextSize = 14
                    end
                end
            end
        end
    }
}

-- // 9. Система применения тем
local ThemeSystem = {
    ApplyPreset = function(presetName)
        local preset = DefaultThemes[presetName]
        if not preset then
            warn("[UIThemeInjector] Пресет не найден: " .. presetName)
            return false
        end
        
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
        
        CurrentSettings.GameUI.CustomFrames.BackgroundColor = preset.BackgroundColor
        CurrentSettings.GameUI.CustomFrames.Transparency = preset.Transparency
        CurrentSettings.GameUI.CustomFrames.CornerRadius = preset.CornerRadius
        
        CurrentSettings.GameUI.Buttons.BackgroundColor = preset.SecondaryColor
        CurrentSettings.GameUI.Buttons.HoverColor = preset.BackgroundColor
        CurrentSettings.GameUI.Buttons.TextColor = preset.TextColor
        CurrentSettings.GameUI.Buttons.CornerRadius = preset.CornerRadius
        
        CurrentSettings.GameUI.Labels.TextColor = preset.TextColor
        CurrentSettings.GameUI.Labels.Font = preset.Font
        
        return true
    end,
    
    ApplyAll = function()
        CoreGuiModules.Chat.ApplyTheme()
        CoreGuiModules.PlayerList.ApplyTheme()
        CoreGuiModules.Backpack.ApplyTheme()
        CoreGuiModules.HealthBar.ApplyTheme()
        
        GameUIModules.CustomFrames.ApplyTheme()
        GameUIModules.Buttons.ApplyTheme()
        GameUIModules.Labels.ApplyTheme()
    end,
    
    ResetAll = function()
        CoreGuiModules.Chat.Reset()
        CoreGuiModules.PlayerList.Reset()
        CoreGuiModules.Backpack.Reset()
        CoreGuiModules.HealthBar.Reset()
        
        GameUIModules.CustomFrames.Reset()
        GameUIModules.Buttons.Reset()
        GameUIModules.Labels.Reset()
    end
}

-- // 10. Создание интерфейса Rayfield
local Window = Rayfield:CreateWindow({
    Name = "UI Theme Injector",
    LoadingTitle = "Загрузка интерфейса...",
    LoadingSubtitle = "by Winion",
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

-- // 11. Вкладка: Пресеты тем
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

PresetSection = PresetsTab:CreateSection("Управление")

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

-- // 12. Вкладка: CoreGui настройки
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

-- // 13. Вкладка: Игровые интерфейсы
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

-- СТАЛО (добавлена проверка на nil):
GameUITab:CreateInput({
    Name = "Имя целевого фрейма",
    CurrentValue = CurrentSettings.GameUI.CustomFrames.TargetFrameName or "",
    PlaceholderText = "Например: ShopFrame",  -- Изменено с Placeholder на PlaceholderText
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
        if CurrentSettings.GameUI.GameUI.CustomFrames.Enabled then
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

-- // 14. Вкладка: Расширенные настройки
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

-- // 15. Вкладка: Информация
local InfoTab = Window:CreateTab("Информация", 4483362458)

local InfoSection = InfoTab:CreateSection("О скрипте")

InfoTab:CreateParagraph({
    Title = "UI Theme Injector",
    Content = "Профессиональный инструмент для кастомизации интерфейсов Roblox. Поддерживает настройку CoreGui элементов и игровых интерфейсов с использованием современных эффектов Glassmorphism."
})

InfoTab:CreateParagraph({
    Title = "Возможности",
    Content = "- 5 готовых пресетов тем\n- Детальная настройка цветов и прозрачности\n- Эффект стекла (Glassmorphism)\n- Плавные анимации\n- Адаптация под мобильные устройства\n- Система сохранения настроек\n- Кастомизация игровых интерфейсов"
})

InfoTab:CreateParagraph({
    Title = "Автор",
    Content = "Winion (@Winion)\nВерсия: 1.0\nДата: 2026"
})

InfoTab:CreateParagraph({
    Title = "Тип устройства",
    Content = "Текущее устройство: " .. UIUtils.GetDeviceType() .. "\nМасштаб: " .. UIUtils.GetScaleFactor()
})

-- // 16. Инициализация и загрузка сохранений
local function Initialize()
    print("[UIThemeInjector] Инициализация скрипта...")
    
    local loaded = SaveSystem.Load()
    if loaded then
        print("[UIThemeInjector] Настройки загружены из файла сохранения")
        ThemeSystem.ApplyAll()
    else
        print("[UIThemeInjector] Применение темы по умолчанию")
        ThemeSystem.ApplyPreset("DarkRed")
        ThemeSystem.ApplyAll()
    end
    
    print("[UIThemeInjector] Интерфейс успешно инициализирован")
    print("[UIThemeInjector] Тип устройства: " .. UIUtils.GetDeviceType())
end

-- Запуск инициализации
task.spawn(Initialize)

-- // 17. Мониторинг изменений в PlayerGui (для динамических интерфейсов)
if CurrentSettings.GameUI.Buttons.Enabled or CurrentSettings.GameUI.Labels.Enabled then
    PlayerGui.ChildAdded:Connect(function(child)
        task.wait(0.5)
        if CurrentSettings.GameUI.Buttons.Enabled then
            GameUIModules.Buttons.ApplyTheme()
        end
        if CurrentSettings.GameUI.Labels.Enabled then
            GameUIModules.Labels.ApplyTheme()
        end
    end)
end

-- // 18. Обработка изменений размера экрана (адаптивность)
Services.UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        task.wait(0.1)
        if CurrentSettings.Advanced.Responsive.Enabled then
            local newScale = UIUtils.GetScaleFactor()
            print("[UIThemeInjector] Масштаб обновлен: " .. newScale)
        end
    end
end)

print("[UIThemeInjector] Скрипт полностью загружен и готов к работе")