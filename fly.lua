local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local isEnabled = false
local scriptRunning = true
local flyConnection = nil
local antiVoidConnection = nil
local flySpeed = 20
local verticalControlsEnabled = false 
local bodyVelocity = nil
local bodyGyro = nil
local keysPressed = {}
local ANTIVOID_HEIGHT = workspace.FallenPartsDestroyHeight + 120
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyControllerGui"
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
local SpeedTextBox = Instance.new("TextBox")
SpeedTextBox.Name = "SpeedTextBox"
SpeedTextBox.Size = UDim2.new(0, 35, 0, 20)
SpeedTextBox.Position = UDim2.new(0, 10, 0, 50)
SpeedTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedTextBox.BorderSizePixel = 0
SpeedTextBox.Text = table.concat({tostring(flySpeed)})
SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTextBox.Font = Enum.Font.SourceSans
SpeedTextBox.TextSize = 14
SpeedTextBox.ClearTextOnFocus = false
SpeedTextBox.Parent = MainFrame
local TextCorner = Instance.new("UICorner")
TextCorner.CornerRadius = UDim.new(0, 4)
TextCorner.Parent = SpeedTextBox
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
SliderBar.Size = UDim2.new(flySpeed / 1000, 0, 1, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
SliderBar.BorderSizePixel = 0
SliderBar.Text = ""
SliderBar.AutoButtonColor = false
SliderBar.Parent = SliderFrame
local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 4)
BarCorner.Parent = SliderBar
local function updateUIFromSpeed(targetSpeed)
flySpeed = math.clamp(targetSpeed, 0, 1000)
SpeedTextBox.Text = tostring(flySpeed)
SliderBar.Size = UDim2.new(flySpeed / 1000, 0, 1, 0)
end
local lastValidText = tostring(flySpeed)
SpeedTextBox:GetPropertyChangedSignal("Text"):Connect(function()
if SpeedTextBox.Text == "" then return end
local num = tonumber(SpeedTextBox.Text)
if num and num >= 0 and num <= 1000 and not string.find(SpeedTextBox.Text, "%D") then
lastValidText = SpeedTextBox.Text
flySpeed = num
SliderBar.Size = UDim2.new(flySpeed / 1000, 0, 1, 0)
else
SpeedTextBox.Text = lastValidText
end
end)
SpeedTextBox.FocusLost:Connect(function()
if SpeedTextBox.Text == "" then updateUIFromSpeed(0) end
end)
local isDragging = false
local function updateSliderFromMouse()
local mousePos = UserInputService:GetMouseLocation()
local sliderLeftX = SliderFrame.AbsolutePosition.X
local sliderWidth = SliderFrame.AbsoluteSize.X
local relativeX = mousePos.X - sliderLeftX
local percentage = math.clamp(relativeX / sliderWidth, 0, 1)
updateUIFromSpeed(math.round(percentage * 1000))
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
verticalControlsEnabled = not verticalControlsEnabled
if verticalControlsEnabled then
VerticalToggleButton.TextColor3 = Color3.fromRGB(180, 240, 180)
else
VerticalToggleButton.TextColor3 = Color3.fromRGB(240, 180, 180)
end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
keysPressed[input.KeyCode] = true
end)
UserInputService.InputEnded:Connect(function(input)
keysPressed[input.KeyCode] = nil
end)
local bodyPosition = nil
local function startFly()
if flyConnection then flyConnection:Disconnect() end
local camera = workspace.CurrentCamera
local character = localPlayer.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if not hrp or not humanoid then return end
local animator = humanoid:FindFirstChildOfClass("Animator")
if animator then
for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
track:Stop(0)
end
end
if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
local lastPosition = hrp.Position
flyConnection = RunService.Heartbeat:Connect(function()
if not isEnabled or not scriptRunning then return end
character = localPlayer.Character
hrp = character and character:FindFirstChild("HumanoidRootPart")
humanoid = character and character:FindFirstChildOfClass("Humanoid")
if hrp then
if animator then
for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
track:Stop(0)
end
end
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
local cameraLook = camera.CFrame.LookVector
local moveVector = Vector3.new(0, 0, 0)
if keysPressed[Enum.KeyCode.W] then moveVector = moveVector + cameraLook end
if keysPressed[Enum.KeyCode.S] then moveVector = moveVector - cameraLook end
if keysPressed[Enum.KeyCode.A] then moveVector = moveVector - camera.CFrame.RightVector end
if keysPressed[Enum.KeyCode.D] then moveVector = moveVector + camera.CFrame.RightVector end
if verticalControlsEnabled then
if keysPressed[Enum.KeyCode.Space] then moveVector = moveVector + Vector3.new(0, 1, 0) end
if keysPressed[Enum.KeyCode.LeftShift] then moveVector = moveVector - Vector3.new(0, 1, 0) end
end
if moveVector.Magnitude > 0 then
local speedMultiplier = (flySpeed / 10) * 1.5
lastPosition = lastPosition + (moveVector.Unit * speedMultiplier)
end
hrp.CFrame = CFrame.lookAt(lastPosition, lastPosition + cameraLook)
end
end)
end
local function stopFly()
if flyConnection then
flyConnection:Disconnect()
flyConnection = nil
end
local character = localPlayer.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
end
if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end
local function startAntiVoid()
if antiVoidConnection then antiVoidConnection:Disconnect() end
local camera = workspace.CurrentCamera
antiVoidConnection = RunService.Heartbeat:Connect(function()
if not scriptRunning then return end
local character = localPlayer.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
if hrp and hrp.Position.Y <= ANTIVOID_HEIGHT then
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
if not isEnabled then
local voidMoveVector = Vector3.new(0, 0, 0)
if keysPressed[Enum.KeyCode.W] then voidMoveVector = voidMoveVector + camera.CFrame.LookVector end
if keysPressed[Enum.KeyCode.S] then voidMoveVector = voidMoveVector - camera.CFrame.LookVector end
if keysPressed[Enum.KeyCode.A] then voidMoveVector = voidMoveVector - camera.CFrame.RightVector end
if keysPressed[Enum.KeyCode.D] then voidMoveVector = voidMoveVector + camera.CFrame.RightVector end
voidMoveVector = Vector3.new(voidMoveVector.X, 0, voidMoveVector.Z)
if voidMoveVector.Magnitude > 0 then
hrp.AssemblyLinearVelocity = voidMoveVector.Unit * 80
end
end
hrp.CFrame = CFrame.new(hrp.Position.X, ANTIVOID_HEIGHT + 0.01, hrp.Position.Z)
end
end)
end
localPlayer.CharacterAdded:Connect(function(newCharacter)
if not scriptRunning then return end
newCharacter:WaitForChild("HumanoidRootPart")
if isEnabled then
task.wait(0.1)
startFly()
end
end)
startAntiVoid()
ToggleButton.MouseButton1Click:Connect(function()
if not scriptRunning then return end
isEnabled = not isEnabled
if isEnabled then
ToggleButton.Text = "ON"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
startFly()
else
ToggleButton.Text = "OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopFly()
end
end)
CloseButton.MouseButton1Click:Connect(function()
scriptRunning = false
stopFly()
if antiVoidConnection then
antiVoidConnection:Disconnect()
antiVoidConnection = nil
end
ScreenGui:Destroy()
end)
