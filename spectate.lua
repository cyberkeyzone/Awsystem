return function(WindUI, OptionalTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    
    local lp = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    -- ==========================================
    -- MENGAMBIL KONTROL ANALOG MOBILE ROBLOX
    -- ==========================================
    local controlModule = nil
    pcall(function()
        controlModule = require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
    end)

    -- =========================================================================
    -- [1] NORMAL MOBILE FLY SYSTEM
    -- =========================================================================
    OptionalTab:Paragraph({
        Title = "✈️ Normal Mobile Fly",
        Desc = "Sistem terbang fisik menggunakan analog bawaan Roblox.",
        Color = Color3.fromHex("#29F89B")
    })

    local isFlying = false
    local flySpeed = 100
    local flyConnection = nil

    local NormalFlyUI = Instance.new("ScreenGui")
    NormalFlyUI.Name = "SYNC_NormalFlyGUI"
    NormalFlyUI.ResetOnSpawn = false
    NormalFlyUI.Enabled = false
    NormalFlyUI.Parent = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or lp.PlayerGui

    local CircleNFly = Instance.new("TextButton")
    CircleNFly.Size = UDim2.new(0, 50, 0, 50)
    CircleNFly.Position = UDim2.new(0.8, 0, 0.3, 0)
    CircleNFly.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    CircleNFly.Text = "✈️"
    CircleNFly.TextSize = 24
    CircleNFly.Parent = NormalFlyUI
    Instance.new("UICorner", CircleNFly).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", CircleNFly).Color = Color3.fromRGB(41, 248, 155)
    Instance.new("UIStroke", CircleNFly).Thickness = 2

    local PanelNFly = Instance.new("Frame")
    PanelNFly.Size = UDim2.new(0, 220, 0, 140)
    PanelNFly.Position = UDim2.new(0.5, -110, 0.5, -70)
    PanelNFly.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    PanelNFly.Visible = false
    PanelNFly.Parent = NormalFlyUI
    Instance.new("UICorner", PanelNFly).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", PanelNFly).Color = Color3.fromRGB(41, 248, 155)
    Instance.new("UIStroke", PanelNFly).Thickness = 2

    local TitleNFly = Instance.new("TextLabel")
    TitleNFly.Size = UDim2.new(1, 0, 0, 30)
    TitleNFly.BackgroundTransparency = 1
    TitleNFly.Text = "  Normal Fly"
    TitleNFly.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleNFly.Font = Enum.Font.GothamBold
    TitleNFly.TextSize = 14
    TitleNFly.TextXAlignment = Enum.TextXAlignment.Left
    TitleNFly.Parent = PanelNFly

    local ToggleNFlyBtn = Instance.new("TextButton")
    ToggleNFlyBtn.Size = UDim2.new(0.9, 0, 0, 35)
    ToggleNFlyBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
    ToggleNFlyBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    ToggleNFlyBtn.Text = "FLY: OFF"
    ToggleNFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleNFlyBtn.Font = Enum.Font.GothamBold
    ToggleNFlyBtn.TextSize = 14
    Instance.new("UICorner", ToggleNFlyBtn).CornerRadius = UDim.new(0, 6)
    ToggleNFlyBtn.Parent = PanelNFly

    local SpeedLabelNFly = Instance.new("TextLabel")
    SpeedLabelNFly.Size = UDim2.new(1, 0, 0, 20)
    SpeedLabelNFly.Position = UDim2.new(0, 0, 0.55, 0)
    SpeedLabelNFly.BackgroundTransparency = 1
    SpeedLabelNFly.Text = "Speed: 100"
    SpeedLabelNFly.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabelNFly.Font = Enum.Font.Gotham
    SpeedLabelNFly.TextSize = 12
    SpeedLabelNFly.Parent = PanelNFly

    local SliderBGNFly = Instance.new("Frame")
    SliderBGNFly.Size = UDim2.new(0.9, 0, 0, 8)
    SliderBGNFly.Position = UDim2.new(0.05, 0, 0.75, 0)
    SliderBGNFly.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", SliderBGNFly).CornerRadius = UDim.new(1, 0)
    SliderBGNFly.Parent = PanelNFly

    local SliderFillNFly = Instance.new("Frame")
    SliderFillNFly.Size = UDim2.new(0, 0, 1, 0)
    SliderFillNFly.BackgroundColor3 = Color3.fromRGB(41, 248, 155)
    Instance.new("UICorner", SliderFillNFly).CornerRadius = UDim.new(1, 0)
    SliderFillNFly.Parent = SliderBGNFly

    local SliderKnobNFly = Instance.new("TextButton")
    SliderKnobNFly.Size = UDim2.new(0, 16, 0, 16)
    SliderKnobNFly.Position = UDim2.new(0, -8, 0.5, -8)
    SliderKnobNFly.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnobNFly.Text = ""
    Instance.new("UICorner", SliderKnobNFly).CornerRadius = UDim.new(1, 0)
    SliderKnobNFly.Parent = SliderBGNFly

    -- Drag Logic Normal Fly
    local isDragNFly, startNFly, posNFly, movedNFly = false, nil, nil, false
    CircleNFly.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragNFly = true; movedNFly = false; startNFly = input.Position; posNFly = CircleNFly.Position
        end
    end)
    CircleNFly.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragNFly = false; if not movedNFly then PanelNFly.Visible = not PanelNFly.Visible end
        end
    end)
    
    local isSlideNFly = false
    SliderKnobNFly.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSlideNFly = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSlideNFly = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragNFly and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startNFly
            if delta.Magnitude > 5 then movedNFly = true end
            if movedNFly then CircleNFly.Position = UDim2.new(posNFly.X.Scale, posNFly.X.Offset + delta.X, posNFly.Y.Scale, posNFly.Y.Offset + delta.Y) end
        end
        if isSlideNFly and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((input.Position.X - SliderBGNFly.AbsolutePosition.X) / SliderBGNFly.AbsoluteSize.X, 0, 1)
            SliderFillNFly.Size = UDim2.new(pct, 0, 1, 0)
            SliderKnobNFly.Position = UDim2.new(pct, -8, 0.5, -8)
            flySpeed = math.floor(100 + (pct * 400))
            SpeedLabelNFly.Text = "Speed: " .. tostring(flySpeed)
        end
    end)

    local function CleanNFly()
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            if hrp:FindFirstChild("SYNC_NFlyV") then hrp.SYNC_NFlyV:Destroy() end
            if hrp:FindFirstChild("SYNC_NFlyG") then hrp.SYNC_NFlyG:Destroy() end
        end
        if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end

    ToggleNFlyBtn.MouseButton1Click:Connect(function()
        isFlying = not isFlying
        if isFlying then
            ToggleNFlyBtn.Text = "FLY: ON"
            ToggleNFlyBtn.BackgroundColor3 = Color3.fromRGB(41, 248, 155)
            ToggleNFlyBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
            
            flyConnection = RunService.RenderStepped:Connect(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChildOfClass("Humanoid") then
                    local hrp = lp.Character.HumanoidRootPart
                    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                    
                    local bv = hrp:FindFirstChild("SYNC_NFlyV")
                    local bg = hrp:FindFirstChild("SYNC_NFlyG")
                    if not bv or not bg then
                        CleanNFly()
                        bv = Instance.new("BodyVelocity", hrp); bv.Name = "SYNC_NFlyV"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bg = Instance.new("BodyGyro", hrp); bg.Name = "SYNC_NFlyG"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 10000; bg.D = 100
                    end
                    hum.PlatformStand = true 
                    local moveDir = Vector3.new(0,0,0)
                    if controlModule then
                        local v = controlModule:GetMoveVector()
                        if v.Magnitude > 0 then moveDir = (camera.CFrame.RightVector * v.X) + (camera.CFrame.LookVector * (v.Z * -1)) end
                    end
                    bv.Velocity = moveDir * flySpeed
                    bg.CFrame = camera.CFrame
                end
            end)
        else
            ToggleNFlyBtn.Text = "FLY: OFF"
            ToggleNFlyBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            ToggleNFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            CleanNFly()
        end
    end)

    OptionalTab:Button({
        Title = "🟢 Buka Panel Normal Fly",
        Callback = function() NormalFlyUI.Enabled = not NormalFlyUI.Enabled end
    })


    -- =========================================================================
    -- [2] GHOST TP FLY SYSTEM (ROH TERBANG / FREECAM)
    -- =========================================================================
    OptionalTab:Divider()
    OptionalTab:Paragraph({
        Title = "👻 Ghost TP Fly Panel",
        Desc = "Tubuh aslimu akan diam mematung dengan aman. Rohmu akan keluar dan terbang menembus map. Klik Teleport untuk memindahkan tubuh aslimu ke lokasi roh.",
        Color = Color3.fromHex("#a042f5")
    })

    local isGhosting = false
    local ghostSpeed = 100
    local ghostClone = nil
    local ghostFlyConn = nil

    local GhostUI = Instance.new("ScreenGui")
    GhostUI.Name = "SYNC_GhostFlyGUI"
    GhostUI.ResetOnSpawn = false
    GhostUI.Enabled = false
    GhostUI.Parent = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or lp.PlayerGui

    local CircleGhost = Instance.new("TextButton")
    CircleGhost.Size = UDim2.new(0, 50, 0, 50)
    CircleGhost.Position = UDim2.new(0.8, 0, 0.45, 0)
    CircleGhost.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    CircleGhost.Text = "👻"
    CircleGhost.TextSize = 24
    CircleGhost.Parent = GhostUI
    Instance.new("UICorner", CircleGhost).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", CircleGhost).Color = Color3.fromRGB(160, 66, 245)
    Instance.new("UIStroke", CircleGhost).Thickness = 2

    local PanelGhost = Instance.new("Frame")
    PanelGhost.Size = UDim2.new(0, 220, 0, 180) 
    PanelGhost.Position = UDim2.new(0.5, -110, 0.5, -90)
    PanelGhost.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    PanelGhost.Visible = false
    PanelGhost.Parent = GhostUI
    Instance.new("UICorner", PanelGhost).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", PanelGhost).Color = Color3.fromRGB(160, 66, 245)
    Instance.new("UIStroke", PanelGhost).Thickness = 2

    local TitleGhost = Instance.new("TextLabel")
    TitleGhost.Size = UDim2.new(1, 0, 0, 30)
    TitleGhost.BackgroundTransparency = 1
    TitleGhost.Text = "  Ghost TP Control"
    TitleGhost.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleGhost.Font = Enum.Font.GothamBold
    TitleGhost.TextSize = 14
    TitleGhost.TextXAlignment = Enum.TextXAlignment.Left
    TitleGhost.Parent = PanelGhost

    local ToggleGhostBtn = Instance.new("TextButton")
    ToggleGhostBtn.Size = UDim2.new(0.9, 0, 0, 35)
    ToggleGhostBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
    ToggleGhostBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    ToggleGhostBtn.Text = "GHOST: OFF"
    ToggleGhostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleGhostBtn.Font = Enum.Font.GothamBold
    ToggleGhostBtn.TextSize = 14
    Instance.new("UICorner", ToggleGhostBtn).CornerRadius = UDim.new(0, 6)
    ToggleGhostBtn.Parent = PanelGhost

    local TeleportGhostBtn = Instance.new("TextButton")
    TeleportGhostBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TeleportGhostBtn.Position = UDim2.new(0.05, 0, 0.43, 0)
    TeleportGhostBtn.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    TeleportGhostBtn.Text = "📍 TELEPORT / SHOW"
    TeleportGhostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportGhostBtn.Font = Enum.Font.GothamBold
    TeleportGhostBtn.TextSize = 13
    Instance.new("UICorner", TeleportGhostBtn).CornerRadius = UDim.new(0, 6)
    TeleportGhostBtn.Parent = PanelGhost

    local SpeedLabelGhost = Instance.new("TextLabel")
    SpeedLabelGhost.Size = UDim2.new(1, 0, 0, 20)
    SpeedLabelGhost.Position = UDim2.new(0, 0, 0.68, 0)
    SpeedLabelGhost.BackgroundTransparency = 1
    SpeedLabelGhost.Text = "Speed: 100"
    SpeedLabelGhost.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabelGhost.Font = Enum.Font.Gotham
    SpeedLabelGhost.TextSize = 12
    SpeedLabelGhost.Parent = PanelGhost

    local SliderBGGhost = Instance.new("Frame")
    SliderBGGhost.Size = UDim2.new(0.9, 0, 0, 8)
    SliderBGGhost.Position = UDim2.new(0.05, 0, 0.83, 0)
    SliderBGGhost.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", SliderBGGhost).CornerRadius = UDim.new(1, 0)
    SliderBGGhost.Parent = PanelGhost

    local SliderFillGhost = Instance.new("Frame")
    SliderFillGhost.Size = UDim2.new(0, 0, 1, 0)
    SliderFillGhost.BackgroundColor3 = Color3.fromRGB(160, 66, 245)
    Instance.new("UICorner", SliderFillGhost).CornerRadius = UDim.new(1, 0)
    SliderFillGhost.Parent = SliderBGGhost

    local SliderKnobGhost = Instance.new("TextButton")
    SliderKnobGhost.Size = UDim2.new(0, 16, 0, 16)
    SliderKnobGhost.Position = UDim2.new(0, -8, 0.5, -8)
    SliderKnobGhost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnobGhost.Text = ""
    Instance.new("UICorner", SliderKnobGhost).CornerRadius = UDim.new(1, 0)
    SliderKnobGhost.Parent = SliderBGGhost

    -- Drag Logic Ghost Fly
    local isDragGhost, startGhost, posGhost, movedGhost = false, nil, nil, false
    CircleGhost.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragGhost = true; movedGhost = false; startGhost = input.Position; posGhost = CircleGhost.Position
        end
    end)
    CircleGhost.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragGhost = false; if not movedGhost then PanelGhost.Visible = not PanelGhost.Visible end
        end
    end)
    
    local isSlideGhost = false
    SliderKnobGhost.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSlideGhost = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSlideGhost = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragGhost and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startGhost
            if delta.Magnitude > 5 then movedGhost = true end
            if movedGhost then CircleGhost.Position = UDim2.new(posGhost.X.Scale, posGhost.X.Offset + delta.X, posGhost.Y.Scale, posGhost.Y.Offset + delta.Y) end
        end
        if isSlideGhost and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((input.Position.X - SliderBGGhost.AbsolutePosition.X) / SliderBGGhost.AbsoluteSize.X, 0, 1)
            SliderFillGhost.Size = UDim2.new(pct, 0, 1, 0)
            SliderKnobGhost.Position = UDim2.new(pct, -8, 0.5, -8)
            ghostSpeed = math.floor(100 + (pct * 400))
            SpeedLabelGhost.Text = "Speed: " .. tostring(ghostSpeed)
        end
    end)

    -- Fungsi Menghentikan Mode Ghost & Mengembalikan Setting Normal
    local function StopGhostMode(teleportToGhost)
        if ghostFlyConn then ghostFlyConn:Disconnect(); ghostFlyConn = nil end
        
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local realHRP = lp.Character.HumanoidRootPart
            local realHum = lp.Character:FindFirstChildOfClass("Humanoid")
            
            -- Jika menekan tombol Teleport, pindahkan tubuh asli ke lokasi Roh
            if teleportToGhost and ghostClone and ghostClone:FindFirstChild("HumanoidRootPart") then
                realHRP.CFrame = ghostClone.HumanoidRootPart.CFrame
            end
            
            -- Buka kunci (Unanchor) tubuh asli
            realHRP.Anchored = false
            if realHum then
                camera.CameraSubject = realHum
            end
        end
        
        -- Hancurkan roh
        if ghostClone then
            ghostClone:Destroy()
            ghostClone = nil
        end
        
        isGhosting = false
        ToggleGhostBtn.Text = "GHOST: OFF"
        ToggleGhostBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        ToggleGhostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    ToggleGhostBtn.MouseButton1Click:Connect(function()
        if not isGhosting then
            -- Mencegah bug: Matikan Normal Fly jika sedang menyala
            if isFlying then
                isFlying = false
                ToggleNFlyBtn.Text = "FLY: OFF"
                ToggleNFlyBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            end

            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local realHRP = lp.Character.HumanoidRootPart
            local realHum = lp.Character:FindFirstChildOfClass("Humanoid")
            
            -- 1. KLONING ROH (SEBELUM DIBEKUKAN AGAR ROHNYA TIDAK IKUT BEKU)
            local oldArchivable = lp.Character.Archivable
            lp.Character.Archivable = true
            ghostClone = lp.Character:Clone()
            lp.Character.Archivable = oldArchivable
            
            -- 2. BEKUKAN TUBUH ASLI (Force Idle Pose)
            if realHum then
                -- Paksa animasi mendarat agar tidak terlihat mengambang di udara
                realHum:ChangeState(Enum.HumanoidStateType.Landed)
            end
            realHRP.Velocity = Vector3.new(0, 0, 0)
            realHRP.Anchored = true
            
            -- 3. MODIFIKASI VISUAL & FISIK ROH
            local ghostHRP = ghostClone:FindFirstChild("HumanoidRootPart")
            local ghostHum = ghostClone:FindFirstChildOfClass("Humanoid")
            
            ghostClone.Name = "SYNC_Ghost_" .. lp.Name
            
            -- Pastikan Roh tidak nyangkut (Unanchored)
            if ghostHRP then ghostHRP.Anchored = false end
            if ghostHum then ghostHum.PlatformStand = true end -- Supaya ga jalan kaki kocak
            
            for _, v in pairs(ghostClone:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = false
                    v.CanCollide = false -- ROH TEMBUS PANDANG & TEMBUS DINDING
                    v.Transparency = 0.5
                    v.Color = Color3.new(1, 1, 1) -- Warna Putih Bersinar
                    v.Material = Enum.Material.Neon -- Efek Glowing
                elseif v:IsA("Decal") then
                    v.Transparency = 0.5
                elseif v:IsA("Script") or v:IsA("LocalScript") then
                    v:Destroy() -- Cegah script asli mengganggu roh
                end
            end
            
            ghostClone.Parent = workspace
            
            -- 4. PINDAHKAN KAMERA KE ROH
            if ghostHum then
                camera.CameraSubject = ghostHum
            end
            
            -- 5. TAMBAHKAN MESIN TERBANG KE ROH
            local bv = Instance.new("BodyVelocity", ghostHRP)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            local bg = Instance.new("BodyGyro", ghostHRP)
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 10000; bg.D = 100

            isGhosting = true
            ToggleGhostBtn.Text = "GHOST: ON"
            ToggleGhostBtn.BackgroundColor3 = Color3.fromRGB(160, 66, 245)
            ToggleGhostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- 6. LOOP PENGGERAK ROH (SUPPORT ANALOG MOBILE)
            ghostFlyConn = RunService.RenderStepped:Connect(function()
                if ghostHRP and ghostClone.Parent == workspace then
                    local moveDir = Vector3.new(0,0,0)
                    if controlModule then
                        local v = controlModule:GetMoveVector()
                        if v.Magnitude > 0 then 
                            moveDir = (camera.CFrame.RightVector * v.X) + (camera.CFrame.LookVector * (v.Z * -1)) 
                        end
                    end
                    bv.Velocity = moveDir * ghostSpeed
                    bg.CFrame = camera.CFrame
                else
                    StopGhostMode(false)
                end
            end)
        else
            -- Batal, kembali ke tubuh asli
            StopGhostMode(false)
            WindUI:Notify({Title="Dibatalkan", Content="Kamera kembali ke tubuh asli.", Duration=2})
        end
    end)

    -- Tombol Teleport / Show
    TeleportGhostBtn.MouseButton1Click:Connect(function()
        if isGhosting then
            StopGhostMode(true)
            WindUI:Notify({Title="Teleport", Content="Tubuh aslimu berpindah ke lokasi roh!", Duration=2})
        else
            WindUI:Notify({Title="Error", Content="Nyalakan Ghost Fly terlebih dahulu!", Duration=2})
        end
    end)

    OptionalTab:Button({
        Title = "🟣 Buka Panel Ghost TP Fly",
        Callback = function() GhostUI.Enabled = not GhostUI.Enabled end
    })

    -- Jika pemain mati, bersihkan semua sistem Fly
    lp.CharacterAdded:Connect(function()
        if isGhosting then StopGhostMode(false) end
        if isFlying then ToggleNFlyBtn.Text = "FLY: OFF"; isFlying = false end
    end)
end
