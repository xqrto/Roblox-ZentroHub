-- ================= ZENTRO FLY FIXED (NO AUTO-FORWARD) =================

if _G.ZentroFlyCleanup then
	_G.ZentroFlyCleanup()
	_G.ZentroFlyCleanup = nil
	_G.ZentroFlyActive = false
	return
end

_G.ZentroFlyActive = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera

if not _G.flyspeed then _G.flyspeed = 40 end
local flying = true
local vertical = 0 -- Swipe Up/Down

if not _G.fakemove then _G.fakemove = Vector3.zero end

-- BODY MOVERS
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1e9,1e9,1e9)
bv.Velocity = Vector3.zero
bv.Parent = hrp

local bg = Instance.new("BodyGyro")
bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
bg.P = 1e4
bg.CFrame = hrp.CFrame
bg.Parent = hrp

-- MOBILE SWIPE UP/DOWN
local touchStartY = nil
UIS.TouchStarted:Connect(function(input)
	touchStartY = input.Position.Y
end)
UIS.TouchEnded:Connect(function(input)
	if touchStartY then
		local delta = input.Position.Y - touchStartY
		if math.abs(delta) > 20 then
			vertical = -delta/50
		end
		touchStartY = nil
	end
end)

-- FLY LOOP
local flyConn
flyConn = RunService.RenderStepped:Connect(function()
	if not flying then return end
	bg.CFrame = cam.CFrame

	local dir = _G.fakemove

	-- Nur fliegen, wenn fakemove ≠ 0 oder vertical ≠ 0
	if dir.Magnitude > 0 or vertical ~= 0 then
		-- Kamera-relative Bewegung X/Z
		local move = Vector3.zero
		if dir.Magnitude > 0 then
			move = (cam.CFrame.LookVector * dir.Z + cam.CFrame.RightVector * dir.X)
			if move.Magnitude > 0 then move = move.Unit end
		end

		-- Y aus Swipe
		move = move + Vector3.new(0, vertical, 0)

		-- Geschwindigkeit
		bv.Velocity = move * _G.flyspeed
	else
		bv.Velocity = Vector3.zero
	end

	vertical = 0
end)

-- CLEANUP
_G.ZentroFlyCleanup = function()
	flying = false
	if flyConn then flyConn:Disconnect() end
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end
