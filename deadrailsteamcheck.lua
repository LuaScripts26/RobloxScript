local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
if CoreGui:FindFirstChild("DeadrailsPlayerChecker") then 
CoreGui.DeadrailsPlayerChecker:Destroy() 
end
local TRAIN_NAMES = {"locomotive", "80sTrain", "cattle", "presidential", "golden", "passenger", "armor", "wooden", "frost", "christmas_event_2025", "dracula", "ghost", "yeat", "default"}
local RunService = game:GetService("RunService")
local TRAIN_LOOKUP = {}
for _, name in ipairs(TRAIN_NAMES) do
TRAIN_LOOKUP[name] = true
end
local activeTrains = {}
local heartbeatConnection = nil
local accumulatedTime = 0
local function updateActiveTrains()
table.clear(activeTrains)
for _, child in ipairs(workspace:GetChildren()) do
if child:IsA("Model") and TRAIN_LOOKUP[child.Name] then
activeTrains[child] = true
end
end
end
heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
accumulatedTime = accumulatedTime + dt
if accumulatedTime >= 0.2 then
accumulatedTime = accumulatedTime % 0.2
updateActiveTrains()
end
end)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeadrailsPlayerChecker"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 40)
MainFrame.Position = UDim2.new(1, -247, 0, 100)
MainFrame.BackgroundTransparency = 0.35
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 32)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.LayoutOrder = 0
HeaderFrame.Parent = MainFrame
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.FontFace = Font.fromId(12187372175)
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Finding Train..."
TitleLabel.Parent = HeaderFrame
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.Parent = HeaderFrame
CloseButton.MouseButton1Click:Connect(function() 
if heartbeatConnection then
heartbeatConnection:Disconnect()
heartbeatConnection = nil
end
ScreenGui:Destroy() 
end)
local ListFrame = Instance.new("Frame")
ListFrame.Size = UDim2.new(1, 0, 0, 0)
ListFrame.BackgroundTransparency = 1
ListFrame.LayoutOrder = 1
ListFrame.Parent = MainFrame
local SubListLayout = Instance.new("UIListLayout")
SubListLayout.Parent = ListFrame
SubListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SubListLayout.Padding = UDim.new(0, 3)
local function createPlayerLabel(player)
local TextLabel = Instance.new("TextLabel")
TextLabel.Name = player.Name
TextLabel.Size = UDim2.new(1, 0, 0, 18)
TextLabel.BackgroundTransparency = 1
TextLabel.FontFace = Font.fromId(12187372175)
TextLabel.TextSize = 16
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.Text = "  • " .. player.DisplayName
TextLabel.Parent = ListFrame
return TextLabel
end
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local function checkTrainWeld(hitPart)
for trainModel in pairs(activeTrains) do
if trainModel.Parent and (hitPart:IsDescendantOf(trainModel) or hitPart == trainModel) then
return true
end
end
if hitPart:FindFirstChild("DragWeldConstraint") then
return true
end
return false
end
local function isPlayerOnAnyTrain(player)
local character = player.Character
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
if not rootPart then return false end
local currentOrigin = rootPart.Position
local remainingDistance = 30
local ignoreList = {character}
for i = 1, 300 do
raycastParams.FilterDescendantsInstances = ignoreList
local result = workspace:Raycast(currentOrigin, Vector3.new(0, -remainingDistance, 0), raycastParams)
if result and result.Instance then
local hit = result.Instance
if checkTrainWeld(hit) then
return true
end
table.insert(ignoreList, hit)
local travelDist = (currentOrigin - result.Position).Magnitude
remainingDistance = remainingDistance - travelDist
currentOrigin = result.Position - Vector3.new(0, 0.1, 0)
if remainingDistance <= 0.5 then break end
else
break
end
end
return false
end
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
local moveGui = input.Position - dragStart
MainFrame.Position = UDim2.new(
startPos.X.Scale, 
startPos.X.Offset + moveGui.X, 
startPos.Y.Scale, 
startPos.Y.Offset + moveGui.Y
)
end
HeaderFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = MainFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
HeaderFrame.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
updateDrag(input)
end
end)
heartbeatConnection = RunService.Heartbeat:Connect(function()
if not ScreenGui.Parent then return end
updateActiveTrains()
local allPlayers = Players:GetPlayers()
local onboardCount = 0
for _, child in ipairs(ListFrame:GetChildren()) do
if child:IsA("TextLabel") and not Players:FindFirstChild(child.Name) then child:Destroy() end
end
local maxTextWidth = 140
for _, player in ipairs(allPlayers) do
local label = ListFrame:FindFirstChild(player.Name) or createPlayerLabel(player)
if isPlayerOnAnyTrain(player) then
label.TextColor3 = Color3.fromRGB(0, 255, 0)
onboardCount = onboardCount + 1
else
label.TextColor3 = Color3.fromRGB(255, 0, 0)
end
if label.TextBounds.X > maxTextWidth then maxTextWidth = label.TextBounds.X end
end
if next(activeTrains) ~= nil then
TitleLabel.Text = string.format("Players on Train (%d/%d)", onboardCount, #allPlayers)
else
TitleLabel.Text = "Train not Found"
end
if onboardCount == #allPlayers and #allPlayers > 0 then
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 60, 10)
else
MainFrame.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
end
if TitleLabel.TextBounds.X > maxTextWidth then maxTextWidth = TitleLabel.TextBounds.X end
local targetWidth = maxTextWidth + 45
local targetHeight = 32 + SubListLayout.AbsoluteContentSize.Y + 12
if #allPlayers == 0 then targetHeight = 36 end
ListFrame.Size = UDim2.new(1, 0, 0, SubListLayout.AbsoluteContentSize.Y)
MainFrame.Size = UDim2.new(0, targetWidth, 0, targetHeight)
end)
