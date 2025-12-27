if getgenv().XydeScriptLoaded == true then
    warn("Script is already loaded")
    return
end

getgenv().XydeScriptLoaded = true
-- Xyde Loader: Auto-Rejoin + Auto-Login
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local BASE_URL = "https://xxMacha.pythonanywhere.com/api/check_key?k="
local KEY_URL = "https://macha.lol" 
local FILE_NAME = "XydeKeySystem.txt"
discord = "p9jCxg5m"

-- LINK DO TEGO KONKRETNEGO LOADERA (Zmień jeśli masz własny raw link do tego pliku)
local SCRIPT_URL = 'https://raw.githubusercontent.com/xMacha/Xyde/refs/heads/main/source/XydeLoader.lua' 

-- =================================================================
-- 1. SYSTEM PERSYSTENCJI (AUTO-RESTART PO TELEPORCIE)
-- =================================================================
local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport or fluxus.queue_on_teleport or (function(...) end)

-- Ta komenda sprawia, że po zmianie serwera skrypt odpali się samoczynnie
queue_on_teleport([[
    repeat task.wait() until game:IsLoaded()
    loadstring(game:HttpGet(']] .. SCRIPT_URL .. [['))()
]])

-- Zabezpieczenie na wypadek, gdyby queue_on_teleport wymagało odświeżenia przy samym teleporcie
Player.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        queue_on_teleport([[
            repeat task.wait() until game:IsLoaded()
            loadstring(game:HttpGet(']] .. SCRIPT_URL .. [['))()
        ]])
    end
end)

-- =================================================================
-- 2. LOGIKA ŁADOWANIA SKRYPTÓW GRY
-- =================================================================
local function RunScript()
    local currentPlaceId = game.PlaceId
    
    if currentPlaceId == 8417221956 then
-- Xyde Script for Specter
print("Xyde - Loading Rayfield")
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Roblox-GUI-libs/refs/heads/main/source/Rayfield.lua'))()
-- ============================================================================
-- 1. SERWISY I ZMIENNE
-- ============================================================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
getgenv().TargetFOV = 70
local SanityGui = nil
local SanityLoop = nil
local HuntNotifyEnabled = false
local HuntCooldown = false

-- Foldery gry
local Map = Workspace:FindFirstChild("Map")
local EvidenceFolder = Workspace:WaitForChild("Dynamic"):WaitForChild("Evidence")
local GhostNPCs = Workspace:WaitForChild("NPCs")
local Van = Workspace:WaitForChild("Van")
local ClosetsFolder = Map:WaitForChild("Closets")
local Motions = EvidenceFolder:WaitForChild("MotionGrids")

-- Zmienne konfiguracyjne
getgenv().GhostRoom = nil
local ESP_Settings = {
    Ghost = false, 
    Players = false, 
    Evidence = false, 
    Closets = false
}
local HuntNotify = false
local InfStamina = false

-- ============================================================================
-- 2. FUNKCJE POMOCNICZE
-- ============================================================================
-- FOV pętla
if not getgenv().FOVLoop then
    getgenv().FOVLoop = RunService.RenderStepped:Connect(function()
        Camera.FieldOfView = getgenv().TargetFOV
    end)
end

-- Funkcja sprawdzająca czy kolor jest czerwony (dla Motion)
local function isColorRed(color)
    -- Sprawdza czy czerwony jest dominujący
	return color.R > color.G + color.B
end

-- Funkcja Teleportacji (Noclip + Tween)
local function tp(x, y, z)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    root.Anchored = true
    
    -- Wyłącz kolizję
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local targetCFrame = CFrame.new(x, y, z)
    local distance = (targetCFrame.Position - root.Position).Magnitude
    local speed = 240 -- Szybkość lotu
    local info = TweenInfo.new(distance/speed, Enum.EasingStyle.Linear)
    
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()

    -- Przywróć
    root.Anchored = false
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
    root.Anchored = false
end

-- System ESP
local function UpdateESP()
    local function Highlight(model, text, color)
        if not model then return end
        if not model:FindFirstChild("XydeESP") then
            local hl = Instance.new("Highlight", model)
            hl.Name = "XydeESP"
            hl.FillColor = color
            hl.OutlineColor = color
            hl.FillTransparency = 0.5
            
            local bg = Instance.new("BillboardGui", model)
            bg.Name = "XydeText"
            bg.Adornee = model:IsA("Model") and model.PrimaryPart or model
            bg.Size = UDim2.new(0,100,0,50)
            bg.StudsOffset = Vector3.new(0,2,0)
            bg.AlwaysOnTop = true
            
            local lab = Instance.new("TextLabel", bg)
            lab.BackgroundTransparency = 1
            lab.Size = UDim2.new(1,0,1,0)
            lab.Text = text
            lab.TextColor3 = color
            lab.TextStrokeTransparency = 0
            lab.Font = Enum.Font.SourceSansBold
            lab.TextSize = 14
        end
    end
    
    local function Clear(model)
        if model:FindFirstChild("XydeESP") then model.XydeESP:Destroy() end
        if model:FindFirstChild("XydeText") then model.XydeText:Destroy() end
    end

    -- 1. Ghost
    if ESP_Settings.Ghost then
        for _, g in pairs(GhostNPCs:GetChildren()) do
            if g:IsA("Model") then 
                Highlight(g, "GHOST", Color3.fromRGB(255, 0, 0))
                if g:FindFirstChildOfClass("MeshPart") then g:FindFirstChildOfClass("MeshPart").Transparency = 0.5 end
            end
        end
    else
        for _, g in pairs(GhostNPCs:GetChildren()) do Clear(g) end
    end

    -- 2. Players
    if ESP_Settings.Players then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then Highlight(p.Character, p.DisplayName, Color3.fromRGB(0, 255, 0)) end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do if p.Character then Clear(p.Character) end end
    end

    -- 3. Evidence (Fingerprints, Orbs, EMF 2-5)
    if ESP_Settings.Evidence then
        for _, v in pairs(EvidenceFolder.Fingerprints:GetChildren()) do Highlight(v, "Fingerprint", Color3.fromRGB(0, 255, 255)) end
        for _, v in pairs(EvidenceFolder.Orbs:GetChildren()) do Highlight(v, "Orb", Color3.fromRGB(255, 0, 255)) end
        
        -- EMF UPDATE: Wykrywanie 2, 3, 4 i 5
        for _, v in pairs(EvidenceFolder.EMF:GetChildren()) do 
            if v.Name == "EMF5" then 
                Highlight(v, "EMF 5", Color3.fromRGB(255, 255, 0)) 
            elseif v.Name == "EMF4" then
                Highlight(v, "EMF 4", Color3.fromRGB(255, 170, 0))
            elseif v.Name == "EMF3" then
                Highlight(v, "EMF 3", Color3.fromRGB(0, 255, 0))
            elseif v.Name == "EMF2" then
                Highlight(v, "EMF 2", Color3.fromRGB(0, 200, 0))
            end 
        end
    else
        for _, v in pairs(EvidenceFolder:GetDescendants()) do Clear(v) end
    end

    -- 4. Closets (Szafy)
    if ESP_Settings.Closets then
        for _, c in pairs(ClosetsFolder:GetChildren()) do
            if c:IsA("Model") and c.Name == "Closet" then
                Highlight(c, "Closet", Color3.fromRGB(100, 100, 255))
            end
        end
    else
        for _, c in pairs(ClosetsFolder:GetChildren()) do Clear(c) end
    end
end
RunService.RenderStepped:Connect(UpdateESP)

-- Stamina Loop
task.spawn(function()
    while task.wait() do
        if InfStamina and LocalPlayer:GetAttribute("Stamina") then
            LocalPlayer:SetAttribute("Stamina", 100)
        end
    end
end)

-- ============================================================================
-- 3. INTERFEJS
-- ============================================================================
local Window = Rayfield:CreateWindow({
   Name = "Xyde script - Specter",
   Icon = "scroll-text",
   LoadingTitle = "Loading",
   LoadingSubtitle = "by Macha",
   ShowText = "Xyde",
      Discord = {
      Enabled = true,
      Invite = discord,
      RememberJoins = false},
   Theme = {
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
   ConfigurationSaving = { Enabled = true, FolderName = "XydeHub", FileName = "Specter" },
})

local TabMain = Window:CreateTab("Main", 4483362458)
local TabTeleport = Window:CreateTab("Teleport", "map-pin")
local TabVisuals = Window:CreateTab("Visuals", "eye")
local TabAuto = Window:CreateTab("Auto farm", "refresh-ccw")

-- ============================================================================
-- TAB: MAIN
-- ============================================================================
local SectionGhost = TabMain:CreateSection("Ghost Room")
local GhostRoomLabel = TabMain:CreateLabel("Ghost Room: Not Found")

TabMain:CreateButton({
    Name = "Find Ghost Room (can be inaccurate)",
    Callback = function()
        local Equip = LocalPlayer.Character:FindFirstChild("EquipmentModel")
        local EMFTool = Equip and Equip:FindFirstChild("2")
        local EMFStatus = Equip and Equip:FindFirstChild("1")
        
        if not EMFTool then Rayfield:Notify({Title="Error", Content="Equip EMF Reader first!"}) return end

        if not EMFStatus or EMFStatus.Color ~= Color3.fromRGB(52, 142, 64) then
            ReplicatedStorage.Packages.Knit.Services.InventoryService.RF.Toggle:InvokeServer("EMF Reader")
            task.wait(0.2)
        end

        local StartPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        Rayfield:Notify({Title="Scanning", Content="Starting scan..."})

        local function ScanRooms()
            for _, r in pairs(Map.Rooms:GetChildren()) do
                if r:IsA("Folder") and r:FindFirstChild("Hitbox") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = r.Hitbox.CFrame
                    Camera.CFrame = r.Hitbox.CFrame
                    task.wait(0.65)

                    if EMFTool.Color == Color3.fromRGB(131, 156, 49) then
                        task.wait(1.0)
                        if EMFTool.Color == Color3.fromRGB(131, 156, 49) then
                            return r
                        end
                    end
                end
            end
            return nil
        end

        local Found = ScanRooms()
        if not Found then
            Rayfield:Notify({Title="Retry", Content="Checking again..."})
            task.wait(0.5)
            Found = ScanRooms()
        end

        LocalPlayer.Character.HumanoidRootPart.CFrame = StartPos
        
        if Found then
            getgenv().GhostRoom = Found
            GhostRoomLabel:Set("Ghost Room: " .. Found.Name)
            Rayfield:Notify({Title="SUCCESS", Content="Room: " .. Found.Name, Image="ghost"})
        else
            Rayfield:Notify({Title="Failed", Content="Room not found.", Image="ban"})
        end
    end,
})

local SectionEvidence = TabMain:CreateSection("Evidence Status")
local EMFLabel = TabMain:CreateLabel("EMF 5: --")
local PrintLabel = TabMain:CreateLabel("Fingerprints: --")
local OrbLabel = TabMain:CreateLabel("Orbs: --")
local FreezingLabel = TabMain:CreateLabel("Freezing: --")
local SpiritBoxLabel = TabMain:CreateLabel("Spirit Box: --")
local MotionLabel = TabMain:CreateLabel("Motion: --") 

EvidenceFolder.EMF.ChildAdded:Connect(function(c) if c.Name=="EMF5" then EMFLabel:Set("EMF 5: FOUND!") end end)
EvidenceFolder.Fingerprints.ChildAdded:Connect(function() PrintLabel:Set("Fingerprints: FOUND!") end)
EvidenceFolder.Orbs.ChildAdded:Connect(function() OrbLabel:Set("Orbs: FOUND!") end)

-- POPRAWIONY MOTION CHECKER
task.spawn(function()
    while task.wait(0.5) do
        local foundMotion = false
        if Motions then
            for _, m in pairs(Motions:GetDescendants()) do
                if m:IsA("Part") then
                    -- Sprawdzamy czy kolor ma duzo czerwonego (Motion Detected)
                    if isColorRed(m.Color) then 
                        foundMotion = true
                        break
                    end
                end
            end
        end
        
        if foundMotion then
            MotionLabel:Set("Motion: FOUND!")
        end
    end
end)

-- PRZYCISKI DO SPRAWDZANIA DOWODÓW
TabMain:CreateButton({
    Name = "Check Freezing (Use Thermometer)",
    Callback = function()
        local thermometer = LocalPlayer.Character:FindFirstChild("EquipmentModel") and LocalPlayer.Character.EquipmentModel:FindFirstChild("Temp") and LocalPlayer.Character.EquipmentModel.Temp:FindFirstChild("SurfaceGui") and LocalPlayer.Character.EquipmentModel.Temp.SurfaceGui:FindFirstChild("TextLabel")
        local thermometer_screen = LocalPlayer.Character:FindFirstChild("EquipmentModel") and LocalPlayer.Character.EquipmentModel:FindFirstChild("Temp") and LocalPlayer.Character.EquipmentModel.Temp:FindFirstChild("SurfaceGui")

        if not thermometer then Rayfield:Notify({Title="Error", Content="Equip Thermometer!"}) return end
        if not thermometer_screen.Enabled then ReplicatedStorage.Packages.Knit.Services.InventoryService.RF.Toggle:InvokeServer("Thermometer") end
        if not getgenv().GhostRoom then Rayfield:Notify({Title="Error", Content="Find Ghost Room first!"}) return end

        local last_pos = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().GhostRoom.Hitbox.CFrame
        Rayfield:Notify({Title="Checking", Content="Wait 9s for temp..."})
        task.wait(9)

        local tempeture = tonumber(thermometer.Text:match("[-%d]+"))
        if tempeture and tempeture < 0 then
            Rayfield:Notify({Title="Evidence", Content="Freezing temp Found!", Image="snowflake"})
            FreezingLabel:Set("Freezing: FOUND!")
        else
            Rayfield:Notify({Title="Result", Content="No Freezing."})
            FreezingLabel:Set("Freezing: Not Found")
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = last_pos
    end,
})

TabMain:CreateButton({
    Name = "Check Spirit Box (Use Spirit Box)",
    Callback = function()
        local spirit_box = LocalPlayer.Character:FindFirstChild("EquipmentModel") and LocalPlayer.Character.EquipmentModel:FindFirstChild("Main")
        local spirit_box_screen = LocalPlayer.Character:FindFirstChild("EquipmentModel") and LocalPlayer.Character.EquipmentModel:FindFirstChild("Screen")

        if not spirit_box then Rayfield:Notify({Title="Error", Content="Equip Spirit Box!"}) return end
        if spirit_box_screen.Color == Color3.fromRGB(0, 0, 0) then ReplicatedStorage.Packages.Knit.Services.InventoryService.RF.Toggle:InvokeServer("Spirit Box") end
        if not getgenv().GhostRoom then Rayfield:Notify({Title="Error", Content="Find Ghost Room first!"}) return end

        local last_pos = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().GhostRoom.Hitbox.CFrame
        
        local got_spirit_box = false
        local responses = spirit_box.DescendantAdded:Connect(function(reply)
            if reply:IsA("BillboardGui") then
                got_spirit_box = true
                Rayfield:Notify({Title="Evidence", Content="Spirit Box Replied!", Image="mic"})
                SpiritBoxLabel:Set("Spirit Box: FOUND!")
            end
        end)

        Rayfield:Notify({Title="Checking", Content="Asking 'Where are you?'..."})
        local general = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        
        -- POPRAWIONE LOOP DLA SPIRIT BOXA (WOLNIEJ)
        for i = 1, 5 do -- 5 prób zamiast 15
            if general then general:SendAsync("Where are you?") else game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Where are you?", "All") end
            task.wait(3.5) -- Czekamy 3.5 sekundy na odpowiedź
            if got_spirit_box then break end
        end
        
        if responses then responses:Disconnect() end
        if not got_spirit_box then 
            Rayfield:Notify({Title="Result", Content="No response."}) 
            SpiritBoxLabel:Set("Spirit Box: Not Found")
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = last_pos
    end,
})

TabMain:CreateButton({
    Name = "Tp Motion Sensor To Ghost",
    Callback = function()
        local motion_grid = Motions:FindFirstChild("SensorGrid")
        if motion_grid then
            Rayfield:Notify({Title="Teleporting", Content="Moving sensors..."})
            for _, mg in pairs(motion_grid:GetChildren()) do
                if mg:IsA("Part") then
                    local ghost = Workspace.NPCs:FindFirstChildOfClass("Model")
                    if ghost then mg.CFrame = ghost.HumanoidRootPart.CFrame + Vector3.new(1,0,0) end
                end
            end
        else
            Rayfield:Notify({Title="Error", Content="Place Motion Sensor first!"})
        end
    end,
})

TabMain:CreateSection("Misc")
TabMain:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Callback = function(Value) InfStamina = Value end,
})
TabMain:CreateToggle({
    Name = "Enable Jumping",
    CurrentValue = false,
    Callback = function(Value)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Value and 50 or 0
        end
    end,
})


TabMain:CreateButton({Name="Remove Doors", Callback=function() if Map:FindFirstChild("Doors") then Map.Doors:Destroy() end end})



-- ============================================================================
-- TAB: TELEPORT
-- ============================================================================
local SectionLoc = TabTeleport:CreateSection("General")

TabTeleport:CreateKeybind({
    Name = "Teleport to Van",
    CurrentKeybind = "Y",
    HoldToInteract = false,
    Flag = "TpToVan",
    Callback = function(Keybind) if Van then tp(Van:GetPivot().Position.X, Van:GetPivot().Position.Y+4, Van:GetPivot().Position.Z) end end,
})

TabTeleport:CreateKeybind({
    Name = "Teleport to Ghost Room", CurrentKeybind = "U", HoldToInteract = false, Flag = "TpToGhostRoom",
    Callback = function(Keybind) 
        if getgenv().GhostRoom then 
            local p = getgenv().GhostRoom.Hitbox.Position
            tp(p.X, p.Y+3, p.Z)
        else
            Rayfield:Notify({Title="Error", Content="Find Ghost Room first!"})
        end 
    end,
})

local SectionObjs = TabTeleport:CreateSection("Objects")
TabTeleport:CreateButton({Name="Teleport to Bone", Callback=function() if Map:FindFirstChild("Bone") then local p=Map.Bone.Position tp(p.X, p.Y+3, p.Z) end end})
TabTeleport:CreateButton({Name="Teleport to Fusebox", Callback=function() if Map:FindFirstChild("Fusebox") then local p=Map.Fusebox.Fusebox.Position tp(p.X, p.Y, p.Z) end end})
TabTeleport:CreateButton({Name="Teleport to Quija Board", Callback=function() if Map.cursed_object:FindFirstChild("Board") then local p=Map.cursed_object.Board.Position tp(p.X, p.Y+1, p.Z) end end})
TabTeleport:CreateButton({Name="Teleport to Necronomicon", Callback=function() if Map.cursed_object:FindFirstChild("Book") then local p=Map.cursed_object.Book.Face.Position tp(p.X, p.Y+1, p.Z) end end})
TabTeleport:CreateButton({Name="Teleport to Skull", Callback=function() if Map.cursed_object:FindFirstChild("Skull") then local p=Map.cursed_object.Skull.Position tp(p.X, p.Y+1, p.Z) end end})
TabTeleport:CreateButton({
    Name = "Teleport to Dirty Sink",
    Callback = function()
        local Map = game.Workspace:FindFirstChild("Map")
        local EventObjects = Map and Map:FindFirstChild("EventObjects")
        local Sinks = EventObjects and EventObjects:FindFirstChild("Sinks")
        
        if Sinks then
            local found = false
            for _, sink in pairs(Sinks:GetChildren()) do
                -- Szukamy części "Water" w modelu zlewu
                local water = sink:FindFirstChild("Water")
                
                -- Sprawdzamy czy woda jest widoczna (Transparency == 0)
                if water and water.Transparency == 0 then
                    found = true
                    -- Pobieramy pozycję zlewu (albo samej wody)
                    local targetPos = water.Position
                    tp(targetPos.X, targetPos.Y + 2, targetPos.Z) -- Teleport 2 study nad wodą
                    
                    Rayfield:Notify({
                        Title = "Success",
                        Content = "Teleported to dirty sink!",
                        Image = "droplet"
                    })
                    break -- Przerywamy pętlę po znalezieniu pierwszego aktywnego zlewu
                end
            end
            
            if not found then
                Rayfield:Notify({
                    Title = "Info",
                    Content = "No dirty sinks found.",
                    Duration = 2,
                    Image = "ban"
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Sinks not found, contact us on Discord.",
                Image = "circle-alert"
            })
        end
    end,
})

-- PRZYWRÓCONA LISTA POKOI I GRACZY
local SectionLists = TabTeleport:CreateSection("Lists")

local function getRoomNames()
    local t = {}
    if Map:FindFirstChild("Rooms") then for _, r in pairs(Map.Rooms:GetChildren()) do if r:FindFirstChild("Hitbox") then table.insert(t, r.Name) end end end
    table.sort(t)
    return t
end

local RoomDropdown = TabTeleport:CreateDropdown({
    Name = "Teleport to Room",
    Options = getRoomNames(),
    CurrentOption = {"Select Room"},
    Callback = function(opt)
        local r = Map.Rooms:FindFirstChild(opt[1])
        if r then local p = r.Hitbox.Position tp(p.X, p.Y+3, p.Z) end
    end,
})
TabTeleport:CreateButton({Name="Refresh Room List", Callback=function() RoomDropdown:Refresh(getRoomNames(), true) end})

local function getPlrs()
    local t = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.DisplayName) end end
    return t
end

local PlrDropdown = TabTeleport:CreateDropdown({
    Name = "Teleport to Player",
    Options = getPlrs(),
    CurrentOption = {"Select"},
    Callback = function(opt)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName == opt[1] and p.Character then 
                local pp = p.Character.HumanoidRootPart.Position
                tp(pp.X, pp.Y, pp.Z)
            end
        end
    end,
})
TabTeleport:CreateButton({Name="Refresh Player List", Callback=function() PlrDropdown:Refresh(getPlrs(), true) end})

-- ============================================================================
-- TAB: VISUALS
-- ============================================================================
local SectionESP = TabVisuals:CreateSection("ESP Options")

TabVisuals:CreateToggle({Name="Ghost ESP", Callback=function(v) ESP_Settings.Ghost = v end})
TabVisuals:CreateToggle({Name="Player ESP", Callback=function(v) ESP_Settings.Players = v end})
TabVisuals:CreateToggle({Name="Evidence ESP", Callback=function(v) ESP_Settings.Evidence = v end})
TabVisuals:CreateToggle({Name="Closet ESP", Callback=function(v) ESP_Settings.Closets = v end})

local SectionWorld = TabVisuals:CreateSection("Misc")
TabVisuals:CreateToggle({
    Name = "Fullbright",
    Callback = function(v)
        if v then Lighting.Ambient = Color3.new(1,1,1) Lighting.ClockTime = 12 else Lighting.Ambient = Color3.new(0,0,0) Lighting.ClockTime = 0 end
    end,
})
local FOVSlider = TabVisuals:CreateSlider({
   Name = "Field of View (FOV)",
   Range = {30, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "FOVSlider", -- Unikalna flaga do zapisu configu
   Callback = function(Value)
       -- Slider aktualizuje tylko zmienną, a pętla wyżej robi resztę roboty
       getgenv().TargetFOV = Value
   end,
})

local SanityToggle = TabVisuals:CreateToggle({
   Name = "Show Sanity",
   CurrentValue = false,
   Flag = "SanityDisplay",
   Callback = function(Value)
       if Value then
           -- === WŁĄCZANIE ===
           
           -- 1. Tworzymy ScreenGui (kontener na ekranie)
           SanityGui = Instance.new("ScreenGui")
           -- Próbujemy wstawić do CoreGui (bezpieczniejsze), a jak się nie da to do PlayerGui
           if pcall(function() SanityGui.Parent = game.CoreGui end) then
               SanityGui.Parent = game.CoreGui
           else
               SanityGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
           end

           -- 2. Tworzymy Tło (Frame)
           local Background = Instance.new("Frame")
           Background.Name = "SanityBackground"
           Background.Parent = SanityGui
           Background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
           Background.BackgroundTransparency = 0.3
           Background.Position = UDim2.new(0.85, 0, 0.85, 0) -- Pozycja (prawy dolny róg)
           Background.Size = UDim2.new(0, 150, 0, 50)
           
           -- Zaokrąglone rogi
           local Corner = Instance.new("UICorner")
           Corner.CornerRadius = UDim.new(0, 8)
           Corner.Parent = Background

           -- 3. Tworzymy Napis (TextLabel)
           local Label = Instance.new("TextLabel")
           Label.Parent = Background
           Label.Size = UDim2.new(1, 0, 1, 0) -- Wypełnia całe tło
           Label.BackgroundTransparency = 1
           Label.TextColor3 = Color3.fromRGB(255, 255, 255)
           Label.TextSize = 20
           Label.Font = Enum.Font.SourceSansBold
           Label.Text = "Sanity: --"

           -- 4. Pętla aktualizująca wartość
           SanityLoop = RunService.RenderStepped:Connect(function()
               local sanityValue = LocalPlayer:GetAttribute("Sanity")
               
               if sanityValue then
                   -- Zaokrąglamy wartość w dół (math.floor)
                   Label.Text = "Sanity: " .. tostring(math.floor(sanityValue)) .. "%"
                   
                   -- Zmiana koloru na czerwony, gdy Sanity jest niskie (< 30)
                   if sanityValue < 30 then
                       Label.TextColor3 = Color3.fromRGB(255, 50, 50)
                   else
                       Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                   end
               else
                   Label.Text = "Sanity: N/A"
               end
           end)

       else
           -- === WYŁĄCZANIE ===
           
           if SanityGui then
               SanityGui:Destroy() -- Usuwa GUI z ekranu
               SanityGui = nil
           end
           
           if SanityLoop then
               SanityLoop:Disconnect() -- Zatrzymuje pętlę
               SanityLoop = nil
           end
       end
   end,
})
-- ============================================================================
-- TAB: AUTO
-- ============================================================================

TabAuto:CreateToggle({
   Name = "Auto Bone Farm (Debug)",
   CurrentValue = false,
   Flag = "AutoBone",
   Callback = function(Value)
       getgenv().AutoBoneFarm = Value
       
       if Value then
           task.spawn(function()
               while getgenv().AutoBoneFarm do
                   task.wait(1) -- Krótka przerwa na starcie pętli
                   
                   -- Sprawdzenie czy postać istnieje
                   if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                       print("[DEBUG] Czekam na postać...")
                       task.wait(1)
                       continue
                   end

                   print("[DEBUG] Szukam kości na mapie...")
                   
                   -- Definicje obiektów
                   local Map = Workspace:FindFirstChild("Map")
                   local Bone = Map and Map:FindFirstChild("Bone")
                   local VanToggle = Workspace:WaitForChild("Van"):WaitForChild("Close"):WaitForChild("Toggle")

                   -- 1. ZBIERANIE KOŚCI
                   if Bone then
                       Rayfield:Notify({Title="DEBUG", Content="Znaleziono kość! Teleport...", Duration=2})
                       print("[DEBUG] Kość znaleziona: " .. tostring(Bone.CFrame))

                       -- Teleport do kości
                       LocalPlayer.Character.HumanoidRootPart.CFrame = Bone.CFrame
                       task.wait(0.5) -- Czekamy aż serwer ogarnie pozycję

                       -- Próba podniesienia (ProximityPrompt)
                       local prompt = Bone:FindFirstChildWhichIsA("ProximityPrompt", true)
                       if prompt then
                           print("[DEBUG] Klikam kość (x10)...")
                           for i=1, 10 do
                               fireproximityprompt(prompt)
                               task.wait(0.05)
                           end
                           Rayfield:Notify({Title="DEBUG", Content="Próba podniesienia zakończona", Duration=2})
                       else
                           print("[DEBUG] BŁĄD: Kość nie ma ProximityPrompt!")
                       end
                   else
                       print("[DEBUG] Nie znaleziono kości (może już zebrana lub bug mapy)")
                       Rayfield:Notify({Title="DEBUG", Content="Brak kości na mapie", Duration=2})
                   end

                   task.wait(1)

                   -- 2. UCIECZKA (VAN)
                   if VanToggle then
                       print("[DEBUG] Uciekam do Vana...")
                       Rayfield:Notify({Title="DEBUG", Content="Ucieczka (Van)...", Duration=2})

                       -- Teleport do guzika
                       LocalPlayer.Character.HumanoidRootPart.CFrame = VanToggle.CFrame
                       task.wait(0.5)

                       -- Kliknięcie guzika
                       local vanPrompt = VanToggle:FindFirstChildWhichIsA("ProximityPrompt", true)
                       if vanPrompt then
                           fireproximityprompt(vanPrompt)
                           print("[DEBUG] Kliknięto Van Toggle")
                       end
                       
                       -- Czekamy chwilę, żeby gra zdążyła zareagować przed kolejną pętlą
                       -- Jeśli gra się skończy, pętla i tak zostanie przerwana przez teleport
                       task.wait(5) 
                   end
               end
           end)
       else
           print("[DEBUG] Auto Bone Farm zatrzymany.")
       end
   end,
})
print("Xyde - Loaded")
    elseif currentPlaceId == 2753915549 or currentPlaceId == 4442272183 or currentPlaceId == 7449423635 then
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
    else
        warn("Xyde: Gra nieobsługiwana lub skrypt uniwersalny nie został zdefiniowany.")
        -- Tutaj możesz dodać uniwersalne GUI jeśli gra nie jest na liście
    end
end

-- =================================================================
-- 3. FUNKCJE KLUCZA
-- =================================================================
local function CheckKey(key)
    if not key or key == "" then return false end
    -- Usuwamy spacje i znaki nowej linii dla pewności
    key = key:gsub("%s+", "")
    
    local success, response = pcall(function()
        return game:HttpGet(BASE_URL .. key)
    end)
    
    if success and response == "true" then
        return true
    end
    return false
end

local function SaveKey(key)
    if writefile then
        writefile(FILE_NAME, key)
    end
end

local function LoadSavedKey()
    if isfile and isfile(FILE_NAME) then
        return readfile(FILE_NAME)
    end
    return ""
end

-- =================================================================
-- 4. INTERFEJS UŻYTKOWNIKA (GUI)
-- =================================================================

-- Najpierw sprawdzamy, czy mamy zapisany klucz. 
-- Jeśli tak i jest poprawny -> pomijamy GUI całkowicie!
local savedKey = LoadSavedKey()
if savedKey ~= "" then
    -- Szybkie sprawdzenie w tle (opcjonalne, można pominąć sprawdzanie online dla szybkości, ale bezpieczniej sprawdzić)
    if CheckKey(savedKey) then
        -- Klucz poprawny, odpalamy skrypt od razu bez GUI
        RunScript()
        return -- Kończymy działanie tego loadera, bo gra już działa
    end
end

-- Jeśli klucza nie ma lub jest błędny, rysujemy GUI:

if CoreGui:FindFirstChild("XydeKeySystem") then
    CoreGui.XydeKeySystem:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XydeKeySystem"
if pcall(function() ScreenGui.Parent = CoreGui end) then else ScreenGui.Parent = Player.PlayerGui end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(148, 0, 211)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "XYDE SCRIPT"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
KeyBox.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyBox.PlaceholderText = "Enter Key Here..."
KeyBox.Text = savedKey -- Wpisz stary klucz, nawet jak nie zadziałał w auto-loginie
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.Parent = MainFrame

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 6)
KeyCorner.Parent = KeyBox

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Text = "CHECK KEY"
VerifyBtn.Size = UDim2.new(0.38, 0, 0, 35)
VerifyBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(148, 0, 211)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 14
VerifyBtn.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = VerifyBtn

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.Size = UDim2.new(0.38, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.52, 0, 0.6, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = GetKeyBtn

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Text = "Waiting..."
StatusLbl.Size = UDim2.new(1, 0, 0, 20)
StatusLbl.Position = UDim2.new(0, 0, 0.85, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 12
StatusLbl.Parent = MainFrame

-- LOGIKA PRZYCISKÓW
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KEY_URL)
        StatusLbl.Text = "Link copied!"
        StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        StatusLbl.Text = "Clipboard not supported"
    end
end)

local function TryLogin()
    local inputKey = KeyBox.Text
    StatusLbl.Text = "Checking..."
    StatusLbl.TextColor3 = Color3.fromRGB(255, 200, 0)
    VerifyBtn.Text = "..."
    
    task.wait(0.1)
    
    if CheckKey(inputKey) then
        StatusLbl.Text = "Success!"
        StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
        SaveKey(inputKey) 
        
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        tween:Play()
        MainFrame.Visible = false
        ScreenGui:Destroy()
        
        RunScript()
    else
        StatusLbl.Text = "Invalid Key!"
        StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        VerifyBtn.Text = "CHECK KEY"
    end
end

VerifyBtn.MouseButton1Click:Connect(TryLogin)
