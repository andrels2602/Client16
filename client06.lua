--[[
  ______  __       __   _______ .__   __. .___________..___  ___.  __   _______  
 /      ||  |     |  | |   ____||  \ |  | |           ||   \/   | |  | |       \ 
|  ,----'|  |     |  | |  |__   |   \|  | `---|  |----`|  \  /  | |  | |  .--.  |
|  |     |  |     |  | |   __|  |  . `  |     |  |     |  |\/|  | |  | |  |  |  |
|  `----.|  `----.|  | |  |____ |  |\   |     |  |     |  |  |  | |  | |  '--'  |
 \______||_______||__| |_______||__| \__|     |__|     |__|  |__| |__| |_______/        -- a 2015 / 2016 Client Recreation for executors!
                                                                                 
--]]

-- DESC:

-- clientMid is a 2015 / 2016 Client Recreation, been looking for one of these for 2 months to be exact but could not find any topbar script
-- so what ever "sane" human being would do RECREATE it from scrath, and as you are thinking.. it damn includes the old topbar and settingsShield too!

--------END OF DESC--------

-- Services --

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- Others --

local Player = Players.LocalPlayer

--COREUI removal stuff --

repeat task.wait() until game:IsLoaded()

local function kill()
	for _, v in ipairs(CoreGui:GetChildren()) do
		if v.Name == "TopBarApp" or v.Name == "PlayerList" then
			pcall(function()
				v:Destroy()
			end)
		end
	end
end

kill()

CoreGui.ChildAdded:Connect(function(v)
	if v.Name == "TopBarApp" or v.Name == "PlayerList" then
		task.wait()
		pcall(function()
			v:Destroy()
		end)
	end
end)

-- Here you can edit the config as many as you like if you dant want speedbasedfootsteps disable it! thats it.

local Config = {
	SpeedBasedFootsteps = false, -- Mid 2016 idk maybe it is? this just makes the sound pitch go fast or slow based on the local character speed. (THIS APPLY TO ALL PLAYERS!) --
	-- only use one time! this. like if you dont want it just put FALSE if you want it put TRUE
	UiVersion = 2016, -- this is your choice to choose the year and it changes the coregui version.
	-- Versions (BETA) : {2015, 2016} (put exatcly like it says here choose one!)
    Plataform = "Xbox", -- this is a custom approach if you want to use like if it was a "Emulator".
	-- Versions : {Xbox, PC, Mobile} (put exatcly like it says here choose one!)

	-- [TopbarConstants] --

	TOPBAR_DISABLED_MODE = "Custom",
	-- Modes : {Custom, Automatic} (put exatcly like it says here choose one!)

	HEALTH_DISABLED = false,     --/
	PLAYERLIST_DISABLED = true, --|
	CHAT_DISABLED = false,      --| All of this only works if you set to custom!
	BACKPACK_DISABLED = true,   --|
                                --\
    -- Properties

	HEALTH_RED_COLOR = Color3.new(1, 28/255, 0),
    HEALTH_YELLOW_COLOR = Color3.new(250/255, 235/255, 0),
    HEALTH_GREEN_COLOR = Color3.new(27/255, 252/255, 107/255)
}

-- Main Script ( if you want to edit some things here it is :D ) --

---- [SOUND] ----

local TAG = "Footstep"

local function waitForChild(parent, childName)
	local child = parent:FindFirstChild(childName)
	if child then return child end
	while true do
		child = parent.ChildAdded:Wait()
		if child.Name == childName then return child end
	end
end

local function newSound(parent, name, id)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Name = name
	sound.Archivable = false
	sound:SetAttribute(TAG, true)
	sound.Parent = parent
	return sound
end

local function removeAllSounds(character)
	for _, obj in pairs(character:GetDescendants()) do
		if obj:IsA("Sound") then
			if not obj:GetAttribute(TAG) then
				if obj.Name == "Running" or obj.Name == "Footstep" then
					obj:Stop()
					obj:Destroy()
				end
			end
		end
	end
end

local function setupSounds(character)
	task.wait(0.2)
	removeAllSounds(character)

	character.DescendantAdded:Connect(function(obj)
		if obj:IsA("Sound") then
			if not obj:GetAttribute(TAG) then
				if obj.Name == "Running" or obj.Name == "Footstep" then
					task.wait()
					obj:Stop()
					obj:Destroy()
				end
			end
		end
	end)

	local head = waitForChild(character, "Head")
	local humanoid = waitForChild(character, "Humanoid")

-- Edit the Id's here!

	local sGettingUp = newSound(head, "GettingUp", "rbxasset://sounds/action_get_up.mp3")
	local sDied = newSound(head, "Died", "rbxassetid://1237557124")
	local sFreeFalling = newSound(head, "FreeFalling", "rbxasset://sounds/action_falling.mp3")
	local sJumping = newSound(head, "Jumping", "rbxasset://sounds/action_jump.mp3")
	local sLanding = newSound(head, "Landing", "rbxasset://sounds/action_jump_land.mp3")
	local sSplash = newSound(head, "Splash", "rbxasset://sounds/impact_water.mp3")

	local sRunning = newSound(head, "Running", "rbxasset://sounds/action_footsteps_plastic.mp3")
	sRunning.Looped = true

	local sSwimming = newSound(head, "Swimming", "rbxasset://sounds/action_swim.mp3")
	sSwimming.Looped = true

	local sClimbing = newSound(head, "Climbing", "rbxasset://sounds/action_footsteps_plastic.mp3")
	sClimbing.Looped = true

	local prevState = "None"
	local fallSpeed = 0

	local function stopLooped()
		sRunning:Stop()
		sClimbing:Stop()
		sSwimming:Stop()
	end

	humanoid.Died:Connect(function()
		stopLooped()
		sDied:Play()
	end)

-- Main pitch part.

	humanoid.Running:Connect(function(speed)
		sClimbing:Stop()
		sSwimming:Stop()

		if prevState == "FreeFall" and fallSpeed > 0.1 then
			sLanding.Volume = math.min(1, math.max(0, (fallSpeed - 50) / 110))
			sLanding:Play()
			fallSpeed = 0
		end

		if speed > 0.5 then
			if not sRunning.IsPlaying then
				sRunning:Play()
			end
			sRunning.Pitch = speed / 8
		else
			sRunning:Stop()
		end

		prevState = "Run"
	end)

	humanoid.Swimming:Connect(function(speed)
		if prevState ~= "Swim" and speed > 0.1 then
			sSplash.Volume = math.min(1, speed / 350)
			sSplash:Play()
		end
		sRunning:Stop()
		sClimbing:Stop()
		sSwimming.Pitch = 1.6
		sSwimming:Play()
		prevState = "Swim"
	end)

	humanoid.Climbing:Connect(function(speed)
		sRunning:Stop()
		sSwimming:Stop()
		if speed > 0.01 then
			sClimbing:Play()
			sClimbing.Pitch = speed / 5.5
		else
			sClimbing:Stop()
		end
		prevState = "Climb"
	end)

	humanoid.Jumping:Connect(function()
		sJumping:Play()
		prevState = "Jump"
	end)

	humanoid.GettingUp:Connect(function(state)
		stopLooped()
		if state then sGettingUp:Play() end
		prevState = "GetUp"
	end)

	humanoid.FreeFalling:Connect(function(state)
		stopLooped()
		if state then
			sFreeFalling:Play()
		else
			sFreeFalling:Stop()
		end
		fallSpeed = math.max(fallSpeed, math.abs(head.Velocity.Y))
		prevState = "FreeFall"
	end)
end

local function onPlayer(player)
	if player.Character then
		setupSounds(player.Character)
	end
	player.CharacterAdded:Connect(setupSounds)
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayer(player)
end

Players.PlayerAdded:Connect(onPlayer)

---- [COREUI] ----
if Config.Plataform == "Xbox" then
	for _, gui in ipairs(Player.PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			gui.IgnoreGuiInset = true
		end
	end
	Player.PlayerGui.ChildAdded:Connect(function(gui)
		if gui:IsA("ScreenGui") then
			gui.IgnoreGuiInset = true
		end
	end)

	if not Config.HEALTH_DISABLED then
		local healthColorToPosition = {
			[Vector3.new(Config.HEALTH_RED_COLOR.R, Config.HEALTH_RED_COLOR.G, Config.HEALTH_RED_COLOR.B)] = 0.1,
			[Vector3.new(Config.HEALTH_YELLOW_COLOR.R, Config.HEALTH_YELLOW_COLOR.G, Config.HEALTH_YELLOW_COLOR.B)] = 0.5,
			[Vector3.new(Config.HEALTH_GREEN_COLOR.R, Config.HEALTH_GREEN_COLOR.G, Config.HEALTH_GREEN_COLOR.B)] = 0.8,
		}

		local function HealthbarColorTransferFunction(p)
			if p < 0.1 then return Config.HEALTH_RED_COLOR end
			if p > 0.8 then return Config.HEALTH_GREEN_COLOR end
			local n = Vector3.new(0, 0, 0)
			local d = 0
			for c, pos in pairs(healthColorToPosition) do
				local diff = p - pos
				if diff == 0 then
					return Color3.new(c.X, c.Y, c.Z)
				end
				local w = 1 / (diff * diff)
				n = n + (w * c)
				d = d + w
			end
			local r = n / d
			return Color3.new(r.X, r.Y, r.Z)
		end

		local Gui = Instance.new("ScreenGui")
		Gui.Name = "CoreGui"
		Gui.IgnoreGuiInset = true
		Gui.DisplayOrder = 1000
		Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		Gui.Parent = CoreGui

		local Xbox = Instance.new("Frame")
		Xbox.Name = "Xbox"
		Xbox.BackgroundTransparency = 1
		Xbox.Size = UDim2.new(1, 0, 1, 0)
		Xbox.Parent = Gui

		local TopRightContainer = Instance.new("ImageButton")
		TopRightContainer.Name = "TopRightContainer"
		TopRightContainer.Active = false
		TopRightContainer.BackgroundTransparency = 1
		TopRightContainer.Position = UDim2.new(1, -360, 0, 10)
		TopRightContainer.Selectable = false
		TopRightContainer.Size = UDim2.new(0, 350, 0, 100)
		TopRightContainer.AutoButtonColor = false
		TopRightContainer.Parent = Xbox

		local HealthContainer = Instance.new("Frame")
		HealthContainer.Name = "HealthContainer"
		HealthContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		HealthContainer.BackgroundTransparency = 0.5
		HealthContainer.BorderSizePixel = 0
		HealthContainer.Position = UDim2.new(0, 92, 0, 0)
		HealthContainer.Size = UDim2.new(1, -86, 0, 50)
		HealthContainer.Parent = TopRightContainer

		local HealthFillHolder = Instance.new("Frame")
		HealthFillHolder.Name = "HealthFillHolder"
		HealthFillHolder.BackgroundTransparency = 1
		HealthFillHolder.BorderSizePixel = 0
		HealthFillHolder.Position = UDim2.new(0, 5, 0, 5)
		HealthFillHolder.Size = UDim2.new(1, -10, 1, -10)
		HealthFillHolder.Parent = HealthContainer

		local HealthFill = Instance.new("Frame")
		HealthFill.Name = "HealthFill"
		HealthFill.BackgroundColor3 = Color3.fromRGB(27, 252, 107)
		HealthFill.BorderSizePixel = 0
		HealthFill.Size = UDim2.new(1, 0, 1, 0)
		HealthFill.Parent = HealthFillHolder

		local HealthText = Instance.new("TextLabel")
		HealthText.Name = "HealthText"
		HealthText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		HealthText.BackgroundTransparency = 0.5
		HealthText.BorderSizePixel = 0
		HealthText.Position = UDim2.new(0, -100, 0, 0)
		HealthText.Size = UDim2.new(0, 98, 0, 50)
		HealthText.Font = Enum.Font.SourceSans
		HealthText.Text = "Health"
		HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
		HealthText.TextSize = 36
		HealthText.Parent = HealthContainer

		local function Visibility()
			HealthContainer.Visible = not Config.HEALTH_DISABLED
		end

		local function UpdateHealth(humanoid)
			if humanoid.MaxHealth <= 0 then return end
			local percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			HealthFill.Size = UDim2.new(percent, 0, 1, 0)
			HealthFill.BackgroundColor3 = HealthbarColorTransferFunction(percent)
		end

		local function BindHumanoid(humanoid)
			repeat task.wait() until humanoid.MaxHealth > 0
			UpdateHealth(humanoid)
			humanoid.HealthChanged:Connect(function() UpdateHealth(humanoid) end)
			humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function() UpdateHealth(humanoid) end)
		end

		local function OnCharacterAdded(character)
			HealthFill.Size = UDim2.new(1, 0, 1, 0)
			HealthFill.BackgroundColor3 = Config.HEALTH_GREEN_COLOR
			local humanoid = character:WaitForChild("Humanoid")
			BindHumanoid(humanoid)
		end

		Visibility()

		if Player.Character then
			OnCharacterAdded(Player.Character)
		end
		Player.CharacterAdded:Connect(OnCharacterAdded)
	end
end
