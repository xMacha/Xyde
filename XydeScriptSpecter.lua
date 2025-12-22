wait(1)
-- to do: 
-- sink
-- van keybinf
-- inf stamina
-- ghost room
-- Remove doors
-- hunt
-- remove doors
-- FOV
-- autofarm
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Roblox-GUI-libs/refs/heads/main/Rayfield.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Xyde script - Specter",
   Icon = "scroll-text", -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading",
   LoadingSubtitle = "by Macha",
   ShowText = "Xyde", -- for mobile users to unhide rayfield, change if you'd like
   Theme = {TextColor = Color3.fromRGB(255, 255, 255), Background = Color3.fromRGB(15, 15, 15), Topbar = Color3.fromRGB(25, 25, 25), Shadow = Color3.fromRGB(0, 0, 0), NotificationBackground = Color3.fromRGB(20, 20, 20), NotificationActionsBackground = Color3.fromRGB(230, 230, 230), TabBackground = Color3.fromRGB(40, 40, 40), TabStroke = Color3.fromRGB(160, 80, 220), TabBackgroundSelected = Color3.fromRGB(130, 40, 210), TabTextColor = Color3.fromRGB(255, 255, 255), SelectedTabTextColor = Color3.fromRGB(255, 255, 255), ElementBackground = Color3.fromRGB(30, 30, 30), ElementBackgroundHover = Color3.fromRGB(40, 40, 40), SecondaryElementBackground = Color3.fromRGB(25, 25, 25), ElementStroke = Color3.fromRGB(60, 60, 60), SecondaryElementStroke = Color3.fromRGB(40, 40, 40), SliderBackground = Color3.fromRGB(60, 30, 80), SliderProgress = Color3.fromRGB(148, 0, 211), SliderStroke = Color3.fromRGB(180, 100, 230), ToggleBackground = Color3.fromRGB(30, 30, 30), ToggleEnabled = Color3.fromRGB(148, 0, 211), ToggleDisabled = Color3.fromRGB(100, 100, 100), ToggleEnabledStroke = Color3.fromRGB(180, 100, 230), ToggleDisabledStroke = Color3.fromRGB(125, 125, 125), ToggleEnabledOuterStroke = Color3.fromRGB(60, 20, 100), ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65), DropdownSelected = Color3.fromRGB(40, 30, 50), DropdownUnselected = Color3.fromRGB(30, 30, 30), InputBackground = Color3.fromRGB(30, 30, 30), InputStroke = Color3.fromRGB(160, 80, 220), PlaceholderColor = Color3.fromRGB(178, 178, 178)},
   
   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = xyde, -- Create a custom folder for your hub/game
      FileName = "specter"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "qvHJg2g8", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, 

   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})


-- Taby
local TabMain = Window:CreateTab("Main", 4483362458)
local TabTeleport = Window:CreateTab("Teleport", "map-pin")
local TabVisuals = Window:CreateTab("Visuals", "eye")
local TabAutofarm = Window:CreateTab("Autofarm", "refresh-ccw")
-- Sekcje
local SectionMisc1 = TabMain:CreateSection("Info")
local SectionGhostRoom = TabMain:CreateSection("Ghost Room")
local SectionEvidence = TabMain:CreateSection("Ghost Evidence")
local SectionMisc1 = TabMain:CreateSection("Misc")
local SectionLocations = TabTeleport:CreateSection("Locations")
local SectionEsp = TabVisuals:CreateSection("ESP")
local SectionMisc2 = TabVisuals:CreateSection("Misc")
-- Zmienne
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GhostRoom = false
-- Teleportacja zakładka
local function tp(x, y, z)
    -- Sprawdzamy czy postać istnieje
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- 1. Zrób Anchor (Zabrolokuj fizykę)
    rootPart.Anchored = true

    -- 2. Wyłącz kolizje (Aby przenikać przez ściany podczas lotu)
    -- Wyłączamy kolizje dla wszystkich części ciała
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- 3. Poleć do miejsca (Ustawienia lotu)
    local targetCFrame = CFrame.new(x, y, z)
    local speed = 100 -- Prędkość lotu (studów na sekundę) - im więcej, tym szybciej
    local distance = (targetCFrame.Position - rootPart.Position).Magnitude
    local time = distance / speed -- Czas obliczany na podstawie odległości

    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})

    tween:Play()
    tween.Completed:Wait() -- Czekaj aż doleci na miejsce

    -- 4. Włącz kolizje
    -- Przywracamy kolizje (głównie dla RootPart, reszta zwykle ustawia się sama przez Humanoida)
    rootPart.CanCollide = true
    
    -- Opcjonalnie włączamy dla reszty, ale ostrożnie, by nie zbugować postaci w podłodze
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end

    -- 5. Wyłącz Anchor (Przywróć fizykę)
    rootPart.Anchored = false
end

local TeleportToVan = TabTeleport:CreateButton({
   Name = "Teleport to van",
   Callback = function()
	Van = game.workspace.Van
	Pos = Van.WorldPivot.Position
	tp(Pos.X, Pos.Y + 4.5, Pos.Z)
	end,
})

local TeleportToRoom = TabTeleport:CreateButton({
   Name = "Teleport to ghost room",
   Callback = function()
	if GhostRoom then
		-- teleport
	else
		Rayfield:Notify({
		   Title = "ERROR",
		   Content = "You need to first find ghoost room!",
		   Duration = 6.5,
		   Image = "circle-alert",
		})
	end
   end,
})

-- Funkcja pomocnicza do pobierania nazw pokoi
local function getRoomNames()
    local roomNames = {}
    local map = game.Workspace:FindFirstChild("Map")
    local roomsFolder = map and map:FindFirstChild("Rooms")
    
    if roomsFolder then
        for _, room in pairs(roomsFolder:GetChildren()) do
            -- Sprawdzamy, czy w folderze pokoju jest "Hitbox"
            if room:FindFirstChild("Hitbox") then
                table.insert(roomNames, room.Name)
            end
        end
    end
    
    -- Opcjonalnie: Sortujemy alfabetycznie dla porządku
    table.sort(roomNames)
    
    return roomNames
end

-- Tworzenie Dropdowna
local RoomDropdown = TabTeleport:CreateDropdown({
   Name = "Teleport to Room",
   Options = getRoomNames(), -- Pobiera listę na start
   CurrentOption = {"Select Room"},
   MultipleOptions = false,
   Callback = function(Options)
      local selectedRoomName = Options[1]
      
      -- Szukamy wybranego pokoju
      local roomsFolder = game.Workspace.Map:FindFirstChild("Rooms")
      local room = roomsFolder and roomsFolder:FindFirstChild(selectedRoomName)
      
      if room and room:FindFirstChild("Hitbox") then
          local pos = room.Hitbox.Position
          -- Używamy twojej funkcji tp
          tp(pos.X, pos.Y + 2, pos.Z) -- +2 stud w górę, żeby nie ugrzęznąć w podłodze
      else
          Rayfield:Notify({Title = "Error", Content = "Room or Hitbox not found!", Duration = 3})
      end
   end,
})

-- Przycisk do odświeżania listy (gdy mapa się dogeneruje)
TabTeleport:CreateButton({
   Name = "Refresh Room List",
   Callback = function()
       local newOptions = getRoomNames()
       RoomDropdown:Refresh(newOptions, true) -- true oznacza, że czyścimy starą selekcję
       Rayfield:Notify({Title = "Success", Content = "Found " .. #newOptions .. " rooms.", Duration = 2, Image = "check",})
   end,
})
------------------------------
local SectionObj = TabTeleport:CreateSection("Objects")
-------------------------------

local TeleportToBone = TabTeleport:CreateButton({
   Name = "Teleport to bone",
   Callback = function()
    if game.workspace.Map:FindFirstChild("Bone") then
		Bone = game.workspace.Map.Bone
		Pos = Bone.Position
		tp(Pos.X, Pos.Y + 4.5, Pos.Z)
	else
		Rayfield:Notify({
   		Title = "ERROR",
   		Content = "There is no bone",
    	Duration = 6.5,
   		Image = "circle-alert",})
	end
   end,
})

--board
local TeleportToBoard = TabTeleport:CreateButton({
   Name = "Teleport to ouija board",
   Callback = function()
	if game.workspace.Map.cursed_object:FindFirstChild("Board") then
		Board = game.workspace.Map.cursed_object.Board
		Pos = Board.Position
		tp(Pos.X, Pos.Y + 1, Pos.Z)
	else
		Rayfield:Notify({
   		Title = "ERROR",
   		Content = "There is no ouija board",
    	Duration = 6.5,
   		Image = "circle-alert",})
	end
   end,
})
-- fuse
local TeleportToFuse = TabTeleport:CreateButton({
   Name = "Teleport to fusebox",
   Callback = function()
	Fuse = game.workspace.Map.Fusebox.Fusebox
	Pos = Fuse.Position
	tp(Pos.X, Pos.Y, Pos.Z)
   end,
})
-- skull
local TeleportToSkull = TabTeleport:CreateButton({
   Name = "Teleport to cursed skull",
   Callback = function()
	if game.workspace.Map.cursed_object:FindFirstChild("Skull") then
		Skull = game.workspace.Map.cursed_object.Skull
		Pos = Skull.Position
		tp(Pos.X, Pos.Y, Pos.Z)
	else
		Rayfield:Notify({
   		Title = "ERROR",
   		Content = "There is no cursed skull",
    	Duration = 6.5,
   		Image = "circle-alert",})
	end
   end,
})
-- book
local TeleportToBook = TabTeleport:CreateButton({
   Name = "Teleport to necronomicon",
   Callback = function()
	if game.workspace.Map.cursed_object:FindFirstChild("Book") then
		Book = game.workspace.Map.cursed_object.Book
		Pos = Book.Face.Position
		tp(Pos.X, Pos.Y, Pos.Z)
	else
		Rayfield:Notify({
   		Title = "ERROR",
   		Content = "There is no necronomicon",
    	Duration = 6.5,
   		Image = "circle-alert",})
	end
   end,1
})

-----------------------
local SectionPlayers = TabTeleport:CreateSection("Players")
-----------------------

local function getPlayerNames()
    local names = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local PlayerDropdown = TabTeleport:CreateDropdown({
    Name = "Teleport to Player",
    Options = getPlayerNames(),
    CurrentOption = {"Select Player"},
    MultipleOptions = false,
    Callback = function(Options)
        local targetName = Options[1]
        local targetPlayer = game.Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = targetPlayer.Character.HumanoidRootPart.Position
            tp(pos.X, pos.Y, pos.Z)
        end
    end,
})

-- Opcjonalne: Odświeżanie listy graczy co 10 sekund
task.spawn(function()
    while task.wait(10) do
        PlayerDropdown:Refresh(getPlayerNames(), true)
    end
end)

-------------------------------------------------------------
local fullbright = TabVisuals:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "fullbright", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   if Value then
	    game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	else
		game.Lighting.Ambient = Color3.fromRGB(0, 0, 0)
   end
   end,
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Zmienne trzymane na zewnątrz, żeby mieć do nich dostęp przy wyłączaniu
local SanityGui = nil
local SanityLoop = nil

-- Używamy TabVisuals zgodnie z twoim poleceniem
local SanityToggle = TabVisuals:CreateToggle({
   Name = "Show Sanity (Draggable)",
   CurrentValue = false,
   Flag = "SanityDisplay",
   Callback = function(Value)
       if Value then
           -- === WŁĄCZANIE ===
           
           -- 1. Tworzymy ScreenGui
           SanityGui = Instance.new("ScreenGui")
           if pcall(function() SanityGui.Parent = game.CoreGui end) then
               SanityGui.Parent = game.CoreGui
           else
               SanityGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
           end

           -- 2. Tworzymy Tło (Frame), które będzie można przesuwać
           local Background = Instance.new("Frame")
           Background.Name = "SanityBackground"
           Background.Parent = SanityGui
           Background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
           Background.BackgroundTransparency = 0.3
           Background.Position = UDim2.new(0.8, 0, 0.85, 0) -- Startowa pozycja
           Background.Size = UDim2.new(0, 200, 0, 50)
           
           -- 3. Włączamy przenoszenie myszką
           Background.Active = true
           Background.Draggable = true -- To pozwala przesuwać element

           -- Zaokrąglone rogi dla tła (Naprawiony błąd RCorner)
           local Corner = Instance.new("UICorner")
           Corner.CornerRadius = UDim.new(0, 8)
           Corner.Parent = Background

           -- 4. Tworzymy Etykietę z tekstem (w środku tła)
           local Label = Instance.new("TextLabel")
           Label.Parent = Background
           Label.Size = UDim2.new(1, 0, 1, 0) -- Wypełnia całe tło
           Label.BackgroundTransparency = 1 -- Przezroczysta, bo tło ma kolor
           Label.TextColor3 = Color3.fromRGB(255, 255, 255)
           Label.TextSize = 22
           Label.Font = Enum.Font.SourceSansBold
           Label.Text = "Waiting..."

           -- 5. Pętla aktualizująca wartość Sanity
           SanityLoop = RunService.RenderStepped:Connect(function()
               local sanityValue = LocalPlayer:GetAttribute("Sanity")
               
               if sanityValue then
                   Label.Text = "Sanity: " .. tostring(math.floor(sanityValue))
                   
                   -- Opcjonalnie: Zmiana koloru tekstu gdy mało Sanity
                   if sanityValue < 50 then
                       Label.TextColor3 = Color3.fromRGB(255, 50, 50) -- Czerwony
                   else
                       Label.TextColor3 = Color3.fromRGB(255, 255, 255) -- Biały
                   end
               else
                   Label.Text = "Sanity: N/A"
               end
           end)

       else
           -- === WYŁĄCZANIE ===
           
           if SanityGui then
               SanityGui:Destroy()
               SanityGui = nil
           end
           
           if SanityLoop then
               SanityLoop:Disconnect()
               SanityLoop = nil
           end
       end
   end,
})

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Zmienna przechowująca wybrane FOV
local TargetFOV = 70 -- Domyślna wartość
local FOVLoop = nil

-- Uruchamiamy pętlę, która "siłowo" trzyma ustawione FOV
-- Dzięki temu inne skrypty gry nie mogą go zmienić
if not FOVLoop then
    FOVLoop = RunService.RenderStepped:Connect(function()
        Camera.FieldOfView = TargetFOV
    end)
end

local FOVSlider = TabVisuals:CreateSlider({
   Name = "Field of View",
   Range = {30, 120}, -- Zakres FOV (standardowo 70, max zazwyczaj 120)
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "FOV_Slider",
   Callback = function(Value)
       -- Slider aktualizuje tylko zmienną, pętla wyżej robi resztę roboty
       TargetFOV = Value
   end,
})
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local StaminaLoop = nil -- Zmienna do przechowywania pętli

local StaminaToggle = TabMain:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Flag = "InfStamina",
   Callback = function(Value)
       if Value then
           -- === WŁĄCZANIE (ON) ===
           -- Uruchamiamy pętlę, która działa w tle bardzo szybko (co klatkę)
           StaminaLoop = RunService.RenderStepped:Connect(function()
               
               -- Opcja 1: Sprawdzamy, czy Stamina jest Atrybutem (najczęstsze)
               if LocalPlayer:GetAttribute("Stamina") ~= nil then
                   LocalPlayer:SetAttribute("Stamina", 100)
               
               -- Opcja 2: Sprawdzamy, czy Stamina jest obiektem (np. IntValue/NumberValue)
               elseif LocalPlayer:FindFirstChild("Stamina") then
                   LocalPlayer.Stamina.Value = 100
               end
               
           end)
       else
           -- === WYŁĄCZANIE (OFF) ===
           -- Zatrzymujemy pętlę, aby gra wróciła do normy
           if StaminaLoop then
               StaminaLoop:Disconnect()
               StaminaLoop = nil
           end
       end
   end,
})
