local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalAtmosphereDensity = nil
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if atmosphere then
originalAtmosphereDensity = atmosphere.Density
end
local isEnabled = false
local fogRemovalEnabled = false
local scriptRunning = true
local updateConnection = nil
local currentBrightness = 255
local AmbientCLR = Color3.fromRGB(currentBrightness, currentBrightness, currentBrightness)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrightnessControllerGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 130, 0, 80)
MainFrame.Position = UDim2.new(1, -165, 0, 8)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
local dragging, dragInput, dragStart, startPos
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 100, 0, 35)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = MainFrame
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -22, 0, 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.Parent = MainFrame
local VerticalToggleButton = Instance.new("TextButton")
VerticalToggleButton.Name = "VerticalToggleButton"
VerticalToggleButton.Size = UDim2.new(0, 20, 0, 20)
VerticalToggleButton.Position = UDim2.new(1, -22, 0, 24)
VerticalToggleButton.BackgroundTransparency = 1 
VerticalToggleButton.Text = "?"
VerticalToggleButton.TextColor3 = Color3.fromRGB(240, 180, 180)
VerticalToggleButton.Font = Enum.Font.SourceSansBold
VerticalToggleButton.TextSize = 16
VerticalToggleButton.Parent = MainFrame
local VerticalCorner = Instance.new("UICorner")
VerticalCorner.CornerRadius = UDim.new(0, 4)
VerticalCorner.Parent = VerticalToggleButton
local AmbientTextBox = Instance.new("TextBox")
AmbientTextBox.Name = "BrightnessTextBox"
AmbientTextBox.Size = UDim2.new(0, 35, 0, 20)
AmbientTextBox.Position = UDim2.new(0, 10, 0, 50)
AmbientTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AmbientTextBox.BorderSizePixel = 0
AmbientTextBox.Text = tostring(currentBrightness)
AmbientTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmbientTextBox.Font = Enum.Font.SourceSans
AmbientTextBox.TextSize = 14
AmbientTextBox.ClearTextOnFocus = false
AmbientTextBox.Parent = MainFrame
local TextCorner = Instance.new("UICorner")
TextCorner.CornerRadius = UDim.new(0, 4)
TextCorner.Parent = AmbientTextBox
local SliderFrame = Instance.new("Frame")
SliderFrame.Name = "SliderFrame"
SliderFrame.Size = UDim2.new(0, 70, 0, 10)
SliderFrame.Position = UDim2.new(0, 50, 0, 55)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = MainFrame
local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = SliderFrame
local SliderBar = Instance.new("TextButton")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(currentBrightness / 255, 0, 1, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
SliderBar.BorderSizePixel = 0
SliderBar.Text = ""
SliderBar.AutoButtonColor = false
SliderBar.Parent = SliderFrame
local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 4)
BarCorner.Parent = SliderBar
local function updateUIFromBrightness(targetBrightness)
currentBrightness = math.clamp(targetBrightness, 0, 255)
AmbientTextBox.Text = tostring(currentBrightness)
SliderBar.Size = UDim2.new(currentBrightness / 255, 0, 1, 0)
AmbientCLR = Color3.fromRGB(currentBrightness, currentBrightness, currentBrightness)
end
local lastValidText = tostring(currentBrightness)
AmbientTextBox:GetPropertyChangedSignal("Text"):Connect(function()
if AmbientTextBox.Text == "" then return end
local num = tonumber(AmbientTextBox.Text)
if num and num >= 0 and num <= 255 and not string.find(AmbientTextBox.Text, "%D") then
lastValidText = AmbientTextBox.Text
currentBrightness = num
SliderBar.Size = UDim2.new(currentBrightness / 255, 0, 1, 0)
AmbientCLR = Color3.fromRGB(currentBrightness, currentBrightness, currentBrightness)
else
AmbientTextBox.Text = lastValidText
end
end)
AmbientTextBox.FocusLost:Connect(function()
if AmbientTextBox.Text == "" then updateUIFromBrightness(0) end
end)
local isDragging = false
local function updateSliderFromMouse()
local mousePos = UserInputService:GetMouseLocation()
local sliderLeftX = SliderFrame.AbsolutePosition.X
local sliderWidth = SliderFrame.AbsoluteSize.X
local relativeX = mousePos.X - sliderLeftX
local percentage = math.clamp(relativeX / sliderWidth, 0, 1)
updateUIFromBrightness(math.round(percentage * 255))
end
SliderBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
isDragging = true
updateSliderFromMouse()
end
end)
SliderFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
isDragging = true
updateSliderFromMouse()
end
end)
local function updateDrag(input)
local moveGui = input.Position - dragStart
MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + moveGui.X, startPos.Y.Scale, startPos.Y.Offset + moveGui.Y)
end
MainFrame.InputBegan:Connect(function(input)
if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isDragging then
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
MainFrame.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
updateSliderFromMouse()
elseif input == dragInput and dragging then
updateDrag(input)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
isDragging = false 
end
end)
VerticalToggleButton.MouseButton1Click:Connect(function()
if not scriptRunning then return end
fogRemovalEnabled = not fogRemovalEnabled
if fogRemovalEnabled then
VerticalToggleButton.TextColor3 = Color3.fromRGB(180, 240, 180)
else
VerticalToggleButton.TextColor3 = Color3.fromRGB(240, 180, 180)
Lighting.FogStart = originalFogStart
Lighting.FogEnd = originalFogEnd
local currentAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if currentAtmosphere and originalAtmosphereDensity then
currentAtmosphere.Density = originalAtmosphereDensity
end
end
end)
updateConnection = RunService.Heartbeat:Connect(function()
if not scriptRunning then return end
if isEnabled then
Lighting.Ambient = AmbientCLR
Lighting.OutdoorAmbient = AmbientCLR
end
if fogRemovalEnabled then
Lighting.FogStart = 0
Lighting.FogEnd = 99999999
local currentAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if currentAtmosphere then
currentAtmosphere.Density = 0
end
end
end)
ToggleButton.MouseButton1Click:Connect(function()
if not scriptRunning then return end
isEnabled = not isEnabled
if isEnabled then
ToggleButton.Text = "ON"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
else
ToggleButton.Text = "OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Lighting.Ambient = originalAmbient
Lighting.OutdoorAmbient = originalOutdoorAmbient
end
end)
CloseButton.MouseButton1Click:Connect(function()
scriptRunning = false
if updateConnection then
updateConnection:Disconnect()
updateConnection = nil
end
Lighting.Ambient = originalAmbient
Lighting.OutdoorAmbient = originalOutdoorAmbient
Lighting.FogStart = originalFogStart
Lighting.FogEnd = originalFogEnd
local currentAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if currentAtmosphere and originalAtmosphereDensity then
currentAtmosphere.Density = originalAtmosphereDensity
end
ScreenGui:Destroy()
end)
