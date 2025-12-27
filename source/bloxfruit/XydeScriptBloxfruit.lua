local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Roblox-GUI-libs/refs/heads/main/source/Rayfield.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Xyde Script - Blox Fruits",
    Icon = "scroll-text",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Macha",
    Theme = {
        TextColor = Color3.fromRGB(255, 255, 255),
        Background = Color3.fromRGB(15, 15, 15),
        Topbar = Color3.fromRGB(25, 25, 25),
        Shadow = Color3.fromRGB(0, 0, 0),
        NotificationBackground = Color3.fromRGB(20, 20, 20),
        NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
        TabBackground = Color3.fromRGB(40, 40, 40),
        TabStroke = Color3.fromRGB(160, 80, 220),
        TabBackgroundSelected = Color3.fromRGB(130, 40, 210),
        TabTextColor = Color3.fromRGB(255, 255, 255),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(30, 30, 30),
        ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
        SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
        ElementStroke = Color3.fromRGB(60, 60, 60),
        SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
        SliderBackground = Color3.fromRGB(60, 30, 80),
        SliderProgress = Color3.fromRGB(148, 0, 211),
        SliderStroke = Color3.fromRGB(180, 100, 230),
        ToggleBackground = Color3.fromRGB(30, 30, 30),
        ToggleEnabled = Color3.fromRGB(148, 0, 211),
        ToggleDisabled = Color3.fromRGB(100, 100, 100),
        ToggleEnabledStroke = Color3.fromRGB(180, 100, 230),
        ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
        ToggleEnabledOuterStroke = Color3.fromRGB(60, 20, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
        DropdownSelected = Color3.fromRGB(40, 30, 50),
        DropdownUnselected = Color3.fromRGB(30, 30, 30),
        InputBackground = Color3.fromRGB(30, 30, 30),
        InputStroke = Color3.fromRGB(160, 80, 220),
        PlaceholderColor = Color3.fromRGB(178, 178, 178)
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Xreaper", -- Dodano cudzysłów
        FileName = "cfg"
    },
    Discord = {
        Enabled = true,
        Invite = discord, -- Wstawiono kod zaproszenia jako string
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "Enter Key",
        Subtitle = "Join Discord",
        Note = "Join our discord to get key",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"admin"}
    }
})

Rayfield:Notify({
    Title = "Welcome",
    Content = "Use K to hide/unhide menu",
    Duration = 6.5,
    Image = "skull",
})

local PlayerTab = Window:CreateTab("Player", "user")
local Section = PlayerTab:CreateSection("Movement")

local Speed = PlayerTab:CreateSlider({
    Name = "Player speed multiplier",
    Range = {1, 30},
    Increment = 0.1,
    Suffix = "x Speed",
    CurrentValue = 1,
    Flag = "Speed",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local function applySpeedMultiplier()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            character:SetAttribute("SpeedMultiplier", Value)
            -- Opcjonalnie bezpośrednia zmiana speeda jeśli atrybut nie działa
            -- humanoid.WalkSpeed = 16 * Value 
        end
        applySpeedMultiplier()
        player.CharacterAdded:Connect(function()
            applySpeedMultiplier()
        end)
    end,
})

local Slider = PlayerTab:CreateSlider({
    Name = "Dash length",
    Range = {1, 800},
    Increment = 1,
    Suffix = "Length", -- Usunięto błąd ",1"
    CurrentValue = 1,
    Flag = "DashLenght",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local function applyDashLength()
            local character = player.Character or player.CharacterAdded:Wait()
            character:SetAttribute("DashLength", Value)
        end
        applyDashLength()
        player.CharacterAdded:Connect(function()
            applyDashLength()
        end)
    end,
})

local JumpSlider = PlayerTab:CreateSlider({
    Name = "Jump Height",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Height",
    CurrentValue = 50,
    Flag = "Height",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local function applyJump()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.JumpPower = Value
        end
        applyJump()
        player.CharacterAdded:Connect(function()
            applyJump()
        end)
    end,
})

local Toggle = PlayerTab:CreateToggle({
    Name = "Greater melee range",
    CurrentValue = false,
    Flag = "largeattackrange",
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- Sprawdź czy ręce istnieją
        local rHand = character:FindFirstChild("RightHand")
        local lHand = character:FindFirstChild("LeftHand")
        
        if rHand and lHand then
            if Value then
                rHand.Size = Vector3.new(1, 1, 50)
                lHand.Size = Vector3.new(1, 1, 50)
                lHand.Transparency = 1
                rHand.Transparency = 1
            else
                rHand.Size = Vector3.new(1, 1, 1)
                lHand.Size = Vector3.new(1, 1, 1)
                lHand.Transparency = 0
                rHand.Transparency = 0
            end
        end
    end,
})

local Section = PlayerTab:CreateSection("Teleport")
------------------------- --TELEPORT--------------------------------------

local Keybind = PlayerTab:CreateKeybind({
    Name = "Teleport to nearest player",
    CurrentKeybind = "None",
    HoldToInteract = false,
    Flag = "Keybind1",
    Callback = function(Keybind)
        local localPlayer = game.Players.LocalPlayer
        local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local localHRP = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localHRP then
            Rayfield:Notify({Title = "Error", Content = "RootPart not found!", Duration = 3})
            return
        end

        local nearestPlayer = nil
        local nearestDistance = math.huge

        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = player.Character.HumanoidRootPart
                local distance = (targetHRP.Position - localHRP.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end

        if nearestPlayer and nearestPlayer.Character then
            local targetHRP = nearestPlayer.Character.HumanoidRootPart
            local newCFrame = targetHRP.CFrame * CFrame.new(0, 0, -5)
            localHRP.CFrame = newCFrame
            Rayfield:Notify({Title = "Teleport", Content = "Teleported to: " .. nearestPlayer.Name, Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "No player found!", Duration = 3})
        end
    end,
})

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local targetPlayerName = nil -- Zmienna do przechowywania wybranego gracza

-- Pobierz listę graczy
local options = {}
for _, plr in ipairs(Players:GetPlayers()) do
    table.insert(options, plr.Name)
end

local SelectPlayer = PlayerTab:CreateDropdown({
    Name = "Select Player",
    Options = options,
    CurrentOption = { options[1] or "No player" },
    MultipleOptions = false,
    Flag = "TeleportToPlayer",
    Callback = function(Options)
        targetPlayerName = Options[1]
    end,
})

local TeleportPlayerRefreshButton = PlayerTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        local newOptions = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(newOptions, plr.Name)
        end
        SelectPlayer:Refresh(newOptions)
        if #newOptions > 0 then
            SelectPlayer:Set({ newOptions[1] })
        else
            SelectPlayer:Set({ "No player" })
        end
    end,
})

local TeleportButton = PlayerTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        if not targetPlayerName then return end
        
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")

        local tPlayer = Players:FindFirstChild(targetPlayerName)
        if not tPlayer then
            Rayfield:Notify({Title = "Error", Content = "Player left or not found", Duration = 3})
            return
        end

        local tCharacter = tPlayer.Character or tPlayer.CharacterAdded:Wait()
        local tHRP = tCharacter:WaitForChild("HumanoidRootPart")

        -- Funkcja Noclip
        local function setNoclip(state)
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
        end

        setNoclip(true)
        hrp.Anchored = false

        local speed = 350
        local distance = (hrp.Position - tHRP.Position).Magnitude
        local tweenTime = distance / speed

        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, { CFrame = tHRP.CFrame })

        tween.Completed:Connect(function()
            hrp.Anchored = false
            setNoclip(false)
            -- Reset atrybutu (jeśli był zmieniany)
            character:SetAttribute("SpeedMultiplier", 1)
        end)

        tween:Play()
    end,
})

------------------------------------------------------------------
-- Sekcja Teleport do Miejscówek
local firstsea  = 2753915549
local secondsea = 4442272183
local thirdsea  = 7449423635

local TeleportLocations = {} 

if game.PlaceId == firstsea then
    TeleportLocations = {
        ["Second sea"]   = Vector3.new(-1163, 7, 1727),
        ["Middle Town"]  = Vector3.new(-689, 8, 1583),
        ["Jungle"]       = Vector3.new(-1440, 61, 5),
        ["Coloseum"]     = Vector3.new(-1650, 56, -3169),
        ["Desert"]       = Vector3.new(1216, 32, 4366),
        ["Marine Base"]  = Vector3.new(-4934, 165, 4324),
        ["Prison"]       = Vector3.new(5272, 69, 747),
        ["Sky"]          = Vector3.new(-4631, 848, -1939)
        -- Dodaj resztę wg potrzeb, skróciłem dla czytelności
    }
elseif game.PlaceId == secondsea then
    TeleportLocations = {
        ["Port"]         = Vector3.new(109, 18, 2832),
        ["Cafe"]         = Vector3.new(-377, 72, 322),
        ["Mansion"]      = Vector3.new(-337, 330, 643),
        ["Factory"]      = Vector3.new(272, 84, -274),
        ["Green Zone"]   = Vector3.new(-2440, 72, -3216)
    }
elseif game.PlaceId == thirdsea then
    TeleportLocations = {
        ["Port"]         = Vector3.new(-384, 20, 5438),
        ["Castle"]       = Vector3.new(-5075, 370, -3174),
        ["Mansion"]      = Vector3.new(-12634, 458, -7429),
        ["Hydra"]        = Vector3.new(4370, 1250, 583)
    }
else
    -- Fallback aby kod nie wywalił błędu w złym miejscu
    TeleportLocations = { ["Not Supported Place"] = Vector3.new(0,0,0) }
end

local locationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(locationNames, name)
end
-- Sortowanie nazw alfabetycznie dla wygody
table.sort(locationNames)

local selectedLocation = locationNames[1]

local TeleportDropdown = PlayerTab:CreateDropdown({
    Name = "Select Location",
    Options = locationNames,
    CurrentOption = { locationNames[1] },
    MultipleOptions = false,
    Flag = "TeleportLocation",
    Callback = function(Options)
        selectedLocation = Options[1]
    end,
})

local TeleportLocationButton = PlayerTab:CreateButton({
    Name = "Teleport to Location",
    Callback = function()
        local destination = TeleportLocations[selectedLocation]
        if not destination then return end

        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        
        local distance = (destination - hrp.Position).Magnitude
        local duration = distance / 350
        
        -- Noclip na czas lotu
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(destination) })
        
        tween.Completed:Connect(function()
             for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end)

        tween:Play()
        
        Rayfield:Notify({
            Title = "Teleporting",
            Content = "Going to " .. selectedLocation,
            Duration = 5,
            Image = "rewind",
        })
    end,
})

local Section = PlayerTab:CreateSection("Misc")

local Button = PlayerTab:CreateButton({
    Name = "Unload UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-------------------------ESP----------------------------------
local ESPTab = Window:CreateTab("ESP", "eye")

local ESPEnabledGlobal = false
local ShowOutline = false
local ShowFill = false
local ShowUsername = false
local ShowLevel = false
local ShowFruit = false
local ESPOutlineColor = Color3.fromRGB(255,255,255)
local ESPFillColor = Color3.fromRGB(255,0,0)

local function createESP(player, character)
    if character:FindFirstChild("ESPHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Adornee = character
    highlight.FillTransparency = ShowFill and 0.5 or 1
    highlight.FillColor = ESPFillColor
    highlight.OutlineTransparency = ShowOutline and 0 or 1
    highlight.OutlineColor = ESPOutlineColor
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPInfo"
    billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 150, 0, 50) -- Zwiększono lekko wysokość
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextSize = 14
    textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textLabel.TextStrokeTransparency = 0 -- Dodano obrys tekstu dla czytelności
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    local function updateText()
        local info = ""
        if ShowUsername then
            info = info .. player.Name .. "\n"
        end
        if ShowLevel then
            local level = "N/A"
            if player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
                level = tostring(player.Data.Level.Value)
            end
            info = info .. "Lvl: " .. level .. "\n"
        end
        if ShowFruit then
            local fruit = "N/A"
            if player:FindFirstChild("Data") and player.Data:FindFirstChild("DevilFruit") then
                fruit = tostring(player.Data.DevilFruit.Value)
            end
            info = info .. "Fruit: " .. fruit
        end
        textLabel.Text = info
    end

    updateText()
    
    -- Lepsza pętla niż while wait()
    task.spawn(function()
        while character and character.Parent do
            updateText()
            task.wait(1)
        end
    end)
end

local function removeESP(character)
    if not character then return end
    local highlight = character:FindFirstChild("ESPHighlight")
    if highlight then highlight:Destroy() end
    local billboard = character:FindFirstChild("ESPInfo")
    if billboard then billboard:Destroy() end
end

local ToggleESP = ESPTab:CreateToggle({
    Name = "Toggle ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESPEnabledGlobal = Value
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                if Value then
                    createESP(player, player.Character)
                else
                    removeESP(player.Character)
                end
            end
        end
    end,
})

local ToggleOutline = ESPTab:CreateToggle({
    Name = "ESP Outline",
    CurrentValue = false,
    Flag = "espoutlineaaa",
    Callback = function(Value)
        ShowOutline = Value
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if highlight then
                    highlight.OutlineTransparency = ShowOutline and 0 or 1
                end
            end
        end
    end,
})

local ToggleESPFill = ESPTab:CreateToggle({
    Name = "ESP Fill",
    CurrentValue = false,
    Flag = "espfill",
    Callback = function(Value)
        ShowFill = Value
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if highlight then
                    highlight.FillTransparency = ShowFill and 0.5 or 1
                end
            end
        end
    end,
})

local ToggleUsername = ESPTab:CreateToggle({
    Name = "Show Username",
    CurrentValue = false,
    Flag = "Tuser",
    Callback = function(Value) ShowUsername = Value end,
})

local ToggleLevel = ESPTab:CreateToggle({
    Name = "Show Level",
    CurrentValue = false,
    Flag = "levbelsad",
    Callback = function(Value) ShowLevel = Value end,
})

local ToggleFruit = ESPTab:CreateToggle({
    Name = "Show Fruit",
    CurrentValue = false,
    Flag = "Toggle121",
    Callback = function(Value) ShowFruit = Value end,
})

local ESPOutLinecolorpicker = ESPTab:CreateColorPicker({
    Name = "ESP Outline Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "ESPoutlinecolor",
    Callback = function(Value)
        ESPOutlineColor = Value
        for _, player in ipairs(game.Players:GetPlayers()) do
           if player ~= game.Players.LocalPlayer and player.Character then
               local highlight = player.Character:FindFirstChild("ESPHighlight")
               if highlight then
                   highlight.OutlineColor = ESPOutlineColor
               end
           end
        end
    end,
})

local ESPFillcolorpicker = ESPTab:CreateColorPicker({
    Name = "ESP Fill Color",
    Color = Color3.fromRGB(255,0,0),
    Flag = "ESPFillColor",
    Callback = function(Value)
        ESPFillColor = Value
        for _, player in ipairs(game.Players:GetPlayers()) do
           if player ~= game.Players.LocalPlayer and player.Character then
               local highlight = player.Character:FindFirstChild("ESPHighlight")
               if highlight then
                   highlight.FillColor = ESPFillColor
               end
           end
        end
    end,
})

game.Players.PlayerAdded:Connect(function(player)
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            if ESPEnabledGlobal then
                createESP(player, character)
            end
        end)
    end
end)
