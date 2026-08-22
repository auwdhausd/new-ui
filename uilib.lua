--[[
    CS:GO Style UI Library for Roblox
    Modern, sleek UI components
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI Configuration
local Config = {
    MainColor = Color3.fromRGB(30, 30, 30),
    SecondaryColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(255, 180, 0), -- CS:GO Orange
    TextColor = Color3.fromRGB(255, 255, 255),
    BorderColor = Color3.fromRGB(60, 60, 60),
    
    AnimationSpeed = 0.2,
    CornerRadius = UDim.new(0, 4),
}

-- Create Main GUI
function UILibrary:CreateWindow(title)
    local self = setmetatable({}, UILibrary)
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CSGOUILibrary"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 550, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Config.MainColor
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = Config.CornerRadius
    mainCorner.Parent = self.MainFrame
    
    -- Border/Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.BorderColor
    stroke.Thickness = 1
    stroke.Parent = self.MainFrame
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Config.AccentColor
    topBar.BorderSizePixel = 0
    topBar.Parent = self.MainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = Config.CornerRadius
    topCorner.Parent = topBar
    
    -- Fix bottom corners
    local bottomCover = Instance.new("Frame")
    bottomCover.Size = UDim2.new(1, 0, 0, 4)
    bottomCover.Position = UDim2.new(0, 0, 1, -4)
    bottomCover.BackgroundColor3 = Config.AccentColor
    bottomCover.BorderSizePixel = 0
    bottomCover.Parent = topBar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Config.TextColor
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Content Container
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "Content"
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 50)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ScrollBarThickness = 4
    self.ContentFrame.ScrollBarImageColor3 = Config.AccentColor
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentFrame.Parent = self.MainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = self.ContentFrame
    
    -- Auto-resize canvas
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, topBar)
    
    return self
end

-- Make window draggable
function UILibrary:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Toggle
function UILibrary:CreateToggle(text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundColor3 = Config.SecondaryColor
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Config.CornerRadius
    corner.Parent = toggleFrame
    
    -- Text Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle Button
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = toggleButton
    
    -- Toggle Circle
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Config.TextColor
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    -- State
    local toggled = default or false
    
    local function updateToggle()
        local tweenInfo = TweenInfo.new(Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if toggled then
            TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Config.AccentColor}):Play()
            TweenService:Create(toggleCircle, tweenInfo, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(toggleCircle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        
        if callback then
            callback(toggled)
        end
    end
    
    -- Initial state
    updateToggle()
    
    -- Click handler
    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = toggleFrame
    
    clickButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)
    
    return {
        SetValue = function(value)
            toggled = value
            updateToggle()
        end,
        GetValue = function()
            return toggled
        end
    }
end

-- Create Slider
function UILibrary:CreateSlider(text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider"
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundColor3 = Config.SecondaryColor
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Config.CornerRadius
    corner.Parent = sliderFrame
    
    -- Text Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    -- Value Label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default or min)
    valueLabel.TextColor3 = Config.AccentColor
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    -- Slider Track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -20, 0, 4)
    sliderTrack.Position = UDim2.new(0, 10, 1, -15)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    -- Slider Fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Config.AccentColor
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    -- Slider Handle
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "Handle"
    sliderHandle.Size = UDim2.new(0, 12, 0, 12)
    sliderHandle.Position = UDim2.new(0, -6, 0.5, -6)
    sliderHandle.BackgroundColor3 = Config.TextColor
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Parent = sliderFill
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = sliderHandle
    
    -- State
    local value = default or min
    local dragging = false
    
    local function updateSlider(val)
        value = math.clamp(val, min, max)
        local percent = (value - min) / (max - min)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(math.floor(value))
        
        if callback then
            callback(value)
        end
    end
    
    -- Initial value
    updateSlider(value)
    
    -- Drag handler
    local function onInput(input)
        if dragging then
            local trackSize = sliderTrack.AbsoluteSize.X
            local trackPos = sliderTrack.AbsolutePosition.X
            local mousePos = input.Position.X
            
            local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            local newValue = min + (max - min) * percent
            
            updateSlider(newValue)
        end
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            onInput(input)
        end
    end)
    
    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            onInput(input)
        end
    end)
    
    return {
        SetValue = function(val)
            updateSlider(val)
        end,
        GetValue = function()
            return value
        end
    }
end

-- Create Dropdown
function UILibrary:CreateDropdown(text, options, default, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    dropdownFrame.BackgroundColor3 = Config.SecondaryColor
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = self.ContentFrame
    dropdownFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Config.CornerRadius
    corner.Parent = dropdownFrame
    
    -- Text Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 35)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    -- Selected Value
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(0, 100, 0, 35)
    selectedLabel.Position = UDim2.new(1, -110, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = default or options[1] or "None"
    selectedLabel.TextColor3 = Config.AccentColor
    selectedLabel.TextSize = 14
    selectedLabel.Font = Enum.Font.GothamBold
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    selectedLabel.Parent = dropdownFrame
    
    -- Arrow Icon
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 0, 35)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Config.TextColor
    arrow.TextSize = 12
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = dropdownFrame
    
    -- Options Container
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "Options"
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.Position = UDim2.new(0, 0, 0, 35)
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Parent = dropdownFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = optionsContainer
    
    -- State
    local isOpen = false
    local currentValue = default or options[1]
    
    -- Create option buttons
    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Config.TextColor
        optionButton.TextSize = 13
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = optionsContainer
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Config.AccentColor
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            currentValue = option
            selectedLabel.Text = option
            
            if callback then
                callback(option)
            end
            
            -- Close dropdown
            isOpen = false
            local tweenInfo = TweenInfo.new(Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(dropdownFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 35)}):Play()
            TweenService:Create(arrow, tweenInfo, {Rotation = 0}):Play()
        end)
    end
    
    -- Toggle dropdown
    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 0, 35)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.ZIndex = 2
    clickButton.Parent = dropdownFrame
    
    clickButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        local tweenInfo = TweenInfo.new(Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if isOpen then
            local optionsHeight = listLayout.AbsoluteContentSize.Y
            TweenService:Create(dropdownFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 35 + optionsHeight)}):Play()
            TweenService:Create(arrow, tweenInfo, {Rotation = 180}):Play()
        else
            TweenService:Create(dropdownFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 35)}):Play()
            TweenService:Create(arrow, tweenInfo, {Rotation = 0}):Play()
        end
    end)
    
    return {
        SetValue = function(value)
            currentValue = value
            selectedLabel.Text = value
        end,
        GetValue = function()
            return currentValue
        end
    }
end

return UILibrary
