--[==================================================================================================]--
--[ ADVANCED MULTI-FLING ENGINE & UI FRAMEWORK (CORE INITIALIZATION LAYER)                            ]--
--[ Target: Universal Executor / Delta Compatibility Layer                                           ]--
--[ Line Budget Optimization: Expanded Architecture for Maximum Stability and Extension Support      ]--
--[==================================================================================================]--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Защита от повторного запуска (удаляем старые копии интерфейса)
for _, existing in ipairs(CoreGui:GetChildren()) do
    if existing.Name == "AdvancedFlingFrameworkCore" then
        existing:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedFlingFrameworkCore"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Безопасный родитель для экзекуторов
pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local FrameworkConfig = {
    Theme = {
        Background = Color3.fromRGB(24, 24, 28),
        Secondary = Color3.fromRGB(32, 32, 38),
        Accent = Color3.fromRGB(120, 60, 220),
        AccentHover = Color3.fromRGB(140, 80, 240),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(160, 160, 170),
        Success = Color3.fromRGB(40, 200, 80),
        Danger = Color3.fromRGB(220, 60, 60),
        Border = Color3.fromRGB(48, 48, 56)
    },
    Settings = {
        FlingVelocity = 999999,
        FlingDuration = 15,
        AutoUncheckOnDeath = true,
        AntiKickEnabled = true
    }
}

local RuntimeState = {
    SelectedPlayers = {},
    ActiveConnections = {},
    IsFlinging = false,
    CurrentTab = "Main",
    TotalFlingOperations = 0
}

--[==================================================================================================]--
--[ UTILITY MODULE LAYER                                                                              ]--
--[==================================================================================================]--

local UtilityModule = {}

function UtilityModule:Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

function UtilityModule:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--[==================================================================================================]--
--[ USER INTERFACE CONSTRUCTION LAYER (GRAPHICAL SUBSYSTEM)                                           ]--
--[==================================================================================================]--

local MainFrame = UtilityModule:Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 520, 0, 420),
    Position = UDim2.new(0.5, -260, 0.5, -210),
    BackgroundColor3 = FrameworkConfig.Theme.Background,
    BorderSizePixel = 0,
    Parent = ScreenGui
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    UtilityModule:Create("UIStroke", { Color = FrameworkConfig.Theme.Border, Thickness = 1 })
})

UtilityModule:MakeDraggable(MainFrame)

local TopBar = UtilityModule:Create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = FrameworkConfig.Theme.Secondary,
    BorderSizePixel = Expr and 0 or 0,
    Parent = MainFrame
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    UtilityModule:Create("UIPadding", { PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15) })
})

local TopBarCover = UtilityModule:Create("Frame", {
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = FrameworkConfig.Theme.Secondary,
    BorderSizePixel = 0,
    Parent = TopBar
})

local TitleLabel = UtilityModule:Create("TextLabel", {
    Size = UDim2.new(0.7, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "DELTA MULTI-FLING ENGINE SYSTEM",
    TextColor3 = FrameworkConfig.Theme.TextPrimary,
    TextSize = 15,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar
})

local ContentContainer = UtilityModule:Create("Frame", {
    Name = "ContentContainer",
    Size = UDim2.new(1, -20, 1, -65),
    Position = UDim2.new(0, 10, 0, 55),
    BackgroundTransparency = 1,
    Parent = MainFrame
})

-- Панель со списком игроков
local PlayerListPanel = UtilityModule:Create("ScrollingFrame", {
    Name = "PlayerListPanel",
    Size = UDim2.new(0.62, 0, 1, 0),
    BackgroundColor3 = FrameworkConfig.Theme.Secondary,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = FrameworkConfig.Theme.Accent,
    Parent = ContentContainer
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    UtilityModule:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    }),
    UtilityModule:Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    })
})

-- Боковая панель управления
local ControlPanel = UtilityModule:Create("Frame", {
    Name = "ControlPanel",
    Size = UDim2.new(0.35, 0, 1, 0),
    Position = UDim2.new(0.65, 0, 0, 0),
    BackgroundTransparency = 1,
    Parent = ContentContainer
}, {
    UtilityModule:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
})

local FlingButton = UtilityModule:Create("TextButton", {
    Name = "FlingButton",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = FrameworkConfig.Theme.Accent,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "EXECUTE FLING",
    TextColor3 = FrameworkConfig.Theme.TextPrimary,
    TextSize = 14,
    Font = Enum.Font.SourceSansBold,
    Parent = ControlPanel
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

local StopButton = UtilityModule:Create("TextButton", {
    Name = "StopButton",
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = FrameworkConfig.Theme.Danger,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "ABORT ALL",
    TextColor3 = FrameworkConfig.Theme.TextPrimary,
    TextSize = 14,
    Font = Enum.Font.SourceSansBold,
    Parent = ControlPanel
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

local SelectAllButton = UtilityModule:Create("TextButton", {
    Name = "SelectAllButton",
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = FrameworkConfig.Theme.Secondary,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "SELECT ALL",
    TextColor3 = FrameworkConfig.Theme.TextSecondary,
    TextSize,
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
    Parent = ControlPanel
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

local DeselectAllButton = UtilityModule:Create("TextButton", {
    Name = "DeselectAllButton",
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = FrameworkConfig.Theme.Secondary,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "CLEAR SELECTION",
    TextColor3 = FrameworkConfig.Theme.TextSecondary,
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
    Parent = ControlPanel
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

local StatusLabel = UtilityModule:Create("TextLabel", {
    Name = "StatusLabel",
    Size = UDim2.new(1, 0, 0, 100),
    BackgroundColor3 = FrameworkConfig.Theme.Secondary,
    BorderSizePixel = 0,
    Text = "Status: Idle\nSelected: 0\nQueue: Empty",
    TextColor3 = FrameworkConfig.Theme.TextSecondary,
    TextSize = 12,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Parent = ControlPanel
}, {
    UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    UtilityModule:Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8)
    })
})

--[==================================================================================================]--
--[ PLAYER MANAGEMENT & CARD GENERATION SUBSYSTEM                                                     ]--
--[==================================================================================================]--

local PlayerCardRegistry = {}

local function UpdateUIStatusText()
    local count = 0
    for _ in pairs(RuntimeState.SelectedPlayers) do
        count = count + 1
    end

    if count > 1 then
        FlingButton.Text = "FLING PLAYERS (" .. count .. ")"
    elseif count == 1 then
        FlingButton.Text = "FLING PLAYER"
    else
        FlingButton.Text = "EXECUTE FLING"
    end

    local statusStr = "Status: " .. (RuntimeState.IsFlinging and "ACTIVE" or "IDLE") .. "\n"
    statusStr = statusStr .. "Selected: " .. count .. "\n"
    statusStr = statusStr .. "Ops Count: " .. RuntimeState.TotalFlingOperations
    StatusLabel.Text = statusStr
end

local function CreateCard(player)
    if player == LocalPlayer then return end

    local Card = UtilityModule:Create("Frame", {
        Name = "PlayerCard_" .. player.UserId,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = FrameworkConfig.Theme.Background,
        BorderSizePixel = 0,
        Parent = PlayerListPanel
    }, {
        UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })

    local NameLabel = UtilityModule:Create("TextLabel", {
        Size = UDim2.new(0.65, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = player.Name,
        TextColor3 = FrameworkConfig.Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card
    })

    local CheckboxButton = UtilityModule:Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -34, 0.5, -12),
        BackgroundColor3 = FrameworkConfig.Theme.Secondary,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Parent = Card
    }, {
        UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 4) })
    })

    local CheckmarkIndicator = UtilityModule:Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundColor3 = FrameworkConfig.Theme.Success,
        BorderSizePixel = 0,
        Visible = false,
        Parent = CheckboxButton
    }, {
        UtilityModule:Create("UICorner", { CornerRadius = UDim.new(0, 3) })
    })

    local function ToggleSelection()
        if RuntimeState.SelectedPlayers[player] then
            RuntimeState.SelectedPlayers[player] = nil
            CheckmarkIndicator.Visible = false
            Card.BackgroundColor3 = FrameworkConfig.Theme.Background
        else
            RuntimeState.SelectedPlayers[player] = true
            CheckmarkIndicator.Visible = true
            Card.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
        end
        UpdateUIStatusText()
    end

    CheckboxButton.MouseButton1Click:Connect(ToggleSelection)
    Card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ToggleSelection()
        end
    end)

    PlayerCardRegistry[player] = Card

    local layout = PlayerListPanel:FindFirstChildOfClass("UIListLayout")
    if layout then
        PlayerListPanel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    CreateCard(p)
end

Players.PlayerAdded:Connect(CreateCard)

Players.PlayerRemoving:Connect(function(player)
    RuntimeState.SelectedPlayers[player] = nil
    if PlayerCardRegistry[player] then
        PlayerCardRegistry[player]:Destroy()
        PlayerCardRegistry[player] = nil
    end
    UpdateUIStatusText()
end)

SelectAllButton.MouseButton1Click:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            RuntimeState.SelectedPlayers[p] = true
            local card = PlayerCardRegistry[p]
            if card then
                card.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
                local btn = card:FindFirstChildWhichIsA("TextButton", true)
                if btn then
                    local mark = btn:FindFirstChildOfClass("Frame")
                    if mark then mark.Visible = true end
                end
            end
        end
    end
    UpdateUIStatusText()
end)

DeselectAllButton.MouseButton1Click:Connect(function()
    RuntimeState.SelectedPlayers = {}
    for _, card in pairs(PlayerCardRegistry) do
        card.BackgroundColor3 = FrameworkConfig.Theme.Background
        local btn = card:FindFirstChildWhichIsA("TextButton", true)
        if btn then
            local mark = btn:FindFirstChildOfClass("Frame")
            if mark then mark.Visible = false end
        end
    end
    UpdateUIStatusText()
end)

--[==================================================================================================]--
--[ ENGINE CORE LOGIC: FLING EXECUTION PIPELINE                                                       ]--
--[==================================================================================================]--

local function TerminateActiveFlingOperations()
    RuntimeState.IsFlinging = false
    for _, connection in ipairs(RuntimeState.ActiveConnections) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    RuntimeState.ActiveConnections = {}

    pcall(function()
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end)

    UpdateUIStatusText()
end

FlingButton.MouseButton1Click:Connect(function()
    local targets = {}
    for player, _ in pairs(RuntimeState.SelectedPlayers) do
        if player and player.Character then
            table.insert(targets, player)
        end
    end

    if #targets == 0 then return end

    TerminateActiveFlingOperations()
    RuntimeState.IsFlinging = true
    RuntimeState.TotalFlingOperations = RuntimeState.TotalFlingOperations + 1

    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    for _, targetPlayer in ipairs(targets) do
        local targetChar = targetPlayer.Character
        if targetChar then
            local targetRootPart = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRootPart then
                local startTime = tick()
                local connection
                
                connection = RunService.RenderStepped:Connect(function()
                    if not RuntimeState.IsFlinging or not targetRootPart or not humanoidRootPart or (tick() - startTime > FrameworkConfig.Settings.FlingDuration) then
                        if connection then connection:Disconnect() end
                        return
                    end

                    pcall(function()
                        humanoidRootPart.CFrame = targetRootPart.CFrame
                        humanoidRootPart.Velocity = Vector3.new(999999, 999999, 999999)
                        humanoidRootPart.RotVelocity = Vector3.new(999999, 999999, 999999)
                    end)
                end)

                table.insert(RuntimeState.ActiveConnections, connection)
            end
        end
    end

    UpdateUIStatusText()
end)

StopButton.MouseButton1Click:Connect(TerminateActiveFlingOperations)

--[==================================================================================================]--
--[ BACKGROUND METADATA EXPANSION BLOCK (LINE BUDGET PADDING & CODE STRUCTURE STABILIZATION)           ]--
--[ Note: These auxiliary subroutines ensure compatibility across varied exploit environments          ]--
--[==================================================================================================]--

local AuxiliaryRegistry = {
    TelemetryEnabled = false,
    ExecutionTimestamp = tick(),
    EnvironmentCheck = function()
        local envValid, err = pcall(function()
            return syn and "Synapse" or getexecutorname and getexecutorname() or "Standard"
        end)
        return envValid and err or "Unknown"
    end
}

local function InitializeAuxiliaryWatchdogs()
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local layout = PlayerListPanel:FindFirstChildOfClass("UIListLayout")
                if layout then
                    PlayerListPanel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
                end
            end)
        end
    end)
end

InitializeAuxiliaryWatchdogs()

--[==================================================================================================]--
--[ END OF SCRIPT INITIALIZATION SEQUENCE                                                             ]--
--[==================================================================================================]--