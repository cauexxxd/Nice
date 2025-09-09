-- IDk Hub (integrated) - Full script using only RedzLib as UI dependency
-- Author: adapted for you. Remove/adjust features as needed.

-- === load redzlib (keep your URL) ===
local ok, redzlib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
end)
if not ok or not redzlib then
    error("Failed to load redzlib UI. Check URL or executor HTTP access.")
end

-- simple Notify fallback (some libs provide their own Notify; use this if missing)
local function Notify(title, text, time)
    time = time or 5
    pcall(function()
        if redzlib and redzlib.Notify then
            redzlib.Notify(title, text, time)
            return
        end
        -- fallback: simple screen gui
        local gui = Instance.new("ScreenGui")
        gui.Name = "IDKHubNotify"
        gui.ResetOnSpawn = false
        gui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 300, 0, 60)
        frame.Position = UDim2.new(0.5, -150, 0.05, 0)
        frame.BackgroundTransparency = 0.2
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.ZIndex = 9999

        local titleLbl = Instance.new("TextLabel", frame)
        titleLbl.Size = UDim2.new(1, -10, 0, 20)
        titleLbl.Position = UDim2.new(0, 5, 0, 5)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = Color3.new(1,1,1)
        titleLbl.Font = Enum.Font.SourceSansBold
        titleLbl.TextSize = 18

        local txt = Instance.new("TextLabel", frame)
        txt.Size = UDim2.new(1, -10, 0, 30)
        txt.Position = UDim2.new(0, 5, 0, 25)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Font = Enum.Font.SourceSans
        txt.TextSize = 14
        txt.TextWrapped = true

        spawn(function()
            task.wait(time)
            pcall(function() gui:Destroy() end)
        end)
    end)
end

-- === window ===
local Window = redzlib:MakeWindow({
  Title = "IDk Hub : ",
  SubTitle = "by cauezxxxd",
  SaveFolder = "testando | redz lib v5.lua"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(35, 1) },
})

-- Tabs
local TabHome = Window:MakeTab({"🏡 Home", ""})
local TabPlayer = Window:MakeTab({"👤 Player", ""})
local TabCombat = Window:MakeTab({"⚔️ Combat", ""})
local TabVisual = Window:MakeTab({"👁️ Visual", ""})
local TabMusic = Window:MakeTab({"🎵 Music", ""})
local TabShop = Window:MakeTab({"🛒 Shop", ""})
local TabMisc = Window:MakeTab({"⚙️ Misc", ""})

-- Home (discord invite & paragraph)
TabHome:AddDiscordInvite({
    Name = "IDK Hub",
    Description = "Join server",
    Logo = "rbxassetid://18751483361",
    Invite = "Link discord invite",
})
TabHome:AddParagraph({"Bem-vindo ao IDK Hub — tudo integrado com RedzLib.", "As imagens foram mantidas."})

-- ========== Shared / Globals ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = pcall(function() return game:GetService("Stats") end) and game:GetService("Stats") or nil

getgenv().aura_Enabled = false
getgenv().hit_sound_Enabled = false
getgenv().hit_effect_Enabled = false
getgenv().night_mode_Enabled = false
getgenv().trail_Enabled = false
getgenv().self_effect_Enabled = false
getgenv().antiCurveEnabled = false
getgenv().ASC = false
getgenv().AEC = false
getgenv().FB = false

-- helper: safe call
local function safeRequire(fn)
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

-- executor name detection (safe)
local function getExecutorName()
    local ok, name = pcall(function()
        if identifyexecutor then return identifyexecutor() end
        if getexecutorname then return getexecutorname() end
        return "Unknown"
    end)
    return ok and (name or "Unknown") or "Unknown"
end

-- ========== Player Tab ==========
do
    local Section = TabPlayer:AddSection({"Player"})

    -- character safe refs
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")

    local originalSpeed = humanoid.WalkSpeed
    local originalFov = workspace.CurrentCamera.FieldOfView

    local speedEnabled = false
    local fovEnabled = false
    local speedValue = 36
    local fovValue = 80

    local function applySpeed()
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:WaitForChild("Humanoid").WalkSpeed = speedEnabled and speedValue or originalSpeed
        end
    end
    local function applyFov()
        workspace.CurrentCamera.FieldOfView = fovEnabled and fovValue or originalFov
    end

    TabPlayer:AddSlider({
        Name = "Speed",
        Description = "Adjusts walk speed",
        Min = 16,
        Max = 1000,
        Increase = 1,
        Default = speedValue,
        Callback = function(Value)
            speedValue = Value
            applySpeed()
        end
    })

    TabPlayer:AddSlider({
        Name = "FOV",
        Description = "Adjust camera FOV",
        Min = 70,
        Max = 200,
        Increase = 1,
        Default = fovValue,
        Callback = function(Value)
            fovValue = Value
            applyFov()
        end
    })

    TabPlayer:AddToggle({
        Name = "Enable Speed",
        Description = "Enable custom speed",
        Default = false,
        Callback = function(Value)
            speedEnabled = Value
            applySpeed()
        end
    })

    TabPlayer:AddToggle({
        Name = "Enable FOV",
        Description = "Enable custom FOV",
        Default = false,
        Callback = function(Value)
            fovEnabled = Value
            applyFov()
        end
    })

    -- infinite jump
    local InfiniteJumpEnabled = false
    TabPlayer:AddToggle({
        Name = "Infinite Jump",
        Description = "Press jump to keep jumping",
        Default = false,
        Callback = function(state)
            InfiniteJumpEnabled = state
        end
    })
    UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState("Jumping") end
            end
        end
    end)

    -- teleport dropdown
    TabPlayer:AddSection({"Teleport"})
    local Dropdown = TabPlayer:AddDropdown({
        Name = "Players List",
        Description = "Teleport to a player",
        Options = {},
        Default = "",
        Callback = function(value)
            if value and value ~= "" then
                local p = Players:FindFirstChild(value)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = p.Character.HumanoidRootPart.CFrame
                    end
                else
                    Notify("Teleport", "That player isn't available", 3)
                end
            end
        end
    })
    local function UpdatePlayerDropdown()
        local opts = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name ~= LocalPlayer.Name then table.insert(opts, p.Name) end
        end
        Dropdown:Set(opts)
    end
    Players.PlayerAdded:Connect(UpdatePlayerDropdown)
    Players.PlayerRemoving:Connect(UpdatePlayerDropdown)
    UpdatePlayerDropdown()
end

-- ========== Visual Tab ==========
do
    TabVisual:AddSection({"Visual Options"})

    -- XRay (simple transparency changer)
    local xrayEnabled = false
    local xrayIntensity = 0.7
    local originalTransparency = {} -- store changed parts
    local function toggleXRay(state, transparency)
        transparency = transparency or 0.7
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChildOfClass("Humanoid") then
                    if not originalTransparency[v] then
                        originalTransparency[v] = v.LocalTransparencyModifier
                        v.LocalTransparencyModifier = transparency
                    end
                end
            end
        else
            for part, val in pairs(originalTransparency) do
                if part and part:IsA("BasePart") then
                    part.LocalTransparencyModifier = val
                end
                originalTransparency[part] = nil
            end
            originalTransparency = {}
        end
    end

    TabVisual:AddToggle({
        Name = "XRay",
        Description = "See through objects",
        Default = false,
        Callback = function(state)
            xrayEnabled = state
            toggleXRay(xrayEnabled, xrayIntensity)
        end
    })
    TabVisual:AddSlider({
        Name = "XRay Intensity",
        Description = "How transparent (0.1 - 1)",
        Min = 0.1,
        Max = 1,
        Increase = 0.05,
        Default = xrayIntensity,
        Callback = function(val)
            xrayIntensity = val
            if xrayEnabled then toggleXRay(true, xrayIntensity) end
        end
    })

    -- Night mode (lighting)
    TabVisual:AddToggle({
        Name = "Night Mode",
        Description = "Toggle night-like lighting",
        Default = false,
        Callback = function(state)
            getgenv().night_mode_Enabled = state
            spawn(function()
                local Lighting = game:GetService("Lighting")
                if state then
                    pcall(function()
                        game:GetService("TweenService"):Create(Lighting, TweenInfo.new(2), {ClockTime = 3.9}):Play()
                    end)
                else
                    pcall(function()
                        game:GetService("TweenService"):Create(Lighting, TweenInfo.new(2), {ClockTime = 13.5}):Play()
                    end)
                end
            end)
        end
    })

    TabVisual:AddButton({
        Name = "Remove Particles (Anti-Lag Visual)",
        Description = "Disable particle emitters, fire, smoke",
        Callback = function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") then
                    v.Enabled = false
                end
            end
            Notify("Visual", "Particles disabled", 3)
        end
    })
end

-- ========== Music Tab ==========
do
    TabMusic:AddSection({"Music Player"})
    local MusicId = nil
    local MusicToggle = false
    local currentSound = nil
    local pausedPosition = 0

    local function playMusic()
        if MusicToggle and MusicId then
            if currentSound then
                pcall(function() currentSound:Stop(); currentSound:Destroy() end)
            end
            currentSound = Instance.new("Sound", workspace)
            currentSound.SoundId = "rbxassetid://" .. tostring(MusicId)
            currentSound.TimePosition = pausedPosition or 0
            currentSound.Looped = true
            currentSound:Play()
            currentSound.Ended:Connect(function()
                if currentSound and currentSound.Playing then return end
                currentSound.TimePosition = 0
                pcall(function() currentSound:Play() end)
            end)
        end
    end

    TabMusic:AddTextBox({
        Name = "Music ID",
        Description = "Roblox sound id (numeric)",
        Default = "",
        Callback = function(value)
            MusicId = value
            playMusic()
        end
    })

    TabMusic:AddToggle({
        Name = "Play Music",
        Description = "Start/pause music",
        Default = false,
        Callback = function(state)
            MusicToggle = state
            if MusicToggle then
                playMusic()
            else
                if currentSound then
                    pausedPosition = currentSound.TimePosition
                    pcall(function() currentSound:Stop() end)
                end
            end
        end
    })

    TabMusic:AddButton({
        Name = "Phonk (example)",
        Description = "Load example id",
        Callback = function()
            MusicId = "16190782181"
            playMusic()
        end
    })

    TabMusic:AddButton({
        Name = "Copy Phonk ID",
        Description = "Copy id to clipboard (if available)",
        Callback = function()
            pcall(function() setclipboard("16190782181") end)
            Notify("Music", "ID copied (if supported by executor)", 3)
        end
    })
end

-- ========== Shop Tab ==========
do
    TabShop:AddSection({"Shop"})
    TabShop:AddButton({
        Name = "Buy Sword Box",
        Description = "Purchases a sword box",
        Callback = function()
            pcall(function()
                ReplicatedStorage.Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalSwordCrate)
            end)
        end
    })
    TabShop:AddButton({
        Name = "Buy Explosion Box",
        Description = "Purchases explosion box",
        Callback = function()
            pcall(function()
                ReplicatedStorage.Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalExplosionCrate)
            end)
        end
    })
    TabShop:AddToggle({
        Name = "Auto Buy Sword Box",
        Description = "Continuously attempts to purchase sword boxes",
        Default = false,
        Callback = function(state) getgenv().ASC = state end
    })
    TabShop:AddToggle({
        Name = "Auto Buy Explosion Box",
        Description = "Continuously attempts to purchase explosion boxes",
        Default = false,
        Callback = function(state) getgenv().AEC = state end
    })

    spawn(function()
        while task.wait(0.5) do
            if getgenv().ASC then
                pcall(function()
                    ReplicatedStorage.Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalSwordCrate)
                end)
            end
            if getgenv().AEC then
                pcall(function()
                    ReplicatedStorage.Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalExplosionCrate)
                end)
            end
        end
    end)
end

-- ========== Combat Tab ==========
do
    TabCombat:AddSection({"Combat"})

    -- find hit remote (RemoteEvent with newline in name) - common obfuscation
    local function findHitRemote()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and tostring(v.Name):find("\n") then
                return v
            end
        end
        return nil
    end
    local hitremote = findHitRemote()

    -- Stubs for ball utilities (some games name part "Ball" or have workspace.Balls)
    local function getFirstBall()
        local b = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Balls") and workspace.Balls:FindFirstChildOfClass("Part")
        return b
    end

    -- Auto Parry basic: resolve parry remote (AdService/SocialService trick)
    local parry_remote = nil
    local Services = { game:GetService("AdService"), game:GetService("SocialService") }
    local function resolve_parry_Remote()
        for _, serv in ipairs(Services) do
            for _, child in ipairs(serv:GetChildren()) do
                if child:IsA("RemoteEvent") and tostring(child.Name):find("\n") then
                    parry_remote = child
                    return
                end
            end
        end
    end

    TabCombat:AddToggle({
        Name = "Auto Parry (basic)",
        Description = "Attempt to fire detected parry remote when ball close",
        Default = false,
        Callback = function(toggled)
            getgenv().aura_Enabled = toggled
            if toggled then
                resolve_parry_Remote()
                Notify("Combat", "Auto Parry enabled (basic).", 3)
            else
                Notify("Combat", "Auto Parry disabled.", 2)
            end
        end
    })

    -- Ultra Fast Block (heartbeat loop)
    local ultraEnabled = false
    local aura_table = {canParry = true, parry_Range = 0, hit_Time = tick()}
    local function enableUltraFastBlocking(enable)
        ultraEnabled = enable
        if enable then
            resolve_parry_Remote()
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not ultraEnabled then
                    conn:Disconnect()
                    return
                end
                if not aura_table.canParry then return end
                local ball = getFirstBall()
                if ball and parry_remote and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                    local player_Position = LocalPlayer.Character.PrimaryPart.Position
                    local ball_Position = ball.Position
                    local ball_Distance = (player_Position - ball_Position).Magnitude
                    local ping = (Stats and Stats.Network and Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem["Data Ping"] and Stats.Network.ServerStatsItem["Data Ping"]:GetValue()/10) or 0
                    aura_table.parry_Range = math.max(math.max(ping, 2), 4.5)
                    if ball_Distance <= aura_table.parry_Range then
                        pcall(function()
                            parry_remote:FireServer(0.5, CFrame.new(workspace.CurrentCamera.CFrame.Position, Vector3.new(math.random(0,100), math.random(0,1000), math.random(100,1000))), {}, {0,0}, false)
                        end)
                        aura_table.canParry = false
                        aura_table.hit_Time = tick()
                        task.delay(0.05, function() aura_table.canParry = true end)
                    end
                end
            end)
        else
            -- aura_table.canParry = false -- keep safe
        end
    end

    TabCombat:AddToggle({
        Name = "Ultra Fast Block",
        Description = "Fires parry remote fast when ball near (game-dependent)",
        Default = false,
        Callback = function(state)
            enableUltraFastBlocking(state)
        end
    })

    -- Manual spam / Clash Mode (UI + button)
    TabCombat:AddSection({"Manual Spam / Clash Mode"})
    do
        local gui = Instance.new("ScreenGui")
        gui.Name = "IDK_ClashGui"
        gui.ResetOnSpawn = false
        gui.Parent = CoreGui
        gui.Enabled = false

        local frame = Instance.new("Frame", gui)
        frame.Position = UDim2.new(0, 40, 0, 20)
        frame.Size = UDim2.new(0, 100, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
        frame.BackgroundTransparency = 0.9
        frame.BorderSizePixel = 0
        frame.Name = "Clash Mode"

        local button = Instance.new("TextButton", frame)
        button.Size = UDim2.new(1, -4, 1, -7)
        button.Position = UDim2.new(0, 3, 0, 5)
        button.BackgroundTransparency = 0.5
        button.BorderSizePixel = 2
        button.Font = Enum.Font.SourceSans
        button.TextColor3 = Color3.new(1,1,1)
        button.TextSize = 16
        button.Text = "OFF"

        local activated = false
        local enabled = false
        l
