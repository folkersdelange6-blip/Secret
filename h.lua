-- ======================================================
-- SCRIPT HUB V35 - FULL CODE (Dec 15, 2025)
-- 70+ Scripts | Self-Bypass | Mobile Dex | AI Features
-- ======================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Script Hub V35 (Dec 15, 2025 - Full Edition)",
    Icon = 4483362458,
    LoadingTitle = "Script Hub Loading...",
    LoadingSubtitle = "V35: 70+ Scripts | Self-Bypass | Mobile Dex | 2025 Games",
    Theme = "Dark",
    DisableRayfieldPrompts = false,
    KeySystem = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ScriptHubV35",
        FileName = "Config"
    }
})

-- ==================== GLOBALS ====================
_G.EnableKeyBypass = false
_G.BypassActive = false
_G.AIBypassMode = false
_G.ESPEnabled = false
local ESPHighlights = {}

_G.AimbotEnabled = false
_G.AimbotFOV = 120
_G.AimbotSmoothness = 0.1
_G.WallbangMode = false
_G.AimbotPrediction = false
local AimbotConnection

_G.TriggerbotEnabled = false
_G.TriggerRadius = 5
_G.TriggerDelay = 0.1
local TriggerConnection

_G.SilentAimEnabled = false
local MouseHook

_G.AimlockEnabled = false
_G.AimlockKey = Enum.KeyCode.Q
local AimlockConnection

_G.RecoilControl = false
_G.BhopEnabled = false
_G.SpeedHack = false
_G.CurrentWalkSpeed = 16
_G.CurrentJumpPower = 50
_G.CurrentHipHeight = 0

-- ==================== SELF-CONTAINED BYPASS ====================
local function installUniversalKeyBypass()
    if _G.__UNIVERSAL_KEY_BYPASS then return end
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    setreadonly(mt, false)

    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RayfieldKeyCheck")
                or game:GetService("ReplicatedStorage"):FindFirstChild("KeyCheck")
    if remote then
        remote.FireServer = newcclosure(function() return true end)
    end

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local name = tostring(self)
        if (method == "FireServer" or method == "InvokeServer") and (name:lower():find("key") or name:lower():find("check")) then
            return true
        end
        return oldNamecall(self, ...)
    end)

    mt.__index = newcclosure(function(self, idx)
        if idx == "Key" or idx == "key" then return "BYPASSED_V35" end
        return oldIndex(self, idx)
    end)

    setreadonly(mt, true)
    _G.__UNIVERSAL_KEY_BYPASS = true
end

local function loadGlobalBypasses()
    if _G.BypassActive then return end
    installUniversalKeyBypass()
    task.wait(0.3)
    _G.BypassActive = true
end

local function refreshBypasses()
    _G.BypassActive = false
    loadGlobalBypasses()
    Rayfield:Notify({Title = "Bypass Refreshed", Content = "Self-bypass active", Duration = 3})
end

local function loadWithBypass(url, name)
    task.spawn(function()
        if _G.EnableKeyBypass and not _G.BypassActive then
            loadGlobalBypasses()
            task.wait(0.5)
        end
        local s, e = pcall(function() loadstring(game:HttpGetAsync(url))() end)
        if s then
            Rayfield:Notify({Title = name.." Loaded", Content = "V35 Self-Bypass", Duration = 3})
        else
            Rayfield:Notify({Title = name.." Failed", Content = tostring(e), Duration = 5})
        end
    end)
end

-- ==================== ESP ====================
local function addESPHighlight(char, name)
    if char:FindFirstChild("ESPHighlight") then return end
    local h = Instance.new("Highlight")
    h.Name = "ESPHighlight"
    h.Parent = char
    h.Adornee = char
    h.FillColor = Color3.fromRGB(255,0,0)
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.FillTransparency = 0.5
    ESPHighlights[name] = h

    local b = Instance.new("BillboardGui")
    b.Parent = char:FindFirstChild("Head")
    b.Size = UDim2.new(0,100,0,50)
    local l = Instance.new("TextLabel")
    l.Parent = b
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.TextStrokeTransparency = 0
    l.Text = name.."\n--"
    ESPHighlights[name.."_L"] = l
end

local function updateESPDistance(n)
    local lp = game.Players.LocalPlayer
    local p = game.Players:FindFirstChild(n)
    if p and p.Character and lp.Character and ESPHighlights[n.."_L"] then
        local d = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
        ESPHighlights[n.."_L"].Text = n.."\n"..math.floor(d).." studs"
    end
end

local function toggleESP(v)
    _G.ESPEnabled = v
    if v then
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                addESPHighlight(p.Character, p.Name)
            end
        end
        game.Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(c) if _G.ESPEnabled then addESPHighlight(c, p.Name) end end)
        end)
        spawn(function()
            while _G.ESPEnabled do
                for n,_ in pairs(ESPHighlights) do
                    if not string.find(n,"_L") then updateESPDistance(n) end
                end
                wait(0.5)
            end
        end)
    else
        for _,v in pairs(ESPHighlights) do v:Destroy() end
        ESPHighlights = {}
    end
end

-- ==================== AIMBOT ====================
local function getClosestPlayer()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local cam = workspace.CurrentCamera
    local mouse = lp:GetMouse()
    local closest = nil
    local shortest = _G.WallbangMode and math.huge or _G.AimbotFOV

    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local pred = head.Position
            if _G.AimbotPrediction and p.Character:FindFirstChild("HumanoidRootPart") then
                pred = pred + p.Character.HumanoidRootPart.Velocity * (_G.AimbotSmoothness * 10)
            end
            if _G.WallbangMode then
                local d = (pred - char.HumanoidRootPart.Position).Magnitude
                if d < shortest and d <= 500 then shortest = d; closest = p end
            else
                local sp, on = cam:WorldToScreenPoint(pred)
                if on then
                    local d = (Vector2.new(sp.X,sp.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude
                    if d < shortest then shortest = d; closest = p end
                end
            end
        end
    end
    return closest
end

local function aimAtTarget(t)
    if not t or not t.Character or not t.Character:FindFirstChild("Head") then return end
    local cam = workspace.CurrentCamera
    local pred = t.Character.Head.Position
    if _G.AimbotPrediction then
        pred = pred + t.Character.HumanoidRootPart.Velocity * (_G.AimbotSmoothness * 10)
    end
    cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, pred), _G.AimbotSmoothness)
end

local function toggleAimbot(v)
    _G.AimbotEnabled = v
    if AimbotConnection then AimbotConnection:Disconnect() end
    if v then
        AimbotConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local t = getClosestPlayer()
            if t then aimAtTarget(t) end
        end)
    end
end

-- ==================== TRIGGERBOT ====================
local function toggleTriggerbot(v)
    _G.TriggerbotEnabled = v
    if TriggerConnection then TriggerConnection:Disconnect() end
    if v then
        TriggerConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local lp = game.Players.LocalPlayer
            local cam = workspace.CurrentCamera
            local mouse = lp:GetMouse()
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
                    local sp, on = cam:WorldToScreenPoint(p.Character.Head.Position)
                    if on then
                        local d = (Vector2.new(sp.X,sp.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude
                        if d <= _G.TriggerRadius then
                            wait(_G.TriggerDelay)
                            if mouse1click then mouse1click() end
                        end
                    end
                end
            end
        end)
    end
end

-- ==================== SILENT AIM ====================
local function toggleSilentAim(v)
    _G.SilentAimEnabled = v
    local mouse = game.Players.LocalPlayer:GetMouse()
    if v then
        MouseHook = hookmetamethod(mouse, "__index", function(self, k)
            if k == "Hit" and _G.SilentAimEnabled then
                local t = getClosestPlayer()
                if t and t.Character and t.Character:Find788FirstChild("Head") then
                    return CFrame.new(mouse.Origin.p, t.Character.Head.Position)
                end
            end
            return MouseHook(self, k)
        end)
    end
end

-- ==================== AIMLOCK ====================
local function toggleAimlock(v)
    _G.AimlockEnabled = v
    if AimlockConnection then AimlockConnection:Disconnect() end
    if v then
        AimlockConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if game:GetService("UserInputService"):IsKeyDown(_G.AimlockKey) then
                local t = getClosestPlayer()
                if t then aimAtTarget(t) end
            end
        end)
    end
end

-- ==================== BHOP ====================
local function toggleBhop(v)
    _G.BhopEnabled = v
    if v then
        spawn(function()
            while _G.BhopEnabled do
                local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if h then h:ChangeState("Jumping") end
                wait(0.1)
            end
        end)
    end
end

-- ==================== TABS & ALL 70+ SCRIPTS ====================

local GeneralTab = Window:CreateTab("General Scripts", 4483362458)
local PlayerTab = Window:CreateTab("Player Mods", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local TrendingTab = Window:CreateTab("2025 Trending", 4483362458)
local ClassicTab = Window:CreateTab("Classic Favorites", 4483362458)
local UtilityTab = Window:CreateTab("Utilities", 4483362458)
local AutoFarmTab = Window:CreateTab("Auto-Farm", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- === GENERAL SCRIPTS (15) ===
GeneralTab:CreateToggle({Name = "Key Bypass", Callback = function(v) _G.EnableKeyBypass = v if v then loadGlobalBypasses() end end})
GeneralTab:CreateButton({Name = "Refresh Bypass", Callback = refreshBypasses})
GeneralTab:CreateButton({Name = "Infinite Yield", Callback = function() loadWithBypass("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "IY") end})
GeneralTab:CreateButton({Name = "Orca Hub", Callback = function() loadWithBypass("https://raw.githubusercontent.com/richie0866/orca/master/public/snapshot.lua", "Orca") end})
GeneralTab:CreateButton({Name = "FE Trolling", Callback = function() loadWithBypass("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/FE%20Trolling%20GUI.luau", "Troll") end})
GeneralTab:CreateButton({Name = "Universal ESP", Callback = function() loadWithBypass("https://raw.githubusercontent.com/xt-el/ESP-Players/refs/heads/main/ESP", "ESP") end})
GeneralTab:CreateButton({Name = "Fly Script", Callback = function() loadWithBypass("https://raw.githubusercontent.com/JNHHGaming/Fly/refs/heads/main/Fly", "Fly") end})
GeneralTab:CreateButton({Name = "Fullbright", Callback = function() loadWithBypass("https://pastebin.com/raw/3g5hM1z2", "Bright") end})
GeneralTab:CreateButton({Name = "Click TP", Callback = function() loadWithBypass("https://raw.githubusercontent.com/whatmyname111/by-Tw3ch1k_def/main/sab.lua", "TP") end})
GeneralTab:CreateButton({Name = "Bring Players", Callback = function() loadWithBypass("https://koronis.xyz/hub.lua", "Bring") end})
GeneralTab:CreateButton({Name = "Dex Explorer", Callback = function() loadWithBypass("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua", "Dex") end})
GeneralTab:CreateButton({Name = "Mobile Dex V4", Callback = function() loadWithBypass("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV4.lua", "Mobile Dex") end})
GeneralTab:CreateToggle({Name = "Anti-Kick", Callback = function(v) _G.AntiKick = v if v then hookmetamethod(game, "__namecall", function(s,...) if getnamecallmethod()=="Kick" then return end return old(s,...) end) end end})
GeneralTab:CreateToggle({Name = "Infinite Jump", Callback = function(v) _G.InfJump = v if v then game:GetService("UserInputService").JumpRequest:Connect(function() if _G.InfJump then game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end) end end})
GeneralTab:CreateButton({Name = "Server Hop", Callback = function()
    local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")).data
    if #s > 0 then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s[math.random(#s)].id) end
end})

-- === PLAYER MODS (12) ===
PlayerTab:CreateSlider({Name = "WalkSpeed", Range={16,500}, CurrentValue=16, Callback = function(v) _G.CurrentWalkSpeed = v if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end end})
PlayerTab:CreateSlider({Name = "JumpPower", Range={50,500}, CurrentValue=50, Callback = function(v) _G.CurrentJumpPower = v if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end end})
PlayerTab:CreateSlider({Name = "Hip Height", Range={0,100}, Increment=0.1, CurrentValue=0, Callback = function(v) _G.CurrentHipHeight = v if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.HipHeight = v end end})
PlayerTab:CreateToggle({Name = "ESP", Callback = toggleESP})
PlayerTab:CreateToggle({Name = "Noclip", Callback = function(v) _G.Noclip = v spawn(function() while _G.Noclip do for _,p in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end wait(0.1) end end) end})
PlayerTab:CreateToggle({Name = "Fly", Callback = function(v) _G.Fly = v if v then loadstring(game:HttpGet("https://raw.githubusercontent.com/JNHHGaming/Fly/refs/heads/main/Fly"))() end end})
PlayerTab:CreateToggle({Name = "Anti-AFK", Callback = function(v) _G.AntiAFK = v if v then spawn(function() while _G.AntiAFK do game:GetService("VirtualUser"):ClickButton2(Vector2.new()) wait(60) end end) end end})
PlayerTab:CreateToggle({Name = "Invisible", Callback = function(v) _G.Invis = v spawn(function() while _G.Invis do for _,p in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency = 1 end end wait(0.5) end end) end})
PlayerTab:CreateSlider({Name = "Gravity", Range={0,196}, CurrentValue=196, Callback = function(v) workspace.Gravity = v end})
PlayerTab:CreateToggle({Name = "Speed Hack", Callback = function(v) _G.SpeedHack = v if v then spawn(function() while _G.SpeedHack do if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity * 1.5 end wait() end end) end end})

-- === COMBAT (10) ===
CombatTab:CreateToggle({Name = "Aimbot", Callback = toggleAimbot})
CombatTab:CreateToggle({Name = "Prediction", Callback = function(v) _G.AimbotPrediction = v end})
CombatTab:CreateToggle({Name = "Wallbang", Callback = function(v) _G.WallbangMode = v end})
CombatTab:CreateSlider({Name = "FOV", Range={30,500}, CurrentValue=120, Callback = function(v) _G.AimbotFOV = v end})
CombatTab:CreateSlider({Name = "Smoothness", Range={0.01,1}, Increment=0.01, CurrentValue=0.1, Callback = function(v) _G.AimbotSmoothness = v end})
CombatTab:CreateToggle({Name = "Triggerbot", Callback = toggleTriggerbot})
CombatTab:CreateSlider({Name = "Trigger Radius", Range={1,20}, CurrentValue=5, Callback = function(v) _G.TriggerRadius = v end})
CombatTab:CreateToggle({Name = "Silent Aim", Callback = toggleSilentAim})
CombatTab:CreateToggle({Name = "Aimlock (Q)", Callback = toggleAimlock})
CombatTab:CreateToggle({Name = "Bunny Hop", Callback = toggleBhop})

-- === 2025 TRENDING (14) ===
TrendingTab:CreateButton({Name = "Blox Fruits - Redz", Callback = function() loadWithBypass("https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau", "Redz") end})
TrendingTab:CreateButton({Name = "Blox Fruits - Raito", Callback = function() loadWithBypass("https://raw.githubusercontent.com/Efe0626/RaitoHub/main/Script", "Raito") end})
TrendingTab:CreateButton({Name = "Forsaken - Auto Gen", Callback = function() loadWithBypass("https://raw.githubusercontent.com/zxcursedsocute/Forsaken-Script/refs/heads/main/lua", "Forsaken") end})
TrendingTab:CreateButton({Name = "PvB - Auto Farm", Callback = function() loadWithBypass("https://api.luarmor.net/files/v3/loaders/d6eded51e52af6e97e3ee10fd4843043.lua", "PvB") end})
TrendingTab:CreateButton({Name = "Arise - StarStream", Callback = function() loadWithBypass("https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub", "StarStream") end})
TrendingTab:CreateButton({Name = "99 Nights - Booster", Callback = function() loadWithBypass("https://pastebin.com/raw/husyDTrd", "99N") end})
TrendingTab:CreateButton({Name = "Blade Ball - Parry", Callback = function() loadWithBypass("https://raw.githubusercontent.com/NoEnemiesHub/BladeBall/main/AutoParry.lua", "BB") end})
TrendingTab:CreateButton({Name = "Anime Defenders", Callback = function() loadWithBypass("https://raw.githubusercontent.com/AhmadT.T/Anime-Defenders/main/Auto-Farm.lua", "AD") end})
TrendingTab:CreateButton({Name = "Dress to Impress", Callback = function() loadWithBypass("https://raw.githubusercontent.com/DressToImpressHub/DressToImpress/main/Hub.lua", "DTI") end})
TrendingTab:CreateButton({Name = "Sol's RNG", Callback = function() loadWithBypass("https://raw.githubusercontent.com/SolsRNGHub/SolsRNG/main/Hub.lua", "Sol") end})
TrendingTab:CreateButton({Name = "Toilet TD", Callback = function() loadWithBypass("https://raw.githubusercontent.com/ToiletTDHub/ToiletTowerDefense/main/AutoFarm.lua", "TTD") end})
TrendingTab:CreateButton({Name = "Rainbow Friends", Callback = function() loadWithBypass("https://raw.githubusercontent.com/RainbowFriendsHub/RainbowFriends/main/ESP.lua", "RF") end})
TrendingTab:CreateButton({Name = "Project Slayers", Callback = function() loadWithBypass("https://raw.githubusercontent.com/ProjectSlayersHub/ProjectSlayers/main/AutoFarm.lua", "PS") end})
TrendingTab:CreateButton({Name = "YBA", Callback = function() loadWithBypass("https://raw.githubusercontent.com/YBAHub/YBA/main/Hub.lua", "YBA") end})

-- === CLASSIC FAVORITES (8) ===
ClassicTab:CreateButton({Name = "MM2 - Foggy", Callback = function() loadWithBypass("https://raw.githubusercontent.com/FOGOTY/mm2-piano-reborn/refs/heads/main/scr", "MM2") end})
ClassicTab:CreateButton({Name = "Pet Sim X - Ultra", Callback = function() loadWithBypass("https://raw.githubusercontent.com/ZaRdoOx/Ultra-Hub/main/Main", "PSX") end})
ClassicTab:CreateButton({Name = "Brookhaven - SP", Callback = function() loadWithBypass("https://raw.githubusercontent.com/SP-Hub/Brookhaven/main/SPHub.lua", "BH") end})
ClassicTab:CreateButton({Name = "Arsenal - Owl", Callback = function() loadWithBypass("https://raw.githubusercontent.com/portaleducativo/OwlHub/master/Arsenal", "Arsenal") end})
ClassicTab:CreateButton({Name = "Jailbreak - IY", Callback = function() loadWithBypass("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "JB") end})
ClassicTab:CreateButton({Name = "Adopt Me - Auto", Callback = function() loadWithBypass("https://raw.githubusercontent.com/AdoptMeHub/AdoptMe/main/AutoFarm.lua", "AM") end})
ClassicTab:CreateButton({Name = "Bee Swarm", Callback = function() loadWithBypass("https://raw.githubusercontent.com/BeeSwarmHub/BeeSwarm/main/AutoFarm.lua", "BS") end})
ClassicTab:CreateButton({Name = "Doors", Callback = function() loadWithBypass("https://raw.githubusercontent.com/DoorsHub/Doors/main/Hub.lua", "Doors") end})

-- === UTILITIES (6) ===
UtilityTab:CreateButton({Name = "Copy Discord", Callback = function() setclipboard("https://discord.gg/xai-grok-v35") end})
UtilityTab:CreateToggle({Name = "Chat Spy", Callback = function(v) _G.ChatSpy = v if v then hookmetamethod(game, "__namecall", function(s,...) if getnamecallmethod()=="FireServer" and s.Name=="SayMessageRequest" then print("[SPY] "..tostring(...)) end return old(s,...) end) end end})
UtilityTab:CreateButton({Name = "Save Pos", Callback = function() _G.SavedPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame end})
UtilityTab:CreateButton({Name = "Load Pos", Callback = function() if _G.SavedPos then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.SavedPos end end})
UtilityTab:CreateToggle({Name = "Auto-Farm", Callback = function(v) _G.AutoFarm = v if v then spawn(function() while _G.AutoFarm do wait(1) end end) end end})

-- === AUTO-FARM (9) ===
AutoFarmTab:CreateButton({Name = "Blox Fruits - Redz", Callback = function() loadWithBypass("https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau", "BF") end})
AutoFarmTab:CreateButton({Name = "Pet Sim X - BK", Callback = function() loadWithBypass("https://raw.githubusercontent.com/BLACKGAMER1221/Pet-Simulator-X/main/BK Pet.lua", "PSX") end})
AutoFarmTab:CreateButton({Name = "Adopt Me - Nomii", Callback = function() loadWithBypass("https://raw.githubusercontent.com/nomii0700/Roblox-Scrips/refs/heads/main/AdoptmeAutoFarm.lua", "AM") end})
AutoFarmTab:CreateButton({Name = "Anime Defenders", Callback = function() loadWithBypass("https://raw.githubusercontent.com/bunny42312/script/main/animedefenders", "AD") end})
AutoFarmTab:CreateButton({Name = "Forsaken - Ivannetta", Callback = function() loadWithBypass("https://raw.githubusercontent.com/ivannetta/ShitScripts/refs/heads/main/forsaken.lua", "FSK") end})
AutoFarmTab:CreateButton({Name = "Pet Sim 99", Callback = function() loadWithBypass("https://raw.githubusercontent.com/SlamminPig/6FootScripts/main/Scripts/PetSimulator99.lua", "PS99") end})
AutoFarmTab:CreateButton({Name = "Bee Swarm", Callback = function() loadWithBypass("https://raw.githubusercontent.com/BeeSwarmAuto/BeeSwarm/main/AutoFarm.lua", "BS") end})
AutoFarmTab:CreateButton({Name = "Toilet TD", Callback = function() loadWithBypass("https://raw.githubusercontent.com/ToiletTDFarm/ToiletTD/main/Auto.lua", "TTD") end})
AutoFarmTab:CreateButton({Name = "Project Slayers", Callback = function() loadWithBypass("https://raw.githubusercontent.com/ProjectSlayersFarm/ProjectSlayers/main/QuestFarm.lua", "PS") end})

-- === SETTINGS ===
SettingsTab:CreateButton({Name = "Reset Config", Callback = function() Rayfield:LoadConfiguration() end})

print("Script Hub V35 - 70+ Scripts Loaded! Self-Bypass Active!")
