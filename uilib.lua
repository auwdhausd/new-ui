--[[
    Vestra/Exodus Style UI Library for Roblox
    Advanced UI with Tabs, Sections, and More Components
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI Configuration
local Config = {
    MainColor = Color3.fromRGB(20, 20, 30),
    SecondaryColor = Color3.fromRGB(30, 30, 45),
    TabColor = Color3.fromRGB(25, 25, 38),
    AccentColor = Color3.fromRGB(100, 100, 255),
    AccentColor2 = Color3.fromRGB(255, 50, 100),
    TextColor = Color3.fromRGB(200, 200, 220),
    BorderColor = Color3.fromRGB(60, 60, 90),
    
    AnimationSpeed = 0.15,
    CornerRadius = UDim.new(0, 6),
}

-- Utility: Create Rainbow Color
local function GetRainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 0.8, 1)
end

-- Create Window
function UILibrary:CreateWindow(title)
    local self = setmetatable({}, UILibrary)
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "VestraUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 700, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Config.MainColor
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = Config.CornerRadius
    mainCorner.Parent = self.MainFrame
    
    -- Border Glow
    local glow = Instance.new("UIStroke")
    glow.Color = Config.AccentColor
    glow.Thickness = 2
    glow.Transparency = 0.5
    glow.Parent = self.MainFrame
    
    -- Animated Rainbow Border
    spawn(function()
        while wait(0.1) do
            if self.MainFrame and self.MainFrame.Parent then
                glow.Color = GetRainbowColor()
            else
                break
            end
        end
    end)
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundColor3 = Config.SecondaryColor
    topBar.BorderSizePixel = 0
    topBar.Parent = self.MainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = Config.CornerRadius
    topCorner.Parent = topBar
    
    local bottomCover = Instance.new("Frame")
    bottomCover.Size = UDim2.new(1, 0, 0, 6)
    bottomCover.Position = UDim2.new(0, 0, 1, -6)
    bottomCover.BackgroundColor3 = Config.SecondaryColor
    bottomCover.BorderSizePixel = 0
    bottomCover.Parent = topBar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Config.TextColor
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Tab Container (Top Bar)
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, -230, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 220, 0, 5)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = topBar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = self.TabContainer
    
    -- Content Area
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "Content"
    self.ContentContainer.Size = UDim2.new(1, -20, 1, -65)
    self.ContentContainer.Position = UDim2.new(0, 10, 0, 55)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, topBar)
    
    return self
end

-- Make Draggable
function UILibrary:MakeDraggable(frame, handle)
    local dragging, dragInput, mousePos, framePos
    
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
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Tab
function UILibrary:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Sections = {}
    
    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundColor3 = Config.TabColor
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Config.TextColor
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    -- Tab Content Frame
    tab.ContentFrame = Instance.new("ScrollingFrame")
    tab.ContentFrame.Name = name .. "Content"
    tab.ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    tab.ContentFrame.BackgroundTransparency = 1
    tab.ContentFrame.BorderSizePixel = 0
    tab.ContentFrame.ScrollBarThickness = 4
    tab.ContentFrame.ScrollBarImageColor3 = Config.AccentColor
    tab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.ContentFrame.Visible = false
    tab.ContentFrame.Parent = self.ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tab.ContentFrame
    
    -- Show/Hide tab
    tabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.ContentFrame.Visible = false
            t.Button.BackgroundColor3 = Config.TabColor
        end
        tab.ContentFrame.Visible = true
        tabButton.BackgroundColor3 = Config.SecondaryColor
        self.CurrentTab = tab
    end)
    
    tab.Button = tabButton
    table.insert(self.Tabs, tab)
    
    -- Show first tab by default
    if #self.Tabs == 1 then
        tabButton.BackgroundColor3 = Config.SecondaryColor
        tab.ContentFrame.Visible = true
        self.CurrentTab = tab
    end
    
    -- Create Section function
    function tab:CreateSection(sectionName)
        local section = {}
        section.Name = sectionName
        
        -- Section Frame
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = sectionName
        sectionFrame.Size = UDim2.new(0, 330, 1, 0)
        sectionFrame.BackgroundColor3 = Config.SecondaryColor
        sectionFrame.BorderSizePixel = 0
        sectionFrame.Parent = tab.ContentFrame
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = Config.CornerRadius
        sectionCorner.Parent = sectionFrame
        
        -- Section Title
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, -20, 0, 30)
        sectionTitle.Position = UDim2.new(0, 10, 0, 10)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = sectionName
        sectionTitle.TextColor3 = Config.AccentColor
        sectionTitle.TextSize = 16
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Parent = sectionFrame
        
        -- Section Content
        section.Container = Instance.new("ScrollingFrame")
        section.Container.Size = UDim2.new(1, -20, 1, -50)
        section.Container.Position = UDim2.new(0, 10, 0, 40)
        section.Container.BackgroundTransparency = 1
        section.Container.BorderSizePixel = 0
        section.Container.ScrollBarThickness = 3
        section.Container.ScrollBarImageColor3 = Config.AccentColor
        section.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
        section.Container.Parent = sectionFrame
        
        local containerLayout = Instance.new("UIListLayout")
        containerLayout.Padding = UDim.new(0, 8)
        containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        containerLayout.Parent = section.Container
        
        containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Container.CanvasSize = UDim2.new(0, 0, 0, containerLayout.AbsoluteContentSize.Y + 10)
        end)
        
        section.AddLabel = function(self, text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Config.TextColor
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = section.Container
            return label
        end
        
        section.AddButton = function(self, text, callback)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, 35)
            button.BackgroundColor3 = Config.TabColor
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = Config.TextColor
            button.TextSize = 14
            button.Font = Enum.Font.GothamSemibold
            button.Parent = section.Container
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = button
            
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Config.AccentColor}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Config.TabColor}):Play()
            end)
            
            button.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            
            return button
        end
        
        section.AddSeparator = function(self)
            local separator = Instance.new("Frame")
            separator.Size = UDim2.new(1, 0, 0, 2)
            separator.BackgroundColor3 = Config.BorderColor
            separator.BorderSizePixel = 0
            separator.Parent = section.Container
            return separator
        end
        
        section.AddToggle = function(self, text, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 35)
            toggleFrame.BackgroundColor3 = Config.TabColor
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = section.Container
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 4)
            toggleCorner.Parent = toggleFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Config.TextColor
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame
            
            local toggleButton = Instance.new("Frame")
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            toggleButton.BorderSizePixel = 0
            toggleButton.Parent = toggleFrame
            
            local toggleBtnCorner = Instance.new("UICorner")
            toggleBtnCorner.CornerRadius = UDim.new(1, 0)
            toggleBtnCorner.Parent = toggleButton
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = Config.TextColor
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle
            
            local toggled = default or false
            
            local function update()
                local tweenInfo = TweenInfo.new(Config.AnimationSpeed, Enum.EasingStyle.Quad)
                if toggled then
                    TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Config.AccentColor}):Play()
                    TweenService:Create(toggleCircle, tweenInfo, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                    label.TextColor3 = Config.AccentColor
                else
                    TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
                    TweenService:Create(toggleCircle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                    label.TextColor3 = Config.TextColor
                end
                if callback then callback(toggled) end
            end
            
            update()
            
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = toggleFrame
            
            clickBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                update()
            end)
            
            return {
                SetValue = function(val)
                    toggled = val
                    update()
                end,
                GetValue = function()
                    return toggled
                end
            }
        end
        
        section.AddSlider = function(self, text, min, max, default, callback)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 50)
            sliderFrame.BackgroundColor3 = Config.TabColor
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = section.Container
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 4)
            sliderCorner.Parent = sliderFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Config.TextColor
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Position = UDim2.new(1, -55, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default or min)
            valueLabel.TextColor3 = Config.AccentColor
            valueLabel.TextSize = 13
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -20, 0, 4)
            track.Position = UDim2.new(0, 10, 1, -15)
            track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            track.BorderSizePixel = 0
            track.Parent = sliderFrame
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Config.AccentColor
            fill.BorderSizePixel = 0
            fill.Parent = track
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill
            
            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 12, 0, 12)
            handle.Position = UDim2.new(0, -6, 0.5, -6)
            handle.BackgroundColor3 = Config.TextColor
            handle.BorderSizePixel = 0
            handle.Parent = fill
            
            local handleCorner = Instance.new("UICorner")
            handleCorner.CornerRadius = UDim.new(1, 0)
            handleCorner.Parent = handle
            
            local value = default or min
            local dragging = false
            
            local function update(val)
                value = math.clamp(val, min, max)
                local percent = (value - min) / (max - min)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                valueLabel.Text = tostring(math.floor(value))
                if callback then callback(value) end
            end
            
            update(value)
            
            local function onInput(input)
                if dragging then
                    local trackSize = track.AbsoluteSize.X
                    local trackPos = track.AbsolutePosition.X
                    local mousePos = input.Position.X
                    local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                    update(min + (max - min) * percent)
                end
            end
            
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    onInput(input)
                end
            end)
            
            track.InputEnded:Connect(function(input)
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
                SetValue = function(val) update(val) end,
                GetValue = function() return value end
            }
        end
        
        section.AddDropdown = function(self, text, options, default, callback)
            local dropFrame = Instance.new("Frame")
            dropFrame.Size = UDim2.new(1, 0, 0, 35)
            dropFrame.BackgroundColor3 = Config.TabColor
            dropFrame.BorderSizePixel = 0
            dropFrame.ClipsDescendants = true
            dropFrame.Parent = section.Container
            
            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 4)
            dropCorner.Parent = dropFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -110, 0, 35)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Config.TextColor
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = dropFrame
            
            local selected = Instance.new("TextLabel")
            selected.Size = UDim2.new(0, 90, 0, 35)
            selected.Position = UDim2.new(1, -100, 0, 0)
            selected.BackgroundTransparency = 1
            selected.Text = default or options[1] or "NONE"
            selected.TextColor3 = Config.AccentColor
            selected.TextSize = 12
            selected.Font = Enum.Font.GothamBold
            selected.TextXAlignment = Enum.TextXAlignment.Right
            selected.Parent = dropFrame
            
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 0, 35)
            arrow.Position = UDim2.new(1, -20, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "+"
            arrow.TextColor3 = Config.TextColor
            arrow.TextSize = 16
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = dropFrame
            
            local optionsContainer = Instance.new("Frame")
            optionsContainer.Size = UDim2.new(1, 0, 0, 0)
            optionsContainer.Position = UDim2.new(0, 0, 0, 35)
            optionsContainer.BackgroundTransparency = 1
            optionsContainer.Parent = dropFrame
            
            local optLayout = Instance.new("UIListLayout")
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optLayout.Parent = optionsContainer
            
            local isOpen = false
            local currentValue = default or options[1]
            
            for _, option in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 28)
                optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                optBtn.BorderSizePixel = 0
                optBtn.Text = option
                optBtn.TextColor3 = Config.TextColor
                optBtn.TextSize = 12
                optBtn.Font = Enum.Font.Gotham
                optBtn.Parent = optionsContainer
                
                optBtn.MouseEnter:Connect(function()
                    optBtn.BackgroundColor3 = Config.AccentColor
                end)
                
                optBtn.MouseLeave:Connect(function()
                    optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                end)
                
                optBtn.MouseButton1Click:Connect(function()
                    currentValue = option
                    selected.Text = option
                    if callback then callback(option) end
                    
                    isOpen = false
                    TweenService:Create(dropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                end)
            end
            
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 0, 35)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.ZIndex = 2
            clickBtn.Parent = dropFrame
            
            clickBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                
                if isOpen then
                    local height = optLayout.AbsoluteContentSize.Y
                    TweenService:Create(dropFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 35 + height)}):Play()
                    TweenService:Create(arrow, tweenInfo, {Rotation = 45}):Play()
                else
                    TweenService:Create(dropFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    TweenService:Create(arrow, tweenInfo, {Rotation = 0}):Play()
                end
            end)
            
            return {
                SetValue = function(val)
                    currentValue = val
                    selected.Text = val
                end,
                GetValue = function()
                    return currentValue
                end
            }
        end
        
        section.AddKeybind = function(self, text, defaultKey, callback)
            local keybindFrame = Instance.new("Frame")
            keybindFrame.Size = UDim2.new(1, 0, 0, 35)
            keybindFrame.BackgroundColor3 = Config.TabColor
            keybindFrame.BorderSizePixel = 0
            keybindFrame.Parent = section.Container
            
            local keybindCorner = Instance.new("UICorner")
            keybindCorner.CornerRadius = UDim.new(0, 4)
            keybindCorner.Parent = keybindFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -100, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Config.TextColor
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = keybindFrame
            
            local keyButton = Instance.new("TextButton")
            keyButton.Size = UDim2.new(0, 80, 0, 25)
            keyButton.Position = UDim2.new(1, -85, 0.5, -12.5)
            keyButton.BackgroundColor3 = Config.SecondaryColor
            keyButton.BorderSizePixel = 0
            keyButton.Text = "[" .. (defaultKey or "NONE") .. "]"
            keyButton.TextColor3 = Config.AccentColor
            keyButton.TextSize = 12
            keyButton.Font = Enum.Font.GothamBold
            keyButton.Parent = keybindFrame
            
            local keyCorner = Instance.new("UICorner")
            keyCorner.CornerRadius = UDim.new(0, 4)
            keyCorner.Parent = keyButton
            
            local currentKey = defaultKey
            local listening = false
            
            keyButton.MouseButton1Click:Connect(function()
                listening = true
                keyButton.Text = "[...]"
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    keyButton.Text = "[" .. currentKey .. "]"
                    listening = false
                    if callback then callback(currentKey) end
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
                end
            }
        end
        
        section.AddBox = function(self, text, placeholder, callback)
            local boxFrame = Instance.new("Frame")
            boxFrame.Size = UDim2.new(1, 0, 0, 60)
            boxFrame.BackgroundColor3 = Config.TabColor
            boxFrame.BorderSizePixel = 0
            boxFrame.Parent = section.Container
            
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 4)
            boxCorner.Parent = boxFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Config.TextColor
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = boxFrame
            
            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -20, 0, 25)
            textBox.Position = UDim2.new(0, 10, 0, 28)
            textBox.BackgroundColor3 = Config.SecondaryColor
            textBox.BorderSizePixel = 0
            textBox.PlaceholderText = placeholder or ""
            textBox.Text = ""
            textBox.TextColor3 = Config.TextColor
            textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
            textBox.TextSize = 12
            textBox.Font = Enum.Font.Gotham
            textBox.ClearTextOnFocus = false
            textBox.Parent = boxFrame
            
            local textCorner = Instance.new("UICorner")
            textCorner.CornerRadius = UDim.new(0, 4)
            textCorner.Parent = textBox
            
            textBox.FocusLost:Connect(function()
                if callback then callback(textBox.Text) end
            end)
            
            return {
                SetText = function(txt)
                    textBox.Text = txt
                end,
                GetText = function()
                    return textBox.Text
                end
            }
        end
        
        table.insert(tab.Sections, section)
        return section
    end
    
    return tab
end

return UILibrary
