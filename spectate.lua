return function(WindUI, OptionalTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    
    local lp = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    OptionalTab:Paragraph({
        Title = "✈️ Mobile Fly System",
        Desc = "Sistem terbang khusus yang disempurnakan untuk Mobile. Gunakan analog bawaan Roblox untuk bergerak dan arahkan layar untuk terbang ke atas/bawah.",
        Color = Color3.fromHex("#29F89B")
    })

    -- ==========================================
    -- VARIABEL SISTEM FLY
    -- ==========================================
    local isFlying = false
    local flySpeed = 100
    local flyConnection = nil
    
    -- Mengambil Control Module bawaan Roblox (Untuk membaca pergerakan Analog Mobile)
    local controlModule = nil
    pcall(function()
        controlModule = require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
    end)

    -- ==========================================
    -- CUSTOM FLOATING UI (CIRCLE + PANEL)
    -- ==========================================
    local FloatingUI = Instance.new("ScreenGui")
    FloatingUI.Name = "SYNC_FlyGUI"
    FloatingUI.ResetOnSpawn = false
    FloatingUI.Enabled = false
    FloatingUI.Parent = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or lp.PlayerGui

    -- 1. Tombol Circle (Bisa didrag)
    local CircleWidget = Instance.new("TextButton")
    CircleWidget.Size = UDim2.new(0, 50, 0, 50)
    CircleWidget.Position = UDim2.new(0.8, 0, 0.3, 0)
    CircleWidget.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    CircleWidget.Text = "✈️"
    CircleWidget.TextSize = 24
    CircleWidget.Parent = FloatingUI
    Instance.new("UICorner", CircleWidget).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", CircleWidget).Color = Color3.fromRGB(41, 248, 155)
    Instance.new("UIStroke", CircleWidget).Thickness = 2

    -- 2. Panel Utama
    local MainPanel = Instance.new("Frame")
    MainPanel.Size = UDim2.new(0, 220, 0, 140)
    MainPanel.Position = UDim2.new(0.5, -110, 0.5, -70)
    MainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainPanel.Visible = false
    MainPanel.Parent = FloatingUI
    Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", MainPanel).Color = Color3.fromRGB(41, 248, 155)
    Instance.new("UIStroke", MainPanel).Thickness = 2

    -- Judul Panel
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "  Fly Control"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = MainPanel

    -- Tombol Toggle Fly
    local ToggleFlyBtn = Instance.new("TextButton")
    ToggleFlyBtn.Size = UDim2.new(0.9, 0, 0, 35)
    ToggleFlyBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
    ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    ToggleFlyBtn.Text = "FLY: OFF"
    ToggleFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleFlyBtn.Font = Enum.Font.GothamBold
    ToggleFlyBtn.TextSize = 14
    Instance.new("UICorner", ToggleFlyBtn).CornerRadius = UDim.new(0, 6)
    ToggleFlyBtn.Parent = MainPanel

    -- Teks Speed
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 0, 0.55, 0)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed: 100"
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 12
    SpeedLabel.Parent = MainPanel

    -- Custom Slider Speed (100 - 500)
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(0.9, 0, 0, 8)
    SliderBG.Position = UDim2.new(0.05, 0, 0.75, 0)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
    SliderBG.Parent = MainPanel

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0) -- Mulai dari 0% (Speed 100)
    SliderFill.BackgroundColor3 = Color3.fromRGB(41, 248, 155)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    SliderFill.Parent = SliderBG

    local SliderKnob = Instance.new("TextButton")
    SliderKnob.Size = UDim2.new(0, 16, 0, 16)
    SliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnob.Text = ""
    Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)
    SliderKnob.Parent = SliderBG

    -- ==========================================
    -- LOGIKA DRAG & SLIDER UI
    -- ==========================================
    local isDraggingCircle = false
    local circleDragStart, circleStartPos, circleHasMoved

    CircleWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingCircle = true
            circleHasMoved = false
            circleDragStart = input.Position
            circleStartPos = CircleWidget.Position
        end
    end)

    CircleWidget.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingCircle = false
            if not circleHasMoved then
                -- Jika hanya di-tap (tidak didrag), buka/tutup panel utama
                MainPanel.Visible = not MainPanel.Visible
            end
        end
    end)

    local isDraggingSlider = false
    SliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSlider = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSlider = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        -- Drag Circle Widget
        if isDraggingCircle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - circleDragStart
            if delta.Magnitude > 5 then circleHasMoved = true end
            if circleHasMoved then
                CircleWidget.Position = UDim2.new(circleStartPos.X.Scale, circleStartPos.X.Offset + delta.X, circleStartPos.Y.Scale, circleStartPos.Y.Offset + delta.Y)
            end
        end

        -- Drag Slider Speed
        if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseX = input.Position.X
            local bgX = SliderBG.AbsolutePosition.X
            local bgSize = SliderBG.AbsoluteSize.X
            
            local relativeX = math.clamp(mouseX - bgX, 0, bgSize)
            local percentage = relativeX / bgSize
            
            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            SliderKnob.Position = UDim2.new(percentage, -8, 0.5, -8)
            
            -- Kalkulasi Speed (0% = 100, 100% = 500)
            flySpeed = math.floor(100 + (percentage * 400))
            SpeedLabel.Text = "Speed: " .. tostring(flySpeed)
        end
    end)

    -- ==========================================
    -- LOGIKA TERBANG (MOBILE JOYSTICK SUPPORT)
    -- ==========================================
    local function CleanUpFly()
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            if hrp:FindFirstChild("SYNC_FlyVelocity") then hrp.SYNC_FlyVelocity:Destroy() end
            if hrp:FindFirstChild("SYNC_FlyGyro") then hrp.SYNC_FlyGyro:Destroy() end
        end
        if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end

    local function StartFlyLoop()
        if flyConnection then flyConnection:Disconnect() end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if isFlying and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChildOfClass("Humanoid") then
                local hrp = lp.Character.HumanoidRootPart
                local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                
                -- Pastikan objek fisika ada
                local bv = hrp:FindFirstChild("SYNC_FlyVelocity")
                local bg = hrp:FindFirstChild("SYNC_FlyGyro")
                
                if not bv or not bg then
                    CleanUpFly()
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "SYNC_FlyVelocity"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = hrp
                    
                    bg = Instance.new("BodyGyro")
                    bg.Name = "SYNC_FlyGyro"
                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bg.D = 100
                    bg.P = 10000
                    bg.CFrame = camera.CFrame
                    bg.Parent = hrp
                end
                
                hum.PlatformStand = true 
                
                -- MENGAMBIL ARAH DARI ANALOG MOBILE
                local moveDir = Vector3.new(0, 0, 0)
                if controlModule then
                    local moveVector = controlModule:GetMoveVector()
                    if moveVector.Magnitude > 0 then
                        -- Menggabungkan arah kamera dengan input analog
                        moveDir = (camera.CFrame.RightVector * moveVector.X) + (camera.CFrame.LookVector * (moveVector.Z * -1))
                    end
                end
                
                bv.Velocity = moveDir * flySpeed
                bg.CFrame = camera.CFrame
            end
        end)
    end

    ToggleFlyBtn.MouseButton1Click:Connect(function()
        isFlying = not isFlying
        if isFlying then
            ToggleFlyBtn.Text = "FLY: ON"
            ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(41, 248, 155)
            ToggleFlyBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
            StartFlyLoop()
        else
            ToggleFlyBtn.Text = "FLY: OFF"
            ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            ToggleFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            CleanUpFly()
        end
    end)

    -- Membersihkan fly jika karakter mati/reset
    lp.CharacterAdded:Connect(function()
        if isFlying then
            task.wait(1)
            StartFlyLoop()
        end
    end)

    -- ==========================================
    -- EVENT TOMBOL WIND UI
    -- ==========================================
    OptionalTab:Button({
        Title = "🟢 Buka / Tutup Panel Fly",
        Callback = function()
            FloatingUI.Enabled = not FloatingUI.Enabled
            if FloatingUI.Enabled then
                WindUI:Notify({Title="Panel Aktif", Content="Panel Fly telah muncul di layar.", Duration=2})
            end
        end
    })

end
