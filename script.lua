-- LocalScript: StarterPlayer > StarterCharacterScripts
-- Locks your character in place while playing the run animation.
-- Toggle with a key (default: X). Set AUTO_LOCK_ON_SPAWN = true to lock instantly on spawn.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- ===== Settings =====
local AUTO_LOCK_ON_SPAWN = true   -- true = locked immediately when you spawn
local TOGGLE_KEY = Enum.KeyCode.X -- key to toggle lock on/off
-- ====================

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local animator = humanoid:WaitForChild("Animator")

local locked = false
local runTrack = nil

-- Grab the run animation from the default Animate script
local animate = character:WaitForChild("Animate")
local runAnim = animate:WaitForChild("run"):WaitForChild("RunAnim")
runTrack = animator:LoadAnimation(runAnim)
runTrack.Priority = Enum.AnimationPriority.Movement
runTrack.Looped = true

local function setLock(state)
	locked = state

	if locked then
		-- Anchor the root: character can't move, fall, or get pushed
		rootPart.Anchored = true
		humanoid.AutoRotate = false -- can't turn either
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0

		-- Force the run animation to keep playing while standing still
		if not runTrack.IsPlaying then
			runTrack:Play(0.1)
		end
	else
		rootPart.Anchored = false
		humanoid.AutoRotate = true
		humanoid.JumpHeight = 7.2 -- default jump height (adjust if your game uses JumpPower)
		if runTrack.IsPlaying then
			runTrack:Stop(0.1)
		end
	end
end

-- Key toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == TOGGLE_KEY then
		setLock(not locked)
	end
end)

-- Auto-lock on spawn
if AUTO_LOCK_ON_SPAWN then
	setLock(true)
end

-- Re-apply lock if character resets/respawns while the flag is set
humanoid.Died:Connect(function()
	setLock(false)
end)
