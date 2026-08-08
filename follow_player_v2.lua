
--[[
    ShadowFollow - Advanced Pathfinding Follow Script
    Author: Grow_Jandle
    Version: 2.0
    Description: High-end mobile executor script with glassmorphism UI,
                 maximal pathfinding, and real-time obstacle avoidance.
]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

--// Local Player
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:WaitForChild("Humanoid")
local LocalRoot = LocalCharacter:WaitForChild("HumanoidRootPart")

--// State Variables
local TargetPlayer = nil
local TargetHumanoid = nil
local TargetRoot = nil
local CurrentPath = nil
local IsFollowing = false
local IsMinimized = false
local ClickSelectMode = false
local SpectateMode = false
local StoppingDistance = 3
local SpeedMultiplier = 16
local StuckTimer = 0
local LastPosition = LocalRoot.Position
local OriginalCameraSubject = Camera.CameraSubject
local OriginalWalkSpeed = LocalHumanoid.WalkSpeed

--// Localization
local CurrentLanguage = "EN"
local Localization = {
    EN = {
        Title = "ShadowFollow",
        Subtitle = "Advanced Pathfinding System",
        TargetLabel = "TARGET USERNAME",
        TargetPlaceholder = "Enter player name...",
        FollowBtn = "START FOLLOW",
        StopBtn = "STOP",
        ClickSelectBtn = "CLICK SELECT",
        StopDistLabel = "STOPPING DISTANCE",
        SpeedLabel = "WALK SPEED",
        TeleportBtn = "TELEPORT TO TARGET",
        SpectateBtn = "SPECTATE",
        StatusIdle = "IDLE",
        StatusFollowing = "FOLLOWING",
        StatusStuck = "RECALCULATING",
        StatusNoTarget = "NO TARGET",
        StatusClickSelect = "TAP A PLAYER",
        SettingsTitle = "SETTINGS",
        LanguageLabel = "LANGUAGE",
        DeleteScriptBtn = "DELETE SCRIPT",
        ResetSettingsBtn = "RESET SETTINGS",
        InfoTitle = "ABOUT",
        AuthorsLabel = "AUTHORS",
        DescriptionLabel = "DESCRIPTION",
        HowToUseLabel = "HOW TO USE",
        ExtraTitle = "EXTRA FEATURES",
        CloseBtn = "CLOSE",
        BackBtn = "BACK",
        SpectateOn = "SPECTATE ON",
        SpectateOff = "SPECTATE OFF",
        TrailToggle = "RAINBOW TRAIL",
        NoclipToggle = "NOCLIP",
        ESPToggle = "TARGET ESP"
    },
    RU = {
        Title = "ShadowFollow",
        Subtitle = "Система продвинутого следования",
        TargetLabel = "ИМЯ ЦЕЛИ",
        TargetPlaceholder = "Введите имя игрока...",
        FollowBtn = "НАЧАТЬ СЛЕДОВАНИЕ",
        StopBtn = "СТОП",
        ClickSelectBtn = "ВЫБОР КЛИКОМ",
        StopDistLabel = "ДИСТАНЦИЯ ОСТАНОВКИ",
        SpeedLabel = "СКОРОСТЬ ХОДЬБЫ",
        TeleportBtn = "ТЕЛЕПОРТ К ЦЕЛИ",
        SpectateBtn = "НАБЛЮДАТЬ",
        StatusIdle = "ОЖИДАНИЕ",
        StatusFollowing = "СЛЕДОВАНИЕ",
        StatusStuck = "ПЕРЕСЧЁТ",
        StatusNoTarget = "НЕТ ЦЕЛИ",
        StatusClickSelect = "НАЖМИТЕ НА ИГРОКА",
        SettingsTitle = "НАСТРОЙКИ",
        LanguageLabel = "ЯЗЫК",
        DeleteScriptBtn = "УДАЛИТЬ СКРИПТ",
        ResetSettingsBtn = "СБРОС НАСТРОЕК",
        InfoTitle = "О СКРИПТЕ",
        AuthorsLabel = "АВТОРЫ",
        DescriptionLabel = "ОПИСАНИЕ",
        HowToUseLabel = "КАК ИСПОЛЬЗОВАТЬ",
        ExtraTitle = "ДОП. ФУНКЦИИ",
        CloseBtn = "ЗАКРЫТЬ",
        BackBtn = "НАЗАД",
        SpectateOn = "НАБЛЮДЕНИЕ ВКЛ",
        SpectateOff = "НАБЛЮДЕНИЕ ВЫКЛ",
        TrailToggle = "РАДУЖНЫЙ СЛЕД",
        NoclipToggle = "НОКЛИП",
        ESPToggle = "ESP ЦЕЛИ"
    }
}

local function L(key)
    return Localization[CurrentLanguage][key] or key
end

--// Extra Features State
local RainbowTrailEnabled = false
local NoclipEnabled = false
local ESPEnabled = false
local TrailEffect = nil
local ESPHighlight = nil

--// Utility: Create UI Element
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

--// Utility: Make Draggable
local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// Destroy Previous GUI if exists
if LocalPlayer.PlayerGui:FindFirstChild("ShadowFollowGUI") then
    LocalPlayer.PlayerGui:FindFirstChild("ShadowFollowGUI"):Destroy()
end

--// ScreenGui
local ScreenGui = Create("ScreenGui", {
    Name = "ShadowFollowGUI",
    Parent = LocalPlayer.PlayerGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

--// Main Frame (Glassmorphism)
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 340, 0, 520),
    Position = UDim2.new(0.5, -170, 0.5, -260),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    BackgroundTransparency = 0.15,
    ClipsDescendants = true
})

local MainCorner = Create("UICorner", {
    Parent = MainFrame,
    CornerRadius = UDim.new(0, 16)
})

local MainStroke = Create("UIStroke", {
    Parent = MainFrame,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 1.2,
    Transparency = 0.7
})

local MainGradient = Create("UIGradient", {
    Parent = MainFrame,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    }),
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.3)
    })
})

--// Top Bar
local TopBar = Create("Frame", {
    Name = "TopBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.6
})

local TopBarCorner = Create("UICorner", {
    Parent = TopBar,
    CornerRadius = UDim.new(0, 16)
})

-- Fix bottom corners of top bar
local TopBarFix = Create("Frame", {
    Parent = TopBar,
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 1, -16),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0
})

--// Title
local TitleLabel = Create("TextLabel", {
    Parent = TopBar,
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Text = L("Title"),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
})

--// Subtitle
local SubtitleLabel = Create("TextLabel", {
    Parent = TopBar,
    Size = UDim2.new(1, -90, 0, 12),
    Position = UDim2.new(0, 14, 0, 26),
    BackgroundTransparency = 1,
    Text = L("Subtitle"),
    TextColor3 = Color3.fromRGB(160, 160, 170),
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
})

--// Window Controls
local CloseBtn = Create("TextButton", {
    Parent = TopBar,
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(1, -22, 0.5, -7),
    BackgroundColor3 = Color3.fromRGB(220, 50, 50),
    Text = "",
    AutoButtonColor = true
})
Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(1, 0)})

local MinimizeBtn = Create("TextButton", {
    Parent = TopBar,
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(1, -44, 0.5, -7),
    BackgroundColor3 = Color3.fromRGB(230, 190, 40),
    Text = "",
    AutoButtonColor = true
})
Create("UICorner", {Parent = MinimizeBtn, CornerRadius = UDim.new(1, 0)})

--// Settings Button (Gear Icon)
local SettingsBtn = Create("TextButton", {
    Parent = TopBar,
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(1, -72, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
    BackgroundTransparency = 0.4,
    Text = "",
    AutoButtonColor = true
})
Create("UICorner", {Parent = SettingsBtn, CornerRadius = UDim.new(0, 6)})

-- Gear SVG-like icon using ImageLabel (we'll use a text fallback)
local SettingsIcon = Create("TextLabel", {
    Parent = SettingsBtn,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "⚙",
    TextColor3 = Color3.fromRGB(200, 200, 210),
    TextSize = 14,
    Font = Enum.Font.GothamBold
})

--// Info Button (Key Icon)
local InfoBtn = Create("TextButton", {
    Parent = TopBar,
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(1, -98, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
    BackgroundTransparency = 0.4,
    Text = "",
    AutoButtonColor = true
})
Create("UICorner", {Parent = InfoBtn, CornerRadius = UDim.new(0, 6)})

local InfoIcon = Create("TextLabel", {
    Parent = InfoBtn,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "🔑",
    TextColor3 = Color3.fromRGB(200, 200, 210),
    TextSize = 13,
    Font = Enum.Font.GothamBold
})

--// Scrolling Frame for Content
local ScrollFrame = Create("ScrollingFrame", {
    Parent = MainFrame,
    Size = UDim2.new(1, -20, 1, -54),
    Position = UDim2.new(0, 10, 0, 49),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120),
    CanvasSize = UDim2.new(0, 0, 0, 680),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
})

local ScrollLayout = Create("UIListLayout", {
    Parent = ScrollFrame,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local ScrollPadding = Create("UIPadding", {
    Parent = ScrollFrame,
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 10)
})

--// Helper: Create Section
local function CreateSection(title, order)
    local section = Create("Frame", {
        Parent = ScrollFrame,
        Size = UDim2.new(1, -4, 0, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0.4,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order
    })
    Create("UICorner", {Parent = section, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = section, Color = Color3.fromRGB(255,255,255), Thickness = 0.8, Transparency = 0.85})
    
    local padding = Create("UIPadding", {
        Parent = section,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    })
    
    local layout = Create("UIListLayout", {
        Parent = section,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local label = Create("TextLabel", {
        Parent = section,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(180, 180, 195),
        TextSize = 10,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0
    })
    
    return section, layout
end

--// Helper: Create Input Field
local function CreateInput(parent, placeholder, order, defaultText)
    local input = Create("TextBox", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(10, 10, 15),
        BackgroundTransparency = 0.3,
        PlaceholderText = placeholder,
        Text = defaultText or "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        LayoutOrder = order
    })
    Create("UICorner", {Parent = input, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = input, Color = Color3.fromRGB(255,255,255), Thickness = 0.8, Transparency = 0.8})
    Create("UIPadding", {Parent = input, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
    return input
end

--// Helper: Create Button
local function CreateButton(parent, text, color, order)
    local btn = Create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        LayoutOrder = order,
        AutoButtonColor = true
    })
    Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = btn, Color = Color3.fromRGB(255,255,255), Thickness = 0.8, Transparency = 0.7})
    return btn
end

--// Helper: Create Toggle
local function CreateToggle(parent, text, order)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BackgroundTransparency = 0.3,
        LayoutOrder = order
    })
    Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = container, Color = Color3.fromRGB(255,255,255), Thickness = 0.6, Transparency = 0.85})
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleBg = Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    })
    Create("UICorner", {Parent = toggleBg, CornerRadius = UDim.new(1, 0)})
    
    local toggleCircle = Create("Frame", {
        Parent = toggleBg,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    })
    Create("UICorner", {Parent = toggleCircle, CornerRadius = UDim.new(1, 0)})
    
    local enabled = false
    local btn = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            toggleBg.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
            tweenPosition(toggleCircle, UDim2.new(1, -18, 0.5, -8))
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            tweenPosition(toggleCircle, UDim2.new(0, 2, 0.5, -8))
        end
    end)
    
    return container, function() return enabled end
end

local function tweenPosition(obj, newPos)
    local tween = game:GetService("TweenService"):Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = newPos})
    tween:Play()
end

--// Build UI Sections
-- Section 1: Target Selection
local targetSection, targetLayout = CreateSection(L("TargetLabel"), 1)

local UsernameInput = CreateInput(targetSection, L("TargetPlaceholder"), 1)

local FollowBtn = CreateButton(targetSection, L("FollowBtn"), Color3.fromRGB(35, 140, 50), 2)

local ClickSelectBtn = CreateButton(targetSection, L("ClickSelectBtn"), Color3.fromRGB(200, 170, 30), 3)

-- Section 2: Status
local statusSection, statusLayout = CreateSection("STATUS", 2)
local StatusLabel = Create("TextLabel", {
    Parent = statusSection,
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = Color3.fromRGB(10, 10, 15),
    BackgroundTransparency = 0.3,
    Text = L("StatusIdle"),
    TextColor3 = Color3.fromRGB(160, 160, 170),
    TextSize = 12,
    Font = Enum.Font.GothamSemibold,
    LayoutOrder = 1
})
Create("UICorner", {Parent = StatusLabel, CornerRadius = UDim.new(0, 6)})

-- Section 3: Controls
local controlSection, controlLayout = CreateSection("CONTROLS", 3)

local StopDistLabel = Create("TextLabel", {
    Parent = controlSection,
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    Text = L("StopDistLabel"),
    TextColor3 = Color3.fromRGB(140, 140, 155),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = 1
})

local StopDistInput = CreateInput(controlSection, "3", 2, "3")

local SpeedLabel = Create("TextLabel", {
    Parent = controlSection,
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    Text = L("SpeedLabel"),
    TextColor3 = Color3.fromRGB(140, 140, 155),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = 3
})

local SpeedInput = CreateInput(controlSection, "16", 4, "16")

local TeleportBtn = CreateButton(controlSection, L("TeleportBtn"), Color3.fromRGB(50, 50, 140), 5)

local SpectateBtn = CreateButton(controlSection, L("SpectateBtn"), Color3.fromRGB(100, 50, 130), 6)

-- Section 4: Extra Features
local extraSection, extraLayout = CreateSection(L("ExtraTitle"), 4)

local TrailToggle, getTrailState = CreateToggle(extraSection, L("TrailToggle"), 1)
local NoclipToggle, getNoclipState = CreateToggle(extraSection, L("NoclipToggle"), 2)
local ESPToggle, getESPState = CreateToggle(extraSection, L("ESPToggle"), 3)

--// Settings Menu (Overlay)
local SettingsMenu = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 300, 0, 320),
    Position = UDim2.new(0.5, -150, 0.5, -160),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    BackgroundTransparency = 0.1,
    Visible = false,
    ZIndex = 10
})
Create("UICorner", {Parent = SettingsMenu, CornerRadius = UDim.new(0, 14)})
Create("UIStroke", {Parent = SettingsMenu, Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.7})

local SettingsTopBar = Create("Frame", {
    Parent = SettingsMenu,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,
    ZIndex = 11
})
Create("UICorner", {Parent = SettingsTopBar, CornerRadius = UDim.new(0, 14)})
local SettingsTopFix = Create("Frame", {
    Parent = SettingsTopBar,
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,
    ZIndex = 11
})

local SettingsTitleLabel = Create("TextLabel", {
    Parent = SettingsTopBar,
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Text = L("SettingsTitle"),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11
})

local SettingsCloseBtn = Create("TextButton", {
    Parent = SettingsTopBar,
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(1, -22, 0.5, -7),
    BackgroundColor3 = Color3.fromRGB(220, 50, 50),
    Text = "",
    ZIndex = 11
})
Create("UICorner", {Parent = SettingsCloseBtn, CornerRadius = UDim.new(1, 0)})

local SettingsContent = Create("Frame", {
    Parent = SettingsMenu,
    Size = UDim2.new(1, -24, 1, -50),
    Position = UDim2.new(0, 12, 0, 45),
    BackgroundTransparency = 1,
    ZIndex = 11
})
local SettingsListLayout = Create("UIListLayout", {
    Parent = SettingsContent,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
})

-- Language Selector
local LangLabel = Create("TextLabel", {
    Parent = SettingsContent,
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Text = L("LanguageLabel"),
    TextColor3 = Color3.fromRGB(160, 160, 175),
    TextSize = 11,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = 1,
    ZIndex = 11
})

local LangENBtn = Create("TextButton", {
    Parent = SettingsContent,
    Size = UDim2.new(0.48, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(40, 160, 60),
    Text = "EN",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    LayoutOrder = 2,
    ZIndex = 11
})
Create("UICorner", {Parent = LangENBtn, CornerRadius = UDim.new(0, 8)})

local LangRUBtn = Create("TextButton", {
    Parent = SettingsContent,
    Size = UDim2.new(0.48, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
    Text = "RU",
    TextColor3 = Color3.fromRGB(200,200,200),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    LayoutOrder = 3,
    ZIndex = 11
})
Create("UICorner", {Parent = LangRUBtn, CornerRadius = UDim.new(0, 8)})

local DeleteScriptBtn = CreateButton(SettingsContent, L("DeleteScriptBtn"), Color3.fromRGB(180, 40, 40), 4)
DeleteScriptBtn.ZIndex = 11

local ResetSettingsBtn = CreateButton(SettingsContent, L("ResetSettingsBtn"), Color3.fromRGB(180, 140, 30), 5)
ResetSettingsBtn.ZIndex = 11

--// Info Menu (Overlay)
local InfoMenu = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 320, 0, 400),
    Position = UDim2.new(0.5, -160, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    BackgroundTransparency = 0.1,
    Visible = false,
    ZIndex = 10
})
Create("UICorner", {Parent = InfoMenu, CornerRadius = UDim.new(0, 14)})
Create("UIStroke", {Parent = InfoMenu, Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.7})

local InfoTopBar = Create("Frame", {
    Parent = InfoMenu,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,
    ZIndex = 11
})
Create("UICorner", {Parent = InfoTopBar, CornerRadius = UDim.new(0, 14)})
local InfoTopFix = Create("Frame", {
    Parent = InfoTopBar,
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,
    ZIndex = 11
})

local InfoTitleLabel = Create("TextLabel", {
    Parent = InfoTopBar,
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Text = L("InfoTitle"),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11
})

local InfoCloseBtn = Create("TextButton", {
    Parent = InfoTopBar,
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(1, -22, 0.5, -7),
    BackgroundColor3 = Color3.fromRGB(220, 50, 50),
    Text = "",
    ZIndex = 11
})
Create("UICorner", {Parent = InfoCloseBtn, CornerRadius = UDim.new(1, 0)})

local InfoScroll = Create("ScrollingFrame", {
    Parent = InfoMenu,
    Size = UDim2.new(1, -24, 1, -50),
    Position = UDim2.new(0, 12, 0, 45),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    CanvasSize = UDim2.new(0, 0, 0, 500),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 11
})
local InfoListLayout = Create("UIListLayout", {
    Parent = InfoScroll,
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder
})

-- Author Card
local AuthorCard = Create("Frame", {
    Parent = InfoScroll,
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    BackgroundTransparency = 0.3,
    LayoutOrder = 1,
    ZIndex = 11
})
Create("UICorner", {Parent = AuthorCard, CornerRadius = UDim.new(0, 10)})
Create("UIStroke", {Parent = AuthorCard, Color = Color3.fromRGB(255,255,255), Thickness = 0.6, Transparency = 0.85})

-- Avatar placeholder (circle)
local AvatarCircle = Create("Frame", {
    Parent = AuthorCard,
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(0, 12, 0.5, -22),
    BackgroundColor3 = Color3.fromRGB(80, 60, 120),
    ZIndex = 12
})
Create("UICorner", {Parent = AvatarCircle, CornerRadius = UDim.new(1, 0)})
Create("UIStroke", {Parent = AvatarCircle, Color = Color3.fromRGB(140, 100, 200), Thickness = 1.5, Transparency = 0.3, ZIndex = 12})

local AvatarIcon = Create("TextLabel", {
    Parent = AvatarCircle,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "G",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    ZIndex = 12
})

local AuthorNameLabel = Create("TextLabel", {
    Parent = AuthorCard,
    Size = UDim2.new(1, -70, 0, 18),
    Position = UDim2.new(0, 66, 0.5, -18),
    BackgroundTransparency = 1,
    Text = "Grow_Jandle",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12
})

local AuthorRoleLabel = Create("TextLabel", {
    Parent = AuthorCard,
    Size = UDim2.new(1, -70, 0, 30),
    Position = UDim2.new(0, 66, 0.5, 2),
    BackgroundTransparency = 1,
    Text = "Script Developer & UI Designer",
    TextColor3 = Color3.fromRGB(150, 150, 165),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    ZIndex = 12
})

-- Description
local DescCard = Create("Frame", {
    Parent = InfoScroll,
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    BackgroundTransparency = 0.3,
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = 2,
    ZIndex = 11
})
Create("UICorner", {Parent = DescCard, CornerRadius = UDim.new(0, 10)})
Create("UIStroke", {Parent = DescCard, Color = Color3.fromRGB(255,255,255), Thickness = 0.6, Transparency = 0.85})
local DescPadding = Create("UIPadding", {Parent = DescCard, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})

local DescTitle = Create("TextLabel", {
    Parent = DescCard,
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Text = L("DescriptionLabel"),
    TextColor3 = Color3.fromRGB(180, 180, 195),
    TextSize = 11,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12
})

local DescText = Create("TextLabel", {
    Parent = DescCard,
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "ShadowFollow is an advanced pathfinding-based follow system designed for Roblox. It combines PathfindingService with real-time raycasting to provide seamless obstacle avoidance, stuck detection, and smooth character tracking. Features include click-to-select targeting, spectate mode, teleportation, rainbow trails, and ESP visualization. Built with a modern glassmorphism UI for an elegant user experience.",
    TextColor3 = Color3.fromRGB(170, 170, 185),
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    AutomaticSize = Enum.AutomaticSize.Y,
    ZIndex = 12
})

-- How to Use
local HowToCard = Create("Frame", {
    Parent = InfoScroll,
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    BackgroundTransparency = 0.3,
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = 3,
    ZIndex = 11
})
Create("UICorner", {Parent = HowToCard, CornerRadius = UDim.new(0, 10)})
Create("UIStroke", {Parent = HowToCard, Color = Color3.fromRGB(255,255,255), Thickness = 0.6, Transparency = 0.85})
local HowToPadding = Create("UIPadding", {Parent = HowToCard, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})

local HowToTitle = Create("TextLabel", {
    Parent = HowToCard,
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Text = L("HowToUseLabel"),
    TextColor3 = Color3.fromRGB(180, 180, 195),
    TextSize = 11,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12
})

local HowToText = Create("TextLabel", {
    Parent = HowToCard,
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "1. Type a player name or use Click Select to tap a target in the 3D world.\n2. Press START FOLLOW to begin tracking.\n3. Adjust stopping distance and walk speed as needed.\n4. Use TELEPORT to instantly appear behind your target.\n5. Toggle SPECTATE to watch your target in third-person.\n6. Enable extra features like Rainbow Trail, Noclip, or ESP from the main menu.\n7. Use the gear icon for settings (language, reset, delete).\n8. Minimize the UI with the yellow button for a clean floating widget.",
    TextColor3 = Color3.fromRGB(170, 170, 185),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    AutomaticSize = Enum.AutomaticSize.Y,
    ZIndex = 12
})

-- Version
local VersionLabel = Create("TextLabel", {
    Parent = InfoScroll,
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "ShadowFollow v2.0 | Built with Luau",
    TextColor3 = Color3.fromRGB(100, 100, 115),
    TextSize = 9,
    Font = Enum.Font.Gotham,
    LayoutOrder = 4,
    ZIndex = 11
})

--// Floating Widget (Minimized State)
local FloatingWidget = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 20, 0.5, -26),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    BackgroundTransparency = 0.2,
    Visible = false,
    ZIndex = 20
})
Create("UICorner", {Parent = FloatingWidget, CornerRadius = UDim.new(1, 0)})
Create("UIStroke", {Parent = FloatingWidget, Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.6})

local WidgetLabel = Create("TextLabel", {
    Parent = FloatingWidget,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "SF",
    TextColor3 = Color3.fromRGB(200, 180, 255),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    ZIndex = 21
})

local WidgetBtn = Create("TextButton", {
    Parent = FloatingWidget,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 22
})

MakeDraggable(FloatingWidget, FloatingWidget)

--// Draggable for Main Menu and Overlays
MakeDraggable(MainFrame, TopBar)
MakeDraggable(SettingsMenu, SettingsTopBar)
MakeDraggable(InfoMenu, InfoTopBar)

--// Pathfinding Setup
local function CreatePath()
    local path = PathfindingService:CreatePath({
        AgentRadius = 2.5,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false,
        AgentJumpHeight = 8,
        AgentMaxSlope = 45,
        Costs = {
            Water = 80,
            DangerZone = 100,
            Ice = 3,
            Neon = 1,
            Wood = 1,
            Fabric = 2,
            Plastic = 1,
            Grass = 2,
            Sand = 4,
            Slate = 1,
            Concrete = 1,
            Leather = 2,
            Marble = 1,
            Pavement = 1,
            Metal = 1,
            Rock = 2,
            Glacier = 50,
            Snow = 10,
            Ground = 3,
            Mud = 20,
            Brick = 1,
            Granite = 1,
            DiamondPlate = 1,
            CorrodedMetal = 2,
            Foil = 1
        }
    })
    return path
end

--// Raycast Obstacle Detection
local function CheckImmediateObstacles()
    if not LocalRoot or not LocalHumanoid then return false end
    
    local origin = LocalRoot.Position + Vector3.new(0, 2, 0) -- Chest level
    local direction = LocalRoot.CFrame.LookVector * 4 -- 4 studs ahead
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalCharacter}
    
    local result = Workspace:Raycast(origin, direction, rayParams)
    
    if result then
        local distance = (result.Position - origin).Magnitude
        if distance < 4 then
            return true
        end
    end
    
    -- Additional side scans
    local rightDir = LocalRoot.CFrame.RightVector * 2.5
    local leftDir = -LocalRoot.CFrame.RightVector * 2.5
    
    local rightResult = Workspace:Raycast(origin, rightDir, rayParams)
    local leftResult = Workspace:Raycast(origin, leftDir, rayParams)
    
    if rightResult and (rightResult.Position - origin).Magnitude < 2.5 then
        return true
    end
    if leftResult and (leftResult.Position - origin).Magnitude < 2.5 then
        return true
    end
    
    return false
end

--// Stuck Detection
local function CheckStuck(dt)
    if not LocalRoot then return end
    
    local currentPos = LocalRoot.Position
    local distance = (currentPos - LastPosition).Magnitude
    
    if distance < 0.1 and IsFollowing then
        StuckTimer = StuckTimer + dt
        if StuckTimer > 0.5 then
            -- Force jump and recalculate
            if LocalHumanoid and LocalHumanoid.Health > 0 then
                LocalHumanoid.Jump = true
            end
            StuckTimer = 0
            if TargetRoot then
                CurrentPath = CreatePath()
                local success = pcall(function()
                    CurrentPath:ComputeAsync(LocalRoot.Position, TargetRoot.Position)
                end)
                if success and CurrentPath.Status == Enum.PathStatus.Success then
                    local waypoints = CurrentPath:GetWaypoints()
                    if #waypoints > 1 then
                        LocalHumanoid:MoveTo(waypoints[2].Position)
                    end
                end
            end
            StatusLabel.Text = L("StatusStuck")
            StatusLabel.TextColor3 = Color3.fromRGB(230, 190, 40)
        end
    else
        StuckTimer = 0
    end
    
    LastPosition = currentPos
end

--// Follow Logic
local function FollowTarget()
    if not TargetRoot or not TargetHumanoid or TargetHumanoid.Health <= 0 then
        IsFollowing = false
        StatusLabel.Text = L("StatusNoTarget")
        StatusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
        return
    end
    
    local distanceToTarget = (LocalRoot.Position - TargetRoot.Position).Magnitude
    
    if distanceToTarget <= StoppingDistance then
        -- Within stopping distance, slow down
        LocalHumanoid:MoveTo(TargetRoot.Position)
        StatusLabel.Text = L("StatusFollowing")
        StatusLabel.TextColor3 = Color3.fromRGB(40, 180, 60)
        return
    end
    
    -- Check for immediate obstacles (raycast)
    if CheckImmediateObstacles() then
        if LocalHumanoid.Health > 0 then
            LocalHumanoid.Jump = true
        end
    end
    
    -- Recalculate path
    CurrentPath = CreatePath()
    local success = pcall(function()
        CurrentPath:ComputeAsync(LocalRoot.Position, TargetRoot.Position)
    end)
    
    if success and CurrentPath.Status == Enum.PathStatus.Success then
        local waypoints = CurrentPath:GetWaypoints()
        
        -- Find next waypoint to move to
        local nextWaypointIndex = 2
        for i, waypoint in ipairs(waypoints) do
            if (waypoint.Position - LocalRoot.Position).Magnitude > 2 then
                nextWaypointIndex = i
                break
            end
        end
        
        if nextWaypointIndex <= #waypoints then
            local wp = waypoints[nextWaypointIndex]
            LocalHumanoid:MoveTo(wp.Position)
            
            if wp.Action == Enum.PathWaypointAction.Jump then
                LocalHumanoid.Jump = true
            end
        end
        
        StatusLabel.Text = L("StatusFollowing")
        StatusLabel.TextColor3 = Color3.fromRGB(40, 180, 60)
    else
        -- Path failed, try direct movement
        LocalHumanoid:MoveTo(TargetRoot.Position)
        StatusLabel.Text = L("StatusStuck")
        StatusLabel.TextColor3 = Color3.fromRGB(230, 190, 40)
    end
end

--// Find Target by Partial Name
local function FindPlayerByName(name)
    if not name or name == "" then return nil end
    name = name:lower()
    
    -- Exact match first
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == name then
            return player
        end
    end
    
    -- Partial match
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name then
            return player
        end
    end
    
    -- Display name match
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName and player.DisplayName:lower():sub(1, #name) == name then
            return player
        end
    end
    
    return nil
end

--// Set Target
local function SetTarget(player)
    if not player then return end
    
    TargetPlayer = player
    TargetHumanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    TargetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if TargetHumanoid and TargetRoot then
        UsernameInput.Text = player.Name
        StatusLabel.Text = L("StatusIdle")
        StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    end
    
    -- Update ESP if enabled
    UpdateESP()
end

--// Click-to-Select Mode
local function EnableClickSelect()
    ClickSelectMode = true
    ClickSelectBtn.BackgroundColor3 = Color3.fromRGB(230, 200, 40)
    ClickSelectBtn.Text = L("StatusClickSelect")
    StatusLabel.Text = L("StatusClickSelect")
    StatusLabel.TextColor3 = Color3.fromRGB(230, 190, 40)
end

local function DisableClickSelect()
    ClickSelectMode = false
    ClickSelectBtn.BackgroundColor3 = Color3.fromRGB(200, 170, 30)
    ClickSelectBtn.Text = L("ClickSelectBtn")
    if not IsFollowing then
        StatusLabel.Text = L("StatusIdle")
        StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    end
end

--// ESP System
local function UpdateESP()
    -- Remove old
    if ESPHighlight then
        ESPHighlight:Destroy()
        ESPHighlight = nil
    end
    
    if ESPEnabled and TargetPlayer and TargetPlayer.Character then
        ESPHighlight = Instance.new("Highlight")
        ESPHighlight.Adornee = TargetPlayer.Character
        ESPHighlight.FillColor = Color3.fromRGB(255, 50, 50)
        ESPHighlight.FillTransparency = 0.7
        ESPHighlight.OutlineColor = Color3.fromRGB(255, 255, 100)
        ESPHighlight.OutlineTransparency = 0
        ESPHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        ESPHighlight.Parent = TargetPlayer.Character
    end
end

--// Rainbow Trail
local function UpdateTrail()
    if TrailEffect then
        TrailEffect:Destroy()
        TrailEffect = nil
    end
    
    if RainbowTrailEnabled and LocalCharacter and LocalRoot then
        local attachment0 = Instance.new("Attachment", LocalRoot)
        local attachment1 = Instance.new("Attachment", LocalRoot)
        attachment0.Position = Vector3.new(0, 0, 0.5)
        attachment1.Position = Vector3.new(0, 0, -0.5)
        
        TrailEffect = Instance.new("Trail", LocalRoot)
        TrailEffect.Attachment0 = attachment0
        TrailEffect.Attachment1 = attachment1
        TrailEffect.Lifetime = 1.5
        TrailEffect.MinLength = 0.05
        TrailEffect.LightEmission = 0.8
        TrailEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 100, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 0, 211))
        })
        TrailEffect.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    end
end

--// Noclip
local function UpdateNoclip()
    if not LocalCharacter then return end
    for _, part in ipairs(LocalCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = NoclipEnabled
        end
    end
end

--// Event Connections

-- Close Button
CloseBtn.MouseButton1Click:Connect(function()
    -- Clean exit
    IsFollowing = false
    SpectateMode = false
    Camera.CameraSubject = OriginalCameraSubject
    LocalHumanoid.WalkSpeed = OriginalWalkSpeed
    
    if ESPHighlight then ESPHighlight:Destroy() end
    if TrailEffect then TrailEffect:Destroy() end
    
    ScreenGui:Destroy()
end)

-- Minimize Button
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    MainFrame.Visible = false
    FloatingWidget.Visible = true
end)

-- Widget Click (Restore)
WidgetBtn.MouseButton1Click:Connect(function()
    IsMinimized = false
    MainFrame.Visible = true
    FloatingWidget.Visible = false
end)

-- Settings Button
SettingsBtn.MouseButton1Click:Connect(function()
    SettingsMenu.Visible = true
    InfoMenu.Visible = false
end)

-- Info Button
InfoBtn.MouseButton1Click:Connect(function()
    InfoMenu.Visible = true
    SettingsMenu.Visible = false
end)

-- Settings Close
SettingsCloseBtn.MouseButton1Click:Connect(function()
    SettingsMenu.Visible = false
end)

-- Info Close
InfoCloseBtn.MouseButton1Click:Connect(function()
    InfoMenu.Visible = false
end)

-- Language Buttons
LangENBtn.MouseButton1Click:Connect(function()
    CurrentLanguage = "EN"
    LangENBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
    LangENBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LangRUBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    LangRUBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    -- Update all text
    TitleLabel.Text = L("Title")
    SubtitleLabel.Text = L("Subtitle")
    FollowBtn.Text = IsFollowing and L("StopBtn") or L("FollowBtn")
    ClickSelectBtn.Text = L("ClickSelectBtn")
    StopDistLabel.Text = L("StopDistLabel")
    SpeedLabel.Text = L("SpeedLabel")
    TeleportBtn.Text = L("TeleportBtn")
    SpectateBtn.Text = L("SpectateBtn")
    SettingsTitleLabel.Text = L("SettingsTitle")
    DeleteScriptBtn.Text = L("DeleteScriptBtn")
    ResetSettingsBtn.Text = L("ResetSettingsBtn")
    InfoTitleLabel.Text = L("InfoTitle")
    if not IsFollowing then
        StatusLabel.Text = L("StatusIdle")
    end
end)

LangRUBtn.MouseButton1Click:Connect(function()
    CurrentLanguage = "RU"
    LangRUBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
    LangRUBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LangENBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    LangENBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.Text = L("Title")
    SubtitleLabel.Text = L("Subtitle")
    FollowBtn.Text = IsFollowing and L("StopBtn") or L("FollowBtn")
    ClickSelectBtn.Text = L("ClickSelectBtn")
    StopDistLabel.Text = L("StopDistLabel")
    SpeedLabel.Text = L("SpeedLabel")
    TeleportBtn.Text = L("TeleportBtn")
    SpectateBtn.Text = L("SpectateBtn")
    SettingsTitleLabel.Text = L("SettingsTitle")
    DeleteScriptBtn.Text = L("DeleteScriptBtn")
    ResetSettingsBtn.Text = L("ResetSettingsBtn")
    InfoTitleLabel.Text = L("InfoTitle")
    if not IsFollowing then
        StatusLabel.Text = L("StatusIdle")
    end
end)

-- Delete Script
DeleteScriptBtn.MouseButton1Click:Connect(function()
    IsFollowing = false
    SpectateMode = false
    Camera.CameraSubject = OriginalCameraSubject
    LocalHumanoid.WalkSpeed = OriginalWalkSpeed
    if ESPHighlight then ESPHighlight:Destroy() end
    if TrailEffect then TrailEffect:Destroy() end
    ScreenGui:Destroy()
end)

-- Reset Settings
ResetSettingsBtn.MouseButton1Click:Connect(function()
    StoppingDistance = 3
    SpeedMultiplier = 16
    StopDistInput.Text = "3"
    SpeedInput.Text = "16"
    LocalHumanoid.WalkSpeed = 16
    CurrentLanguage = "EN"
    LangENBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
    LangRUBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    RainbowTrailEnabled = false
    NoclipEnabled = false
    ESPEnabled = false
    UpdateTrail()
    UpdateESP()
end)

-- Follow / Stop Button
FollowBtn.MouseButton1Click:Connect(function()
    if IsFollowing then
        -- Stop
        IsFollowing = false
        FollowBtn.Text = L("FollowBtn")
        FollowBtn.BackgroundColor3 = Color3.fromRGB(35, 140, 50)
        StatusLabel.Text = L("StatusIdle")
        StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    else
        -- Start
        local name = UsernameInput.Text
        local player = FindPlayerByName(name)
        
        if player and player ~= LocalPlayer then
            SetTarget(player)
            IsFollowing = true
            FollowBtn.Text = L("StopBtn")
            FollowBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            StatusLabel.Text = L("StatusFollowing")
            StatusLabel.TextColor3 = Color3.fromRGB(40, 180, 60)
        else
            StatusLabel.Text = L("StatusNoTarget")
            StatusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
        end
    end
end)

-- Click Select Button
ClickSelectBtn.MouseButton1Click:Connect(function()
    if ClickSelectMode then
        DisableClickSelect()
    else
        EnableClickSelect()
    end
end)

-- Username Input (Focus Lost)
UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local player = FindPlayerByName(UsernameInput.Text)
        if player and player ~= LocalPlayer then
            SetTarget(player)
        end
    end
end)

-- Stopping Distance Input
StopDistInput.FocusLost:Connect(function()
    local val = tonumber(StopDistInput.Text)
    if val and val >= 0 and val <= 50 then
        StoppingDistance = val
    else
        StopDistInput.Text = tostring(StoppingDistance)
    end
end)

-- Speed Input
SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val >= 0 and val <= 200 then
        SpeedMultiplier = val
        if LocalHumanoid then
            LocalHumanoid.WalkSpeed = val
        end
    else
        SpeedInput.Text = tostring(SpeedMultiplier)
    end
end)

-- Teleport Button
TeleportBtn.MouseButton1Click:Connect(function()
    if TargetRoot and LocalRoot then
        local behindTarget = TargetRoot.CFrame * CFrame.new(0, 0, 4)
        LocalRoot.CFrame = behindTarget
    end
end)

-- Spectate Button
SpectateBtn.MouseButton1Click:Connect(function()
    SpectateMode = not SpectateMode
    if SpectateMode then
        if TargetHumanoid then
            Camera.CameraSubject = TargetHumanoid
            SpectateBtn.Text = L("SpectateOn")
            SpectateBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        end
    else
        Camera.CameraSubject = OriginalCameraSubject
        SpectateBtn.Text = L("SpectateBtn")
        SpectateBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 130)
    end
end)

-- Click-to-Select Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if ClickSelectMode and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        
        if target then
            -- Find character model
            local character = target:FindFirstAncestorOfClass("Model")
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart and humanoid.Health > 0 then
                    -- Find the player
                    local player = Players:GetPlayerFromCharacter(character)
                    if player and player ~= LocalPlayer then
                        SetTarget(player)
                        DisableClickSelect()
                    end
                end
            end
        end
    end
end)

--// Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    LocalCharacter = char
    LocalHumanoid = char:WaitForChild("Humanoid")
    LocalRoot = char:WaitForChild("HumanoidRootPart")
    OriginalWalkSpeed = LocalHumanoid.WalkSpeed
    
    if RainbowTrailEnabled then
        task.wait(1)
        UpdateTrail()
    end
end)

--// Target Character Respawn
local function WatchTargetCharacter()
    if not TargetPlayer then return end
    
    TargetPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        TargetHumanoid = char:WaitForChild("Humanoid")
        TargetRoot = char:WaitForChild("HumanoidRootPart")
        UpdateESP()
        
        if SpectateMode then
            Camera.CameraSubject = TargetHumanoid
        end
    end)
end

--// Main Heartbeat Loop
RunService.Heartbeat:Connect(function(dt)
    -- Validate references
    if not LocalRoot or not LocalHumanoid then
        if LocalCharacter then
            LocalRoot = LocalCharacter:FindFirstChild("HumanoidRootPart")
            LocalHumanoid = LocalCharacter:FindFirstChild("Humanoid")
        end
        if not LocalRoot or not LocalHumanoid then return end
    end
    
    -- Validate target
    if TargetPlayer then
        if not TargetRoot or not TargetRoot.Parent then
            TargetRoot = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        if not TargetHumanoid or not TargetHumanoid.Parent then
            TargetHumanoid = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid")
        end
    end
    
    -- Follow logic
    if IsFollowing then
        FollowTarget()
    end
    
    -- Stuck detection
    CheckStuck(dt)
    
    -- Noclip update
    if NoclipEnabled then
        UpdateNoclip()
    end
end)

--// Player Added (for target tracking)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if TargetPlayer == player then
            task.wait(0.5)
            TargetHumanoid = player.Character:FindFirstChild("Humanoid")
            TargetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        end
    end)
end)

--// Player Removing
Players.PlayerRemoving:Connect(function(player)
    if TargetPlayer == player then
        IsFollowing = false
        TargetPlayer = nil
        TargetHumanoid = nil
        TargetRoot = nil
        FollowBtn.Text = L("FollowBtn")
        FollowBtn.BackgroundColor3 = Color3.fromRGB(35, 140, 50)
        StatusLabel.Text = L("StatusNoTarget")
        StatusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

--// Initial Setup
print("[ShadowFollow] Loaded successfully. Author: Grow_Jandle")
print("[ShadowFollow] Version 2.0 - Glassmorphism UI with Maximal Pathfinding")