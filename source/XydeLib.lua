local XydeLib = {}

-- ==========================================
-- SERWISY I ZMIENNE
-- ==========================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

XydeLib.Flags = {} 
XydeLib.Folder = "XydeConfig" 

-- ==========================================
-- MOTYW (THEME)
-- ==========================================
local theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(25, 25, 25),
    Section = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(148, 0, 211), -- Fioletowy Akcent
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(170, 170, 170),
    Outline = Color3.fromRGB(50, 50, 50)
}

-- ==========================================
-- GŁÓWNA FUNKCJA (CREATE WINDOW)
-- ==========================================
function XydeLib:CreateWindow(settings)
    local Window = {}
    Window.Tabs = {}
    
    if not isfolder(XydeLib.Folder) then makefolder(XydeLib.Folder) end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XydeLibUI_v2"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if pcall(function() ScreenGui.Parent = CoreGui end) then else ScreenGui.Parent = Players.LocalPlayer.PlayerGui end

    -- Ukrywanie Menu (Right Shift)
    local uiVisible = true
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightShift then
            uiVisible = not uiVisible
            ScreenGui.Enabled = uiVisible
        end
    end)

    -- Główna Rama
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = theme.Accent
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame

    -- Pasek Tytułowy
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = theme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = settings.Name or "Xyde Script"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- Kontener na Zakładki
    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(0, 130, 1, -40)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = theme.Sidebar
    TabHolder.BorderSizePixel = 0
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabHolder
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.Parent = TabHolder

    -- Kontener na Strony
    local PageHolder = Instance.new("Frame")
    PageHolder.Name = "PageHolder"
    PageHolder.Size = UDim2.new(1, -130, 1, -40)
    PageHolder.Position = UDim2.new(0, 130, 0, 40)
    PageHolder.BackgroundTransparency = 1
    PageHolder.Parent = MainFrame

    -- Przesuwanie Okna (Draggable)
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    TopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ==========================================
    -- SYSTEM CONFIG I POWIADOMIENIA
    -- ==========================================
    
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Size = UDim2.new(0, 300, 1, -20)
    NotificationHolder.Position = UDim2.new(1, -320, 0, 10)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ScreenGui
    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.Padding = UDim.new(0, 5)
    NotifyLayout.Parent = NotificationHolder

    function Window:Notify(config)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.BackgroundColor3 = theme.Section
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = NotificationHolder
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = theme.Accent
        stroke.Thickness = 1
        
        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 6)

        local title = Instance.new("TextLabel", frame)
        title.Text = config.Title or "Info"
        title.Size = UDim2.new(1, -10, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.TextColor3 = theme.Accent
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left

        local content = Instance.new("TextLabel", frame)
        content.Text = config.Content or ""
        content.Size = UDim2.new(1, -10, 0, 30)
        content.Position = UDim2.new(0, 10, 0, 25)
        content.BackgroundTransparency = 1
        content.TextColor3 = theme.Text
        content.Font = Enum.Font.Gotham
        content.TextSize = 13
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextWrapped = true

        frame:TweenSize(UDim2.new(1, 0, 0, 60), "Out", "Quad", 0.3)
        task.delay(config.Duration or 3, function()
            frame:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.3)
            task.wait(0.3)
            frame:Destroy()
        end)
    end

    function Window:SaveConfig(name)
        if writefile then
            local json = HttpService:JSONEncode(XydeLib.Flags)
            writefile(XydeLib.Folder .. "/" .. name .. ".json", json)
            Window:Notify({Title = "Config", Content = "Zapisano: " .. name, Duration = 2})
        end
    end

    function Window:LoadConfig(name)
        if isfile and isfile(XydeLib.Folder .. "/" .. name .. ".json") then
            local json = readfile(XydeLib.Folder .. "/" .. name .. ".json")
            local data = HttpService:JSONDecode(json)
            for flag, value in pairs(data) do
                XydeLib.Flags[flag] = value
            end
            Window:Notify({Title = "Config", Content = "Wczytano: " .. name, Duration = 2})
        end
    end

    function Window:SendWebhook(url, content)
        local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if not request then return end
        request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({content = content, username = "Xyde Script"})
        })
    end

    -- ==========================================
    -- SYSTEM ZAKŁADEK (TABS)
    -- ==========================================
    function Window:CreateTab(name)
        local Tab = {}
        local first = false
        if #Window.Tabs == 0 then first = true end

        local TabButton = Instance.new("TextButton")
        TabButton.Text = name
        TabButton.Size = UDim2.new(1, -10, 0, 30)
        TabButton.BackgroundColor3 = first and theme.Accent or theme.Background
        TabButton.TextColor3 = theme.Text
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 13
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabHolder
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = theme.Accent
        Page.Visible = first
        Page.Parent = PageHolder

        local PLayout = Instance.new("UIListLayout", Page)
        PLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PLayout.Padding = UDim.new(0, 6)
        
        local PPad = Instance.new("UIPadding", Page)
        PPad.PaddingTop = UDim.new(0, 10)
        PPad.PaddingLeft = UDim.new(0, 10)
        PPad.PaddingRight = UDim.new(0, 10)

        PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y + 20)
        end)

        table.insert(Window.Tabs, {Btn = TabButton, Page = Page})

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.Background}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.Accent}):Play()
        end)

        -- ==========================================
        -- ELEMENTY UI
        -- ==========================================

        function Tab:CreateSection(text)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 25)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = theme.Accent
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SectionFrame
        end

        function Tab:CreateLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = theme.TextDark
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Page
        end

        function Tab:CreateButton(options)
            local callback = options.Callback or function() end
            local Button = Instance.new("TextButton")
            Button.Name = options.Name
            Button.Text = options.Name
            Button.Size = UDim2.new(1, 0, 0, 35)
            Button.BackgroundColor3 = theme.Section
            Button.TextColor3 = theme.Text
            Button.Font = Enum.Font.GothamSemibold
            Button.TextSize = 13
            Button.AutoButtonColor = false
            Button.Parent = Page
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

            Button.MouseButton1Click:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = theme.Accent}):Play()
                task.wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = theme.Section}):Play()
                if callback then pcall(callback) end
            end)
        end

        function Tab:CreateToggle(options)
            local toggled = options.Default or false
            local flag = options.Flag or options.Name
            XydeLib.Flags[flag] = toggled

            local Frame = Instance.new("TextButton")
            Frame.Text = ""
            Frame.Size = UDim2.new(1, 0, 0, 35)
            Frame.BackgroundColor3 = theme.Section
            Frame.AutoButtonColor = false
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

            local Title = Instance.new("TextLabel", Frame)
            Title.Text = options.Name
            Title.Size = UDim2.new(1, -50, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame", Frame)
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -46, 0.5, -9)
            Switch.BackgroundColor3 = toggled and theme.Accent or Color3.fromRGB(60,60,60)
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame", Switch)
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Dot.BackgroundColor3 = theme.Text
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            Frame.MouseButton1Click:Connect(function()
                toggled = not toggled
                XydeLib.Flags[flag] = toggled
                local tColor = toggled and theme.Accent or Color3.fromRGB(60,60,60)
                local tPos = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = tColor}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = tPos}):Play()
                if options.Callback then options.Callback(toggled) end
            end)
        end

        function Tab:CreateSlider(options)
            local min, max = options.Min or 0, options.Max or 100
            local default = options.Default or min
            local value = default
            local flag = options.Flag or options.Name
            XydeLib.Flags[flag] = value

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 45)
            Frame.BackgroundColor3 = theme.Section
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

            local Title = Instance.new("TextLabel", Frame)
            Title.Text = options.Name
            Title.Size = UDim2.new(1, -10, 0, 20)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel", Frame)
            ValueLabel.Text = tostring(value)
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3 = theme.TextDark
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local BarBg = Instance.new("TextButton", Frame)
            BarBg.Text = ""
            BarBg.Size = UDim2.new(1, -20, 0, 6)
            BarBg.Position = UDim2.new(0, 10, 0, 30)
            BarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            BarBg.AutoButtonColor = false
            Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", BarBg)
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = theme.Accent
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local function Update(input)
                local percent = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * percent)
                ValueLabel.Text = tostring(value)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                XydeLib.Flags[flag] = value
                if options.Callback then options.Callback(value) end
            end

            local sliding = false
            BarBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
            end)
        end

        function Tab:CreateInput(options)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 40)
            Frame.BackgroundColor3 = theme.Section
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

            local Title = Instance.new("TextLabel", Frame)
            Title.Text = options.Name
            Title.Size = UDim2.new(0.4, 0, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local BoxBg = Instance.new("Frame", Frame)
            BoxBg.Size = UDim2.new(0.5, 0, 0, 24)
            BoxBg.Position = UDim2.new(0.45, 0, 0.5, -12)
            BoxBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", BoxBg).CornerRadius = UDim.new(0, 4)

            local Box = Instance.new("TextBox", BoxBg)
            Box.Size = UDim2.new(1, -10, 1, 0)
            Box.Position = UDim2.new(0, 5, 0, 0)
            Box.BackgroundTransparency = 1
            Box.Text = options.Default or ""
            Box.PlaceholderText = options.Placeholder or "..."
            Box.TextColor3 = theme.Text
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 13
            
            Box.FocusLost:Connect(function(enter)
                XydeLib.Flags[options.Flag or options.Name] = Box.Text
                if options.Callback then options.Callback(Box.Text) end
            end)
        end

        function Tab:CreateDropdown(options)
            local dropped = false
            local list = options.Options or {}
            local current = options.Default or list[1] or "Select..."
            local flag = options.Flag or options.Name
            XydeLib.Flags[flag] = current

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 35)
            Frame.BackgroundColor3 = theme.Section
            Frame.ClipsDescendants = true
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

            local DropBtn = Instance.new("TextButton", Frame)
            DropBtn.Size = UDim2.new(1, 0, 0, 35)
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = ""
            
            local Title = Instance.new("TextLabel", DropBtn)
            Title.Text = options.Name
            Title.Size = UDim2.new(0.5, 0, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local Selected = Instance.new("TextLabel", DropBtn)
            Selected.Text = current .. " v"
            Selected.Size = UDim2.new(0.5, -10, 1, 0)
            Selected.Position = UDim2.new(0.5, 0, 0, 0)
            Selected.BackgroundTransparency = 1
            Selected.TextColor3 = theme.TextDark
            Selected.Font = Enum.Font.Gotham
            Selected.TextSize = 13
            Selected.TextXAlignment = Enum.TextXAlignment.Right

            local Container = Instance.new("ScrollingFrame", Frame)
            Container.Size = UDim2.new(1, 0, 0, 100)
            Container.Position = UDim2.new(0, 0, 0, 35)
            Container.BackgroundTransparency = 1
            Container.ScrollBarThickness = 2
            Container.CanvasSize = UDim2.new(0,0,0,0)
            
            local DLayout = Instance.new("UIListLayout", Container)
            DLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            DLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.CanvasSize = UDim2.new(0, 0, 0, DLayout.AbsoluteContentSize.Y)
            end)

            local function RefreshList()
                for _, v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(list) do
                    local btn = Instance.new("TextButton", Container)
                    btn.Size = UDim2.new(1, 0, 0, 25)
                    btn.BackgroundColor3 = theme.Section
                    btn.Text = opt
                    btn.TextColor3 = theme.TextDark
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 13
                    btn.MouseButton1Click:Connect(function()
                        current = opt
                        Selected.Text = current .. " v"
                        XydeLib.Flags[flag] = current
                        if options.Callback then options.Callback(current) end
                        dropped = false
                        Frame:TweenSize(UDim2.new(1, 0, 0, 35), "In", "Quad", 0.2)
                    end)
                end
            end
            RefreshList()

            DropBtn.MouseButton1Click:Connect(function()
                dropped = not dropped
                if dropped then
                    Frame:TweenSize(UDim2.new(1, 0, 0, 135), "Out", "Quad", 0.2)
                else
                    Frame:TweenSize(UDim2.new(1, 0, 0, 35), "In", "Quad", 0.2)
                end
            end)
        end

        function Tab:CreateBind(options)
            local key = options.Default or Enum.KeyCode.E
            local binding = false
            local flag = options.Flag or options.Name
            
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 35)
            Frame.BackgroundColor3 = theme.Section
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

            local Title = Instance.new("TextLabel", Frame)
            Title.Text = options.Name
            Title.Size = UDim2.new(0.5, 0, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local BindBtn = Instance.new("TextButton", Frame)
            BindBtn.Text = key.Name
            BindBtn.Size = UDim2.new(0, 80, 0, 24)
            BindBtn.Position = UDim2.new(1, -90, 0.5, -12)
            BindBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            BindBtn.TextColor3 = theme.Text
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.TextSize = 12
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)

            BindBtn.MouseButton1Click:Connect(function()
                binding = true
                BindBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    BindBtn.Text = key.Name
                    binding = false
                    XydeLib.Flags[flag] = key
                    if options.Callback then options.Callback(key) end
                elseif input.KeyCode == key and not binding then
                    if options.Callback then options.Callback(key) end
                end
            end)
        end

        return Tab
    end

    -- ==========================================
    -- WSTECZNA KOMPATYBILNOŚĆ
    -- ==========================================
    local MainTab = Window:CreateTab("Main")
    function Window:CreateLabel(txt) MainTab:CreateLabel(txt) end
    function Window:CreateToggle(opts) MainTab:CreateToggle(opts) end
    function Window:CreateButton(opts) MainTab:CreateButton(opts) end
    function Window:CreateInput(opts) MainTab:CreateInput(opts) end
    function Window:CreateSlider(opts) MainTab:CreateSlider(opts) end
    function Window:CreateDropdown(opts) MainTab:CreateDropdown(opts) end
    function Window:CreateBind(opts) MainTab:CreateBind(opts) end

    return Window
end

return XydeLib
