


-- some necessary definations
getgenv().jaidenConnection = {}
local plr = game.Players
local lp = plr.LocalPlayer
local character = lp.Character
local lpName = lp.Name
local parryButton = game:GetService("ReplicatedStorage").Remotes.ParryButtonPress
local parryButton_2 = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ParryAttempt")

-- path
local alive = game.Workspace.Alive
local dead = game.Workspace.Dead
local ballFolder = game.Workspace.Balls

-- changing variables
local ballTarget = ballFolder:GetChildren()[1]:GetAttribute("target") or ""
local maxVelocity = 0
local visualSize = 0
local is_spam_needed = false

local ball


local function isParried(ball)
        local vectorToMe = (character.HumanoidRootPart.Position - ball.Position)
        local Distance = vectorToMe.Magnitude

        local Direction = vectorToMe.Unit
        local Speed = ball.Velocity:Dot(Direction)
        if Speed <= 0 then return 9e9 end
        return ((Distance - 30) / Speed)
end
local function parry()
    local stuffs = {}
    for i, v in pairs(plr:GetPlayers()) do
        if not v ~= plr.LocalPlayer then
            if v.Character then
                if v.Character:FindFirstChild("HumanoidRootPart") then
                    stuffs[tostring(v.UserId)] = game.workspace.CurrentCamera:WorldToScreenPoint(v.Character.PrimaryPart.Position)
                end
            end
        end
    end
    parryButton_2:FireServer("NaN", game.workspace.CurrentCamera.CFrame, stuffs, {
        game.workspace.CurrentCamera.ViewportSize.X / 2,
        game.workspace.CurrentCamera.ViewportSize.Y / 2
    })
end

local function createVisual()
    local part = Instance.new("Part", game.Workspace)
    local Size = Vector3.new(0.1, 0.1, 0.1)
    part.Name = "Jaiden's Visual"
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Size = Size
    part.Material = Enum.Material.ForceField
    part.Shape = Enum.PartType.Ball
    part.CastShadow = false
    return part
end



-- script
local visualPart
visualPart = createVisual()


repeat
    wait()
until ballFolder:GetChildren()[1] ~= nil

ball = ballFolder:GetChildren()[1]



getgenv().jaidenConnection.lpEvent = game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar

    for i, v in pairs(game.Workspace:GetChildren()) do
        if v.Name == "Jaiden's Visual" then
            v:Destroy()
        end
    end

    visualPart = createVisual()
end)

getgenv().jaidenConnection.ballSpawned = ballFolder.ChildAdded:Connect(function()
    ballFolder:GetChildren()[1]:GetAttributeChangedSignal('target'):Connect(function()
        ballTarget = ballFolder:GetChildren()[1]:GetAttribute('target')
        if ballTarget == lpName then
            local timeToImpact = isParried(ballFolder:GetChildren()[1])
            if timeToImpact < 0.7 then
                print("close detected")
                if timeToImpact < 0.17 or (character.HumanoidRootPart.Position - ball.Position).Magnitude < 20 then
                    is_spam_needed = true
                    print(is_spam_needed)
                else
                    is_spam_needed = false
                    print(is_spam_needed)
                end
                parryButton:Fire()
            end
        else
            if (character.HumanoidRootPart.Position - ball.Position).Magnitude > 20 then
                is_spam_needed = false
            end
        end
    end)
end)
getgenv().jaidenConnection.ballRemoved = ballFolder.ChildRemoved:Connect(function()
    is_spam_needed = false
end)





getgenv().jaidenConnection.heartBeat = game:GetService('RunService').Heartbeat:Connect(function()
    ball = ballFolder:GetChildren()[1]

    if ball then
        if is_spam_needed then
            parry()
            parryButton:Fire()
        end
        visualPart.Size = Vector3.new(maxVelocity / 6, maxVelocity / 6, maxVelocity / 6)
        visualPart.Position = character.HumanoidRootPart.Position
        if character:FindFirstChild("Highlight") then
            if (character.HumanoidRootPart.Position - ball.Position).Magnitude <= ball.Velocity.Magnitude then
                if isParried(ball) < 0.16 then
                    parryButton:Fire()
                end
            end
        end
    end
end)
--[[
    loadstring(game:HttpGet("https://clipboard.strebel.xyz/lzqu0"))()
]]
