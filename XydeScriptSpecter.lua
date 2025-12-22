local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Roblox-GUI-libs/refs/heads/main/Rayfield.lua'))()

-- ============================================================================
-- 1. SERWISY I ZMIENNE
-- ============================================================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Foldery gry
local Map = Workspace:FindFirstChild("Map")
local EvidenceFolder = Workspace:WaitForChild("Dynamic"):WaitForChild("Evidence")
local GhostNPCs = Workspace:WaitForChild("NPCs")
local Van = Workspace:WaitForChild("Van")

-- Zmienne globalne skryptu
getgenv().GhostRoom = nil
local ESP_Settings = {Ghost = false, Players = false, Items = false, Evidence = false}
local HuntNotify = false

-- ============================================================================
-- 2. FUNKCJE POMOCNICZE (LOGIKA)
-- ============================================================================

-- Funkcja Teleportacji (Twoja ulepszona wersja z Noclipem i Anchorem)
local function tp(x, y, z)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    local oldAnchored = root.Anchored
    root.Anchored = true
    
    -- Wyłącz kolizję na chwilę
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local targetCFrame = CFrame.new(x, y, z)
    local distance = (targetCFrame.Position - root.Position).Magnitude
    local speed = 100 -- Prędkość lotu
    local info = TweenInfo.new(distance/speed, Enum.EasingStyle.Linear)
    
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()

    -- Przywróć stan
    root.Anchored = oldAnchored
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

-- Funkcja ESP (Podświetlanie + Napis)
local function UpdateESP()
    local function CreateHighlight(model, text, color)
        if not model then return end
        if not model:FindFirstChild("MyESP") then
            local hl = Instance.new("Highlight")
            hl.Name = "MyESP"
            hl.FillColor = color
            hl.OutlineColor = color
            hl.Parent = model
            
            local bg = Instance.new("BillboardGui")
            bg.Name = "MyESP_Text"
            bg.Adornee = model:IsA("Model") and model.PrimaryPart or model
            bg.Size = UDim2.new(0, 100, 0, 50)
            bg.StudsOffset = Vector3.new(0, 2, 0)
            bg.AlwaysOnTop = true
            bg.Parent = model
            
            local lab = Instance.new("TextLabel")
            lab.Parent = bg
            lab.BackgroundTransparency = 1
            lab.Size = UDim2.new(1,0,1,0)
            lab.Text = text
            lab.TextColor3 = color
            lab.TextStrokeTransparency = 0
        end
    end

    local function ClearESP(model)
        if model:FindFirstChild("MyESP") then model.MyESP:Destroy() end
        if model:FindFirstChild("MyESP_Text") then model.MyESP_Text:Destroy() end
    end

    -- 1. Ghost ESP
    if ESP_Settings.Ghost then
        for _, g in pairs(GhostNPCs:GetChildren()) do
            if g:IsA("Model") then 
                CreateHighlight(g, "GHOST", Color3.fromRGB(255, 0, 0)) 
                if g:FindFirstChildOfClass("MeshPart") then g:FindFirstChildOfClass("MeshPart").Transparency = 0.5 end
            end
        end
    else
        for _, g in pairs(GhostNPCs:GetChildren()) do ClearESP(g) end
    end

    -- 2. Player ESP
    if ESP_Settings.Players then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then CreateHighlight(p.Character, p.DisplayName, Color3.fromRGB(0, 255, 0)) end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do if p.Character then ClearESP(p.Character) end end
    end
    
    -- 3. Evidence ESP
    if ESP_Settings.Evidence then
        for _, v in pairs(EvidenceFolder.Fingerprints:GetChildren()) do CreateHighlight(v, "Fingerprint", Color3.fromRGB(0, 255, 255)) end
        for _, v in pairs(EvidenceFolder.Orbs:GetChildren()) do CreateHighlight(v, "Orb", Color3.fromRGB(255, 0, 255)) end
    else
        for _, v in pairs(EvidenceFolder:GetDescendants()) do ClearESP(v) end
    end
end
RunService.RenderStepped:Connect(UpdateESP)

-- ============================================================================
-- 3. GUI (TWOJE USTAWIENIA I ZAKŁADKI)
-- ============================================================================

local Window = Rayfield:CreateWindow({
   Name = "Xyde script - Specter",
   Icon = "scroll-text",
   LoadingTitle = "Loading",
   LoadingSubtitle = "by Macha",
   ShowText = "Xyde",
   Theme = { -- Twój oryginalny motyw
      TextColor = Color3.fromRGB(255, 255, 255), Background = Color3.fromRGB(15, 15, 15), Topbar = Color3.fromRGB(25, 25, 25), Shadow = Color3.fromRGB(0, 0, 0),
      NotificationBackground = Color3.fromRGB(20, 20, 20), NotificationActionsBackground = Color3.fromRGB(230, 230, 230), TabBackground = Color3.fromRGB(40, 40, 40),
      TabStroke = Color3.fromRGB(160, 80, 220), TabBackgroundSelected = Color3.fromRGB(130, 40, 210), TabTextColor = Color3.fromRGB(255, 255, 255),
      SelectedTabTextColor = Color3.fromRGB(255, 255, 255), ElementBackground = Color3.fromRGB(30, 30, 30), ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
      SecondaryElementBackground = Color3.fromRGB(25, 25, 25), ElementStroke = Color3.fromRGB(60, 60, 60), SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
      SliderBackground = Color3.fromRGB(60, 30, 80), SliderProgress = Color3.fromRGB(148, 0, 211), SliderStroke = Color3.fromRGB(180, 100, 230),
      ToggleBackground = Color3.fromRGB(30, 30, 30), ToggleEnabled = Color3.fromRGB(148, 0, 211), ToggleDisabled = Color3.fromRGB(100, 100, 100),
      ToggleEnabledStroke = Color3.fromRGB(180, 100, 230), ToggleDisabledStroke = Color3.fromRGB(125, 125, 125), ToggleEnabledOuterStroke = Color3.fromRGB(60, 20, 100),
      ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65), DropdownSelected = Color3.fromRGB(40, 30, 50), DropdownUnselected = Color3.fromRGB(30, 30, 30),
      InputBackground = Color3.fromRGB(30, 30, 30), InputStroke = Color3.fromRGB(160, 80, 220), PlaceholderColor = Color3.fromRGB(178, 178, 178)
   },
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = true,
   ConfigurationSaving = { Enabled = true, FolderName = "XydeHub", FileName = "Specter" }
})

local TabMain = Window:CreateTab("Main", 4483362458)
local TabTeleport = Window:CreateTab("Teleport", "map-pin")
local TabVisuals = Window:CreateTab("Visuals", "eye")
local TabAutofarm = Window:CreateTab("Autofarm", "refresh-ccw")

-- ============================================================================
-- ZAKŁADKA: MAIN (Logika Gry + Notifications)
-- ============================================================================
local SectionMain = TabMain:CreateSection("Game Logic")

-- AUTOMATYCZNE WYKRYWANIE DOWODÓW (Labelki)
local EMFLabel = TabMain:CreateLabel("EMF 5: Not Found")
local PrintLabel = TabMain:CreateLabel("Fingerprints: Not Found")
local OrbLabel = TabMain:CreateLabel("Orbs: Not Found")
local RoomLabel = TabMain:CreateLabel("Ghost Room: Not Found")

-- Logika wykrywania (Podpięta pod eventy gry)
EvidenceFolder.EMF.ChildAdded:Connect(function(child)
    if child.Name == "EMF5" then EMFLabel:Set("EMF 5: FOUND!") Rayfield:Notify({Title="Evidence", Content="EMF 5 Found!", Image="activity"}) end
end)
EvidenceFolder.Fingerprints.ChildAdded:Connect(function(child)
    PrintLabel:Set("Fingerprints: FOUND!") Rayfield:Notify({Title="Evidence", Content="Fingerprints Found!", Image="fingerprint"})
end)
EvidenceFolder.Orbs.ChildAdded:Connect(function(child)
    OrbLabel:Set("Orbs: FOUND!") Rayfield:Notify({Title="Evidence", Content="Ghost Orbs Found!", Image="aperture"})
end)

-- PRZYCISK: FIND GHOST ROOM (Mechanika Astolfo)
TabMain:CreateButton({
    Name = "Find Ghost Room (Auto)",
    Callback = function()
        -- 1. Sprawdzenia
        local Equip = LocalPlayer.Character:FindFirstChild("EquipmentModel")
        local EMFTool = Equip and Equip:FindFirstChild("2") -- Kolor
        local EMFStatus = Equip and Equip:FindFirstChild("1") -- Włącznik
        
        if not EMFTool then Rayfield:Notify({Title="Error", Content="Equip EMF Reader first!"}) return end

        -- 2. Auto-włączanie EMF (Server Invoke)
        if not EMFStatus or EMFStatus.Color ~= Color3.fromRGB(52, 142, 64) then
            ReplicatedStorage.Packages.Knit.Services.InventoryService.RF.Toggle:InvokeServer("EMF Reader")
            task.wait(0.2)
        end

        local StartPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        local Found = nil
        Rayfield:Notify({Title="Scanning", Content="Teleporting to rooms..."})

        -- 3. Skanowanie
        local function Scan()
            for _, r in pairs(Map.Rooms:GetChildren()) do
                if r:IsA("Folder") and r:FindFirstChild("Hitbox") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = r.Hitbox.CFrame
                    Camera.CFrame = r.Hitbox.CFrame
                    task.wait(0.75) -- Czas z Astolfo
                    
                    -- Kolor aktywności ducha (Astolfo logic)
                    if EMFTool.Color == Color3.fromRGB(131, 156, 49) then
                        Found = r
                        return true
                    end
                end
            end
            return false
        end

        if not Scan() then
            Rayfield:Notify({Title="Retry", Content="Checking again..."})
            task.wait(0.5)
            Scan()
        end

        -- 4. Powrót
        LocalPlayer.Character.HumanoidRootPart.CFrame = StartPos
        if Found then
            getgenv().GhostRoom = Found
            RoomLabel:Set("Ghost Room: " .. Found.Name)
            Rayfield:Notify({Title="Success", Content="Found Room: "..Found.Name})
        else
            Rayfield:Notify({Title="Fail", Content="Ghost Room not found."})
        end
    end,
})

-- TOGGLE: HUNT NOTIFICATION
TabMain:CreateToggle({
    Name = "Hunt Notification",
    CurrentValue = false,
    Callback = function(Value) HuntNotify = Value end,
})

-- Pętla sprawdzająca polowanie (Dystans do ducha)
task.spawn(function()
    while task.wait(0.5) do
        if HuntNotify then
            for _, ghost in pairs(GhostNPCs:GetChildren()) do
                if ghost:IsA("Model") and ghost.PrimaryPart then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - ghost.PrimaryPart.Position).Magnitude
                    if dist < 15 then -- Jeśli duch jest blisko
                        Rayfield:Notify({Title="DANGER", Content="GHOST IS NEARBY! HUNT?", Image="skull"})
                        task.wait(3) -- Cooldown powiadomienia
                    end
                end
            end
        end
    end
end)

local SectionPlayer = TabMain:CreateSection("Player")

TabMain:CreateToggle({
    Name = "Infinite Stamina",
    Callback = function(Value)
        getgenv().InfStamina = Value
        if Value then
            task.spawn(function()
                while getgenv().InfStamina do
                    if LocalPlayer:GetAttribute("Stamina") then LocalPlayer:SetAttribute("Stamina", 100) end
                    task.wait()
                end
            end)
        end
    end,
})

TabMain:CreateButton({
    Name = "Remove Doors (Delete Folder)",
    Callback = function()
        if Map:FindFirstChild("Doors") then
            Map.Doors:Destroy()
            Rayfield:Notify({Title="Deleted", Content="Doors removed."})
        end
    end,
})

-- ============================================================================
-- ZAKŁADKA: TELEPORT
-- ============================================================================
local SectionTp = TabTeleport:CreateSection("Locations")

TabTeleport:CreateButton({
    Name = "Teleport to Van",
    Callback = function()
        if Van then tp(Van:GetPivot().Position.X, Van:GetPivot().Position.Y + 4, Van:GetPivot().Position.Z) end
    end,
})

TabTeleport:CreateButton({
    Name = "Teleport to Ghost Room",
    Callback = function()
        if getgenv().GhostRoom then
            tp(getgenv().GhostRoom.Hitbox.Position.X, getgenv().GhostRoom.Hitbox.Position.Y + 3, getgenv().GhostRoom.Hitbox.Position.Z)
        else
            Rayfield:Notify({Title="Error", Content="Use 'Find Ghost Room' in Main first!"})
        end
    end,
})

local SectionObj = TabTeleport:CreateSection("Objects")

TabTeleport:CreateButton({ Name = "Teleport to Bone", Callback = function() if Map:FindFirstChild("Bone") then local p = Map.Bone.Position tp(p.X, p.Y+3, p.Z) end end })
TabTeleport:CreateButton({ Name = "Teleport to Fusebox", Callback = function() if Map:FindFirstChild("Fusebox") then local p = Map.Fusebox.Fusebox.Position tp(p.X, p.Y, p.Z) end end })
TabTeleport:CreateButton({ Name = "Teleport to Ouija", Callback = function() if Map.cursed_object:FindFirstChild("Board") then local p = Map.cursed_object.Board.Position tp(p.X, p.Y+1, p.Z) end end })

local SectionLists = TabTeleport:CreateSection("Lists")

-- Lista Pokoi
local function getRoomNames()
    local t = {}
    if Map:FindFirstChild("Rooms") then for _, r in pairs(Map.Rooms:GetChildren()) do if r:FindFirstChild("Hitbox") then table.insert(t, r.Name) end end end
    table.sort(t)
    return t
end

local RoomDrop = TabTeleport:CreateDropdown({
    Name = "Teleport to Room",
    Options = getRoomNames(),
    CurrentOption = {"Select Room"},
    Callback = function(opt)
        local r = Map.Rooms:FindFirstChild(opt[1])
        if r then local p = r.Hitbox.Position tp(p.X, p.Y+3, p.Z) end
    end,
})
TabTeleport:CreateButton({Name="Refresh Rooms", Callback=function() RoomDrop:Refresh(getRoomNames(), true) end})

-- Lista Graczy
local function getPlrs()
    local t = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.DisplayName) end end
    return t
end
local PlrDrop = TabTeleport:CreateDropdown({
    Name = "Teleport to Player",
    Options = getPlrs(),
    CurrentOption = {"Select"},
    Callback = function(opt)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName == opt[1] and p.Character then tp(p.Character.HumanoidRootPart.Position.X, p.Character.HumanoidRootPart.Position.Y, p.Character.HumanoidRootPart.Position.Z) end
        end
    end,
})
TabTeleport:CreateButton({Name="Refresh Players", Callback=function() PlrDrop:Refresh(getPlrs(), true) end})


-- ============================================================================
-- ZAKŁADKA: VISUALS
-- ============================================================================
local SectionESP = TabVisuals:CreateSection("ESP Settings")

TabVisuals:CreateToggle({Name="Ghost ESP", Callback=function(v) ESP_Settings.Ghost = v end})
TabVisuals:CreateToggle({Name="Player ESP", Callback=function(v) ESP_Settings.Players = v end})
TabVisuals:CreateToggle({Name="Evidence ESP", Callback=function(v) ESP_Settings.Evidence = v end})

local SectionWorld = TabVisuals:CreateSection("World")

TabVisuals:CreateToggle({
    Name = "Fullbright",
    Callback = function(v)
        if v then Lighting.Ambient = Color3.new(1,1,1) Lighting.ClockTime = 12 else Lighting.Ambient = Color3.new(0,0,0) Lighting.ClockTime = 0 end
    end,
})

TabVisuals:CreateSlider({
    Name = "Field of View",
    Range = {60, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(v)
        Camera.FieldOfView = v
    end,
})

-- Sanity GUI (Draggable)
TabVisuals:CreateToggle({
    Name = "Show Sanity GUI",
    Callback = function(v)
        if v then
            local sg = Instance.new("ScreenGui", game.CoreGui)
            sg.Name = "SanityUI"
            local fr = Instance.new("Frame", sg)
            fr.Size = UDim2.new(0,150,0,40)
            fr.Position = UDim2.new(0.5,0,0.9,0)
            fr.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
            fr.Active = true
            fr.Draggable = true
            local tx = Instance.new("TextLabel", fr)
            tx.Size = UDim2.new(1,0,1,0)
            tx.BackgroundTransparency = 1
            tx.TextColor3 = Color3.new(1,1,1)
            tx.Text = "Sanity: --"
            
            task.spawn(function()
                while sg.Parent do
                    local sanAttr = LocalPlayer:GetAttribute("Sanity")
                    if sanAttr then tx.Text = "Sanity: "..math.floor(sanAttr).."%" end
                    task.wait(0.5)
                end
            end)
        else
            if game.CoreGui:FindFirstChild("SanityUI") then game.CoreGui.SanityUI:Destroy() end
        end
    end,
})


-- ============================================================================
-- ZAKŁADKA: AUTOFARM (DODANE Z TO-DO)
-- ============================================================================
TabAutofarm:CreateSection("Tasks")

TabAutofarm:CreateButton({
    Name = "Use Sink (Fill Water)",
    Callback = function()
        -- Szuka zlewu z promptem
        local found = false
        for _, v in pairs(Map:GetDescendants()) do
            if v.Name == "Sink" and v:FindFirstChild("Water") then -- Przykładowa nazwa struktury
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v.Parent:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                    found = true
                    Rayfield:Notify({Title="Sink", Content="Used Sink!"})
                    break
                end
            end
        end
        if not found then Rayfield:Notify({Title="Error", Content="Sink not found nearby."}) end
    end,
})

TabAutofarm:CreateButton({
    Name = "Collect Bone (Auto)",
    Callback = function()
        if Map:FindFirstChild("Bone") then
            local prompt = Map.Bone:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                local old = LocalPlayer.Character.HumanoidRootPart.CFrame
                tp(Map.Bone.Position.X, Map.Bone.Position.Y+2, Map.Bone.Position.Z)
                task.wait(0.2)
                fireproximityprompt(prompt)
                task.wait(0.2)
                LocalPlayer.Character.HumanoidRootPart.CFrame = old
                Rayfield:Notify({Title="Success", Content="Collected Bone"})
            end
        else
            Rayfield:Notify({Title="Error", Content="Bone not spawned yet."})
        end
    end,
})

TabAutofarm:CreateButton({
    Name = "Toggle Power (Fusebox)",
    Callback = function()
        local box = Map:FindFirstChild("Fusebox") and Map.Fusebox:FindFirstChild("Fusebox")
        if box then
            for _, v in pairs(box:GetChildren()) do
                if v:IsA("ProximityPrompt") then
                    local old = LocalPlayer.Character.HumanoidRootPart.CFrame
                    tp(box.Position.X, box.Position.Y, box.Position.Z)
                    task.wait(0.2)
                    fireproximityprompt(v)
                    task.wait(0.2)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = old
                    Rayfield:Notify({Title="Success", Content="Toggled Power"})
                    return
                end
            end
        end
    end,
})
