-- get key from https://macha.lol or https://work.ink/2ba3/xyde-key-system or https://xxmacha.pythonanywhere.com
-- key = "YOUR KEY" 
-- loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Xyde/refs/heads/main/source/XydeLoader.lua'))()

discord = "https://discord.gg/p9jCxg5m"
if not key then
  key = ""
end
local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport or fluxus.queue_on_teleport
queue_on_teleport([[loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Xyde/refs/heads/main/source/XydeLoader.lua'))()]])
local BASE_URL = "https://xxMacha.pythonanywhere.com/api/check_key?k="
local currentPlaceId = game.PlaceId

local success, response = pcall(function()
    return game:HttpGet(BASE_URL .. key)
end)
local function findscript()
	if currentPlaceId == 8417221956 then
		loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Xyde/refs/heads/main/source/specter/XydeScriptSpecter.lua'))()
	end
	if currentPlaceId == 2753915549 or currentPlaceId == 4442272183 or currentPlaceId == 7449423635 then
		loadstring(game:HttpGet('https://raw.githubusercontent.com/xMacha/Xyde/refs/heads/main/source/bloxfruit/XydeScriptBloxfruit.lua'))()
	end
end
-- === WYNIK ===
if success then
    if response == "true" then
        print("Key - ✅")     
		findscript()
    else
        warn("Key - ❌")
    end
end
