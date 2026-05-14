local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local old = CoreGui:FindFirstChild("CustomGUI_V2") or LP.PlayerGui:FindFirstChild("CustomGUI_V2")
if old then old:Destroy() end

-- // SAVE/LOAD SYSTEM //
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId
local SAVE_FILE = PlaceId .. "_ZentroHub_SaveData.json"

local function saveData(data)
    local saveKeybinds = {}
    for modKey, keyEnum in pairs(data.keybinds or {}) do
        if typeof(keyEnum) == "EnumItem" then
            saveKeybinds[modKey] = keyEnum.Name
        end
    end
    local dataToSave = {
        settings = data.settings,
        activeModules = data.activeModules,
        tabPositions = data.tabPositions,
        minimizedTabs = data.minimizedTabs,
        keybinds = saveKeybinds
    }
    local success, err = pcall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode(dataToSave))
    end)
    if not success then warn("Fehler beim Speichern:", err) end
end

local function loadData()
    local success, result = pcall(function()
        if isfile(SAVE_FILE) then
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end
        return nil
    end)
    if success then return result
    else warn("Fehler beim Laden:", result); return nil end
end

local mods = {
    {"Combat", "Aimbot", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/aimbot.lua", true, Keybind = false},
    {"Combat", "GodMode", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/nodie.lua", true, Keybind = true},
    {"Combat", "Hitbox", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/hitbox.lua", true, Keybind = false},
    {"Combat", "Fling", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/fling.lua", true, Keybind = true},
    {"Movement", "Air-Jump", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/AirJump.lua", true, Keybind = true},
    {"Movement", "B-Hop", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/bhop.lua", true, Keybind = true},
    {"Movement", "Click-Tp", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/clicktp.lua", true, Keybind = true},
    {"Movement", "Fly", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/Fly.lua", true, Keybind = true},
    {"Movement", "Noclip", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/Noclip.lua", true, Keybind = true},
    {"Movement", "No-Fall", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/nofall.lua", true, Keybind = true},
    {"Movement", "Speed", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/Speed.lua", true, Keybind = true},
    {"Movement", "Spider", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/spider.lua", true, Keybind = true},
    {"Movement", "Tp-Hub", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/tp.lua", true, Keybind = false},
    {"Movement", "Vehicle-Fly", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/vfly.lua", true, Keybind = false},
    {"Visuals", "Bread-Crumbs", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/breadcrumbs.lua", true, Keybind = true},
    {"Visuals", "Derp", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/derp.lua", true, Keybind = true},
    {"Visuals", "ESP", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/esp.lua", true, Keybind = true},
    {"Visuals", "FreeCam", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/freecam.lua", true, Keybind = false},
    {"Visuals", "Full-Bright", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/fullb.lua", true, Keybind = true},
    {"Visuals", "invisible", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/invis.lua", true, Keybind = true},
    {"Visuals", "Minimap", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/minimap.lua", true, Keybind = true},
    {"Visuals", "Player-Info", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Dbug/playerinfo.lua", true, Keybind = true},
    {"Visuals", "Rainbow-tools", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/neontool.lua", true, Keybind = true},
    {"Visuals", "Spectate", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/spectate.lua", true, Keybind = true},
    {"Visuals", "Tracer", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/tracer.lua", true, Keybind = true},
    {"Visuals", "Watermark", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/watermark.lua", true, Keybind = true},
    {"Game", "Auto-interact", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/autointeract.lua", true, Keybind = true},
    {"Game", "FPS", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/fps.lua", true, Keybind = true},
    {"Game", "Hack-Detect", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/hack.lua", true, Keybind = true},
    {"Game", "Instand-interact", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/instateract.lua", true, Keybind = true},
    {"Game", "Player-Activity", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/playernotify.lua", true, Keybind = true},
    {"Game", "Visuals-dbug", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/dbug.lua", true, Keybind = true},
    {"Game", "Try-To-Unlock", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Dbug/unlock.lua", true, Keybind = true},
    {"Game", "X-Explorer", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Dbug/XExplorer.lua", true, Keybind = true},
    {"Server", "Hop-Full", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/hopfull.lua", false, Keybind = true},
    {"Server", "Hop-Low", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/hoplow.lua", false, Keybind = true},
    {"Server", "Hop-Mid", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/hopmid.lua", false, Keybind = true},
    {"Server", "Rejoin", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/rejoin.lua", false, Keybind = true},
    {"Shading", "Bloom", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/bloom.lua", true, Keybind = true},
    {"Shading", "Color", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/lc.lua", true, Keybind = true},
    {"Shading", "Depth-Of-Field", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/dof.lua", true, Keybind = true},
    {"Shading", "SunRays", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/sunrays.lua", true, Keybind = true},
    {"Shading", "PostFX", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/postfx.lua", true, Keybind = true},
    {"FE", "Bang", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/bang.lua", true, Keybind = false},
    {"FE", "Tkns", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/telik.lua", true, Keybind = false},
    {"Safety", "Anti-AFK", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/afk.lua", true, Keybind = true},
    {"Safety", "Anti-Fling", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/antifling.lua", true, Keybind = true},
    {"Safety", "AntiSit", "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Mods/antisit.lua", true, Keybind = true},
}

local settings = {
    {"Visuals", "ESP", {
        {type = "slider", title = "Max Distance", default = 1000, min = 100, max = 5000, var = "ESPMaxDistance"},
        {type = "checkbox", title = "Show Outline", default = true, var = "esp"},
        {type = "checkbox", title = "Show Boxes", default = false, var = "ESPShowBoxes"},
        {type = "checkbox", title = "Show Names", default = true, var = "ESPShowNames"},
        {type = "checkbox", title = "Show Distance", default = false, var = "ESPShowDistance"},
        {type = "slider", title = "Red", default = 255, min = 0, max = 255, var = "ESP_R"},
        {type = "slider", title = "Green", default = 0, min = 0, max = 255, var = "ESP_G"},
        {type = "slider", title = "Blue", default = 255, min = 0, max = 255, var = "ESP_B"},
        {type = "checkbox", title = "Rainbow Mode", default = false, var = "ESP_Rainbow"},
        {type = "checkbox", title = "Team Check", default = true, var = "ESP_TeamCheck"}
    }},
    {"Visuals", "Derp", {
        {type = "slider", title = "Speed", default = 0.3, min = 0.1, max = 100, var = "derpspeed"},
    }},
    {"Visuals", "Tracer", {
        {type = "slider", title = "Red", default = 255, min = 0, max = 255, var = "Tracer_R"},
        {type = "slider", title = "Green", default = 0, min = 0, max = 255, var = "Tracer_G"},
        {type = "slider", title = "Blue", default = 255, min = 0, max = 255, var = "Tracer_B"},
        {type = "checkbox", title = "Rainbow Mode", default = false, var = "Tracer_Rainbow"},
        {type = "checkbox", title = "Team Check", default = true, var = "TracerTeamCheck"},
    }},
    {"Movement", "Fly", {
        {type = "slider", title = "Speed", default = 60, min = 1, max = 200, var = "FlySpeed"},
        {type = "slider", title = "Speed Multi", default = 1, min = 1, max = 100, var = "FlyMulti"},
    }},
    {"Movement", "Speed", {
        {type = "slider", title = "Speed", default = 16, min = 1, max = 300, var = "WalkSpeed"},
    }},
    {"Shading", "SunRays", {
        {type = "slider", title = "Intensity", default = 50, min = 1, max = 100, var = "Intensity"},
        {type = "slider", title = "Spread", default = 50, min = 1, max = 100, var = "Spread"},
    }},
    {"Shading", "PostFX", {
        {type = "slider", title = "Brightness", default = 0, min = -100, max = 100, var = "PostFx_Brightness"},
        {type = "slider", title = "Contrast", default = 0, min = -100, max = 100, var = "PostFx_Contrast"},
        {type = "slider", title = "Saturation", default = 0, min = -100, max = 100, var = "PostFx_Saturation"},
    }},
    {"Shading", "Depth-Of-Field", {
        {type = "slider", title = "Near", default = 20, min = 0, max = 100, var = "DOF_Near"},
        {type = "slider", title = "Far", default = 80, min = 0, max = 100, var = "DOF_Far"},
        {type = "slider", title = "Focus", default = 50, min = 0, max = 100, var = "DOF_Focus"},
        {type = "slider", title = "Intensity", default = 40, min = 0, max = 100, var = "DOF_Intensity"},
    }},
    {"Shading", "Bloom", {
        {type = "slider", title = "Threshold", default = 20, min = 0, max = 100, var = "Bloom_Threshold"},
        {type = "slider", title = "Size", default = 24, min = 0, max = 100, var = "Bloom_Size"},
        {type = "slider", title = "Intensity", default = 40, min = 0, max = 100, var = "Bloom_Intensity"},
    }},
    {"Shading", "Color", {
        {type = "slider", title = "Red", default = 180, min = 0, max = 255, var = "lcRed"},
        {type = "slider", title = "Green", default = 200, min = 0, max = 255, var = "lcGreen"},
        {type = "slider", title = "Blue", default = 255, min = 0, max = 255, var = "lcBlue"},
    }},
}

-- ======================================================
-- 🎄 WEIHNACHTS THEME COLORS & CONFIG
-- ======================================================

-- Tab-Farben: abwechselnd Rot/Grün/Gold/Dunkelblau-Nacht Weihnachtsvarianten
local xmasTabColors = {
    -- Weihnachtsrot (tief dunkel)
    {bg = Color3.fromRGB(55, 8, 8),   stroke = Color3.fromRGB(200, 40, 40),  title = Color3.fromRGB(255, 120, 120), headerBg = Color3.fromRGB(140, 20, 20)},
    -- Tannengrün (tief dunkel)
    {bg = Color3.fromRGB(8, 38, 12),  stroke = Color3.fromRGB(40, 160, 60),  title = Color3.fromRGB(100, 220, 120), headerBg = Color3.fromRGB(15, 90, 25)},
    -- Weihnachtsgold
    {bg = Color3.fromRGB(45, 32, 5),  stroke = Color3.fromRGB(200, 150, 20), title = Color3.fromRGB(255, 205, 70),  headerBg = Color3.fromRGB(110, 75, 10)},
    -- Nachtblau (Winternacht)
    {bg = Color3.fromRGB(8, 12, 45),  stroke = Color3.fromRGB(60, 100, 210), title = Color3.fromRGB(130, 170, 255), headerBg = Color3.fromRGB(20, 30, 110)},
    -- Cranberry-Rot
    {bg = Color3.fromRGB(48, 8, 25),  stroke = Color3.fromRGB(180, 30, 90),  title = Color3.fromRGB(240, 100, 160), headerBg = Color3.fromRGB(110, 15, 50)},
    -- Mistelgrün
    {bg = Color3.fromRGB(10, 42, 18), stroke = Color3.fromRGB(50, 180, 80),  title = Color3.fromRGB(120, 235, 140), headerBg = Color3.fromRGB(18, 100, 35)},
    -- Kerzen-Orange
    {bg = Color3.fromRGB(50, 22, 5),  stroke = Color3.fromRGB(210, 100, 20), title = Color3.fromRGB(255, 160, 60),  headerBg = Color3.fromRGB(120, 50, 10)},
    -- Eiszapfen-Blau
    {bg = Color3.fromRGB(8, 28, 48),  stroke = Color3.fromRGB(80, 160, 230), title = Color3.fromRGB(160, 210, 255), headerBg = Color3.fromRGB(20, 70, 130)},
}

local tabColorIndex = 0
local function getNextXmasColor()
    tabColorIndex = (tabColorIndex % #xmasTabColors) + 1
    return xmasTabColors[tabColorIndex]
end

-- Weihnachts-Emojis für Tab-Titel
local xmasEmojis = {"🎄", "🎅", "⛄", "🔔", "🎁", "⭐", "🕯️", "❄️"}
local emojiIdx = 0
local function getNextXmasEmoji()
    emojiIdx = (emojiIdx % #xmasEmojis) + 1
    return xmasEmojis[emojiIdx]
end

-- Button Farben (Weihnachts-Rot/Grün Kontrast)
local BTN_INACTIVE_BG     = Color3.fromRGB(28, 10, 10)
local BTN_INACTIVE_TEXT   = Color3.fromRGB(200, 120, 120)
local BTN_INACTIVE_STROKE = Color3.fromRGB(100, 25, 25)
local BTN_ACTIVE_BG       = Color3.fromRGB(10, 38, 14)
local BTN_ACTIVE_TEXT     = Color3.fromRGB(100, 220, 120)
local BTN_ACTIVE_STROKE   = Color3.fromRGB(40, 160, 60)

-- Slider: Gold
local SLIDER_COLOR    = Color3.fromRGB(220, 165, 30)
local SLIDER_BG_COLOR = Color3.fromRGB(35, 25, 5)

-- Keybind: Eisblau
local KEYBIND_COLOR = Color3.fromRGB(100, 180, 240)

-- Weihnachtskugel-Farben für Button-Dots
local ornamentColors = {
    Color3.fromRGB(220, 30, 30),   -- Rot
    Color3.fromRGB(30, 160, 50),   -- Grün
    Color3.fromRGB(220, 180, 20),  -- Gold
    Color3.fromRGB(60, 120, 220),  -- Blau
    Color3.fromRGB(200, 60, 120),  -- Pink
    Color3.fromRGB(180, 80, 20),   -- Orange
    Color3.fromRGB(180, 180, 220), -- Silber
}
local ornIdx = 0
local function getOrnamentColor()
    ornIdx = (ornIdx % #ornamentColors) + 1
    return ornamentColors[ornIdx]
end

-- ======================================================
-- ❄️ SCHNEEFLOCKEN-PARTIKEL (fallen von oben)
-- ======================================================
local function spawnSnowEffect(parent)
    task.spawn(function()
        while parent and parent.Parent do
            local flake = Instance.new("TextLabel", parent)
            flake.BackgroundTransparency = 1
            flake.Text = ({"❄️", "❅", "✦", "·", "∗"})[math.random(1, 5)]
            flake.TextSize = math.random(8, 18)
            flake.Font = Enum.Font.GothamBold
            flake.Size = UDim2.new(0, 22, 0, 22)
            flake.Position = UDim2.new(math.random() * 0.95, 0, 0, -25)
            flake.ZIndex = 10
            flake.TextTransparency = 0
            flake.TextColor3 = Color3.fromRGB(
                math.random(200, 255),
                math.random(220, 255),
                255
            )

            local driftX = (math.random() - 0.5) * 0.15
            TweenService:Create(flake, TweenInfo.new(math.random(4, 7), Enum.EasingStyle.Linear), {
                Position = UDim2.new(math.random() * 0.95 + driftX, 0, 1, 15),
                TextTransparency = 0.3
            }):Play()

            task.delay(7, function()
                if flake and flake.Parent then flake:Destroy() end
            end)

            task.wait(math.random(1, 3) * 0.5)
        end
    end)
end

-- ======================================================
-- 🌨️ SCHNEE-HÄUFCHEN am unteren Rand (statt Gras)
-- ======================================================
local function addSnowDrift(frame, xmasColor)
    -- Schnee-Streifen
    local snowBar = Instance.new("Frame", frame)
    snowBar.Name = "SnowBar"
    snowBar.Size = UDim2.new(1, 0, 0, 12)
    snowBar.AnchorPoint = Vector2.new(0, 1)
    snowBar.Position = UDim2.new(0, 0, 1, 0)
    snowBar.BackgroundColor3 = Color3.fromRGB(210, 230, 255)
    snowBar.BorderSizePixel = 0
    snowBar.ZIndex = frame.ZIndex + 1
    local sc = Instance.new("UICorner", snowBar)
    sc.CornerRadius = UDim.new(0, 6)

    -- Schneeflocken-Text
    local snowLabel = Instance.new("TextLabel", snowBar)
    snowLabel.Size = UDim2.new(1, 0, 1, 0)
    snowLabel.BackgroundTransparency = 1
    snowLabel.Text = "· · · · · · · · · · · · · · · · · ·"
    snowLabel.TextColor3 = Color3.fromRGB(160, 200, 240)
    snowLabel.Font = Enum.Font.GothamBold
    snowLabel.TextSize = 8
    snowLabel.ClipsDescendants = true
    snowLabel.ZIndex = snowBar.ZIndex + 1

    -- Sanftes Glitzern
    task.spawn(function()
        while snowBar and snowBar.Parent do
            TweenService:Create(snowBar, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(230, 245, 255)
            }):Play()
            task.wait(1.5)
            TweenService:Create(snowBar, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(180, 210, 245)
            }):Play()
            task.wait(1.5)
        end
    end)
end

-- ======================================================
-- ⭐ STERN-ANIMATION (schwebt oben am Tab, statt Schmetterling)
-- ======================================================
local function addStarDecoration(frame)
    local star = Instance.new("TextLabel", frame)
    star.Name = "XmasStar"
    star.Size = UDim2.new(0, 20, 0, 20)
    star.Position = UDim2.new(1, -24, 0, 8)
    star.BackgroundTransparency = 1
    star.Text = "⭐"
    star.TextSize = 14
    star.Font = Enum.Font.GothamBold
    star.ZIndex = frame.ZIndex + 5

    -- Sanftes Glitzern: Skalierung simulieren via TextSize
    task.spawn(function()
        local t = math.random() * math.pi * 2
        while star and star.Parent do
            t = t + 0.06
            local pulse = math.abs(math.sin(t))
            star.TextSize = 11 + pulse * 5
            star.TextColor3 = Color3.fromRGB(
                255,
                math.floor(180 + pulse * 75),
                math.floor(30 + pulse * 40)
            )
            task.wait(0.05)
        end
    end)
end

-- ======================================================
-- 🎄 LICHTERKETTEN-ANIMATION (blinkt an der Titelleiste)
-- ======================================================
local function addLightsDecoration(titleBar, xmasColor)
    -- Kleine bunte Lichter als TextLabel
    local lights = Instance.new("TextLabel", titleBar)
    lights.Name = "XmasLights"
    lights.Size = UDim2.new(1, -30, 0, 12)
    lights.Position = UDim2.new(0, 4, 1, -2)
    lights.BackgroundTransparency = 1
    lights.Text = "● ● ● ● ● ● ● ● ● ● ● ●"
    lights.Font = Enum.Font.GothamBold
    lights.TextSize = 8
    lights.TextColor3 = Color3.fromRGB(255, 80, 80)
    lights.ZIndex = titleBar.ZIndex + 3

    -- Blinkende Lichterkette: Farben wechseln
    local lightColors = {
        Color3.fromRGB(255, 50, 50),   -- Rot
        Color3.fromRGB(40, 220, 60),   -- Grün
        Color3.fromRGB(255, 210, 30),  -- Gold
        Color3.fromRGB(60, 140, 255),  -- Blau
        Color3.fromRGB(255, 80, 180),  -- Pink
    }
    task.spawn(function()
        local ci = 1
        while lights and lights.Parent do
            lights.TextColor3 = lightColors[ci]
            ci = (ci % #lightColors) + 1
            task.wait(0.35)
        end
    end)
end

-- ======================================================
-- Gespeicherte Daten laden
-- ======================================================
local savedData = loadData()
_G.ZTH_Settings = _G.ZTH_Settings or {}

for _, settingGroup in ipairs(settings) do
    for _, setting in ipairs(settingGroup[3]) do
        if savedData and savedData.settings and savedData.settings[setting.var] ~= nil then
            _G.ZTH_Settings[setting.var] = savedData.settings[setting.var]
        elseif not _G.ZTH_Settings[setting.var] then
            _G.ZTH_Settings[setting.var] = setting.default
        end
    end
end

local activeModules = (savedData and savedData.activeModules) or {}
local tabPositions  = (savedData and savedData.tabPositions)  or {}
local minimizedTabs = (savedData and savedData.minimizedTabs) or {}
local keybinds = {}
if savedData and savedData.keybinds then
    for modKey, keyName in pairs(savedData.keybinds) do
        if type(keyName) == "string" then
            local enum = Enum.KeyCode[keyName]
            if enum then keybinds[modKey] = enum end
        end
    end
end

local whitelistedIds = {}
pcall(function()
    local keysModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/main/key/keys.lua"))()
    if typeof(keysModule) == "table" then
        for _, idStr in ipairs(keysModule) do
            local idNum = tonumber(idStr)
            if idNum then whitelistedIds[idNum] = true end
        end
    end
end)

-- Spieler-Tag: Weihnachts-Edition 🎄
local function createXmasTag(player)
    if not player or not player.Character or not player.Character:FindFirstChild("Head") then return end
    local head = player.Character.Head
    if head:FindFirstChild("ZTH_Tag") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ZTH_Tag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 240, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🎄 ZentroHub 🎅"
    textLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(20, 60, 20)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 20
    textLabel.Parent = billboard

    -- Rot-Grün-Gold Blinken
    local xmasTextColors = {
        Color3.fromRGB(255, 60, 60),
        Color3.fromRGB(50, 200, 80),
        Color3.fromRGB(255, 200, 30),
        Color3.fromRGB(60, 160, 255),
        Color3.fromRGB(255, 100, 180),
    }
    task.spawn(function()
        local ci = 1
        while billboard and billboard.Parent do
            textLabel.TextColor3 = xmasTextColors[ci]
            ci = (ci % #xmasTextColors) + 1
            task.wait(0.5)
        end
    end)
end

local function checkPlayer(player)
    if whitelistedIds[player.UserId] then
        if player.Character and player.Character:FindFirstChild("Head") then
            createXmasTag(player)
        end
        player.CharacterAdded:Connect(function()
            repeat task.wait() until player.Character and player.Character:FindFirstChild("Head")
            createXmasTag(player)
        end)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do checkPlayer(plr) end
Players.PlayerAdded:Connect(checkPlayer)

-- ======================================================
-- GUI SETUP
-- ======================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomGUI_V2"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- Dunkler Winternacht-Vignette
local Vignette = Instance.new("ImageLabel", ScreenGui)
Vignette.BackgroundTransparency = 1
Vignette.Size = UDim2.new(1, 0, 1, 0)
Vignette.Image = "rbxassetid://257684567"
Vignette.ImageColor3 = Color3.fromRGB(5, 8, 25)
Vignette.ImageTransparency = 1
Vignette.ZIndex = 0

-- Schneeflocken global
spawnSnowEffect(ScreenGui)

local wasCursorVisibleBeforeOpening = false
local function toggleCursor(opening)
    if opening then
        wasCursorVisibleBeforeOpening = UserInputService.MouseIconEnabled
        UserInputService.MouseIconEnabled = true
        local ModalFix = Instance.new("TextButton", ScreenGui)
        ModalFix.Name = "ModalFix"; ModalFix.Modal = true; ModalFix.Visible = false
        TweenService:Create(Vignette, TweenInfo.new(0.3), {ImageTransparency = 0.65}):Play()
    else
        if not wasCursorVisibleBeforeOpening then UserInputService.MouseIconEnabled = false end
        if ScreenGui:FindFirstChild("ModalFix") then ScreenGui.ModalFix:Destroy() end
        TweenService:Create(Vignette, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    end
end
toggleCursor(true)

local function makeDraggable(topbar, object, tabNameKey)
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = object.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tabPositions[tabNameKey] = {
                X_Scale = object.Position.X.Scale, X_Offset = object.Position.X.Offset,
                Y_Scale = object.Position.Y.Scale, Y_Offset = object.Position.Y.Offset
            }
            saveData({settings = _G.ZTH_Settings, activeModules = activeModules,
                tabPositions = tabPositions, minimizedTabs = minimizedTabs, keybinds = keybinds})
        end
    end)
end

-- 🎄 Weihnachts-Slider (Gold-Akzent)
local function createSlider(parent, setting)
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", SliderFrame)
    Title.Size = UDim2.new(1, 0, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = setting.title
    Title.TextColor3 = Color3.fromRGB(210, 170, 100)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 10
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel", SliderFrame)
    ValueLabel.Size = UDim2.new(1, 0, 0, 15)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(_G.ZTH_Settings[setting.var])
    ValueLabel.TextColor3 = SLIDER_COLOR
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 10
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBG = Instance.new("Frame", SliderFrame)
    SliderBG.Position = UDim2.new(0, 0, 0, 20)
    SliderBG.Size = UDim2.new(1, 0, 0, 7)
    SliderBG.BackgroundColor3 = SLIDER_BG_COLOR
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(0, 4)
    local bgStroke = Instance.new("UIStroke", SliderBG)
    bgStroke.Color = Color3.fromRGB(80, 55, 10)
    bgStroke.Thickness = 1

    local SliderFill = Instance.new("Frame", SliderBG)
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = SLIDER_COLOR
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

    -- Slider-Knopf: Weihnachtskugel 🔴
    local SliderKnob = Instance.new("TextLabel", SliderBG)
    SliderKnob.Size = UDim2.new(0, 16, 0, 16)
    SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
    SliderKnob.BackgroundTransparency = 1
    SliderKnob.Text = "🔴"
    SliderKnob.TextSize = 13
    SliderKnob.Font = Enum.Font.GothamBold
    SliderKnob.ZIndex = SliderBG.ZIndex + 2

    local function updateSlider(value)
        local percent = (value - setting.min) / (setting.max - setting.min)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
        ValueLabel.Text = tostring(math.floor(value))
        _G.ZTH_Settings[setting.var] = math.floor(value)
        saveData({settings = _G.ZTH_Settings, activeModules = activeModules,
            tabPositions = tabPositions, minimizedTabs = minimizedTabs, keybinds = keybinds})
    end

    updateSlider(_G.ZTH_Settings[setting.var])

    local dragging = false
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            updateSlider(setting.min + (setting.max - setting.min) * relX)
        end
    end)

    return SliderFrame
end

-- ☃️ Weihnachts-Checkbox (Häkchen = ❄️)
local function createCheckbox(parent, setting)
    local CheckFrame = Instance.new("Frame", parent)
    CheckFrame.Size = UDim2.new(1, -20, 0, 25)
    CheckFrame.BackgroundTransparency = 1

    local CheckButton = Instance.new("TextButton", CheckFrame)
    CheckButton.Size = UDim2.new(0, 18, 0, 18)
    CheckButton.Position = UDim2.new(0, 0, 0.5, -9)
    CheckButton.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
    CheckButton.Text = ""
    Instance.new("UICorner", CheckButton).CornerRadius = UDim.new(0, 4)
    local cbStroke = Instance.new("UIStroke", CheckButton)
    cbStroke.Color = Color3.fromRGB(130, 20, 20)

    local Checkmark = Instance.new("TextLabel", CheckButton)
    Checkmark.Size = UDim2.new(1, 0, 1, 0)
    Checkmark.BackgroundTransparency = 1
    Checkmark.Text = "❄️"
    Checkmark.Font = Enum.Font.GothamBold
    Checkmark.TextSize = 12
    Checkmark.Visible = _G.ZTH_Settings[setting.var]

    local Title = Instance.new("TextLabel", CheckFrame)
    Title.Position = UDim2.new(0, 25, 0, 0)
    Title.Size = UDim2.new(1, -25, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = setting.title
    Title.TextColor3 = Color3.fromRGB(210, 170, 100)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 10
    Title.TextXAlignment = Enum.TextXAlignment.Left

    CheckButton.MouseButton1Click:Connect(function()
        _G.ZTH_Settings[setting.var] = not _G.ZTH_Settings[setting.var]
        Checkmark.Visible = _G.ZTH_Settings[setting.var]
        TweenService:Create(CheckButton, TweenInfo.new(0.2), {
            BackgroundColor3 = _G.ZTH_Settings[setting.var] and Color3.fromRGB(10, 40, 15) or Color3.fromRGB(20, 10, 10)
        }):Play()
        saveData({settings = _G.ZTH_Settings, activeModules = activeModules,
            tabPositions = tabPositions, minimizedTabs = minimizedTabs, keybinds = keybinds})
    end)

    return CheckFrame
end

local keybindConnections = {}

-- 🔔 Weihnachts-Keybind
local function createKeybindInput(parent, moduleKey)
    local KeyFrame = Instance.new("Frame", parent)
    KeyFrame.Size = UDim2.new(1, -20, 0, 30)
    KeyFrame.BackgroundTransparency = 1
    KeyFrame.Name = "KeybindFrame"

    local Title = Instance.new("TextLabel", KeyFrame)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🔔 Keybind"
    Title.TextColor3 = Color3.fromRGB(210, 170, 100)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 11
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local KeyBox = Instance.new("TextButton", KeyFrame)
    KeyBox.Size = UDim2.new(0.5, 0, 0, 24)
    KeyBox.Position = UDim2.new(0.5, 0, 0, 3)
    KeyBox.BackgroundColor3 = Color3.fromRGB(8, 20, 40)
    KeyBox.Text = keybinds[moduleKey] and keybinds[moduleKey].Name or "[None]"
    KeyBox.TextColor3 = KEYBIND_COLOR
    KeyBox.Font = Enum.Font.GothamSemibold
    KeyBox.TextSize = 11
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 4)
    local kStroke = Instance.new("UIStroke", KeyBox)
    kStroke.Color = Color3.fromRGB(40, 90, 160)

    local waitingForKey = false

    KeyBox.MouseButton1Click:Connect(function()
        if keybindConnections[moduleKey] then
            keybindConnections[moduleKey]:Disconnect()
            keybindConnections[moduleKey] = nil
        end
        waitingForKey = true
        KeyBox.Text = "🎅 Press..."
        KeyBox.TextColor3 = Color3.fromRGB(255, 80, 80)

        keybindConnections[moduleKey] = UserInputService.InputBegan:Connect(function(input)
            if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                waitingForKey = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    keybinds[moduleKey] = nil
                    KeyBox.Text = "[None]"
                    KeyBox.TextColor3 = KEYBIND_COLOR
                elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                    keybinds[moduleKey] = input.KeyCode
                    KeyBox.Text = input.KeyCode.Name
                    KeyBox.TextColor3 = KEYBIND_COLOR
                end
                saveData({settings = _G.ZTH_Settings, activeModules = activeModules,
                    tabPositions = tabPositions, minimizedTabs = minimizedTabs, keybinds = keybinds})
                if keybindConnections[moduleKey] then
                    keybindConnections[moduleKey]:Disconnect()
                    keybindConnections[moduleKey] = nil
                end
            end
        end)
    end)

    return KeyFrame
end

local function getSettingsForButton(tabName, buttonName)
    for _, settingGroup in ipairs(settings) do
        if settingGroup[1] == tabName and settingGroup[2] == buttonName then
            return settingGroup[3]
        end
    end
    return nil
end

-- ======================================================
-- 🎁 TAB + BUTTON UI ERSTELLUNG
-- ======================================================
local tabsData = {}
for _, v in ipairs(mods) do
    if not tabsData[v[1]] then tabsData[v[1]] = {} end
    table.insert(tabsData[v[1]], {name = v[2], url = v[3], autoRun = v[4], Keybind = v.Keybind or false})
end

local startX = 60
for tabName, buttons in pairs(tabsData) do
    local xc = getNextXmasColor()
    local emoji = getNextXmasEmoji()

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = xc.bg
    MainFrame.BackgroundTransparency = 0.05

    if tabPositions[tabName] then
        local pos = tabPositions[tabName]
        MainFrame.Position = UDim2.new(pos.X_Scale, pos.X_Offset, pos.Y_Scale, pos.Y_Offset)
    else
        MainFrame.Position = UDim2.new(0, startX, 0, 100)
    end

    MainFrame.Size = UDim2.new(0, 165, 0, 0)
    MainFrame.AutomaticSize = Enum.AutomaticSize.Y
    MainFrame.ZIndex = 2
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local mainStroke = Instance.new("UIStroke", MainFrame)
    mainStroke.Color = xc.stroke
    mainStroke.Thickness = 2

    -- Titelleiste mit Weihnachts-Emoji
    local Title = Instance.new("TextButton", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 38)
    Title.BackgroundColor3 = xc.headerBg
    Title.BackgroundTransparency = 0.2
    Title.Text = emoji .. " " .. tabName:upper()
    Title.TextColor3 = xc.title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

    -- ⭐ Stern oben rechts
    addStarDecoration(Title)
    -- 💡 Lichterkette unten an der Titelleiste
    addLightsDecoration(Title, xc)

    -- Trennlinie
    local divider = Instance.new("Frame", MainFrame)
    divider.Position = UDim2.new(0, 8, 0, 40)
    divider.Size = UDim2.new(1, -16, 0, 2)
    divider.BackgroundColor3 = xc.stroke
    divider.BackgroundTransparency = 0.3
    divider.BorderSizePixel = 0
    Instance.new("UICorner", divider).CornerRadius = UDim.new(1, 0)

    local Container = Instance.new("Frame", MainFrame)
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 0, 0, 44)
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout", Container)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.Padding = UDim.new(0, 5)
    local cp = Instance.new("UIPadding", Container)
    cp.PaddingBottom = UDim.new(0, 16)
    cp.PaddingTop = UDim.new(0, 4)

    -- ❄️ Schnee am unteren Rand
    addSnowDrift(MainFrame, xc)

    for _, btnInfo in ipairs(buttons) do
        local moduleKey = tabName .. "_" .. btnInfo.name
        local active = activeModules[moduleKey] or false
        local settingsExpanded = false

        local ButtonWrapper = Instance.new("Frame", Container)
        ButtonWrapper.Size = UDim2.new(0, 145, 0, 30)
        ButtonWrapper.AutomaticSize = Enum.AutomaticSize.Y
        ButtonWrapper.BackgroundTransparency = 1

        local WrapperList = Instance.new("UIListLayout", ButtonWrapper)
        WrapperList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        WrapperList.Padding = UDim.new(0, 3)

        local Btn = Instance.new("TextButton", ButtonWrapper)
        Btn.Size = UDim2.new(0, 145, 0, 28)
        Btn.BackgroundColor3 = active and BTN_ACTIVE_BG or BTN_INACTIVE_BG
        Btn.BackgroundTransparency = 0.1
        Btn.Text = btnInfo.name
        Btn.TextColor3 = active and BTN_ACTIVE_TEXT or BTN_INACTIVE_TEXT
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        local BtnStroke = Instance.new("UIStroke", Btn)
        BtnStroke.Color = active and BTN_ACTIVE_STROKE or BTN_INACTIVE_STROKE
        BtnStroke.Thickness = 1.5
        BtnStroke.Enabled = true

        -- Weihnachtskugel-Dot links im Button
        local ornDot = Instance.new("Frame", Btn)
        ornDot.Size = UDim2.new(0, 9, 0, 9)
        ornDot.Position = UDim2.new(0, 7, 0.5, -4.5)
        ornDot.BackgroundColor3 = getOrnamentColor()
        ornDot.ZIndex = Btn.ZIndex + 1
        Instance.new("UICorner", ornDot).CornerRadius = UDim.new(1, 0)  -- Kreis = Kugel!
        -- Kleiner Glanzpunkt
        local ornShine = Instance.new("Frame", ornDot)
        ornShine.Size = UDim2.new(0, 3, 0, 3)
        ornShine.Position = UDim2.new(0, 1, 0, 1)
        ornShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ornShine.BackgroundTransparency = 0.3
        ornShine.ZIndex = ornDot.ZIndex + 1
        Instance.new("UICorner", ornShine).CornerRadius = UDim.new(1, 0)

        Btn:SetAttribute("ScriptURL", btnInfo.url)

        -- Settings-Container (dunkel Weihnachts-Stil)
        local SettingsContainer = Instance.new("Frame", ButtonWrapper)
        SettingsContainer.Size = UDim2.new(0, 145, 0, 0)
        SettingsContainer.AutomaticSize = Enum.AutomaticSize.Y
        SettingsContainer.BackgroundColor3 = Color3.fromRGB(18, 8, 8)
        SettingsContainer.BackgroundTransparency = 0.05
        SettingsContainer.Visible = false
        SettingsContainer.ClipsDescendants = true
        Instance.new("UICorner", SettingsContainer).CornerRadius = UDim.new(0, 6)
        local scStroke = Instance.new("UIStroke", SettingsContainer)
        scStroke.Color = Color3.fromRGB(100, 20, 20)
        scStroke.Thickness = 1

        local SettingsList = Instance.new("UIListLayout", SettingsContainer)
        SettingsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        SettingsList.Padding = UDim.new(0, 5)

        local SettingsPadding = Instance.new("UIPadding", SettingsContainer)
        SettingsPadding.PaddingTop    = UDim.new(0, 8)
        SettingsPadding.PaddingBottom = UDim.new(0, 8)
        SettingsPadding.PaddingLeft   = UDim.new(0, 10)
        SettingsPadding.PaddingRight  = UDim.new(0, 10)

        local buttonSettings = getSettingsForButton(tabName, btnInfo.name)
        local hasKeybind = btnInfo.Keybind == true

        if buttonSettings then
            for _, setting in ipairs(buttonSettings) do
                if setting.type == "slider" then
                    createSlider(SettingsContainer, setting)
                elseif setting.type == "checkbox" then
                    createCheckbox(SettingsContainer, setting)
                end
            end
        end

        if hasKeybind then
            local keyInput = createKeybindInput(SettingsContainer, moduleKey)
            keyInput.LayoutOrder = 999
        end

        -- Linksklick: Toggle + Execute
        Btn.MouseButton1Click:Connect(function()
            task.spawn(function() loadstring(game:HttpGet(btnInfo.url))() end)
            active = not active
            activeModules[moduleKey] = active

            TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                BackgroundColor3 = active and BTN_ACTIVE_BG or BTN_INACTIVE_BG,
                TextColor3 = active and BTN_ACTIVE_TEXT or BTN_INACTIVE_TEXT
            }):Play()
            BtnStroke.Color = active and BTN_ACTIVE_STROKE or BTN_INACTIVE_STROKE

            -- Kugel "wippt" bei Aktivierung
            if active then
                TweenService:Create(ornDot, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, 13, 0, 13),
                    Position = UDim2.new(0, 5, 0.5, -6.5)
                }):Play()
                task.delay(0.15, function()
                    TweenService:Create(ornDot, TweenInfo.new(0.15), {
                        Size = UDim2.new(0, 9, 0, 9),
                        Position = UDim2.new(0, 7, 0.5, -4.5)
                    }):Play()
                end)
            end

            saveData({settings = _G.ZTH_Settings, activeModules = activeModules,
                tabPositions = tabPositions, minimizedTabs = minimizedTabs, keybinds = keybinds})
        end)

        -- Rechtsklick: Settings
        if buttonSettings or hasKeybind then
            Btn.MouseButton2Click:Connect(function()
                settingsExpanded = not settingsExpanded
                SettingsContainer.Visible = settingsExpanded
            end)
        end

        -- Auto-Execute
        if active then
            if btnInfo.autoRun then
                task.spawn(function() loadstring(game:HttpGet(btnInfo.url))() end)
            else
                active = false
                activeModules[moduleKey] = false
                BtnStroke.Color = BTN_INACTIVE_STROKE
                Btn.BackgroundColor3 = BTN_INACTIVE_BG
                Btn.TextColor3 = BTN_INACTIVE_TEXT
            end
        end
    end

    makeDraggable(Title, MainFrame, tabName)

    local isMinimized = minimizedTabs[tabName] or false
    Container.Visible = not isMinimized
    MainFrame.AutomaticSize = isMinimized and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
    if isMinimized then MainFrame.Size = UDim2.new(0, 165, 0, 38) end

    Title.MouseButton2Click:Connect(function()
        isMinimized = not isMinimized
        minimizedTabs[tabName] = isMinimized
        Container.Visible = not isMinimized
        MainFrame.AutomaticSize = isMinimized and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        if isMinimized then MainFrame.Size = UDim2.new(0, 165, 0, 38) end
        saveData({settings = _G.ZTH_Settings, activeModules = activeModules,
            tabPositions = tabPositions, minimizedTabs = minimizedTabs, keybinds = keybinds})
    end)

    startX = startX + 180
end

-- ======================================================
-- KEYBIND GLOBAL HANDLER
-- ======================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for moduleKey, boundKey in pairs(keybinds) do
            if input.KeyCode == boundKey then
                local tabName, modName = moduleKey:match("([^_]+)_(.+)")
                if not tabName or not modName then continue end
                for _, frame in ipairs(ScreenGui:GetChildren()) do
                    if frame:IsA("Frame") and frame:FindFirstChild("Container") then
                        for _, btnWrap in ipairs(frame.Container:GetChildren()) do
                            if btnWrap:IsA("Frame") and btnWrap:FindFirstChildWhichIsA("TextButton") then
                                local btn = btnWrap:FindFirstChildWhichIsA("TextButton")
                                if btn and btn.Text == modName then
                                    task.spawn(function()
                                        loadstring(game:HttpGet(btn:GetAttribute("ScriptURL") or ""))()
                                    end)
                                    local active = not activeModules[moduleKey]
                                    activeModules[moduleKey] = active
                                    TweenService:Create(btn, TweenInfo.new(0.2), {
                                        BackgroundColor3 = active and BTN_ACTIVE_BG or BTN_INACTIVE_BG,
                                        TextColor3 = active and BTN_ACTIVE_TEXT or BTN_INACTIVE_TEXT
                                    }):Play()
                                    local btnStroke = btn:FindFirstChildOfClass("UIStroke")
                                    if btnStroke then
                                        btnStroke.Color = active and BTN_ACTIVE_STROKE or BTN_INACTIVE_STROKE
                                    end
                                    saveData({settings = _G.ZTH_Settings, activeModules = activeModules,
                                        tabPositions = tabPositions, minimizedTabs = minimizedTabs, keybinds = keybinds})
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- TOGGLE HUB (RightShift)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
        toggleCursor(ScreenGui.Enabled)
    end
end)

-- ======================================================
-- 🎁 GAME TAB - WEIHNACHTS-EDITION
-- ======================================================

local old2 = CoreGui:FindFirstChild("CustomGUI_V3") or LP.PlayerGui:FindFirstChild("CustomGUI_V3")
if old2 then old2:Destroy() end

local HttpService2 = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local SAVE_FILE2 = "ZentroHubGame_SaveData.json"

local function saveData2(data)
    pcall(function() writefile(SAVE_FILE2, HttpService2:JSONEncode(data)) end)
end

local function loadData2()
    if not isfile(SAVE_FILE2) then return nil end
    local ok, result = pcall(function() return HttpService2:JSONDecode(readfile(SAVE_FILE2)) end)
    return ok and result or nil
end

local savedData2 = loadData2() or {}
local activeModules2 = savedData2.activeModules or {}
local tabPositions2  = savedData2.tabPositions  or {}
local minimizedTabs2 = savedData2.minimizedTabs or {}

local PLACE_ID = tostring(game.PlaceId)
local BASE_URL = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Games/" .. PLACE_ID .. "/"

local tabName2 = "🎄 GAME SCRIPTS"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then
        tabName2 = "🎁 " .. info.Name:upper():gsub("[^%w%s]", "")
    end
end)

local scripts = {}
local ok2, content2 = pcall(game.HttpGet, game, BASE_URL .. "index.lua", true)
if ok2 and content2 and #content2 > 20 then
    local fn = loadstring(content2)
    if fn then
        local tbl = fn()
        if type(tbl) == "table" then
            for _, file in ipairs(tbl) do
                if type(file) == "string" and file:match("%.lua$") then
                    local name = file:gsub("%.lua$", "")
                    table.insert(scripts, {name = name, url = BASE_URL .. file, autoRun = true})
                end
            end
        end
    end
end

if #scripts == 0 then tabName2 = "⛄ NO SCRIPTS FOUND" end

local tabsData2 = {[tabName2] = scripts}

local ScreenGui2 = Instance.new("ScreenGui")
ScreenGui2.Name = "CustomGUI_V3"
ScreenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui2.Parent = CoreGui end)
if not ScreenGui2.Parent then ScreenGui2.Parent = LP:WaitForChild("PlayerGui") end

local Vignette2 = Instance.new("ImageLabel", ScreenGui2)
Vignette2.BackgroundTransparency = 1
Vignette2.Size = UDim2.new(1, 0, 1, 0)
Vignette2.Image = "rbxassetid://257684567"
Vignette2.ImageColor3 = Color3.fromRGB(5, 8, 25)
Vignette2.ImageTransparency = 1
Vignette2.ZIndex = 0

spawnSnowEffect(ScreenGui2)

local wasCursor2 = false
local function toggleCursor2(opening)
    if opening then
        wasCursor2 = UserInputService.MouseIconEnabled
        UserInputService.MouseIconEnabled = true
        local MF = Instance.new("TextButton", ScreenGui2)
        MF.Name = "ModalFix"; MF.Modal = true; MF.Visible = false
        TweenService:Create(Vignette2, TweenInfo.new(0.3), {ImageTransparency = 0.65}):Play()
    else
        if not wasCursor2 then UserInputService.MouseIconEnabled = false end
        if ScreenGui2:FindFirstChild("ModalFix") then ScreenGui2.ModalFix:Destroy() end
        TweenService:Create(Vignette2, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    end
end
toggleCursor2(true)

local function makeDraggable2(topbar, object, key)
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = object.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tabPositions2[key] = {
                X_Scale = object.Position.X.Scale, X_Offset = object.Position.X.Offset,
                Y_Scale = object.Position.Y.Scale, Y_Offset = object.Position.Y.Offset
            }
            saveData2({activeModules = activeModules2, tabPositions = tabPositions2, minimizedTabs = minimizedTabs2})
        end
    end)
end

local startX2 = 60
for tName, btns in pairs(tabsData2) do
    -- Game Tab: Tannengrün
    local gc = xmasTabColors[2]

    local MF2 = Instance.new("Frame", ScreenGui2)
    MF2.BackgroundColor3 = gc.bg
    MF2.BackgroundTransparency = 0.05

    if tabPositions2[tName] then
        local pos = tabPositions2[tName]
        MF2.Position = UDim2.new(pos.X_Scale, pos.X_Offset, pos.Y_Scale, pos.Y_Offset)
    else
        MF2.Position = UDim2.new(0, startX2, 0, 100)
    end

    MF2.Size = UDim2.new(0, 165, 0, 0)
    MF2.AutomaticSize = Enum.AutomaticSize.Y
    MF2.ZIndex = 2
    Instance.new("UICorner", MF2).CornerRadius = UDim.new(0, 10)
    local ms2 = Instance.new("UIStroke", MF2)
    ms2.Color = gc.stroke
    ms2.Thickness = 2

    local T2 = Instance.new("TextButton", MF2)
    T2.Size = UDim2.new(1, 0, 0, 38)
    T2.BackgroundColor3 = gc.headerBg
    T2.BackgroundTransparency = 0.2
    T2.Text = tName
    T2.TextColor3 = gc.title
    T2.Font = Enum.Font.GothamBold
    T2.TextSize = 11
    Instance.new("UICorner", T2).CornerRadius = UDim.new(0, 10)

    addStarDecoration(T2)
    addLightsDecoration(T2, gc)

    local dv2 = Instance.new("Frame", MF2)
    dv2.Position = UDim2.new(0, 8, 0, 40)
    dv2.Size = UDim2.new(1, -16, 0, 2)
    dv2.BackgroundColor3 = gc.stroke
    dv2.BackgroundTransparency = 0.3
    dv2.BorderSizePixel = 0
    Instance.new("UICorner", dv2).CornerRadius = UDim.new(1, 0)

    local C2 = Instance.new("Frame", MF2)
    C2.Name = "Container"
    C2.Position = UDim2.new(0, 0, 0, 44)
    C2.Size = UDim2.new(1, 0, 0, 0)
    C2.AutomaticSize = Enum.AutomaticSize.Y
    C2.BackgroundTransparency = 1

    local UL2 = Instance.new("UIListLayout", C2)
    UL2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UL2.Padding = UDim.new(0, 5)
    local cp2 = Instance.new("UIPadding", C2)
    cp2.PaddingBottom = UDim.new(0, 16)
    cp2.PaddingTop = UDim.new(0, 4)

    addSnowDrift(MF2, gc)

    for _, btnInfo in ipairs(btns) do
        local mk2 = tName .. "_" .. btnInfo.name
        local active2 = activeModules2[mk2] or false

        local BW2 = Instance.new("Frame", C2)
        BW2.Size = UDim2.new(0, 145, 0, 28)
        BW2.AutomaticSize = Enum.AutomaticSize.Y
        BW2.BackgroundTransparency = 1

        local WL2 = Instance.new("UIListLayout", BW2)
        WL2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        WL2.Padding = UDim.new(0, 3)

        local Btn2 = Instance.new("TextButton", BW2)
        Btn2.Size = UDim2.new(0, 145, 0, 28)
        Btn2.BackgroundColor3 = active2 and BTN_ACTIVE_BG or BTN_INACTIVE_BG
        Btn2.BackgroundTransparency = 0.1
        Btn2.Text = btnInfo.name
        Btn2.TextColor3 = active2 and BTN_ACTIVE_TEXT or BTN_INACTIVE_TEXT
        Btn2.Font = Enum.Font.GothamMedium
        Btn2.TextSize = 11
        Instance.new("UICorner", Btn2).CornerRadius = UDim.new(0, 6)

        local BS2 = Instance.new("UIStroke", Btn2)
        BS2.Color = active2 and BTN_ACTIVE_STROKE or BTN_INACTIVE_STROKE
        BS2.Thickness = 1.5

        local od2 = Instance.new("Frame", Btn2)
        od2.Size = UDim2.new(0, 9, 0, 9)
        od2.Position = UDim2.new(0, 7, 0.5, -4.5)
        od2.BackgroundColor3 = getOrnamentColor()
        od2.ZIndex = Btn2.ZIndex + 1
        Instance.new("UICorner", od2).CornerRadius = UDim.new(1, 0)

        Btn2.MouseButton1Click:Connect(function()
            task.spawn(function() loadstring(game:HttpGet(btnInfo.url, true))() end)
            active2 = not active2
            activeModules2[mk2] = active2
            BS2.Color = active2 and BTN_ACTIVE_STROKE or BTN_INACTIVE_STROKE
            TweenService:Create(Btn2, TweenInfo.new(0.2), {
                BackgroundColor3 = active2 and BTN_ACTIVE_BG or BTN_INACTIVE_BG,
                TextColor3 = active2 and BTN_ACTIVE_TEXT or BTN_INACTIVE_TEXT
            }):Play()
            saveData2({activeModules = activeModules2, tabPositions = tabPositions2, minimizedTabs = minimizedTabs2})
        end)

        if active2 and btnInfo.autoRun then
            task.spawn(function() loadstring(game:HttpGet(btnInfo.url, true))() end)
        end
    end

    makeDraggable2(T2, MF2, tName)

    local isMn2 = minimizedTabs2[tName] or false
    C2.Visible = not isMn2
    MF2.AutomaticSize = isMn2 and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
    if isMn2 then MF2.Size = UDim2.new(0, 165, 0, 38) end

    T2.MouseButton2Click:Connect(function()
        isMn2 = not isMn2
        minimizedTabs2[tName] = isMn2
        C2.Visible = not isMn2
        MF2.AutomaticSize = isMn2 and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        if isMn2 then MF2.Size = UDim2.new(0, 165, 0, 38) end
        saveData2({activeModules = activeModules2, tabPositions = tabPositions2, minimizedTabs = minimizedTabs2})
    end)

    startX2 = startX2 + 180
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui2.Enabled = not ScreenGui2.Enabled
        toggleCursor2(ScreenGui2.Enabled)
    end
end)
--// ============================
--// SETTINGS (HIER DEINE EMOJIS!)
--// ============================

local Emojis = {"🎄","❄️","☃️","🎁","🕯️","💫","💝"} -- Emojis ändern
local EmojiCount = 12
local Spread = 160
local Lifetime = 1.2
local Size = 32

local ToggleKey = Enum.KeyCode.RightShift -- AN/AUS Taste

--// ============================

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Enabled = true -- Startet AN

-- GUI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EmojiExplosionGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Explosion Funktion
local function createExplosion(position)
	if not Enabled then return end

	for i = 1, EmojiCount do
		local emoji = Instance.new("TextLabel")
		emoji.BackgroundTransparency = 1
		emoji.TextScaled = true
		emoji.Font = Enum.Font.GothamBold
		emoji.Text = Emojis[math.random(1,#Emojis)]
		emoji.Size = UDim2.new(0, Size, 0, Size)
		emoji.AnchorPoint = Vector2.new(0.5, 0.5)
		emoji.Position = UDim2.new(0, position.X, 0, position.Y)
		emoji.Parent = ScreenGui

		local angle = math.rad(math.random(0,360))
		local distance = math.random(Spread * 0.5, Spread)

		local targetX = position.X + math.cos(angle) * distance
		local targetY = position.Y + math.sin(angle) * distance

		local tween = TweenService:Create(
			emoji,
			TweenInfo.new(Lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0, targetX, 0, targetY),
				Rotation = math.random(-180,180),
				TextTransparency = 1,
				Size = UDim2.new(0, Size * 0.5, 0, Size * 0.5)
			}
		)

		tween:Play()
		tween.Completed:Connect(function()
			emoji:Destroy()
		end)
	end
end

-- Klick erkennen (funktioniert auch auf Buttons!)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- RightShift Toggle
	if input.KeyCode == ToggleKey then
		Enabled = not Enabled
		print("Emoji Explosion:", Enabled and "AN" or "AUS")
		return
	end

	-- Maus Klick oder Touch → Explosion
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		
		local pos = UserInputService:GetMouseLocation()
		createExplosion(pos)
	end
end)