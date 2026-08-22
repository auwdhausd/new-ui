local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Config = {
    MainColor = Color3.fromRGB(20, 20, 35),
    SecondaryColor = Color3.fromRGB(25, 25, 40),
    SectionColor = Color3.fromRGB(30, 30, 50),
    AccentColor = Color3.fromRGB(120, 120, 255),
    AccentColor2 = Color3.fromRGB(255, 100, 150),
    TextColor = Color3.fromRGB(200, 200, 220),
    DarkTextColor = Color3.fromRGB(140, 140, 160),
    BorderColor = Color3.fromRGB(50, 50, 80),
    ToggleOnColor = Color3.fromRGB(100, 100, 255),
    ToggleOffColor = Color3.fromRGB(60, 60, 80),
    SliderColor = Color3.fromRGB(90, 90, 200),
    ButtonColor = Color3.fromRGB(40, 40, 65),
    DropdownColor = Color3.fromRGB(35, 35, 55),
    AnimationSpeed = 0.2,
}

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.BorderColor
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or Config.AnimationSpeed,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragHandle.InputBegan:Connect(function(input)
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
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

local function GetRainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 0.7, 1)
end

function Library:CreateWindow(title, subtitle)
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VestraUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    window.ScreenGui = screenGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = Config.MainColor
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    CreateCorner(mainFrame, 8)
    CreateStroke(mainFrame, Config.AccentColor, 2, 0.3)
    
    local mainGradient = CreateGradient(mainFrame, Config.MainColor, Config.SecondaryColor, 45)
    
    spawn(function()
        while mainFrame and mainFrame.Parent do
            local rainbowColor = GetRainbowColor()
            for _, obj in pairs(mainFrame:GetDescendants()) do
                if obj:IsA("UIStroke") and obj.Name == "RainbowStroke" then
                    Tween(obj, {Color = rainbowColor}, 0.5)
                end
            end
            wait(0.1)
        end
    end)
    
    local rainbowStroke = CreateStroke(mainFrame, GetRainbowColor(), 2, 0.5)
    rainbowStroke.Name = "RainbowStroke"
    
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundColor3 = Config.SecondaryColor
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    CreateCorner(topBar, 8)
    CreateGradient(topBar, Config.SecondaryColor, Config.SectionColor, 90)
    
    local topBarCover = Instance.new("Frame")
    topBarCover.Size = UDim2.new(1, 0, 0, 8)
    topBarCover.Position = UDim2.new(0, 0, 1, -8)
    topBarCover.BackgroundColor3 = Config.SecondaryColor
    topBarCover.BorderSizePixel = 0
    topBarCover.Parent = topBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 300, 0, 25)
    titleLabel.Position = UDim2.new(0, 20, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Config.TextColor
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleLabel"
    subtitleLabel.Size = UDim2.new(0, 300, 0, 15)
    subtitleLabel.Position = UDim2.new(0, 20, 0, 30)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = subtitle or "Advanced UI Library"
    subtitleLabel.TextColor3 = Config.DarkTextColor
    subtitleLabel.TextSize = 12
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = topBar
    
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, -40, 0, 1)
    separator.Position = UDim2.new(0, 20, 1, -1)
    separator.BackgroundColor3 = Config.BorderColor
    separator.BorderSizePixel = 0
    separator.Parent = topBar
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -40, 0, 35)
    tabContainer.Position = UDim2.new(0, 20, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContainer
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -40, 1, -115)
    contentContainer.Position = UDim2.new(0, 20, 0, 105)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    window.MainFrame = mainFrame
    window.TabContainer = tabContainer
    window.ContentContainer = contentContainer
    
    MakeDraggable(mainFrame, topBar)
    
    function window:CreateTab(name)
        local tab = {}
        tab.Name = name
        tab.Sections = {}
        tab.SectionCount = 0
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name
        tabButton.Size = UDim2.new(0, 120, 1, 0)
        tabButton.BackgroundColor3 = Config.ButtonColor
        tabButton.BorderSizePixel = 0
        tabButton.Text = name
        tabButton.TextColor3 = Config.DarkTextColor
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabContainer
        
        CreateCorner(tabButton, 5)
        
        local tabHighlight = Instance.new("Frame")
        tabHighlight.Name = "Highlight"
        tabHighlight.Size = UDim2.new(1, 0, 0, 2)
        tabHighlight.Position = UDim2.new(0, 0, 1, -2)
        tabHighlight.BackgroundColor3 = Config.AccentColor
        tabHighlight.BorderSizePixel = 0
        tabHighlight.BackgroundTransparency = 1
        tabHighlight.Parent = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        local sectionContainer = Instance.new("Frame")
        sectionContainer.Name = "SectionContainer"
        sectionContainer.Size = UDim2.new(1, 0, 1, 0)
        sectionContainer.BackgroundTransparency = 1
        sectionContainer.Parent = tabContent
        
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.FillDirection = Enum.FillDirection.Horizontal
        sectionLayout.Padding = UDim.new(0, 15)
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        sectionLayout.Parent = sectionContainer
        
        tab.TabButton = tabButton
        tab.TabContent = tabContent
        tab.SectionContainer = sectionContainer
        
        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(window.Tabs) do
                t.TabContent.Visible = false
                Tween(t.TabButton, {TextColor3 = Config.DarkTextColor})
                Tween(t.TabButton:FindFirstChild("Highlight"), {BackgroundTransparency = 1})
            end
            
            tabContent.Visible = true
            Tween(tabButton, {TextColor3 = Config.TextColor})
            Tween(tabHighlight, {BackgroundTransparency = 0})
            window.CurrentTab = tab
        end)
        
        tabButton.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(tabButton, {BackgroundColor3 = Config.SectionColor})
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(tabButton, {BackgroundColor3 = Config.ButtonColor})
            end
        end)
        
        table.insert(window.Tabs, tab)
        
        if #window.Tabs == 1 then
            tabContent.Visible = true
            tabButton.TextColor3 = Config.TextColor
            tabHighlight.BackgroundTransparency = 0
            window.CurrentTab = tab
        end
        
        function tab:CreateSection(sectionName)
            local section = {}
            section.Name = sectionName
            
            tab.SectionCount = tab.SectionCount + 1
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = sectionName
            sectionFrame.Size = UDim2.new(0, 280, 1, 0)
            sectionFrame.BackgroundColor3 = Config.SectionColor
            sectionFrame.BorderSizePixel = 0
            sectionFrame.LayoutOrder = tab.SectionCount
            sectionFrame.Parent = sectionContainer
            
            CreateCorner(sectionFrame, 6)
            CreateStroke(sectionFrame, Config.BorderColor, 1, 0.7)
            CreateGradient(sectionFrame, Config.SectionColor, Config.ButtonColor, 180)
            
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "SectionTitle"
            sectionTitle.Size = UDim2.new(1, -30, 0, 30)
            sectionTitle.Position = UDim2.new(0, 15, 0, 10)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = Config.AccentColor
            sectionTitle.TextSize = 16
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionFrame
            
            local sectionSubtitle = Instance.new("TextLabel")
            sectionSubtitle.Name = "SectionSubtitle"
            sectionSubtitle.Size = UDim2.new(1, -30, 0, 15)
            sectionSubtitle.Position = UDim2.new(0, 15, 0, 35)
            sectionSubtitle.BackgroundTransparency = 1
            sectionSubtitle.Text = "Configure " .. sectionName
            sectionSubtitle.TextColor3 = Config.DarkTextColor
            sectionSubtitle.TextSize = 11
            sectionSubtitle.Font = Enum.Font.Gotham
            sectionSubtitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionSubtitle.Parent = sectionFrame
            
            local contentScroll = Instance.new("ScrollingFrame")
            contentScroll.Name = "ContentScroll"
            contentScroll.Size = UDim2.new(1, -20, 1, -65)
            contentScroll.Position = UDim2.new(0, 10, 0, 55)
            contentScroll.BackgroundTransparency = 1
            contentScroll.BorderSizePixel = 0
            contentScroll.ScrollBarThickness = 3
            contentScroll.ScrollBarImageColor3 = Config.AccentColor
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            contentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
            contentScroll.Parent = sectionFrame
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 8)
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            contentLayout.Parent = contentScroll
            
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
            end)
            
            section.Container = contentScroll
            section.SectionFrame = sectionFrame
            
            function section:AddLabel(text)
                local labelFrame = Instance.new("Frame")
                labelFrame.Name = "Label"
                labelFrame.Size = UDim2.new(1, -10, 0, 25)
                labelFrame.BackgroundTransparency = 1
                labelFrame.Parent = self.Container
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -10, 1, 0)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = Config.TextColor
                label.TextSize = 13
                label.Font = Enum.Font.Gotham
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextWrapped = true
                label.Parent = labelFrame
                
                return label
            end
            
            function section:AddButton(text, callback)
                local buttonFrame = Instance.new("TextButton")
                buttonFrame.Name = "Button"
                buttonFrame.Size = UDim2.new(1, -10, 0, 35)
                buttonFrame.BackgroundColor3 = Config.ButtonColor
                buttonFrame.BorderSizePixel = 0
                buttonFrame.Text = ""
                buttonFrame.AutoButtonColor = false
                buttonFrame.Parent = self.Container
                
                CreateCorner(buttonFrame, 5)
                CreateStroke(buttonFrame, Config.BorderColor, 1, 0.8)
                
                local buttonLabel = Instance.new("TextLabel")
                buttonLabel.Size = UDim2.new(1, -20, 1, 0)
                buttonLabel.Position = UDim2.new(0, 10, 0, 0)
                buttonLabel.BackgroundTransparency = 1
                buttonLabel.Text = text
                buttonLabel.TextColor3 = Config.TextColor
                buttonLabel.TextSize = 14
                buttonLabel.Font = Enum.Font.GothamSemibold
                buttonLabel.TextXAlignment = Enum.TextXAlignment.Center
                buttonLabel.Parent = buttonFrame
                
                buttonFrame.MouseEnter:Connect(function()
                    Tween(buttonFrame, {BackgroundColor3 = Config.AccentColor})
                    Tween(buttonLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)})
                end)
                
                buttonFrame.MouseLeave:Connect(function()
                    Tween(buttonFrame, {BackgroundColor3 = Config.ButtonColor})
                    Tween(buttonLabel, {TextColor3 = Config.TextColor})
                end)
                
                buttonFrame.MouseButton1Click:Connect(function()
                    Tween(buttonFrame, {BackgroundColor3 = Config.AccentColor2}, 0.1)
                    wait(0.1)
                    Tween(buttonFrame, {BackgroundColor3 = Config.AccentColor}, 0.1)
                    if callback then
                        callback()
                    end
                end)
                
                return buttonFrame
            end
            
            function section:AddSeparator(text)
                local separatorFrame = Instance.new("Frame")
                separatorFrame.Name = "Separator"
                separatorFrame.Size = UDim2.new(1, -10, 0, text and 25 or 10)
                separatorFrame.BackgroundTransparency = 1
                separatorFrame.Parent = self.Container
                
                local line = Instance.new("Frame")
                line.Size = text and UDim2.new(1, 0, 0, 1) or UDim2.new(1, 0, 1, 0)
                line.Position = text and UDim2.new(0, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, -0.5)
                line.BackgroundColor3 = Config.BorderColor
                line.BorderSizePixel = 0
                line.Parent = separatorFrame
                
                if text then
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(0, 100, 1, 0)
                    textLabel.Position = UDim2.new(0.5, -50, 0, 0)
                    textLabel.BackgroundColor3 = Config.SectionColor
                    textLabel.Text = " " .. text .. " "
                    textLabel.TextColor3 = Config.DarkTextColor
                    textLabel.TextSize = 12
                    textLabel.Font = Enum.Font.Gotham
                    textLabel.Parent = separatorFrame
                end
                
                return separatorFrame
            end
            
            function section:AddToggle(text, default, callback)
                local toggleState = default or false
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "Toggle"
                toggleFrame.Size = UDim2.new(1, -10, 0, 35)
                toggleFrame.BackgroundColor3 = Config.ButtonColor
                toggleFrame.BorderSizePixel = 0
                toggleFrame.Parent = self.Container
                
                CreateCorner(toggleFrame, 5)
                CreateStroke(toggleFrame, Config.BorderColor, 1, 0.8)
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(1, -60, 1, 0)
                toggleLabel.Position = UDim2.new(0, 10, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = text
                toggleLabel.TextColor3 = toggleState and Config.AccentColor or Config.TextColor
                toggleLabel.TextSize = 13
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                local toggleButton = Instance.new("Frame")
                toggleButton.Name = "ToggleButton"
                toggleButton.Size = UDim2.new(0, 40, 0, 20)
                toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
                toggleButton.BackgroundColor3 = toggleState and Config.ToggleOnColor or Config.ToggleOffColor
                toggleButton.BorderSizePixel = 0
                toggleButton.Parent = toggleFrame
                
                CreateCorner(toggleButton, 10)
                
                local toggleCircle = Instance.new("Frame")
                toggleCircle.Name = "Circle"
                toggleCircle.Size = UDim2.new(0, 16, 0, 16)
                toggleCircle.Position = toggleState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleCircle.BorderSizePixel = 0
                toggleCircle.Parent = toggleButton
                
                CreateCorner(toggleCircle, 8)
                
                local clickButton = Instance.new("TextButton")
                clickButton.Size = UDim2.new(1, 0, 1, 0)
                clickButton.BackgroundTransparency = 1
                clickButton.Text = ""
                clickButton.Parent = toggleFrame
                
                local function updateToggle()
                    Tween(toggleButton, {
                        BackgroundColor3 = toggleState and Config.ToggleOnColor or Config.ToggleOffColor
                    })
                    Tween(toggleCircle, {
                        Position = toggleState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    })
                    Tween(toggleLabel, {
                        TextColor3 = toggleState and Config.AccentColor or Config.TextColor
                    })
                    if callback then
                        callback(toggleState)
                    end
                end
                
                clickButton.MouseButton1Click:Connect(function()
                    toggleState = not toggleState
                    updateToggle()
                end)
                
                clickButton.MouseEnter:Connect(function()
                    Tween(toggleFrame, {BackgroundColor3 = Config.SectionColor})
                end)
                
                clickButton.MouseLeave:Connect(function()
                    Tween(toggleFrame, {BackgroundColor3 = Config.ButtonColor})
                end)
                
                return {
                    SetValue = function(value)
                        toggleState = value
                        updateToggle()
                    end,
                    GetValue = function()
                        return toggleState
                    end
                }
            end
            
            function section:AddSlider(text, min, max, default, callback)
                local sliderValue = default or min
                local dragging = false
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "Slider"
                sliderFrame.Size = UDim2.new(1, -10, 0, 50)
                sliderFrame.BackgroundColor3 = Config.ButtonColor
                sliderFrame.BorderSizePixel = 0
                sliderFrame.Parent = self.Container
                
                CreateCorner(sliderFrame, 5)
                CreateStroke(sliderFrame, Config.BorderColor, 1, 0.8)
                
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(1, -60, 0, 20)
                sliderLabel.Position = UDim2.new(0, 10, 0, 5)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = text
                sliderLabel.TextColor3 = Config.TextColor
                sliderLabel.TextSize = 13
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 50, 0, 20)
                valueLabel.Position = UDim2.new(1, -55, 0, 5)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(math.floor(sliderValue))
                valueLabel.TextColor3 = Config.AccentColor
                valueLabel.TextSize = 14
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = sliderFrame
                
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Name = "Track"
                sliderTrack.Size = UDim2.new(1, -20, 0, 4)
                sliderTrack.Position = UDim2.new(0, 10, 1, -15)
                sliderTrack.BackgroundColor3 = Config.ToggleOffColor
                sliderTrack.BorderSizePixel = 0
                sliderTrack.Parent = sliderFrame
                
                CreateCorner(sliderTrack, 2)
                
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Size = UDim2.new(0, 0, 1, 0)
                sliderFill.BackgroundColor3 = Config.SliderColor
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderTrack
                
                CreateCorner(sliderFill, 2)
                CreateGradient(sliderFill, Config.AccentColor, Config.AccentColor2, 90)
                
                local sliderHandle = Instance.new("Frame")
                sliderHandle.Name = "Handle"
                sliderHandle.Size = UDim2.new(0, 12, 0, 12)
                sliderHandle.Position = UDim2.new(1, -6, 0.5, -6)
                sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderHandle.BorderSizePixel = 0
                sliderHandle.Parent = sliderFill
                
                CreateCorner(sliderHandle, 6)
                
                local handleStroke = CreateStroke(sliderHandle, Config.AccentColor, 2, 0)
                
                local function updateSlider(value)
                    sliderValue = math.clamp(value, min, max)
                    local percent = (sliderValue - min) / (max - min)
                    
                    Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    valueLabel.Text = tostring(math.floor(sliderValue))
                    
                    if callback then
                        callback(sliderValue)
                    end
                end
                
                local function onInputPosition(input)
                    local trackSize = sliderTrack.AbsoluteSize.X
                    local trackPos = sliderTrack.AbsolutePosition.X
                    local mousePos = input.Position.X
                    
                    local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                    local value = min + (max - min) * percent
                    
                    updateSlider(value)
                end
                
                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        onInputPosition(input)
                        Tween(sliderHandle, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}, 0.15)
                    end
                end)
                
                sliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        Tween(sliderHandle, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)}, 0.15)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        onInputPosition(input)
                    end
                end)
                
                updateSlider(sliderValue)
                
                return {
                    SetValue = function(value)
                        updateSlider(value)
                    end,
                    GetValue = function()
                        return sliderValue
                    end
                }
            end
            
            function section:AddDropdown(text, options, default, callback)
                local dropdownOpen = false
                local currentValue = default or options[1] or "None"
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "Dropdown"
                dropdownFrame.Size = UDim2.new(1, -10, 0, 35)
                dropdownFrame.BackgroundColor3 = Config.ButtonColor
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.ClipsDescendants = true
                dropdownFrame.Parent = self.Container
                
                CreateCorner(dropdownFrame, 5)
                CreateStroke(dropdownFrame, Config.BorderColor, 1, 0.8)
                
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Size = UDim2.new(1, -100, 0, 35)
                dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = text
                dropdownLabel.TextColor3 = Config.TextColor
                dropdownLabel.TextSize = 13
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame
                
                local selectedLabel = Instance.new("TextLabel")
                selectedLabel.Size = UDim2.new(0, 80, 0, 35)
                selectedLabel.Position = UDim2.new(1, -90, 0, 0)
                selectedLabel.BackgroundTransparency = 1
                selectedLabel.Text = currentValue
                selectedLabel.TextColor3 = Config.AccentColor
                selectedLabel.TextSize = 12
                selectedLabel.Font = Enum.Font.GothamBold
                selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
                selectedLabel.Parent = dropdownFrame
                
                local arrowLabel = Instance.new("TextLabel")
                arrowLabel.Size = UDim2.new(0, 20, 0, 35)
                arrowLabel.Position = UDim2.new(1, -20, 0, 0)
                arrowLabel.BackgroundTransparency = 1
                arrowLabel.Text = "+"
                arrowLabel.TextColor3 = Config.TextColor
                arrowLabel.TextSize = 16
                arrowLabel.Font = Enum.Font.GothamBold
                arrowLabel.Parent = dropdownFrame
                
                local optionsContainer = Instance.new("Frame")
                optionsContainer.Name = "Options"
                optionsContainer.Size = UDim2.new(1, 0, 0, 0)
                optionsContainer.Position = UDim2.new(0, 0, 0, 35)
                optionsContainer.BackgroundTransparency = 1
                optionsContainer.Parent = dropdownFrame
                
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Parent = optionsContainer
                
                for i, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = option
                    optionButton.Size = UDim2.new(1, 0, 0, 28)
                    optionButton.BackgroundColor3 = Config.DropdownColor
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = Config.TextColor
                    optionButton.TextSize = 12
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.AutoButtonColor = false
                    optionButton.LayoutOrder = i
                    optionButton.Parent = optionsContainer
                    
                    optionButton.MouseEnter:Connect(function()
                        Tween(optionButton, {BackgroundColor3 = Config.AccentColor})
                        Tween(optionButton, {TextColor3 = Color3.fromRGB(255, 255, 255)})
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        Tween(optionButton, {BackgroundColor3 = Config.DropdownColor})
                        Tween(optionButton, {TextColor3 = Config.TextColor})
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        currentValue = option
                        selectedLabel.Text = option
                        
                        dropdownOpen = false
                        Tween(dropdownFrame, {Size = UDim2.new(1, -10, 0, 35)})
                        Tween(arrowLabel, {Rotation = 0})
                        
                        if callback then
                            callback(option)
                        end
                    end)
                end
                
                local clickButton = Instance.new("TextButton")
                clickButton.Size = UDim2.new(1, 0, 0, 35)
                clickButton.BackgroundTransparency = 1
                clickButton.Text = ""
                clickButton.ZIndex = 2
                clickButton.Parent = dropdownFrame
                
                clickButton.MouseButton1Click:Connect(function()
                    dropdownOpen = not dropdownOpen
                    
                    if dropdownOpen then
                        local optionsHeight = optionsLayout.AbsoluteContentSize.Y
                        Tween(dropdownFrame, {Size = UDim2.new(1, -10, 0, 35 + optionsHeight)})
                        Tween(arrowLabel, {Rotation = 45})
                    else
                        Tween(dropdownFrame, {Size = UDim2.new(1, -10, 0, 35)})
                        Tween(arrowLabel, {Rotation = 0})
                    end
                end)
                
                clickButton.MouseEnter:Connect(function()
                    if not dropdownOpen then
                        Tween(dropdownFrame, {BackgroundColor3 = Config.SectionColor})
                    end
                end)
                
                clickButton.MouseLeave:Connect(function()
                    if not dropdownOpen then
                        Tween(dropdownFrame, {BackgroundColor3 = Config.ButtonColor})
                    end
                end)
                
                return {
                    SetValue = function(value)
                        currentValue = value
                        selectedLabel.Text = value
                    end,
                    GetValue = function()
                        return currentValue
                    end,
                    Refresh = function(newOptions, newDefault)
                        optionsContainer:ClearAllChildren()
                        
                        local newLayout = Instance.new("UIListLayout")
                        newLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        newLayout.Parent = optionsContainer
                        
                        for i, option in ipairs(newOptions) do
                            local optionButton = Instance.new("TextButton")
                            optionButton.Name = option
                            optionButton.Size = UDim2.new(1, 0, 0, 28)
                            optionButton.BackgroundColor3 = Config.DropdownColor
                            optionButton.BorderSizePixel = 0
                            optionButton.Text = option
                            optionButton.TextColor3 = Config.TextColor
                            optionButton.TextSize = 12
                            optionButton.Font = Enum.Font.Gotham
                            optionButton.AutoButtonColor = false
                            optionButton.LayoutOrder = i
                            optionButton.Parent = optionsContainer
                            
                            optionButton.MouseEnter:Connect(function()
                                Tween(optionButton, {BackgroundColor3 = Config.AccentColor})
                            end)
                            
                            optionButton.MouseLeave:Connect(function()
                                Tween(optionButton, {BackgroundColor3 = Config.DropdownColor})
                            end)
                            
                            optionButton.MouseButton1Click:Connect(function()
                                currentValue = option
                                selectedLabel.Text = option
                                
                                dropdownOpen = false
                                Tween(dropdownFrame, {Size = UDim2.new(1, -10, 0, 35)})
                                Tween(arrowLabel, {Rotation = 0})
                                
                                if callback then
                                    callback(option)
                                end
                            end)
                        end
                        
                        currentValue = newDefault or newOptions[1] or "None"
                        selectedLabel.Text = currentValue
                    end
                }
            end
            
            function section:AddKeybind(text, defaultKey, callback)
                local currentKey = defaultKey or "None"
                local listening = false
                local connection
                
                local keybindFrame = Instance.new("Frame")
                keybindFrame.Name = "Keybind"
                keybindFrame.Size = UDim2.new(1, -10, 0, 35)
                keybindFrame.BackgroundColor3 = Config.ButtonColor
                keybindFrame.BorderSizePixel = 0
                keybindFrame.Parent = self.Container
                
                CreateCorner(keybindFrame, 5)
                CreateStroke(keybindFrame, Config.BorderColor, 1, 0.8)
                
                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Size = UDim2.new(1, -90, 1, 0)
                keybindLabel.Position = UDim2.new(0, 10, 0, 0)
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.Text = text
                keybindLabel.TextColor3 = Config.TextColor
                keybindLabel.TextSize = 13
                keybindLabel.Font = Enum.Font.Gotham
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                keybindLabel.Parent = keybindFrame
                
                local keyButton = Instance.new("TextButton")
                keyButton.Size = UDim2.new(0, 75, 0, 25)
                keyButton.Position = UDim2.new(1, -80, 0.5, -12.5)
                keyButton.BackgroundColor3 = Config.DropdownColor
                keyButton.BorderSizePixel = 0
                keyButton.Text = "[" .. currentKey .. "]"
                keyButton.TextColor3 = Config.AccentColor
                keyButton.TextSize = 12
                keyButton.Font = Enum.Font.GothamBold
                keyButton.AutoButtonColor = false
                keyButton.Parent = keybindFrame
                
                CreateCorner(keyButton, 4)
                
                keyButton.MouseEnter:Connect(function()
                    if not listening then
                        Tween(keyButton, {BackgroundColor3 = Config.SectionColor})
                    end
                end)
                
                keyButton.MouseLeave:Connect(function()
                    if not listening then
                        Tween(keyButton, {BackgroundColor3 = Config.DropdownColor})
                    end
                end)
                
                keyButton.MouseButton1Click:Connect(function()
                    listening = true
                    keyButton.Text = "[...]"
                    Tween(keyButton, {BackgroundColor3 = Config.AccentColor})
                end)
                
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode.Name
                        keyButton.Text = "[" .. currentKey .. "]"
                        listening = false
                        Tween(keyButton, {BackgroundColor3 = Config.DropdownColor})
                        
                        if callback then
                            callback(currentKey)
                        end
                    end
                    
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode.Name == currentKey and callback then
                            callback(currentKey)
                        end
                    end
                end)
                
                return {
                    SetKey = function(key)
                        currentKey = key
                        keyButton.Text = "[" .. key .. "]"
                    end,
                    GetKey = function()
                        return currentKey
                    end,
                    Destroy = function()
                        if connection then
                            connection:Disconnect()
                        end
                    end
                }
            end
            
            function section:AddTextbox(text, placeholder, callback)
                local textboxFrame = Instance.new("Frame")
                textboxFrame.Name = "Textbox"
                textboxFrame.Size = UDim2.new(1, -10, 0, 60)
                textboxFrame.BackgroundColor3 = Config.ButtonColor
                textboxFrame.BorderSizePixel = 0
                textboxFrame.Parent = self.Container
                
                CreateCorner(textboxFrame, 5)
                CreateStroke(textboxFrame, Config.BorderColor, 1, 0.8)
                
                local textboxLabel = Instance.new("TextLabel")
                textboxLabel.Size = UDim2.new(1, -20, 0, 20)
                textboxLabel.Position = UDim2.new(0, 10, 0, 5)
                textboxLabel.BackgroundTransparency = 1
                textboxLabel.Text = text
                textboxLabel.TextColor3 = Config.TextColor
                textboxLabel.TextSize = 13
                textboxLabel.Font = Enum.Font.Gotham
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                textboxLabel.Parent = textboxFrame
                
                local textbox = Instance.new("TextBox")
                textbox.Size = UDim2.new(1, -20, 0, 28)
                textbox.Position = UDim2.new(0, 10, 0, 27)
                textbox.BackgroundColor3 = Config.DropdownColor
                textbox.BorderSizePixel = 0
                textbox.Text = ""
                textbox.PlaceholderText = placeholder or "Enter text..."
                textbox.TextColor3 = Config.TextColor
                textbox.PlaceholderColor3 = Config.DarkTextColor
                textbox.TextSize = 12
                textbox.Font = Enum.Font.Gotham
                textbox.ClearTextOnFocus = false
                textbox.Parent = textboxFrame
                
                CreateCorner(textbox, 4)
                
                textbox.Focused:Connect(function()
                    Tween(textbox, {BackgroundColor3 = Config.SectionColor})
                end)
                
                textbox.FocusLost:Connect(function(enterPressed)
                    Tween(textbox, {BackgroundColor3 = Config.DropdownColor})
                    if enterPressed and callback then
                        callback(textbox.Text)
                    end
                end)
                
                return {
                    SetText = function(txt)
                        textbox.Text = txt
                    end,
                    GetText = function()
                        return textbox.Text
                    end
                }
            end
            
            table.insert(tab.Sections, section)
            return section
        end
        
        return tab
    end
    
    function window:Destroy()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end
    
    function window:Toggle()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end
    
    return window
end

return Library
