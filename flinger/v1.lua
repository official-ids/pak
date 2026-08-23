local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingGuiAdvanced"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = script.Parent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleLabel.BorderSizePixel = 0
TitleLabel.Text = "Advanced Fling Control"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "PlayerScrollingFrame"
ScrollingFrame.Size = UDim2.new(0.9, 0, 0, 200)
ScrollingFrame.Position = UDim2.new(0.05, 0, 0, 50)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local FlingButton = Instance.new("TextButton")
FlingButton.Name = "FlingButton"
FlingButton.Size = UDim2.new(0.9, 0, 0, 40)
FlingButton.Position = UDim2.new(0.05, 0, 0, 260)
FlingButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
FlingButton.BorderSizePixel = 0
FlingButton.Text = "Fling Player"
FlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingButton.TextSize = 16
FlingButton.Font = Enum.Font.SourceSansBold
FlingButton.Parent = MainFrame

local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Size = UDim2.new(0.9, 0, 0, 35)
StopButton.Position = UDim2.new(0.05, 0, 0, 310)
StopButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
StopButton.BorderSizePixel = 0
StopButton.Text = "Stop Fling"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.TextSize = 15
StopButton.Font = Enum.Font.SourceSansBold
StopButton.Parent = MainFrame

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local selectedPlayers = {}
local activeConnections = {}
local isFlinging = false

local function updateButtonText()
	local count = 0
	for _ in pairs(selectedPlayers) do
		count = count + 1
	end
	
	if count > 1 then
		FlingButton.Text = "Fling Players (" .. count .. ")"
	else
		FlingButton.Text = "Fling Player"
	end
end

local function createPlayerCard(player)
	if player == LocalPlayer then return end

	local card = Instance.new("Frame")
	card.Name = player.Name
	card.Size = UDim2.new(1, -10, 0, 45)
	card.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	card.BorderSizePixel = 0
	card.Parent = ScrollingFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
	nameLabel.Position = UDim2.new(0, 10, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	local checkBox = Instance.new("TextButton")
	checkBox.Size = UDim2.new(0, 25, 0, 25)
	checkBox.Position = UDim2.new(1, -35, 0.5, -12.5)
	checkBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	checkBox.BorderSizePixel = 0
	checkBox.Text = ""
	checkBox.Parent = card

	local checkMark = Instance.new("Frame")
	checkMark.Size = UDim2.new(0, 15, 0, 15)
	checkMark.Position = UDim2.new(0.5, -7.5, 0.5, -7.5)
	checkMark.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	checkMark.BorderSizePixel = 0
	checkMark.Visible = false
	checkMark.Parent = checkBox

	checkBox.MouseButton1Click:Connect(function()
		if selectedPlayers[player] then
			selectedPlayers[player] = nil
			checkMark.Visible = false
		else
			selectedPlayers[player] = true
			checkMark.Visible = true
		end
		updateButtonText()
	end)

	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

for _, player in ipairs(Players:GetPlayers()) do
	createPlayerCard(player)
end

Players.PlayerAdded:Connect(function(player)
	createPlayerCard(player)
end)

Players.PlayerRemoving:Connect(function(player)
	selectedPlayers[player] = nil
	local card = ScrollingFrame:FindFirstChild(player.Name)
	if card then
		card:Destroy()
	end
	updateButtonText()
end)

FlingButton.MouseButton1Click:Connect(function()
	local targets = {}
	for player, _ in pairs(selectedPlayers) do
		if player and player.Character then
			table.insert(targets, player)
		end
	end

	if #targets == 0 then return end

	local character = LocalPlayer.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	isFlinging = true
	
	for _, targetPlayer in ipairs(targets) do
		local targetChar = targetPlayer.Character
		if targetChar then
			local targetRootPart = targetChar:FindFirstChild("HumanoidRootPart")
			if targetRootPart then
				local connection
				local startTime = tick()
				
				connection = RunService.RenderStepped:Connect(function()
					if not isFlinging or not targetRootPart or not humanoidRootPart or (tick() - startTime > 10) then
						if connection then
							connection:Disconnect()
						end
						return
					end
					
					humanoidRootPart.CFrame = targetRootPart.CFrame
					humanoidRootPart.Velocity = Vector3.new(99999, 99999, 99999)
				end)
				
				table.insert(activeConnections, connection)
			end
		end
	end
end)

StopButton.MouseButton1Click:Connect(function()
	isFlinging = false
	for _, conn in ipairs(activeConnections) do
		if conn then
			conn:Disconnect()
		end
	end
	activeConnections = {}
	
	local character = LocalPlayer.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Velocity = Vector3.new(0, 0, 0)
		end
	end
end)