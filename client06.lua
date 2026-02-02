-- 2015 / 2016 Client Recreation, been looking for one of these for 2 months to be exact but could not find any topbar script
-- so what ever "sane" human being would do RECREATE it from scrath, and as you are thinking.. it damn includes the old topbar and settings too!

-- Services --

local Players = game:GetService("Players")

-- Here you can edit the config as many as you like if you dant want speedbasedfootsteps disable it! thats it.

local Config = {
	SpeedBasedFootsteps = true -- Mid 2016 idk maybe it is? this just makes the sound pitch go fast or slow based on the local character speed. (THIS APPLY TO ALL PLAYERS!) --
}

-- Main Script ( if you want to edit some things here it is :D ) --

----(SOUND)----

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