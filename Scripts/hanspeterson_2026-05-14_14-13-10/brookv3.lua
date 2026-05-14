-- ╔══════════════════════════════════════════════════════╗
-- ║         CouchPanel v3  –  LocalScript               ║
-- ║   In StarterPlayerScripts oder StarterGui einfügen  ║
-- ╚══════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp   = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local hum  = char:WaitForChild("Humanoid")

lp.CharacterAdded:Connect(function(c)
	char = c
	hrp  = c:WaitForChild("HumanoidRootPart")
	hum  = c:WaitForChild("Humanoid")
end)

-- ══════════════════════════════════════════
--  CAMERA LOCK
-- ══════════════════════════════════════════
local cam       = workspace.CurrentCamera
local camLocked = false

local function lockCamera()
	if camLocked then return end
	camLocked = true
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame     = cam.CFrame
end

local function unlockCamera()
	if not camLocked then return end
	camLocked = false
	cam.CameraType = Enum.CameraType.Custom
end

-- ══════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════
local targetPlayer  = nil
local targetPlayer2 = nil
local startPos      = nil
local isRunning     = false
local isLaunching   = false
local orbitConn     = nil
local orbitAngle    = 0

local ORBIT_RADIUS_START = 4.5
local ORBIT_SPEED_START  = 1.2
local ORBIT_RADIUS_MIN   = 0.4
local ORBIT_SPEED_MAX    = 6.0
local ORBIT_SHRINK_RATE  = 1.5
local ORBIT_ACCEL        = 1.8
local UNDERGROUND        = 3

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local function getCouch()
	local bp = lp:FindFirstChild("Backpack")
	if bp then local t = bp:FindFirstChild("Couch"); if t then return t end end
	if char then local t = char:FindFirstChild("Couch"); if t then return t end end
	return nil
end

local function hasCouchInInventory()
	return getCouch() ~= nil
end

local function equipCouch()
	local c = getCouch()
	if not c then return false end
	if c.Parent ~= char then
		c.Parent = lp.Backpack
		hum:EquipTool(c)
	end
	return true
end

local function unequipCouch()
	if char and char:FindFirstChild("Couch") then hum:UnequipTools() end
end

-- FIX: Destroy() statt workspace-reparent – Game trackt destroyed Tools nicht mehr
local function removeCouch()
	-- Erst aus Hand
	if char then
		local t = char:FindFirstChild("Couch")
		if t then
			hum:UnequipTools()
			task.wait(0.05)
			t:Destroy()
			return  -- fertig, nicht nochmal im Backpack suchen
		end
	end
	-- Dann aus Backpack
	local bp = lp:FindFirstChild("Backpack")
	if bp then
		local t = bp:FindFirstChild("Couch")
		if t then t:Destroy() end
	end
end

local function safeTeleport(cf)
	lockCamera()
	hrp.CFrame = cf
end

local function holdAt(cf, duration, cb)
	safeTeleport(cf)
	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = Vector3.new(0,0,0)
	bv.MaxForce  = Vector3.new(1e9,1e9,1e9)
	bv.P         = 1e9
	bv.Parent    = hrp
	task.delay(duration, function()
		bv:Destroy()
		unlockCamera()
		if cb then cb() end
	end)
end

local function isGrounded()
	return math.abs(hrp.AssemblyLinearVelocity.Y) < 4
end

local function isSitting(p)
	local c = p and p.Character; if not c then return false end
	local h = c:FindFirstChildOfClass("Humanoid")
	return h and h:GetState() == Enum.HumanoidStateType.Seated
end

local function getTargetHRP(p)
	local c = p and p.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

-- ══════════════════════════════════════════
--  GET COUCH (forward-declare)
-- ══════════════════════════════════════════
local getCouchRunning = false
local doGetCouch

-- ══════════════════════════════════════════
--  ORBIT CORE
-- ══════════════════════════════════════════
local flingBtnRef = nil

local function stopOrbit()
	isRunning   = false
	isLaunching = false
	if orbitConn then orbitConn:Disconnect(); orbitConn = nil end
	unequipCouch()
	unlockCamera()
	if startPos then hrp.CFrame = startPos; startPos = nil end
	if flingBtnRef then
		flingBtnRef.Text             = "▶  FLING"
		flingBtnRef.BackgroundColor3 = Color3.fromRGB(40,100,200)
	end
end

local function startOrbit(target, flingMode)
	if not target then return end
	if not getTargetHRP(target) then return end

	if not hasCouchInInventory() then
		doGetCouch()
		return
	end

	startPos    = hrp.CFrame
	isRunning   = true
	isLaunching = false
	orbitAngle  = 0

	local curRadius = ORBIT_RADIUS_START
	local curSpeed  = ORBIT_SPEED_START

	if not equipCouch() then
		isRunning = false
		doGetCouch()
		return
	end

	if flingBtnRef and flingMode then
		flingBtnRef.Text             = "⏹  STOP"
		flingBtnRef.BackgroundColor3 = Color3.fromRGB(180,50,50)
	end

	task.delay(6, function() if isRunning then stopOrbit() end end)

	orbitConn = RunService.Heartbeat:Connect(function(dt)
		if not isRunning then return end
		local tC = target.Character; if not tC then stopOrbit(); return end
		local tR = tC:FindFirstChild("HumanoidRootPart"); if not tR then stopOrbit(); return end

		if isSitting(target) and not isLaunching then
			isLaunching = true
			isRunning   = false
			if orbitConn then orbitConn:Disconnect(); orbitConn = nil end

			if flingMode then
				-- Seats leeren damit Ziel fliegt
				local couch = getCouch()
				if couch then
					for _, d in ipairs(couch:GetDescendants()) do
						if (d:IsA("Seat") or d:IsA("VehicleSeat")) and d.Occupant then
							local occ = d.Occupant
							if occ then
								occ.Sit    = false
								d.Disabled = true
								task.wait()
								d.Disabled = false
							end
						end
					end
				end

				local savedStart = startPos
				startPos = nil

				-- SCHRITT 1: 1 Sekunde nach oben boosten mit Speed 1000
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(0, -10, 10000)
				bv.MaxForce = Vector3.new(0, 1e9, 1e9)
				bv.P        = 1e9
				bv.Parent   = hrp

				task.wait(2)

				-- SCHRITT 2: Couch unequippen
				bv:Destroy()
				unequipCouch()

				-- SCHRITT 3: Zurück zum Boden TP (Startpos Y-Ebene)
				hrp.CFrame = savedStart

				-- SCHRITT 4: Velocity auf 0 und auf Boden halten
				hrp.AssemblyLinearVelocity  = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero

				local bv2 = Instance.new("BodyVelocity")
				bv2.Velocity = Vector3.zero
				bv2.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bv2.P        = 1e9
				bv2.Parent   = hrp

				task.wait(0.3)
				bv2:Destroy()

				-- SCHRITT 5: Insta-Respawn
				local respawnConn
				respawnConn = lp.CharacterAdded:Connect(function(newChar)
					respawnConn:Disconnect()
					char = newChar
					hrp  = newChar:WaitForChild("HumanoidRootPart")
					hum  = newChar:WaitForChild("Humanoid")

					task.wait(0.15)
					hrp.AssemblyLinearVelocity  = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
					hrp.CFrame = savedStart

					isLaunching = false
					if flingBtnRef then
						flingBtnRef.Text             = "▶  FLING"
						flingBtnRef.BackgroundColor3 = Color3.fromRGB(40,100,200)
					end
				end)

				lp:LoadCharacter()

			else
				-- KILL
				lockCamera()
				safeTeleport(CFrame.new(-9194, -279, -173))
				task.delay(0.3, function()
					unequipCouch()
					task.delay(0.5, function()
						local savedStart = startPos
						holdAt(savedStart, 0.5, function()
							isLaunching = false
							startPos    = nil
						end)
					end)
				end)
			end
			return
		end

		if isLaunching then return end

		curRadius  = math.max(ORBIT_RADIUS_MIN, curRadius - ORBIT_SHRINK_RATE * dt)
		curSpeed   = math.min(ORBIT_SPEED_MAX,  curSpeed  + ORBIT_ACCEL       * dt)
		orbitAngle = orbitAngle + curSpeed * dt

		local bp   = tR.Position
		local nx   = bp.X + math.cos(orbitAngle) * curRadius
		local nz   = bp.Z + math.sin(orbitAngle) * curRadius
		local ny   = bp.Y - UNDERGROUND
		local newP = Vector3.new(nx, ny, nz)
		local fwd  = (Vector3.new(bp.X, ny, bp.Z) - newP).Unit
		hrp.CFrame = CFrame.fromMatrix(newP, fwd, Vector3.new(0,1,0))
		hrp.AssemblyLinearVelocity = Vector3.new(
			hrp.AssemblyLinearVelocity.X, -50, hrp.AssemblyLinearVelocity.Z
		)
	end)
end

-- ══════════════════════════════════════════
--  GET COUCH (Definition)
-- ══════════════════════════════════════════
doGetCouch = function()
	if getCouchRunning then return end
	getCouchRunning = true
	lockCamera()
	local savedPos = hrp.CFrame
	safeTeleport(CFrame.new(-82.6, 22, -129.9))
	task.wait(0.05)
	equipCouch()
	local waited = 0
	local cc
	cc = RunService.Heartbeat:Connect(function(dt)
		waited = waited + dt
		local selfSit = hum:GetState() == Enum.HumanoidStateType.Seated
		if selfSit or waited >= 1.2 then
			cc:Disconnect()
			if selfSit then hum.Sit = false; task.wait(0.1) end
			safeTeleport(savedPos)
			task.wait(0.15)
			unlockCamera()
			getCouchRunning = false
		end
	end)
end

-- ══════════════════════════════════════════
--  ATTRACT
-- ══════════════════════════════════════════
local attractRunning = false
local attractConn    = nil
local attractBtnRef  = nil

local function stopAttract()
	attractRunning = false
	if attractConn then attractConn:Disconnect(); attractConn = nil end
	unequipCouch()
	unlockCamera()
	if attractBtnRef then
		attractBtnRef.Text             = "🧲  ATTRACT"
		attractBtnRef.BackgroundColor3 = Color3.fromRGB(100,55,195)
	end
end

local function startAttract(target)
	if not target then return end
	if not getTargetHRP(target) then return end
	if attractRunning then stopAttract(); return end

	if not hasCouchInInventory() then
		doGetCouch()
		return
	end

	local savedPos = hrp.CFrame
	attractRunning = true
	local orbitAng = 0
	local curR     = ORBIT_RADIUS_START
	local curS     = ORBIT_SPEED_START

	if not equipCouch() then
		attractRunning = false
		doGetCouch()
		return
	end

	if attractBtnRef then
		attractBtnRef.Text             = "⏹  STOP"
		attractBtnRef.BackgroundColor3 = Color3.fromRGB(180,50,50)
	end

	attractConn = RunService.Heartbeat:Connect(function(dt)
		if not attractRunning then return end
		local tC = target.Character; if not tC then stopAttract(); return end
		local tR = tC:FindFirstChild("HumanoidRootPart"); if not tR then stopAttract(); return end

		if isSitting(target) then
			attractRunning = false
			if attractConn then attractConn:Disconnect(); attractConn = nil end

			lockCamera()
			safeTeleport(savedPos)

			task.delay(0.5, function()
				unequipCouch()
				unlockCamera()
				if attractBtnRef then
					attractBtnRef.Text             = "🧲  ATTRACT"
					attractBtnRef.BackgroundColor3 = Color3.fromRGB(100,55,195)
				end
			end)
			return
		end

		curR     = math.max(ORBIT_RADIUS_MIN, curR - ORBIT_SHRINK_RATE * dt)
		curS     = math.min(ORBIT_SPEED_MAX,  curS + ORBIT_ACCEL       * dt)
		orbitAng = orbitAng + curS * dt

		local bp   = tR.Position
		local nx   = bp.X + math.cos(orbitAng) * curR
		local nz   = bp.Z + math.sin(orbitAng) * curR
		local ny   = bp.Y - UNDERGROUND
		local newP = Vector3.new(nx, ny, nz)
		local fwd  = (Vector3.new(bp.X, ny, bp.Z) - newP).Unit
		hrp.CFrame = CFrame.fromMatrix(newP, fwd, Vector3.new(0,1,0))
		hrp.AssemblyLinearVelocity = Vector3.new(
			hrp.AssemblyLinearVelocity.X, -50, hrp.AssemblyLinearVelocity.Z
		)
	end)
end

-- ══════════════════════════════════════════
--  VEHICLE FUNCTIONS
-- ══════════════════════════════════════════
local function findFirstFreeSeat(model)
	for _, d in ipairs(model:GetDescendants()) do
		if (d:IsA("VehicleSeat") or d:IsA("Seat")) and not d.Occupant then return d end
	end
end

local function doVehicleTP(targetP, statusFn)
	local carName  = lp.Name.."Car"
	local vehicles = workspace:FindFirstChild("Vehicles")
	if not vehicles then if statusFn then statusFn("⚠ Vehicles-Ordner fehlt", Color3.fromRGB(220,80,80)) end; return end
	local myCar = vehicles:FindFirstChild(carName)
	if not myCar then if statusFn then statusFn("⚠ "..carName.." nicht gefunden", Color3.fromRGB(220,80,80)) end; return end
	local seat = findFirstFreeSeat(myCar)
	if not seat then if statusFn then statusFn("⚠ Kein freier Sitz", Color3.fromRGB(220,80,80)) end; return end

	local savedPos = hrp.CFrame
	lockCamera()
	hrp.CFrame = seat.CFrame + Vector3.new(0,3,0)
	task.wait(0.3); seat:Sit(hum); task.wait(0.5)
	local tHRP = getTargetHRP(targetP)
	if not tHRP then hum.Sit = false; task.wait(0.1); hrp.CFrame = savedPos; unlockCamera(); return end
	local primary = myCar.PrimaryPart or myCar:FindFirstChildWhichIsA("BasePart")
	if primary then myCar:PivotTo(CFrame.new(tHRP.Position + Vector3.new(0,2,0))) end
	task.wait(0.5); hum.Sit = false; task.wait(0.3)
	hrp.CFrame = savedPos
	unlockCamera()
end

local function doTPAllVehicles(targetP, statusFn)
	local tHRP = getTargetHRP(targetP); if not tHRP then return end
	local vehicles = workspace:FindFirstChild("Vehicles"); if not vehicles then return end
	local savedPos = hrp.CFrame
	local done = 0; local carList = {}; local seen = {}
	for _, car in ipairs(vehicles:GetChildren()) do
		if car:IsA("Model") and not seen[car] then seen[car]=true; table.insert(carList, car) end
	end
	lockCamera()
	for i, car in ipairs(carList) do
		local seat = findFirstFreeSeat(car)
		if seat then
			if statusFn then statusFn("🚗 Auto "..i.."/"..#carList.."…", Color3.fromRGB(40,200,140)) end
			hrp.CFrame = seat.CFrame + Vector3.new(0,3,0); task.wait(0.25)
			seat:Sit(hum); task.wait(0.4)
			local freshHRP = getTargetHRP(targetP)
			local dest = freshHRP and freshHRP.Position or tHRP.Position
			local primary = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
			if primary then car:PivotTo(CFrame.new(dest + Vector3.new(math.random(-6,6), 2, math.random(-6,6)))) end
			task.wait(0.4); hum.Sit = false; task.wait(0.25)
			done = done + 1
		end
	end
	hrp.CFrame = savedPos; unlockCamera()
	if statusFn then statusFn("✓ "..done.." Autos angekommen", Color3.fromRGB(40,200,100)) end
end

-- ══════════════════════════════════════════
--  COLOURS / UI
-- ══════════════════════════════════════════
local BG      = Color3.fromRGB(11,11,16)
local BG2     = Color3.fromRGB(18,18,26)
local BG3     = Color3.fromRGB(26,26,38)
local ACCENT  = Color3.fromRGB(60,130,255)
local ACCENT2 = Color3.fromRGB(40,100,200)
local TEXT    = Color3.fromRGB(210,215,230)
local TEXTDIM = Color3.fromRGB(110,115,140)
local RED     = Color3.fromRGB(180,45,45)
local GREEN   = Color3.fromRGB(40,165,75)
local PURPLE  = Color3.fromRGB(100,55,195)
local ORANGE  = Color3.fromRGB(200,120,30)
local TEAL    = Color3.fromRGB(30,130,100)
local W = 300

local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=p end
local function stroke(p, col, t) local s=Instance.new("UIStroke"); s.Color=col or Color3.fromRGB(40,45,68); s.Thickness=t or 1; s.Parent=p end
local function label(p, txt, sz, bold, col, xa)
	local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
	l.Text=txt; l.TextSize=sz or 12; l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextColor3=col or TEXT; l.TextXAlignment=xa or Enum.TextXAlignment.Center; l.Parent=p; return l
end
local function btn(p, txt, bg, tc)
	local b=Instance.new("TextButton"); local orig=bg or BG3
	b.BackgroundColor3=orig; b.BorderSizePixel=0
	b.Text=txt; b.TextSize=12; b.Font=Enum.Font.GothamBold
	b.TextColor3=tc or TEXT; b.AutoButtonColor=false; b.Parent=p; corner(b,5)
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.new(math.min(orig.R+0.08,1),math.min(orig.G+0.08,1),math.min(orig.B+0.08,1))}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=orig}):Play() end)
	return b
end

-- ══════════════════════════════════════════
--  ROOT GUI
-- ══════════════════════════════════════════
local sg=Instance.new("ScreenGui")
sg.Name="CouchGUI"; sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=lp.PlayerGui

local main=Instance.new("Frame")
main.Size=UDim2.new(0,W,0,34); main.Position=UDim2.new(0,12,0,12)
main.BackgroundColor3=BG; main.BorderSizePixel=0
main.Active=true; main.Draggable=true; main.ClipsDescendants=false; main.Parent=sg
corner(main,10); stroke(main,Color3.fromRGB(38,42,65),1)

local titleBar=Instance.new("Frame")
titleBar.Size=UDim2.new(1,0,0,34); titleBar.BackgroundColor3=BG2; titleBar.BorderSizePixel=0; titleBar.Parent=main; corner(titleBar,10)
local titleTxt=label(titleBar,"Kill panel",13,true,TEXT,Enum.TextXAlignment.Left)
titleTxt.Size=UDim2.new(1,-80,1,0); titleTxt.Position=UDim2.new(0,12,0,0)

local toggleBtn=Instance.new("TextButton")
toggleBtn.Size=UDim2.new(0,26,0,20); toggleBtn.Position=UDim2.new(1,-30,0.5,-10)
toggleBtn.BackgroundColor3=BG3; toggleBtn.BorderSizePixel=0; toggleBtn.Text="▼"
toggleBtn.TextSize=10; toggleBtn.Font=Enum.Font.GothamBold; toggleBtn.TextColor3=TEXTDIM
toggleBtn.AutoButtonColor=false; toggleBtn.Parent=titleBar; corner(toggleBtn,4)

local content=Instance.new("Frame")
content.Size=UDim2.new(1,0,1,-34); content.Position=UDim2.new(0,0,0,34)
content.BackgroundTransparency=1; content.ClipsDescendants=true; content.Parent=main

local tabBar=Instance.new("Frame")
tabBar.Size=UDim2.new(1,-16,0,28); tabBar.Position=UDim2.new(0,8,0,6)
tabBar.BackgroundColor3=BG2; tabBar.BorderSizePixel=0; tabBar.Parent=content; corner(tabBar,6)
local tl=Instance.new("UIListLayout"); tl.FillDirection=Enum.FillDirection.Horizontal
tl.SortOrder=Enum.SortOrder.LayoutOrder; tl.Padding=UDim.new(0,2); tl.Parent=tabBar

local function tabBtn(txt,order)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(0.5,-2,1,0); b.BackgroundColor3=BG2; b.BorderSizePixel=0
	b.Text=txt; b.TextSize=11; b.Font=Enum.Font.GothamBold
	b.TextColor3=TEXTDIM; b.AutoButtonColor=false; b.LayoutOrder=order; b.Parent=tabBar; corner(b,5); return b
end
local tab1Btn=tabBtn("⚔ Kill",1)
local tab2Btn=tabBtn("🚗  Vehicles",2)

local page1=Instance.new("Frame"); page1.Size=UDim2.new(1,0,1,-42); page1.Position=UDim2.new(0,0,0,42); page1.BackgroundTransparency=1; page1.Parent=content
local page2=Instance.new("Frame"); page2.Size=UDim2.new(1,0,1,-42); page2.Position=UDim2.new(0,0,0,42); page2.BackgroundTransparency=1; page2.Visible=false; page2.Parent=content

-- ══════════════════════════════════════════
--  DROPDOWN
-- ══════════════════════════════════════════
local function buildDropdown(parentFrame, yPos, onSelect)
	local container=Instance.new("Frame")
	container.Size=UDim2.new(1,-16,0,28); container.Position=UDim2.new(0,8,0,yPos)
	container.BackgroundTransparency=1; container.Parent=parentFrame

	local sb=Instance.new("TextBox")
	sb.Size=UDim2.new(1,0,0,28); sb.BackgroundColor3=BG3; sb.BorderSizePixel=0
	sb.Text=""; sb.PlaceholderText="🔍  Spieler suchen…"
	sb.PlaceholderColor3=TEXTDIM; sb.TextColor3=TEXT; sb.TextSize=12
	sb.Font=Enum.Font.Gotham; sb.TextXAlignment=Enum.TextXAlignment.Left
	sb.ClearTextOnFocus=false; sb.Parent=container; corner(sb,5); stroke(sb,Color3.fromRGB(45,50,78),1)
	local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,8); pad.Parent=sb

	local lf=Instance.new("ScrollingFrame")
	lf.Size=UDim2.new(1,0,0,0); lf.Position=UDim2.new(0,0,0,0)
	lf.BackgroundColor3=BG2; lf.BorderSizePixel=0
	lf.ScrollBarThickness=3; lf.ScrollBarImageColor3=ACCENT
	lf.Visible=false; lf.ZIndex=20; lf.ClipsDescendants=true; lf.Parent=container
	corner(lf,5); stroke(lf,Color3.fromRGB(45,50,78),1)
	local ll=Instance.new("UIListLayout"); ll.Padding=UDim.new(0,1); ll.SortOrder=Enum.SortOrder.Name; ll.Parent=lf
	local lp2=Instance.new("UIPadding",lf)
	lp2.PaddingTop=UDim.new(0,3); lp2.PaddingBottom=UDim.new(0,3); lp2.PaddingLeft=UDim.new(0,3); lp2.PaddingRight=UDim.new(0,3)

	local sel=nil; local listOpen=false

	local function closeList()
		listOpen=false
		TweenService:Create(lf,TweenInfo.new(0.12),{Size=UDim2.new(1,0,0,0)}):Play()
		task.delay(0.13,function() lf.Visible=false end)
	end

	local function buildList(filter)
		for _,c in ipairs(lf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		local count=0
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=lp and (filter=="" or p.Name:lower():find(filter:lower(),1,true)) then
				local row=Instance.new("TextButton")
				row.Size=UDim2.new(1,0,0,24); row.BackgroundColor3=BG3; row.BorderSizePixel=0
				row.Text="  "..p.Name; row.TextSize=12; row.Font=Enum.Font.Gotham
				row.TextColor3=TEXT; row.TextXAlignment=Enum.TextXAlignment.Left
				row.AutoButtonColor=false; row.ZIndex=21; row.Parent=lf; corner(row,4)
				row.MouseEnter:Connect(function() row.BackgroundColor3=Color3.fromRGB(36,40,62) end)
				row.MouseLeave:Connect(function() row.BackgroundColor3=BG3 end)
				row.MouseButton1Click:Connect(function() sel=p; sb.Text=p.Name; onSelect(p); closeList() end)
				count=count+1
			end
		end
		return count
	end

	local function openList()
		listOpen=true; lf.Visible=true
		local n=buildList(sb.Text); local h=math.min(n*25+6,130)
		lf.CanvasSize=UDim2.new(0,0,0,n*25+6)
		lf.Position=UDim2.new(0,0,0,-h-4)
		TweenService:Create(lf,TweenInfo.new(0.14),{Size=UDim2.new(1,0,0,h)}):Play()
	end

	sb.Focused:Connect(openList)
	sb:GetPropertyChangedSignal("Text"):Connect(function()
		if not listOpen then return end
		local n=buildList(sb.Text); local h=math.min(n*25+6,130)
		lf.CanvasSize=UDim2.new(0,0,0,n*25+6)
		lf.Size=UDim2.new(1,0,0,h)
		lf.Position=UDim2.new(0,0,0,-h-4)
	end)
	sb.FocusLost:Connect(function() task.delay(0.2,closeList) end)

	return container, function() return sel end
end

-- ══════════════════════════════════════════
--  PAGE 1 – Couch
-- ══════════════════════════════════════════
local fBtn  = btn(page1,"▶  FLING",   ACCENT2,TEXT)
fBtn.Size=UDim2.new(0.5,-12,0,28); fBtn.Position=UDim2.new(0,8,0,8)

local kBtn  = btn(page1,"☠  KILL",    RED,    TEXT)
kBtn.Size=UDim2.new(0.5,-12,0,28); kBtn.Position=UDim2.new(0.5,4,0,8)

local aBtn  = btn(page1,"🧲  ATTRACT", PURPLE, TEXT)
aBtn.Size=UDim2.new(1,-16,0,28); aBtn.Position=UDim2.new(0,8,0,44)
attractBtnRef = aBtn

local gcBtn = btn(page1,"🛋  GET COUCH", Color3.fromRGB(70,40,140), TEXT)
gcBtn.Size=UDim2.new(1,-16,0,28); gcBtn.Position=UDim2.new(0,8,0,80)

local stat1 = label(page1,"",11,false,TEXTDIM,Enum.TextXAlignment.Center)
stat1.Size=UDim2.new(1,-16,0,14); stat1.Position=UDim2.new(0,8,0,114)

local _,getT1 = buildDropdown(page1, 132, function(p) targetPlayer=p end)
local function s1(txt,col) stat1.Text=txt; stat1.TextColor3=col or TEXTDIM end

flingBtnRef = fBtn

fBtn.MouseButton1Click:Connect(function()
	targetPlayer = getT1() or targetPlayer
	if not targetPlayer then s1("⚠ No player",ORANGE); return end
	if isRunning then stopOrbit(); s1("stoppt",TEXTDIM); return end
	if not hasCouchInInventory() then s1("🛋 No Couch → get…",ORANGE); doGetCouch(); return end
	s1("🔄 Orbiting…",ACCENT)
	startOrbit(targetPlayer, true)
end)

kBtn.MouseButton1Click:Connect(function()
	targetPlayer = getT1() or targetPlayer
	if not targetPlayer then s1("⚠ No player",ORANGE); return end
	if not hasCouchInInventory() then s1("🛋 No Couch → get…",ORANGE); doGetCouch(); return end
	if isSitting(targetPlayer) then
		s1("☠ Kill…",RED); lockCamera()
		local saved = hrp.CFrame
		safeTeleport(CFrame.new(-9194,-279,-173))
		task.delay(0.3, function()
			unequipCouch()
			task.delay(0.5, function()
				holdAt(saved, 0.5, function() s1("✓ back",GREEN) end)
			end)
		end)
	else
		s1("🔄 Warte auf Sitz…",ORANGE)
		kBtn.Text="⏹  STOP"; kBtn.BackgroundColor3=Color3.fromRGB(120,30,30)
		startOrbit(targetPlayer, false)
		task.spawn(function()
			while isRunning or isLaunching do task.wait(0.1) end
			kBtn.Text="☠  KILL"; kBtn.BackgroundColor3=RED
			s1("✓ Fertig",GREEN)
		end)
	end
end)

aBtn.MouseButton1Click:Connect(function()
	targetPlayer = getT1() or targetPlayer
	if not targetPlayer then s1("⚠ No player",ORANGE); return end
	if not hasCouchInInventory() then s1("🛋 No Couch → get…",ORANGE); doGetCouch(); return end
	if attractRunning then
		stopAttract(); s1("Gestoppt",TEXTDIM)
	else
		s1("🧲 Bring...",PURPLE)
		startAttract(targetPlayer)
		task.spawn(function()
			while attractRunning do task.wait(0.1) end
			s1("✓ Player brought",GREEN)
		end)
	end
end)

gcBtn.MouseButton1Click:Connect(function()
	s1("🛋 Get couch",Color3.fromRGB(100,55,195))
	doGetCouch()
	task.delay(2, function() s1("",TEXTDIM) end)
end)

local P1_H = 168

-- ══════════════════════════════════════════
--  PAGE 2 – Vehicles
-- ══════════════════════════════════════════
local vtpBtn = btn(page2,"🚗  VEHICLE TP",     TEAL,                       TEXT)
vtpBtn.Size=UDim2.new(1,-16,0,28); vtpBtn.Position=UDim2.new(0,8,0,8)

local allBtn = btn(page2,"🚙  TP ALL VEHICLES", Color3.fromRGB(25,100,78), TEXT)
allBtn.Size=UDim2.new(1,-16,0,28); allBtn.Position=UDim2.new(0,8,0,44)

local stat2 = label(page2,"",11,false,TEXTDIM,Enum.TextXAlignment.Center)
stat2.Size=UDim2.new(1,-16,0,14); stat2.Position=UDim2.new(0,8,0,78)

local _,getT2 = buildDropdown(page2, 96, function(p) targetPlayer2=p end)
local function s2(txt,col) stat2.Text=txt; stat2.TextColor3=col or TEXTDIM end

vtpBtn.MouseButton1Click:Connect(function()
	targetPlayer2=getT2() or targetPlayer2
	if not targetPlayer2 then s2("⚠ Kein Spieler gewählt",ORANGE); return end
	s2("🚗 Fahre zum Ziel…",TEAL)
	task.spawn(function() doVehicleTP(targetPlayer2,s2) end)
end)

allBtn.MouseButton1Click:Connect(function()
	targetPlayer2=getT2() or targetPlayer2
	if not targetPlayer2 then s2("⚠ Kein Spieler gewählt",ORANGE); return end
	s2("🚙 TP alle Autos…",ORANGE)
	task.spawn(function() doTPAllVehicles(targetPlayer2,s2) end)
end)

local P2_H = 132

-- ══════════════════════════════════════════
--  TAB + TOGGLE
-- ══════════════════════════════════════════
local currentTab=1; local isOpen=true

local function switchTab(n)
	currentTab=n
	page1.Visible=n==1; page2.Visible=n==2
	tab1Btn.BackgroundColor3=n==1 and ACCENT2 or BG2; tab1Btn.TextColor3=n==1 and TEXT or TEXTDIM
	tab2Btn.BackgroundColor3=n==2 and ACCENT2 or BG2; tab2Btn.TextColor3=n==2 and TEXT or TEXTDIM
	if isOpen then
		local h=n==1 and P1_H or P2_H
		TweenService:Create(main,TweenInfo.new(0.18),{Size=UDim2.new(0,W,0,34+42+h)}):Play()
	end
end

tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)

toggleBtn.MouseButton1Click:Connect(function()
	isOpen=not isOpen
	if isOpen then
		content.Visible=true
		local h=currentTab==1 and P1_H or P2_H
		TweenService:Create(main,TweenInfo.new(0.2),{Size=UDim2.new(0,W,0,34+42+h)}):Play()
		toggleBtn.Text="▼"
	else
		TweenService:Create(main,TweenInfo.new(0.2),{Size=UDim2.new(0,W,0,34)}):Play()
		task.delay(0.21,function() content.Visible=false end)
		toggleBtn.Text="▲"
	end
end)

switchTab(1)
print("[CouchPanel v3] Geladen ✓")