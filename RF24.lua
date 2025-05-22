--[[ 🔐 RF24 Admin Bypass Script - Add at very top ]]--


if _G.KAU then return end
_G.KAU = true

local oldRequire = require
require = function(id)
    if id == 14717798356 then
        warn("🛡️ Blocked RF24 admin anticheat module (Handshake).")
        return {}
    end
    return oldRequire(id)
end

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
lp.Kick = function() return nil end
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        warn("🛡️ Kick attempt blocked:", self)
        return nil
    end
    return oldNamecall(self, ...)
end)

task.delay(3, function()
    require = oldRequire
end)

local engine = oldRequire(game:GetService("ReplicatedStorage").engine)
local global = engine:load("Global")
global._debug = true

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Library:CreateWindow({
    Title = "Light | RF24⚔️",
    SubTitle = "Beta",
    TabWidth = 140,
    Size = UDim2.fromOffset(550, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local reachSize = 25
local offsetX, offsetY, offsetZ = 0, 0, 0
local reachPart = nil
local reachEnabled = false

local function applyReach()
    if not reachPart then
        reachPart = Instance.new("Part")
        reachPart.Anchored = true
        reachPart.CanCollide = false
        reachPart.Massless = true
        reachPart.Transparency = 0.5
        reachPart.Color = Color3.fromRGB(255, 255, 255)
        reachPart.Material = Enum.Material.SmoothPlastic
        reachPart.Name = "UniversalReachHitbox"
        reachPart.Parent = workspace
    end

    reachPart.Size = Vector3.new(reachSize, reachSize, reachSize)

    local root = Character:FindFirstChild("HumanoidRootPart")
    if root then
        local offset = Vector3.new(offsetX, offsetY, offsetZ)
        reachPart.CFrame = root.CFrame + offset
    end
end

local function resetReach()
    if reachPart then
        reachPart:Destroy()
        reachPart = nil
    end
    reachEnabled = false
end

RunService.Heartbeat:Connect(function()
    if reachEnabled and reachPart then
        local root = Character:FindFirstChild("HumanoidRootPart")
        if root then
            local offset = Vector3.new(offsetX, offsetY, offsetZ)
            reachPart.CFrame = root.CFrame + offset
        end
    end
end)

MainTab:AddToggle("EnableReach", {
    Title = "Enable Reach",
    Default = false,
    Callback = function(state)
        reachEnabled = state
        if state then
            applyReach()
        else
            resetReach()
        end
    end
})

MainTab:AddSlider("ReachSize", {
    Title = "Reach Size",
    Description = "Size of the stud hitbox (affects all limbs)",
    Default = 25,
    Min = 2,
    Max = 95,
    Rounding = 1,
    Callback = function(value)
        reachSize = value
        if reachEnabled then applyReach() end
    end
})

MainTab:AddTextbox("X", {
    Title = "X Offset",
    Default = "0",
    Numeric = true,
    Callback = function(value)
        offsetX = tonumber(value) or 0
        if reachEnabled then applyReach() end
    end
})

MainTab:AddTextbox("Y", {
    Title = "Y Offset",
    Default = "0",
    Numeric = true,
    Callback = function(value)
        offsetY = tonumber(value) or 0
        if reachEnabled then applyReach() end
    end
})

MainTab:AddTextbox("Z", {
    Title = "Z Offset",
    Default = "0",
    Numeric = true,
    Callback = function(value)
        offsetZ = tonumber(value) or 0
        if reachEnabled then applyReach() end
    end
})


local MiscTab = Window:AddTab({ Title = "Misc", Icon = "settings" })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

getgenv().PullGKEnabled = false

MiscTab:AddToggle("PullGK", {
    Title = "Pull GK",
    Default = false,
    Callback = function(state)
        getgenv().PullGKEnabled = state
        print("Pull GK Enabled:", state)
    end
})

RunService.RenderStepped:Connect(function()
    if not getgenv().PullGKEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if not tostring(character):lower():find("GK") then return end
    local isDiving = hum:GetState() == Enum.HumanoidStateType.Freefall or hrp.Velocity.Magnitude > 30

    if isDiving then
        local mousePos = Mouse.Hit.Position
        local direction = (mousePos - hrp.Position).Unit
        local force = 70
        hrp.Velocity = direction * force
    end
end)


MiscTab:AddSlider("PullSpeed", {
    Title = "Pull Speed",
    Default = 20,
    Min = 5,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        print("Pull Speed:", value)
    end
})

MiscTab:AddSlider("PullDistance", {
    Title = "Pull Distance",
    Default = 30,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        print("Pull Distance:", value)
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

getgenv().BallAimbotEnabled = false
local holdingMouse2 = false

MiscTab:AddToggle("BallAimbot", {
    Title = "Ball Aimbot",
    Default = false,
    Callback = function(state)
        getgenv().BallAimbotEnabled = state
        print("Ball Aimbot:", state)
    end
})

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingMouse2 = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingMouse2 = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().BallAimbotEnabled or not holdingMouse2 then return end

    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChildWhichIsA("Part", true, function(obj)
        return obj.Name:lower():find("ball")
    end)
    if not ball then return end

    local targetRotation = CFrame.new(hrp.Position, ball.Position)
    local currentCFrame = hrp.CFrame
    local alpha = math.clamp((getgenv().AimbotSmoothness or 2) / 10, 0.1, 1)
    hrp.CFrame = currentCFrame:Lerp(targetRotation, alpha)
end)

getgenv().AimbotSmoothness = 2


MiscTab:AddSlider("Smoothness", {
    Title = "Smoothness",
    Description = "Adjust the aimbot smoothness",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(value)
        getgenv().AimbotSmoothness = value
        print("Smoothness:", value)
    end
})


MiscTab:AddToggle("AutoPen", {
    Title = "Auto Pen",
    Default = false,
    Callback = function(state)
        print("Auto Pen:", state)
    end
})

getgenv().AutoFreekickEnabled = false

MiscTab:AddToggle("AutoFreekick", {
    Title = "Auto Freekick",
    Default = false,
    Callback = function(state)
        getgenv().AutoFreekickEnabled = state
        print("Auto Freekick:", state)
    end
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getGoalCorners()
    local goal = workspace:FindFirstChild("Goal")
    if not goal then return nil end
    local topRight = goal.Position + Vector3.new(4, 2, 0)
    local topLeft = goal.Position + Vector3.new(-4, 2, 0)

    return topRight, topLeft
end

local function aimAtGoalCorner()
    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local topRight, topLeft = getGoalCorners()
    if not topRight then return end
    local target = math.random() > 0.5 and topRight or topLeft
    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.X, hrp.Position.Y, target.Z))
end

RunService.RenderStepped:Connect(function()
    if not getgenv().AutoFreekickEnabled then return end

    local isFreekickActive = workspace:FindFirstChild("FreekickActive") ~= nil
        or (LocalPlayer.PlayerGui:FindFirstChild("FreeKickUI") ~= nil)

    if isFreekickActive then
        aimAtGoalCorner()
    end
end)



MiscTab:AddToggle("DeleteBarriers", {
    Title = "Delete Invisible Barriers",
    Default = false,
    Callback = function(state)
        print("Delete Barriers:", state)
        if state then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 1 and v.CanCollide then
                    v:Destroy()
                end
            end
        end
    end
})

local GameTab = Window:AddTab({ Title = "Game", Icon = "gamepad-2" })

GameTab:AddButton({
    Title = "Remove Lag",
    Description = "Disables particles, textures, shadows, and decals to reduce lag.",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        print("Lag sources removed.")
    end
})

local function removeRain()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") and obj.Name:lower():find("rain") then
            obj:Destroy()
        end
        if obj:IsA("Sound") and obj.Name:lower():find("rain") then
            obj:Destroy()
        end
    end
    print("Rain removed.")
end

GameTab:AddButton({
    Title = "Remove Rain",
    Description = "Destroys rain-related particles and sounds.",
    Callback = removeRain
})

GameTab:AddButton({
    Title = "Remove Rain",
    Description = "Destroys rain-related particles and sounds (duplicate button).",
    Callback = removeRain
})

GameTab:AddButton({
    Title = "Remove Blur",
    Description = "Removes any BlurEffect instances in Lighting.",
    Callback = function()
        for _, effect in ipairs(game:GetService("Lighting"):GetChildren()) do
            if effect:IsA("BlurEffect") then
                effect:Destroy()
            end
        end
        print("Blur effects removed.")
    end
})

local CharacterTab = Window:AddTab({ Title = "Character", Icon = "user" })

local tpWalkEnabled = false
local tpWalkSlider

CharacterTab:AddToggle("TPWalkToggle", {
    Title = "TP Walk",
    Default = false,
    Callback = function(value)
        tpWalkEnabled = value
        if tpWalkSlider then
            tpWalkSlider:SetVisible(value)
        end
    end
})

tpWalkSlider = CharacterTab:AddSlider("TPWalkSlider", {
    Title = "TP Walk Speed",
    Description = "Controls your teleport walk speed.",
    Min = 1,
    Max = 75,
    Default = 16,
    Visible = false,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and tpWalkEnabled then
            char.Humanoid.WalkSpeed = value
        end
    end
})

local infiniteStaminaToggle = false

CharacterTab:AddToggle("InfiniteStamina", {
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(value)
        infiniteStaminaToggle = value
    end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if infiniteStaminaToggle then
            local player = game.Players.LocalPlayer
            local stats = player:FindFirstChild("Stats") or player.Character
            if stats and stats:FindFirstChild("Stamina") then
                stats.Stamina.Value = stats.Stamina.MaxValue or 100
            end
        end
    end
end)

CharacterTab:AddButton({
    Title = "Pitch Teleporter",
    Description = "Feature still in development.",
    Callback = function()
        warn("Pitch Teleporter is still in development.")
    end
})

CharacterTab:AddSlider("FOVSlider", {
    Title = "FOV",
    Description = "Adjust your camera field of view.",
    Min = 50,
    Max = 120,
    Default = 70,
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

local TeamsTab = Window:AddTab({ Title = "Teams", Icon = "users" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TeamsFolder = workspace:WaitForChild("Teams")
local HomeTeam = TeamsFolder:WaitForChild("Home")
local AwayTeam = TeamsFolder:WaitForChild("Away")

local function setTeam(teamFolder)
    if LocalPlayer and LocalPlayer.Character then
        if LocalPlayer.Team ~= teamFolder then
            LocalPlayer.Team = teamFolder
        end
        print("Changed team to:", teamFolder.Name)
    end
end

local function goToGK(teamFolder)
    if not LocalPlayer.Character then return end
    local gkSpot = teamFolder:FindFirstChild("GoalkeeperSpawn") or teamFolder:FindFirstChild("GKSpot")
    if gkSpot and not gkSpot:FindFirstChildWhichIsA("Player") then
        LocalPlayer.Character:SetPrimaryPartCFrame(gkSpot.CFrame + Vector3.new(0, 3, 0))
        print("Teleported to GK spot of", teamFolder.Name)
    else
        warn("GK spot is occupied or missing!")
    end
end

TeamsTab:AddButton({
    Title = "Home Team",
    Description = "Join the Home Team.",
    Callback = function()
        setTeam(HomeTeam)
    end
})

TeamsTab:AddButton({
    Title = "Home GK",
    Description = "Teleport to Home GK spot if available.",
    Callback = function()
        goToGK(HomeTeam)
    end
})

TeamsTab:AddButton({
    Title = "Away Team",
    Description = "Join the Away Team.",
    Callback = function()
        setTeam(AwayTeam)
    end
})

TeamsTab:AddButton({
    Title = "Away GK",
    Description = "Teleport to Away GK spot if available.",
    Callback = function()
        goToGK(AwayTeam)
    end
})

local TrollTab = Window:AddTab({ Title = "Troll", Icon = "smile" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local walkFlingEnabled = false
local walkFlingTarget = nil
local walkFlingConnection = nil

local function flingTarget(player)
    local character = LocalPlayer.Character
    local targetChar = player.Character
    if not character or not targetChar then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end

    hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 100, 0)
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = targetHrp

    task.delay(0.5, function()
        bodyVelocity:Destroy()
    end)
end

local function startWalkFling()
    if walkFlingEnabled then return end
    walkFlingEnabled = true

    walkFlingConnection = RunService.Heartbeat:Connect(function()
        if walkFlingTarget and walkFlingTarget.Character then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHrp = walkFlingTarget.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetHrp then
                hrp.CFrame = hrp.CFrame:Lerp(targetHrp.CFrame * CFrame.new(0, 0, 3), 0.3)
                if (hrp.Position - targetHrp.Position).Magnitude < 5 then
                    flingTarget(walkFlingTarget)
                end
            end
        end
    end)
end

local function stopWalkFling()
    walkFlingEnabled = false
    if walkFlingConnection then
        walkFlingConnection:Disconnect()
        walkFlingConnection = nil
    end
end

TrollTab:AddButton({
    Title = "WalkFling",
    Description = "Walk to a selected player and fling them.",
    Callback = function()
        if walkFlingTarget then
            startWalkFling()
            print("WalkFling started on", walkFlingTarget.Name)
        else
            warn("Select a player first in the dropdown.")
        end
    end
})

TrollTab:AddButton({
    Title = "UnWalkFling",
    Description = "Stops the walk fling.",
    Callback = function()
        stopWalkFling()
        print("WalkFling stopped.")
    end
})

local playerNames = {}
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        table.insert(playerNames, plr.Name)
    end
end

local selectedPlayerName = nil

TrollTab:AddDropdown({
    Title = "Select Player to Fling",
    Description = "Choose a player to fling.",
    Options = playerNames,
    Callback = function(value)
        selectedPlayerName = value
        walkFlingTarget = Players:FindFirstChild(value)
        print("Selected player for fling:", value)
    end
})

TrollTab:AddDropdown({
    Title = "Play Celebration",
    Description = "Still in development.",
    Options = { "Celebrate 1", "Celebrate 2", "Celebrate 3" },
    Callback = function(value)
        warn("Play Celebration feature is still in development.")
    end
})

TrollTab:AddDropdown({
    Title = "Play Referee",
    Description = "Still in development.",
    Options = { "Referee 1", "Referee 2" },
    Callback = function(value)
        warn("Play Referee feature is still in development.")
    end
})

local dribbleOutsideEnabled = false

TrollTab:AddToggle({
    Title = "Dribble Outside the Stadium",
    Description = "Allows dribbling outside the stadium without being triggered out.",
    Default = false,
    Callback = function(value)
        dribbleOutsideEnabled = value
        print("Dribble Outside toggle set to", value)

        if dribbleOutsideEnabled then
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Name:lower():find("out") or part.Name:lower():find("bound") then
                    part.CanTouch = false
                    part.CanCollide = false
                    part.Transparency = 1
                end
            end

            local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChildWhichIsA("Part", true)
            if ball then
                for _, connection in pairs(getconnections(ball.Touched)) do
                    connection:Disable()
                end
            end

            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall

            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if dribbleOutsideEnabled and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
                    if tostring(self):lower():find("ballout") or tostring(self):lower():find("outofbounds") then
                        return
                    end
                end

                return oldNamecall(self, unpack(args))
            end)
        end
    end
})

TrollTab:AddButton({
    Title = "Get Up",
    Description = "Forces the player to get up if ragdolled.",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            humanoid.Sit = false
            humanoid.PlatformStand = false
            print("Forced get up.")
        end
    end
})

TrollTab:AddButton({
    Title = "Stop Ragdoll",
    Description = "Stops ragdoll effect on the player.",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            humanoid.PlatformStand = false
            humanoid.Sit = false
            print("Stopped ragdoll.")
        end
    end
})

TrollTab:AddButton({
    Title = "Wear GK Gloves",
    Description = "Equips goalkeeper gloves to the player's hands without being GK.",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end
        local glovesTemplate = ReplicatedStorage:FindFirstChild("GKGloves")
        if not glovesTemplate then
            warn("GK Gloves not found in ReplicatedStorage.")
            return
        end

        local leftGlove = glovesTemplate:FindFirstChild("LeftGlove")
        local rightGlove = glovesTemplate:FindFirstChild("RightGlove")
        if leftGlove and rightGlove then
            local leftClone = leftGlove:Clone()
            local rightClone = rightGlove:Clone()

            leftClone.Name = "GKGloveLeft"
            rightClone.Name = "GKGloveRight"

            local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
            local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

            if leftHand and rightHand then
                leftClone.Parent = leftHand
                rightClone.Parent = rightHand
                print("GK Gloves equipped.")
            else
                warn("Player hands not found.")
            end
        else
            warn("GKGloves parts not found inside template.")
        end
    end
})

TrollTab:AddButton({
    Title = "Remove GK Gloves",
    Description = "Removes goalkeeper gloves from the player's hands.",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end

        local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
        local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

        if leftHand then
            local leftGlove = leftHand:FindFirstChild("GKGloveLeft")
            if leftGlove then
                leftGlove:Destroy()
            end
        end

        if rightHand then
            local rightGlove = rightHand:FindFirstChild("GKGloveRight")
            if rightGlove then
                rightGlove:Destroy()
            end
        end

        print("GK Gloves removed.")
    end
})

local OPTab = Window:AddTab({ Title = "OP", Icon = "bolt" })

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ball = Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("Football")
local gravityPart = Workspace:FindFirstChild("GravityPart")

local ballPredictorEnabled = false
local lagBallEnabled = false
local lagBallKeybind = Enum.KeyCode.L
local ballGravityValue = 196.2
local gravityStrength = 50
local goalBarrierEnabled = false
local barrierPart = nil

local function isPlayerGK()
    local team = LocalPlayer.Team
    if not team then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    if team.Name == "HomeGK" or team.Name == "AwayGK" then
        return true
    end
    local role = LocalPlayer:FindFirstChild("Role")
    if role and role.Value == "GK" then return true end

    return false
end


local lastBallPos = nil
local ballVelocity = Vector3.new()

RunService.Heartbeat:Connect(function()
    if ballPredictorEnabled and ball then
        if lastBallPos then
            ballVelocity = (ball.Position - lastBallPos) / RunService.Heartbeat:Wait()
        end
        lastBallPos = ball.Position
        local predictedPos = ball.Position + ballVelocity * 0.1
        print("Predicted Ball Position:", predictedPos)
    else
        lastBallPos = nil
    end
end)


local lagBallConnection = nil

local function startLagBall()
    if lagBallConnection then return end
    lagBallConnection = RunService.Heartbeat:Connect(function()
        if lagBallEnabled and ball then
            local offset = Vector3.new(
                math.sin(tick()*10)*0.5,
                math.cos(tick()*10)*0.5,
                math.sin(tick()*15)*0.5
            )
            ball.CFrame = ball.CFrame * CFrame.new(offset)
        end
    end)
end

local function stopLagBall()
    if lagBallConnection then
        lagBallConnection:Disconnect()
        lagBallConnection = nil
    end
end

OPTab:AddSlider({
    Title = "Gravity Strength",
    Description = "Change overall game gravity (0-75).",
    Min = 0,
    Max = 75,
    Default = gravityStrength,
    Callback = function(value)
        gravityStrength = value
        workspace.Gravity = gravityStrength
        print("Game gravity set to", gravityStrength)
    end
})

local ballGravityInput = nil
OPTab:AddTextbox({
    Title = "Ball Gravity",
    Description = "Set gravity on the ball (example 9.8).",
    Placeholder = tostring(ballGravityValue),
    Callback = function(text)
        local num = tonumber(text)
        if num and ball then
            ball.AssemblyLinearVelocity = Vector3.new(ball.AssemblyLinearVelocity.X, ball.AssemblyLinearVelocity.Y - (num - workspace.Gravity), ball.AssemblyLinearVelocity.Z)
            ballGravityValue = num
            print("Ball gravity adjusted to", num)
        else
            warn("Invalid ball gravity value or ball not found.")
        end
    end
})

OPTab:AddToggle({
    Title = "Ball Predictor",
    Description = "Predict where the ball is going next.",
    Default = false,
    Callback = function(value)
        ballPredictorEnabled = value
        print("Ball Predictor set to", value)
    end
})

OPTab:AddToggle({
    Title = "Lag Ball",
    Description = "Apply lag effect to the ball.",
    Default = false,
    Callback = function(value)
        lagBallEnabled = value
        if value then
            startLagBall()
        else
            stopLagBall()
        end
        print("Lag Ball set to", value)
    end
})

local keybindCode = lagBallKeybind
local function setKeybindFromText(keyName)
    local success, keyEnum = pcall(function()
        return Enum.KeyCode[keyName]
    end)
    if success and keyEnum then
        keybindCode = keyEnum
        print("Lag Ball keybind set to", keyName)
    else
        warn("Invalid key name for keybind")
    end
end

OPTab:AddTextbox({
    Title = "Keybind (Lag Ball)",
    Description = "Press a key name to set the lag ball toggle key.",
    Placeholder = keybindCode.Name,
    Callback = function(text)
        setKeybindFromText(text)
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == keybindCode then
            lagBallEnabled = not lagBallEnabled
            if lagBallEnabled then
                startLagBall()
            else
                stopLagBall()
            end
            print("Lag Ball toggled via keybind:", lagBallEnabled)
        end
    end
end)

OPTab:AddToggle({
    Title = "Goal Barrier",
    Description = "Places a barrier in the goal to block ball if GK.",
    Default = false,
    Callback = function(value)
        if value then
            if isPlayerGK() then
                if not barrierPart then
                    barrierPart = Instance.new("Part")
                    barrierPart.Name = "GoalBarrier"
                    barrierPart.Anchored = true
                    barrierPart.CanCollide = true
                    barrierPart.Size = Vector3.new(10, 10, 1)
                    barrierPart.Transparency = 0.5
                    barrierPart.Color = Color3.new(0, 0, 1)
                    barrierPart.CFrame = workspace.Goal and workspace.Goal.CFrame or CFrame.new(0, 5, 0)
                    barrierPart.Parent = workspace
                end
                barrierPart.Transparency = 0.5
                barrierPart.CanCollide = true
                print("Goal Barrier enabled.")
            else
                warn("You must be a GK to enable the goal barrier.")
                OPTab:SetToggleValue("Goal Barrier", false)
            end
        else
            if barrierPart then
                barrierPart.Transparency = 1
                barrierPart.CanCollide = false
                print("Goal Barrier disabled.")
            end
        end
    end
})

local miscTab = Window:AddTab({ Title = "???", Icon = "question" })

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ball = Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("FootballNew") or Workspace:FindFirstChild("Football")
local camera = Workspace.CurrentCamera

local maxPower = 400
local maxHeight = 10
local maxDistance = 100

local telekinesisV2Enabled = false
local lockTargetEnabled = false
local magnetModeEnabled = false
local draggingObject = nil

local shootPassCategory = miscTab:AddCategory("Shooting and Passing")

local maxPowerTextbox = shootPassCategory:AddTextbox({
    Title = "Max Power",
    Description = "Set max shot power (default 400).",
    Default = tostring(maxPower),
    Placeholder = "400",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            maxPower = num
            print("Max shot power set to:", maxPower)
        else
            warn("Invalid max power value.")
        end
    end
})

local maxHeightTextbox = shootPassCategory:AddTextbox({
    Title = "Max Height",
    Description = "Set max ball height for pass/shot (default 10).",
    Default = tostring(maxHeight),
    Placeholder = "10",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            maxHeight = num
            print("Max ball height set to:", maxHeight)
        else
            warn("Invalid max height value.")
        end
    end
})

local maxDistanceTextbox = shootPassCategory:AddTextbox({
    Title = "Max Distance",
    Description = "Set max ball distance (example: 100).",
    Default = tostring(maxDistance),
    Placeholder = "100",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            maxDistance = num
            print("Max ball distance set to:", maxDistance)
        else
            warn("Invalid max distance value.")
        end
    end
})

local telekinesisCategory = miscTab:AddCategory("Telekinesis Controls")

telekinesisCategory:AddToggle({
    Title = "Telekinesis V2",
    Description = "Move unanchored objects with your cursor.",
    Default = false,
    Callback = function(value)
        telekinesisV2Enabled = value
        if not value and draggingObject then
            draggingObject = nil
        end
        print("Telekinesis V2:", value)
    end
})

telekinesisCategory:AddToggle({
    Title = "Lock Target",
    Description = "Lock the ball aiming to FootballNew.",
    Default = false,
    Callback = function(value)
        lockTargetEnabled = value
        print("Lock Target:", value)
    end
})

telekinesisCategory:AddToggle({
    Title = "Magnet Mode",
    Description = "Attract ball to player's leg, even if kicked far.",
    Default = false,
    Callback = function(value)
        magnetModeEnabled = value
        print("Magnet Mode:", value)
    end
})

local magnetControlsCategory = miscTab:AddCategory("Magnet Controls")

magnetControlsCategory:AddButton({
    Title = "Enable Magnet Mode",
    Description = "Enable the magnet mode.",
    Callback = function()
        magnetModeEnabled = true
        print("Magnet Mode enabled (via button)")
    end
})

magnetControlsCategory:AddButton({
    Title = "Disable Magnet Mode",
    Description = "Disable the magnet mode.",
    Callback = function()
        magnetModeEnabled = false
        print("Magnet Mode disabled (via button)")
    end
})

local applySettingsCategory = miscTab:AddCategory("Apply Settings")

applySettingsCategory:AddButton({
    Title = "Apply Max Power",
    Description = "Apply the max power from the textbox.",
    Callback = function()
        print("Applied Max Power:", maxPower)
        setShotPower(maxPower)
    end
})

applySettingsCategory:AddButton({
    Title = "Apply Max Height",
    Description = "Apply the max height from the textbox.",
    Callback = function()
        print("Applied Max Height:", maxHeight)
        setBallHeight(maxHeight)
    end
})

applySettingsCategory:AddButton({
    Title = "Apply Max Distance",
    Description = "Apply the max distance from the textbox.",
    Callback = function()
        print("Applied Max Distance:", maxDistance)
        setBallMaxDistance(maxDistance)
    end
})

applySettingsCategory:AddButton({
    Title = "Extra Button 1",
    Description = "Custom function here.",
    Callback = function()
        print("Extra Button 1 pressed")
    end
})

applySettingsCategory:AddButton({
    Title = "Extra Button 2",
    Description = "Custom function here.",
    Callback = function()
        print("Extra Button 2 pressed")
    end
})

local function getPlayerLegPosition()
    local char = LocalPlayer.Character
    if not char then return nil end
    local leg = char:FindFirstChild("RightFoot") or char:FindFirstChild("RightBoot") or char:FindFirstChild("RightLeg")
    if not leg then
        leg = char:FindFirstChild("LeftFoot") or char:FindFirstChild("LeftBoot") or char:FindFirstChild("LeftLeg")
    end
    if leg and leg:IsA("BasePart") then
        return leg.Position
    end
    return nil
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if telekinesisV2Enabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
        if raycastResult and raycastResult.Instance and not raycastResult.Instance.Anchored then
            draggingObject = raycastResult.Instance
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if telekinesisV2Enabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingObject = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if telekinesisV2Enabled and draggingObject then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
        if ray then
            draggingObject.CFrame = CFrame.new(ray.Origin + ray.Direction * 10)
        end
    end

    if lockTargetEnabled and ball and ball.Parent then
        local footballNew = Workspace:FindFirstChild("FootballNew")
        if footballNew then
            ball.CFrame = CFrame.new(ball.Position, footballNew.Position)
        end
    end

    if magnetModeEnabled and ball and ball.Parent then
        local legPos = getPlayerLegPosition()
        if legPos then
            local dist = (ball.Position - legPos).Magnitude
            local forceDir = (legPos - ball.Position).Unit
            if dist > 0 then
                local newPos = ball.Position + forceDir * math.min(dist, 1) * 10 * RunService.Heartbeat:Wait()
                ball.CFrame = CFrame.new(newPos)
            end
        end
    end
end)

local autoGoalEnabled = false
local autoGoalTarget = "GoalPost"
local curvePower = 0
local knucklePower = 0
local powershotPower = 0
local function autoGoalShoot(ball)
    if not autoGoalEnabled or not ball then return end
    local goal = workspace:FindFirstChild(autoGoalTarget)
    if goal and goal:IsA("BasePart") then
        local direction = (goal.Position - ball.Position).Unit
        ball.AssemblyLinearVelocity = direction * 150
    end
end

MainTab:AddToggle("AutoGoal", {
    Title = "Auto Goal",
    Default = false,
    Callback = function(state)
        autoGoalEnabled = state
    end
})

MainTab:AddSlider("CurvePower", {
    Title = "Curve Power",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        curvePower = value
    end
})

MainTab:AddSlider("KnucklePower", {
    Title = "Knuckleball Power",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 1,

local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local function getBall()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" then
            return obj
        end
    end
end

local function isUsingBallCam()
    return UserInputService:IsKeyDown(Enum.KeyCode.Backspace)
end

local function telekinesis()
    local ball = getBall()
    if not ball then return end

    local char = LocalPlayer.Character
    if char and not char:FindFirstChildOfClass("Tool") and isUsingBallCam() then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local dir = ray.Direction
        ball.AssemblyLinearVelocity = dir.Unit * 100
    end
end

OptTab:AddButton({
    Title = "Telekinesis Ball",
    Description = "Use ball cam and aim with mouse (no tools equipped)",
    Callback = function()
        telekinesis()
    end
})

    Callback = function(value)
        knucklePower = value
    end
})

MainTab:AddSlider("PowershotPower", {
    Title = "Powershot Power",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        powershotPower = value
    end
})


Window:AddTab({ Title = "Game", Icon = "gamepad-2" })
Window:AddTab({ Title = "Character", Icon = "user" })
Window:AddTab({ Title = "Teams", Icon = "users" })
Window:AddTab({ Title = "Troll", Icon = "zap" })
Window:AddTab({ Title = "OP", Icon = "shield-half" })
Window:AddTab({ Title = "???", Icon = "help-circle" })
Window:AddTab({ Title = "Extra", Icon = "sparkles" })
Window:AddTab({ Title = "Settings", Icon = "settings-2" })
