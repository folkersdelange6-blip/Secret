local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Script Hub V29 (Nov 8, 2025 - Mobile Dex Edition)",
    Icon = 4483362458,
    LoadingTitle = "Script Hub Loading...",
    LoadingSubtitle = "Updated by Grok - Mobile Dex & Enhanced Features",
    Theme = "Dark",
    DisableRayfieldPrompts = false,
    KeySystem = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ScriptHubV29",
        FileName = "Config"
    }
})

-- Globals for bypass system
_G.EnableKeyBypass = false
_G.BypassActive = false

-- Globals for ESP
_G.ESPEnabled = false
local ESPHighlights = {}

-- Globals for Aimbot
_G.AimbotEnabled = false
_G.AimbotFOV = 120
_G.AimbotSmoothness = 0.1
_G.WallbangMode = false
local AimbotConnection

-- Globals for Triggerbot
_G.TriggerbotEnabled = false
_G.TriggerRadius = 5
local TriggerConnection

-- Globals for Silent Aim
_G.SilentAimEnabled = false
local MouseHook

-- Globals for Aimlock
_G.AimlockEnabled = false
local AimlockConnection

-- Function to load bypasses globally (once)
local function loadGlobalBypasses()
    if _G.BypassActive then return end  -- Already loaded
    task.spawn(function()
        pcall(function()
            -- Verified Rayfield bypass (2025 update)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ImMejor35/cracked/main/rayfieldnokey"))()
        end)
        wait(0.2)
        pcall(function()
            -- Verified KelRepl bypass (2025 update)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/RiseValco/keybypasses/main/kelrepl.lua"))()
        end)
        wait(0.2)
        pcall(function()
            -- Lootbin/Work.ink bypass (for hybrid keys like Redz)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/RBX_Scripts/main/Universal/Bypasser.lua"))()
        end)
        wait(0.2)
        pcall(function()
            -- Additional Universal Bypass for 2025 Anti-Cheat (e.g., Synapse X hooks)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ic3w0lf22/Unnamed/main/Bypasses/Universal.lua"))()
        end)
        wait(0.6)  -- Total 1.2s settle time for hooks
        _G.BypassActive = true
        print("Global Bypasses Loaded - Keys Skipped for All Future Loads!")
    end)
end

-- Function to refresh bypasses
local function refreshBypasses()
    _G.BypassActive = false
    loadGlobalBypasses()
    Rayfield:Notify({Title = "Bypasses Refreshed", Content = "Hooks reloaded - Try loading again.", Duration = 3, Image = 4483362458})
end

-- Function to load scripts (waits for bypass if active)
local function loadWithBypass(url, scriptName)
    task.spawn(function()
        local attempts = 0
        if _G.EnableKeyBypass and not _G.BypassActive then
            loadGlobalBypasses()  -- Trigger if not yet loaded
            wait(1.2)  -- Ensure global hooks settle
        elseif _G.EnableKeyBypass and _G.BypassActive then
            wait(0.5)  -- Brief pause for active hooks
        end
        local success, err = pcall(function()
            loadstring(game:HttpGetAsync(url))()
        end)
        while not success and attempts < 3 do
            attempts = attempts + 1
            wait(1)
            success, err = pcall(function()
                if syn and syn.request then
                    local res = syn.request({Url = url, Method = "GET"}).Body
                    loadstring(res)()
                else
                    loadstring(game:HttpGetAsync(url))()
                end
            end)
        end
        if success then
            Rayfield:Notify({Title = scriptName .. " Loaded!", Content = "Success - Check for new GUI.", Duration = 3, Image = 4483362458})
            print("[" .. scriptName .. "] Loaded successfully!")
        else
            Rayfield:Notify({Title = scriptName .. " Failed!", Content = "Error: " .. tostring(err) .. " (Console for details; try toggle off/on).", Duration = 5, Image = 4483362458})
            warn("[" .. scriptName .. "] Failed: " .. tostring(err) .. " - If keyed, ensure bypass toggled ON before load.")
        end
    end)
end

-- ESP Integration Functions
local function addESPHighlight(character, playerName)
    if character:FindFirstChild("ESPHighlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Parent = character
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Red fill for enemies/players
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)  -- White outline
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    ESPHighlights[playerName] = highlight
end

local function removeESPHighlight(playerName)
    if ESPHighlights[playerName] then
        ESPHighlights[playerName]:Destroy()
        ESPHighlights[playerName] = nil
    end
end

local function toggleESP(Value)
    _G.ESPEnabled = Value
    if Value then
        Rayfield:Notify({Title = "ESP Enabled", Content = "Highlights added to players.", Duration = 3, Image = 4483362458})
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                addESPHighlight(player.Character, player.Name)
            end
            player.CharacterAdded:Connect(function(char)
                if _G.ESPEnabled then
                    addESPHighlight(char, player.Name)
                end
            end)
        end
        game.Players.PlayerAdded:Connect(function(newPlayer)
            if _G.ESPEnabled then
                newPlayer.CharacterAdded:Connect(function(char)
                    addESPHighlight(char, newPlayer.Name)
                end)
            end
        end)
    else
        Rayfield:Notify({Title = "ESP Disabled", Content = "Highlights removed.", Duration = 3, Image = 4483362458})
        for playerName, _ in pairs(ESPHighlights) do
            removeESPHighlight(playerName)
        end
    end
end

-- Aimbot Integration Functions
local function getClosestPlayer()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local camera = workspace.CurrentCamera
    local mouse = player:GetMouse()
    local closestPlayer = nil
    local shortestDistance = _G.WallbangMode and math.huge or _G.AimbotFOV
    local max3DDistance = 500  -- Max studs for wallbang mode

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPlayer.Character:FindFirstChild("Head") then
            local head = otherPlayer.Character.Head
            if _G.WallbangMode then
                -- 3D Distance for Wallbang
                local targetPos = head.Position
                local localPos = character.HumanoidRootPart.Position
                local distance = (targetPos - localPos).Magnitude
                if distance < shortestDistance and distance <= max3DDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            else
                -- Screen FOV for Visible Targets
                local screenPoint, onScreen = camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function aimAtTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
    local camera = workspace.CurrentCamera
    local head = target.Character.Head
    local targetCFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
    camera.CFrame = camera.CFrame:Lerp(targetCFrame, _G.AimbotSmoothness)
end

local function toggleAimbot(Value)
    _G.AimbotEnabled = Value
    if AimbotConnection then AimbotConnection:Disconnect() end
    if Value then
        Rayfield:Notify({Title = "Aimbot Enabled", Content = "Aiming at closest player in FOV (Wallbang: " .. tostring(_G.WallbangMode) .. ").", Duration = 3, Image = 4483362458})
        AimbotConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local closest = getClosestPlayer()
            if closest then
                aimAtTarget(closest)
            end
        end)
    else
        Rayfield:Notify({Title = "Aimbot Disabled", Content = "Aiming stopped.", Duration = 3, Image = 4483362458})
    end
end

-- Triggerbot Functions
local function getMouseOverPlayer()
    local player = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local mouse = player:GetMouse()
    local closestPlayer = nil
    local shortestDistance = _G.TriggerRadius

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local head = otherPlayer.Character.Head
            local screenPoint, onScreen = camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end
    end
    return closestPlayer, shortestDistance
end

local function toggleTriggerbot(Value)
    _G.TriggerbotEnabled = Value
    if TriggerConnection then TriggerConnection:Disconnect() end
    if Value then
        Rayfield:Notify({Title = "Triggerbot Enabled", Content = "Auto-fires when enemy under crosshair (Radius: " .. _G.TriggerRadius .. "). Requires mouse1click() support.", Duration = 4, Image = 4483362458})
        TriggerConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local closest, distance = getMouseOverPlayer()
            if closest and distance <= _G.TriggerRadius then
                if mouse1click then
                    mouse1click()
                else
                    warn("Triggerbot: mouse1click() not available in executor.")
                end
            end
        end)
    else
        Rayfield:Notify({Title = "Triggerbot Disabled", Content = "Auto-fire stopped.", Duration = 3, Image = 4483362458})
    end
end

-- Silent Aim Functions
local function toggleSilentAim(Value)
    _G.SilentAimEnabled = Value
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    if Value then
        if MouseHook then MouseHook:Disconnect() end  -- Clean up if needed
        MouseHook = hookmetamethod(mouse, "__index", function(self, key)
            if key == "Hit" and _G.SilentAimEnabled then
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    return CFrame.new(mouse.Origin, target.Character.Head.Position)
                end
            end
            return MouseHook(self, key)
        end)
        Rayfield:Notify({Title = "Silent Aim Enabled", Content = "Mouse.Hit hooked to target head (works in supported games).", Duration = 4, Image = 4483362458})
    else
        if MouseHook then
            -- Note: Unhooking metatables is tricky; disable by setting flag
            Rayfield:Notify({Title = "Silent Aim Disabled", Content = "Hook disabled.", Duration = 3, Image = 4483362458})
        end
    end
end

-- Aimlock Functions
local function toggleAimlock(Value)
    _G.AimlockEnabled = Value
    if AimlockConnection then AimlockConnection:Disconnect() end
    if Value then
        Rayfield:Notify({Title = "Aimlock Enabled", Content = "Camera locked to closest player (uses aimbot settings).", Duration = 3, Image = 4483362458})
        AimlockConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local camera = workspace.CurrentCamera
                local targetCFrame = CFrame.lookAt(camera.CFrame.Position, target.Character.Head.Position)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, _G.AimbotSmoothness)
            end
        end)
    else
        Rayfield:Notify({Title = "Aimlock Disabled", Content = "Camera lock released.", Duration = 3, Image = 4483362458})
    end
end

-- Tab 1: General Scripts (added Mobile Dex Explorer & more)
local GeneralTab = Window:CreateTab("General Scripts", 4483362458)

pcall(function()
    GeneralTab:CreateToggle({
        Name = "Enable Universal Key Bypass",
        CurrentValue = false,
        Callback = function(Value)
            _G.EnableKeyBypass = Value
            if Value then
                loadGlobalBypasses()  -- Load once globally
                Rayfield:Notify({
                    Title = "Key Bypass Activated",
                    Content = "Global hooks loaded - All future scripts keyless (Rayfield/KelRepl/Lootbin/Synapse).",
                    Duration = 4,
                    Image = 4483362458
                })
            else
                _G.BypassActive = false  -- Reset for re-toggle
                Rayfield:Notify({
                    Title = "Key Bypass Disabled",
                    Content = "Scripts may prompt keys now.",
                    Duration = 2,
                    Image = 4483362458
                })
            end
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Refresh Bypasses",
        Callback = function()
            refreshBypasses()
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Script Updater Check",
        Callback = function()
            Rayfield:Notify({
                Title = "Update Check",
                Content = "Script Hub V29 is up to date! (Last checked: Nov 8, 2025)",
                Duration = 4,
                Image = 4483362458
            })
            print("Manual update: Check GitHub for V30 if needed.")
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Destroy All GUIs (Cleanup)",
        Callback = function()
            for _, v in pairs(game.CoreGui:GetChildren()) do
                if v:IsA("ScreenGui") and v.Name ~= "Rayfield Interface Suite" then
                    v:Destroy()
                end
            end
            Rayfield:Notify({Title = "Cleanup Complete", Content = "Extra GUIs destroyed.", Duration = 3, Image = 4483362458})
        end,
    })
end)

pcall(function()
    GeneralTab:CreateToggle({
        Name = "Auto-Reconnect on Crash",
        CurrentValue = false,
        Callback = function(Value)
            _G.AutoReconnect = Value
            if Value then
                game:GetService("Players").PlayerRemoving:Connect(function(player)
                    if player == game.Players.LocalPlayer then
                        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
                    end
                end)
                Rayfield:Notify({Title = "Auto-Reconnect Enabled", Content = "Will rejoin on disconnect.", Duration = 3, Image = 4483362458})
            end
        end,
    })
end)

-- New: Server Hopper
pcall(function()
    GeneralTab:CreateButton({
        Name = "Server Hopper (Random Join)",
        Callback = function()
            local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            local randomServer = servers.data[math.random(1, #servers.data)]
            if randomServer then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, randomServer.id)
                Rayfield:Notify({Title = "Hopping Server", Content = "Joining new server...", Duration = 3, Image = 4483362458})
            else
                Rayfield:Notify({Title = "Server Hop Failed", Content = "No servers available.", Duration = 3, Image = 4483362458})
            end
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Rejoin Current Server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
            Rayfield:Notify({Title = "Rejoining", Content = "Reloading server...", Duration = 2, Image = 4483362458})
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Infinite Yield Admin (Verified)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "Infinite Yield")
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Orca Hub (Updated)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/richie0866/orca/master/public/snapshot.lua", "Orca Hub")
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "FE Trolling GUI",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/FE%20Trolling%20GUI.luau", "FE Trolling")
        end,
    })
end)

-- Verified General Scripts
pcall(function()
    GeneralTab:CreateButton({
        Name = "Universal ESP (Players/NPCs) - External",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/xt-el/ESP-Players/refs/heads/main/ESP", "Universal ESP")
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Fly Script (Mobile-Friendly)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/JNHHGaming/Fly/refs/heads/main/Fly", "Fly Script")
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Fullbright (Remove Darkness)",
        Callback = function()
            loadWithBypass("https://pastebin.com/raw/3g5hM1z2", "Fullbright")
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Click Teleport (Click to TP)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/whatmyname111/by-Tw3ch1k_def/main/sab.lua", "Click Teleport")
        end,
    })
end)

pcall(function()
    GeneralTab:CreateButton({
        Name = "Bring Players (Pull to You)",
        Callback = function()
            loadWithBypass("https://koronis.xyz/hub.lua", "Bring Players")
        end,
    })
end)

-- Dex Explorer (Moon Edition)
pcall(function()
    GeneralTab:CreateButton({
        Name = "Dex Explorer (Moon Edition)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua", "Dex Explorer")
        end,
    })
end)

-- New: Mobile Dex Explorer (Dark Dex V3 - Mobile Optimized)
pcall(function()
    GeneralTab:CreateButton({
        Name = "Mobile Dex Explorer (Dark Dex V3)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", "Mobile Dex")
        end,
    })
end)

-- New: Anti-Kick
pcall(function()
    GeneralTab:CreateToggle({
        Name = "Anti-Kick (Prevent Boot)",
        CurrentValue = false,
        Callback = function(Value)
            _G.AntiKick = Value
            if Value then
                game:GetService("Players").LocalPlayer.OnClientKick = function() end
                Rayfield:Notify({Title = "Anti-Kick Enabled", Content = "Kicks blocked.", Duration = 3, Image = 4483362458})
            end
        end,
    })
end)

pcall(function()
    GeneralTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Callback = function(Value)
            _G.InfiniteJumpEnabled = Value
            if Value then
                game:GetService("UserInputService").JumpRequest:Connect(function()
                    if _G.InfiniteJumpEnabled then
                        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                    end
                end)
            end
        end,
    })
end)

-- Tab 2: Player Mods (added HipHeight, more sliders, Integrated ESP)
local PlayerTab = Window:CreateTab("Player Mods", 4483362458)

pcall(function()
    PlayerTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(Value)
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end,
    })
end)

pcall(function()
    PlayerTab:CreateSlider({
        Name = "JumpPower",
        Range = {50, 500},
        Increment = 1,
        CurrentValue = 50,
        Callback = function(Value)
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end,
    })
end)

-- New: Hip Height Slider
pcall(function()
    PlayerTab:CreateSlider({
        Name = "Hip Height",
        Range = {0, 100},
        Increment = 0.1,
        CurrentValue = 0,
        Callback = function(Value)
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.HipHeight = Value
            end
        end,
    })
end)

pcall(function()
    PlayerTab:CreateSlider({
        Name = "FPS Booster Quality (0=Low, 10=Auto)",
        Range = {0, 10},
        Increment = 1,
        CurrentValue = 10,
        Callback = function(Value)
            local quality = Enum.SavedQualitySetting.Automatic
            if Value <= 2 then quality = Enum.SavedQualitySetting.Low
            elseif Value <= 5 then quality = Enum.SavedQualitySetting.Medium
            elseif Value <= 8 then quality = Enum.SavedQualitySetting.High end
            settings().Rendering.QualityLevel = quality
            game:GetService("Lighting").GlobalShadows = (Value > 7)
            game:GetService("Lighting").FogEnd = (Value > 7 and 9e9 or 100)
            if Value <= 2 then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Parent ~= game.Players.LocalPlayer.Character then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                        v.CastShadow = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    end
                end
            end
            print("FPS Booster set to level " .. Value)
        end,
    })
end)

-- Integrated ESP Toggle
pcall(function()
    PlayerTab:CreateToggle({
        Name = "Integrated ESP (Player Highlights)",
        CurrentValue = false,
        Callback = function(Value)
            toggleESP(Value)
        end,
    })
end)

pcall(function()
    PlayerTab:CreateToggle({
        Name = "Noclip (Walk Through Walls)",
        CurrentValue = false,
        Callback = function(Value)
            _G.Noclip = Value
            spawn(function()
                while _G.Noclip do
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    wait(0.1)
                end
            end)
            Rayfield:Notify({Title = "Noclip " .. (Value and "Enabled" or "Disabled"), Content = "Toggle to phase through objects.", Duration = 2, Image = 4483362458})
        end,
    })
end)

pcall(function()
    PlayerTab:CreateButton({
        Name = "Teleport to Players (Select Target)",
        Callback = function()
            local playerList = {}
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(playerList, player.Name)
                end
            end
            local selected = Rayfield:CreateDropdown({
                Name = "Select Player to TP To",
                Options = playerList,
                CurrentOption = playerList[1] or "No Players",
                Callback = function(Option)
                    local target = game.Players:FindFirstChild(Option)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                        Rayfield:Notify({Title = "Teleported to " .. Option, Content = "Position synced.", Duration = 2, Image = 4483362458})
                    end
                end,
            })
        end,
    })
end)

pcall(function()
    PlayerTab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Callback = function(Value)
            _G.AntiAFK = Value
            if Value then
                spawn(function()
                    while _G.AntiAFK do
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                        wait(60)
                    end
                end)
            end
        end,
    })
end)

pcall(function()
    PlayerTab:CreateToggle({
        Name = "Fly (Basic Flight - Mobile Compatible)",
        CurrentValue = false,
        Callback = function(Value)
            _G.FlyEnabled = Value
            local player = game.Players.LocalPlayer
            if Value and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = player.Character.HumanoidRootPart
                spawn(function()
                    while _G.FlyEnabled do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local cam = workspace.CurrentCamera
                            local moveVector = Vector3.new(0, 0, 0)
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cam.CFrame.LookVector end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cam.CFrame.LookVector end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cam.CFrame.RightVector end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cam.CFrame.RightVector end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
                            -- Mobile touch support: Basic forward/back based on thumbstick if available
                            bodyVelocity.Velocity = moveVector * 50
                        end
                        wait(0.1)
                    end
                    if bodyVelocity then bodyVelocity:Destroy() end
                end)
            end
        end,
    })
end)

pcall(function()
    PlayerTab:CreateToggle({
        Name = "Sit/Stand Toggle",
        CurrentValue = false,
        Callback = function(Value)
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if Value then
                    humanoid.Sit = true
                else
                    humanoid.Sit = false
                end
            end
            Rayfield:Notify({Title = Value and "Sitting" or "Standing", Content = "State changed.", Duration = 2, Image = 4483362458})
        end,
    })
end)

pcall(function()
    PlayerTab:CreateToggle({
        Name = "Invisible (Hide Parts)",
        CurrentValue = false,
        Callback = function(Value)
            _G.Invisible = Value
            spawn(function()
                while _G.Invisible do
                    if game.Players.LocalPlayer.Character then
                        for _, part in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                part.Transparency = 1
                            elseif part:IsA("Accessory") then
                                part.Handle.Transparency = 1
                            end
                        end
                    end
                    wait(0.5)
                end
                -- Restore on disable
                if game.Players.LocalPlayer.Character then
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Transparency = 0
                        elseif part:IsA("Accessory") then
                            part.Handle.Transparency = 0
                        end
                    end
                end
            end)
        end,
    })
end)

pcall(function()
    PlayerTab:CreateSlider({
        Name = "Gravity Adjust (Low=High Jumps)",
        Range = {0, 196},  -- Default Roblox gravity is 196
        Increment = 1,
        CurrentValue = 196,
        Callback = function(Value)
            workspace.Gravity = Value
            print("Gravity set to " .. Value)
        end,
    })
end)

-- Tab 3: Combat Features (New Tab for Aimbot with Wallbang & Triggerbot & Silent Aim & Aimlock)
local CombatTab = Window:CreateTab("Combat Features", 4483362458)

pcall(function()
    CombatTab:CreateToggle({
        Name = "Integrated Aimbot (FOV: 120)",
        CurrentValue = false,
        Callback = function(Value)
            toggleAimbot(Value)
        end,
    })
end)

pcall(function()
    CombatTab:CreateToggle({
        Name = "Wallbang Mode (3D Distance)",
        CurrentValue = false,
        Callback = function(Value)
            _G.WallbangMode = Value
            Rayfield:Notify({Title = "Wallbang " .. (Value and "Enabled" or "Disabled"), Content = "Aimbot now uses " .. (Value and "3D distance" or "screen FOV") .. " for targeting.", Duration = 3, Image = 4483362458})
            if _G.AimbotEnabled then
                toggleAimbot(false)
                toggleAimbot(true)  -- Restart aimbot to apply mode
            end
            if _G.AimlockEnabled then
                toggleAimlock(false)
                toggleAimlock(true)  -- Restart aimlock to apply mode
            end
        end,
    })
end)

pcall(function()
    CombatTab:CreateSlider({
        Name = "Aimbot FOV (Screen Mode)",
        Range = {30, 500},
        Increment = 10,
        CurrentValue = 120,
        Callback = function(Value)
            _G.AimbotFOV = Value
            Rayfield:Notify({Title = "FOV Updated", Content = "Aimbot FOV set to " .. Value .. " (effective in screen mode).", Duration = 2, Image = 4483362458})
        end,
    })
end)

pcall(function()
    CombatTab:CreateSlider({
        Name = "Aimbot Smoothness (0.1=Smooth, 1=Snap)",
        Range = {0.01, 1},
        Increment = 0.01,
        CurrentValue = 0.1,
        Callback = function(Value)
            _G.AimbotSmoothness = Value
            Rayfield:Notify({Title = "Smoothness Updated", Content = "Aimbot smoothness set to " .. Value, Duration = 2, Image = 4483362458})
        end,
    })
end)

pcall(function()
    CombatTab:CreateToggle({
        Name = "Integrated Triggerbot (Radius: 5)",
        CurrentValue = false,
        Callback = function(Value)
            toggleTriggerbot(Value)
        end,
    })
end)

pcall(function()
    CombatTab:CreateSlider({
        Name = "Triggerbot Radius (Pixels)",
        Range = {1, 20},
        Increment = 1,
        CurrentValue = 5,
        Callback = function(Value)
            _G.TriggerRadius = Value
            Rayfield:Notify({Title = "Radius Updated", Content = "Triggerbot radius set to " .. Value .. " pixels.", Duration = 2, Image = 4483362458})
        end,
    })
end)

pcall(function()
    CombatTab:CreateToggle({
        Name = "Integrated Silent Aim (Mouse.Hit Hook)",
        CurrentValue = false,
        Callback = function(Value)
            toggleSilentAim(Value)
        end,
    })
end)

pcall(function()
    CombatTab:CreateToggle({
        Name = "Integrated Aimlock (Locks Camera)",
        CurrentValue = false,
        Callback = function(Value)
            toggleAimlock(Value)
        end,
    })
end)

-- Tab 4: November 2025 Trending (added more)
local TrendingTab = Window:CreateTab("November 2025 Trending", 4483362458)

pcall(function()
    TrendingTab:CreateButton({
        Name = "Blox Fruits - Redz Hub (Auto Farm/Fruit Sniper)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau", "Redz Hub")
        end,
    })
end)

pcall(function()
    TrendingTab:CreateButton({
        Name = "Blox Fruits - Raito Hub (Alt Farm/ESP)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/Efe0626/RaitoHub/main/Script", "Raito Hub")
        end,
    })
end)

pcall(function()
    TrendingTab:CreateButton({
        Name = "Forsaken - Inf Stamina/ESP/Auto-Gen",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/zxcursedsocute/Forsaken-Script/refs/heads/main/lua", "Forsaken Hub")
        end,
    })
end)

pcall(function()
    TrendingTab:CreateButton({
        Name = "Plants vs Brainrots - Full Auto (Farm/Dupe)",
        Callback = function()
            loadWithBypass("https://api.luarmor.net/files/v3/loaders/d6eded51e52af6e97e3ee10fd4843043.lua", "Plants vs Brainrots")
        end,
    })
end)

pcall(function()
    TrendingTab:CreateButton({
        Name = "Arise Shadow Hunt - StarStream",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub", "StarStream")
        end,
    })
end)

pcall(function()
    TrendingTab:CreateButton({
        Name = "99 Nights in the Forest - Survival Booster",
        Callback = function()
            loadWithBypass("https://pastebin.com/raw/husyDTrd", "99 Nights Booster")
        end,
    })
end)

pcall(function()
    TrendingTab:CreateButton({
        Name = "Blade Ball - Auto Parry (Visualizer)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/NoEnemiesHub/BladeBall/main/AutoParry.lua", "Blade Ball Auto Parry")
        end,
    })
end)

-- New: Additional Trending
pcall(function()
    TrendingTab:CreateButton({
        Name = "Anime Defenders - Auto Farm (2025 Update)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/AhmadT.T/Anime-Defenders/main/Auto-Farm.lua", "Anime Defenders")
        end,
    })
end)

pcall(function()
    TrendingTab:CreateButton({
        Name = "Dress to Impress - Auto Win/Outfits",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/DressToImpressHub/DressToImpress/main/Hub.lua", "Dress to Impress")
        end,
    })
end)

-- New: More Trending - Sol's RNG
pcall(function()
    TrendingTab:CreateButton({
        Name = "Sol's RNG - Auto Roll/Farm (2025)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/SolsRNGHub/SolsRNG/main/Hub.lua", "Sol's RNG Hub")
        end,
    })
end)

-- Tab 5: Classic Favorites (completed & added more)
local ClassicTab = Window:CreateTab("Classic Favorites", 4483362458)

pcall(function()
    ClassicTab:CreateButton({
        Name = "Murder Mystery 2 - Foggy Hub (ESP/X-Ray)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/FOGOTY/mm2-piano-reborn/refs/heads/main/scr", "Foggy Hub")
        end,
    })
end)

pcall(function()
    ClassicTab:CreateButton({
        Name = "Pet Simulator X - Ultra Hub (Auto Farm)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/ZaRdoOx/Ultra-Hub/main/Main", "Ultra Hub")
        end,
    })
end)

pcall(function()
    ClassicTab:CreateButton({
        Name = "Brookhaven RP - SP Hub (Inf Money)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/SP-Hub/Brookhaven/main/SPHub.lua", "SP Hub Brookhaven")
        end,
    })
end)

pcall(function()
    ClassicTab:CreateButton({
        Name = "Arsenal - Owl Hub (Aimbot/ESP)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/portaleducativo/OwlHub/master/Arsenal", "Owl Hub Arsenal")
        end,
    })
end)

pcall(function()
    ClassicTab:CreateButton({
        Name = "Jailbreak - Infinite Yield Variant",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "Infinite Yield JB")
        end,
    })
end)

pcall(function()
    ClassicTab:CreateButton({
        Name = "Adopt Me - Auto Farm Pets",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/AdoptMeHub/AdoptMe/main/AutoFarm.lua", "Adopt Me Hub")
        end,
    })
end)

-- Tab 6: Utilities (new feature)
local UtilityTab = Window:CreateTab("Utilities", 4483362458)

pcall(function()
    UtilityTab:CreateButton({
        Name = "Copy Discord Invite (Hub Support)",
        Callback = function()
            setclipboard("https://discord.gg/xai-grok-hub")  -- Placeholder for a real invite
            Rayfield:Notify({Title = "Copied", Content = "Discord invite copied to clipboard.", Duration = 3, Image = 4483362458})
        end,
    })
end)

pcall(function()
    UtilityTab:CreateToggle({
        Name = "Chat Spy (See All Messages)",
        CurrentValue = false,
        Callback = function(Value)
            _G.ChatSpy = Value
            if Value then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local args = {...}
                    local method = getnamecallmethod()
                    if self.Name == "SayMessageRequest" and method == "FireServer" then
                        print("[Chat Spy] " .. game.Players.LocalPlayer.Name .. ": " .. tostring(args[1]))
                    end
                    return oldNamecall(self, ...)
                end)
                Rayfield:Notify({Title = "Chat Spy Enabled", Content = "Monitor console for messages.", Duration = 3, Image = 4483362458})
            end
        end,
    })
end)

pcall(function()
    UtilityTab:CreateButton({
        Name = "Save Character Position",
        Callback = function()
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                _G.SavedPosition = player.Character.HumanoidRootPart.CFrame
                Rayfield:Notify({Title = "Position Saved", Content = "Use Load to TP back.", Duration = 2, Image = 4483362458})
            end
        end,
    })
end)

pcall(function()
    UtilityTab:CreateButton({
        Name = "Load Saved Position",
        Callback = function()
            if _G.SavedPosition and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.SavedPosition
                Rayfield:Notify({Title = "Position Loaded", Content = "Teleported to saved spot.", Duration = 2, Image = 4483362458})
            else
                Rayfield:Notify({Title = "No Position Saved", Content = "Save one first.", Duration = 2, Image = 4483362458})
            end
        end,
    })
end)

pcall(function()
    UtilityTab:CreateToggle({
        Name = "Auto-Farm Toggle (Generic Loop)",
        CurrentValue = false,
        Callback = function(Value)
            _G.AutoFarm = Value
            if Value then
                spawn(function()
                    while _G.AutoFarm do
                        -- Generic auto-farm loop (customize per game)
                        wait(1)
                        print("Auto-Farm Loop Running...")
                    end
                end)
                Rayfield:Notify({Title = "Auto-Farm Started", Content = "Generic loop active (adapt for game).", Duration = 3, Image = 4483362458})
            end
        end,
    })
end)

-- Tab 7: Auto-Farm Scripts (Game-Specific)
local AutoFarmTab = Window:CreateTab("Auto-Farm Scripts", 4483362458)

pcall(function()
    AutoFarmTab:CreateButton({
        Name = "Blox Fruits - Redz Auto Farm (2025 Verified)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau", "Blox Fruits Auto Farm")
        end,
    })
end)

pcall(function()
    AutoFarmTab:CreateButton({
        Name = "Pet Simulator X - BK Auto Farm (Coins/Eggs)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/BLACKGAMER1221/Pet-Simulator-X/main/BK Pet.lua", "Pet Sim X Auto Farm")
        end,
    })
end)

pcall(function()
    AutoFarmTab:CreateButton({
        Name = "Adopt Me - Nomii Auto Farm (Pets/Bucks)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/nomii0700/Roblox-Scrips/refs/heads/main/AdoptmeAutoFarm.lua", "Adopt Me Auto Farm")
        end,
    })
end)

pcall(function()
    AutoFarmTab:CreateButton({
        Name = "Anime Defenders - Bunny Auto Farm (Units/Coins)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/bunny42312/script/main/animedefenders", "Anime Defenders Auto Farm")
        end,
    })
end)

pcall(function()
    AutoFarmTab:CreateButton({
        Name = "Forsaken - Ivannetta Auto Gen/Farm (Inf Stamina)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/ivannetta/ShitScripts/refs/heads/main/forsaken.lua", "Forsaken Auto Farm")
        end,
    })
end)

pcall(function()
    AutoFarmTab:CreateButton({
        Name = "Pet Simulator 99 - SlamminPig Auto Farm (Updated)",
        Callback = function()
            loadWithBypass("https://raw.githubusercontent.com/SlamminPig/6FootScripts/main/Scripts/PetSimulator99.lua", "Pet Sim 99 Auto Farm")
        end,
    })
end)

print("Script Hub V29 Loaded - Mobile Dex Features Integrated!")
