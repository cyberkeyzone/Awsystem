return function(WindUI, AutoWalkTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local lp = Players.LocalPlayer

    -- ==========================================
    -- KONFIGURASI GITHUB
    -- ==========================================
    local GITHUB_OWNER = "cyberkeyzone" 
    local GITHUB_REPO = "Awsystem" 
    local GITHUB_FOLDER = "Routes" 

    -- ==========================================
    -- VARIABEL SISTEM & STATE
    -- ==========================================
    local isUnlocked = (lp.Name == "myzzkey") 
    local currentPlaceId = game.PlaceId
    
    local cacheFolderName = "Recording" 
    if isfolder and not isfolder(cacheFolderName) then pcall(function() makefolder(cacheFolderName) end) end

    local RouteData = nil
    
    local isPlaying = false
    local isAutoWalkingToStart = false
    local isLooping = false
    local isReversed = false
    local isFlipped = false
    local isRotated = false
    
    local playConn = nil
    local playSpeed = 1.0 -- Sekarang mendukung desimal
    local LoadBtn

    -- ==========================================
    -- FUNGSI INTERNAL DATA
    -- ==========================================
    local function DeserializeData(jsonFrames)
        local deserialized = {}
        for i, frame in ipairs(jsonFrames) do
            if frame and frame.cframe and frame.vel and frame.state then
                deserialized[i] = {
                    cframe = CFrame.new(unpack(frame.cframe)),
                    vel = Vector3.new(unpack(frame.vel)),
                    state = Enum.HumanoidStateType[frame.state]
                }
            end
        end
        return deserialized
    end

    local function FindNearestFrameIndex(data, currentPos)
        local nearestIdx = 1
        local minDis = math.huge
        for i, frame in ipairs(data) do
            local dis = (frame.cframe.Position - currentPos).Magnitude
            if dis < minDis then
                minDis = dis
                nearestIdx = i
            end
        end
        return nearestIdx
    end

    local function SafeSetTitle(btn, newTitle)
        if btn then pcall(function() btn:SetTitle(newTitle) end) end
    end

    -- ==========================================
    -- FUNGSI LOAD INSTAN
    -- ==========================================
    local function ScanLocalCache()
        if not listfiles or not isfolder(cacheFolderName) then return false end
        for _, filePath in ipairs(listfiles(cacheFolderName)) do
            if filePath:match("%.json$") then
                local success, fileData = pcall(function() return readfile(filePath) end)
                if success and fileData then
                    local jsonSuccess, jsonData = pcall(function() return HttpService:JSONDecode(fileData) end)
                    if jsonSuccess and type(jsonData) == "table" and jsonData.PlaceId then
                        if tostring(jsonData.PlaceId) == tostring(currentPlaceId) then
                            local framesToProcess = jsonData.Frames or jsonData
                            local desSuccess, resultData = pcall(function() return DeserializeData(framesToProcess) end)
                            if desSuccess and resultData and #resultData > 0 then
                                RouteData = resultData
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end

    local function DirectCloudFetch()
        local baseUrl = string.format("https://raw.githubusercontent.com/%s/%s/main/%s", GITHUB_OWNER, GITHUB_REPO, GITHUB_FOLDER)
        if GITHUB_FOLDER == "" then baseUrl = string.format("https://raw.githubusercontent.com/%s/%s/main", GITHUB_OWNER, GITHUB_REPO) end

        -- Cek [PlaceId].json
        local url1 = baseUrl .. "/" .. tostring(currentPlaceId) .. ".json"
        local s1, r1 = pcall(function() return game:HttpGet(url1) end)
        if s1 and r1 and not r1:match("404: Not Found") then
            local js, jd = pcall(function() return HttpService:JSONDecode(r1) end)
            if js and type(jd) == "table" then
                local framesToProcess = jd.Frames or jd
                local desSuccess, resultData = pcall(function() return DeserializeData(framesToProcess) end)
                if desSuccess and resultData and #resultData > 0 then
                    RouteData = resultData
                    if writefile then pcall(function() writefile(cacheFolderName .. "/" .. tostring(currentPlaceId) .. ".json", r1) end) end
                    return true
                end
            end
        end

        -- Cek record.json
        local url2 = baseUrl .. "/record.json"
        local s2, r2 = pcall(function() return game:HttpGet(url2) end)
        if s2 and r2 and not r2:match("404: Not Found") then
            local js, jd = pcall(function() return HttpService:JSONDecode(r2) end)
            if js and type(jd) == "table" then
                if jd.PlaceId and tostring(jd.PlaceId) ~= tostring(currentPlaceId) then return false end
                local framesToProcess = jd.Frames or jd
                local desSuccess, resultData = pcall(function() return DeserializeData(framesToProcess) end)
                if desSuccess and resultData and #resultData > 0 then
                    RouteData = resultData
                    if writefile then pcall(function() writefile(cacheFolderName .. "/record.json", r2) end) end
                    return true
                end
            end
        end
        return false
    end

    -- ==========================================
    -- CUSTOM LOCAL UI (ULTRA COMPACT MOBILE)
    -- ==========================================
    local FloatingUI = Instance.new("ScreenGui")
    FloatingUI.Name = "SYNC_AutoWalkPanel"
    FloatingUI.ResetOnSpawn = false
    FloatingUI.Enabled = false
    
    local uiParent = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or lp.PlayerGui
    FloatingUI.Parent = uiParent

    -- 1. Tombol Circle (Widget)
    local WidgetBtn = Instance.new("TextButton")
    WidgetBtn.Size = UDim2.new(0, 42, 0, 42)
    WidgetBtn.Position = UDim2.new(0.5, -21, 0.1, 0)
    WidgetBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    WidgetBtn.Text = "🏃"
    WidgetBtn.TextSize = 20
    WidgetBtn.Parent = FloatingUI
    
    Instance.new("UICorner", WidgetBtn).CornerRadius = UDim.new(1, 0)
    local WidgetStroke = Instance.new("UIStroke")
    WidgetStroke.Color = Color3.fromRGB(41, 248, 155)
    WidgetStroke.Thickness = 2
    WidgetStroke.Parent = WidgetBtn

    -- 2. Main Panel (Desain Compact 2x2 Grid + Slider)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 160, 0, 105) 
    MainFrame.Position = UDim2.new(0.5, -80, 0.1, 55)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false 
    MainFrame.Parent = FloatingUI

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(41, 248, 155)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = MainFrame

    local function CreateMiniBtn(txt, px, py, parent)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 72, 0, 25)
        btn.Position = UDim2.new(0, px, 0, py)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        btn.Text = txt
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Parent = parent
        return btn
    end

    -- Baris 1: Play/Stop & Reverse
    local PlayPanelBtn = CreateMiniBtn("▶️ Play", 5, 5, MainFrame)
    PlayPanelBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 230)
    
    local ReverseBtn = CreateMiniBtn("🔙 Rev: OFF", 82, 5, MainFrame)

    -- Baris 2: Flip & Rotate
    local FlipBtn = CreateMiniBtn("🔀 Flip: OFF", 5, 35, MainFrame)
    local RotateBtn = CreateMiniBtn("🌀 Rot: OFF", 82, 35, MainFrame)

    -- Baris 3: Slider Speed
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, -10, 0, 15)
    SpeedLabel.Position = UDim2.new(0, 5, 0, 65)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed: 1.0x"
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 10
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = MainFrame

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -14, 0, 6)
    SliderTrack.Position = UDim2.new(0, 7, 0, 85)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)
    SliderTrack.Parent = MainFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(41, 248, 155)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    SliderFill.Parent = SliderTrack

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 14, 0, 14)
    SliderKnob.Position = UDim2.new(1, -7, 0.5, -7)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)
    SliderKnob.Parent = SliderFill

    local SliderTouchBtn = Instance.new("TextButton")
    SliderTouchBtn.Size = UDim2.new(1, 0, 1, 30)
    SliderTouchBtn.Position = UDim2.new(0, 0, 0, -15)
    SliderTouchBtn.BackgroundTransparency = 1
    SliderTouchBtn.Text = ""
    SliderTouchBtn.Parent = SliderTrack

    -- ==========================================
    -- LOGIKA DRAG WIDGET
    -- ==========================================
    local isDraggingWidget = false
    local widgetDragStart, widgetStartPos
    local hasMoved = false

    WidgetBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingWidget = true
            hasMoved = false
            widgetDragStart = input.Position
            widgetStartPos = WidgetBtn.Position
        end
    end)

    WidgetBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingWidget = false
            if not hasMoved then MainFrame.Visible = not MainFrame.Visible end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingWidget and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - widgetDragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved then
                WidgetBtn.Position = UDim2.new(widgetStartPos.X.Scale, widgetStartPos.X.Offset + delta.X, widgetStartPos.Y.Scale, widgetStartPos.Y.Offset + delta.Y)
                MainFrame.Position = UDim2.new(WidgetBtn.Position.X.Scale, WidgetBtn.Position.X.Offset - 60, WidgetBtn.Position.Y.Scale, WidgetBtn.Position.Y.Offset + 55)
            end
        end
    end)

    -- ==========================================
    -- LOGIKA SLIDER (MENDUKUNG DESIMAL 1.1x, 1.2x)
    -- ==========================================
    local sliderDragging = false
    SliderTouchBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseX = input.Position.X
            local sliderX = SliderTrack.AbsolutePosition.X
            local sliderSize = SliderTrack.AbsoluteSize.X
            
            local percent = math.clamp((mouseX - sliderX) / sliderSize, 0, 1)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            
            -- Menghitung nilai desimal: 1.0 hingga 25.0
            local rawSpeed = 1 + (percent * 24)
            playSpeed = math.floor(rawSpeed * 10) / 10 
            
            -- Format UI agar selalu 1 angka di belakang koma (contoh: 1.5x)
            SpeedLabel.Text = string.format("Speed: %.1fx", playSpeed)
        end
    end)

    -- ==========================================
    -- LOGIKA FITUR (REVERSE, FLIP, ROTATE)
    -- ==========================================
    local function UpdateBtnState(btn, state, activeTxt, inactiveTxt)
        if state then
            btn.Text = activeTxt
            btn.BackgroundColor3 = Color3.fromRGB(220, 150, 40)
        else
            btn.Text = inactiveTxt
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
    end

    ReverseBtn.MouseButton1Click:Connect(function()
        isReversed = not isReversed
        UpdateBtnState(ReverseBtn, isReversed, "🔙 Rev: ON", "🔙 Rev: OFF")
    end)

    FlipBtn.MouseButton1Click:Connect(function()
        isFlipped = not isFlipped
        UpdateBtnState(FlipBtn, isFlipped, "🔀 Flip: ON", "🔀 Flip: OFF")
    end)

    RotateBtn.MouseButton1Click:Connect(function()
        isRotated = not isRotated
        UpdateBtnState(RotateBtn, isRotated, "🌀 Rot: ON", "🌀 Rot: OFF")
    end)

    -- ==========================================
    -- LOGIKA PLAYBACK (AUTO WALK)
    -- ==========================================
    local function StopPlayback()
        if playConn then playConn:Disconnect() end
        local char = lp.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp then hrp.Anchored = false end
            if hum then 
                hum.AutoRotate = true
                hum:Move(Vector3.zero, false) 
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        isPlaying = false
        isAutoWalkingToStart = false
        PlayPanelBtn.Text = "▶️ Play"
        PlayPanelBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 230)
    end

    PlayPanelBtn.MouseButton1Click:Connect(function()
        if not RouteData then return end
        
        if isPlaying then
            StopPlayback()
            return
        end
        
        isPlaying = true
        PlayPanelBtn.Text = "⏹️ Stop"
        PlayPanelBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Cari posisi terdekat, dan Aktifkan mode AutoWalkToStart
        local floatIndex = hrp and FindNearestFrameIndex(RouteData, hrp.Position) or 1
        isAutoWalkingToStart = true 
        
        if playConn then playConn:Disconnect() end
        playConn = RunService.Stepped:Connect(function()
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if not hrp or not hum then return end
            
            if isAutoWalkingToStart then
                -- BERJALAN NORMAL KE TITIK TERDEKAT (BUKAN TELEPORT)
                hrp.Anchored = false
                hum.AutoRotate = true

                local targetPos = RouteData[math.floor(floatIndex)].cframe.Position
                local dist = (hrp.Position - targetPos).Magnitude
                
                if dist > 3 then
                    hum:MoveTo(targetPos)
                else
                    isAutoWalkingToStart = false 
                end
            else
                -- PLAYBACK RUTE (Bisa menabrak Checkpoint)
                hrp.Anchored = false 
                hum.AutoRotate = false
                
                local actualIndex = math.floor(floatIndex)
                
                if RouteData[actualIndex] then
                    local currentData = RouteData[actualIndex]
                    local targetCFrame = currentData.cframe
                    local targetVel = currentData.vel

                    -- Kombinasi Fitur
                    if isReversed then
                        targetCFrame = targetCFrame * CFrame.Angles(0, math.pi, 0)
                        targetVel = -targetVel
                    end

                    if isFlipped then
                        -- Putar 180 drajat tapi tetap jalan ke arah rute
                        targetCFrame = targetCFrame * CFrame.Angles(0, math.pi, 0)
                    end

                    if isRotated then
                        -- Berputar/Spin terus menerus
                        targetCFrame = targetCFrame * CFrame.Angles(0, os.clock() * 15, 0)
                    end
                    
                    hrp.CFrame = targetCFrame
                    hrp.AssemblyLinearVelocity = targetVel
                    if hum:GetState() ~= currentData.state then hum:ChangeState(currentData.state) end
                    
                    -- Deteksi gerak untuk pemicu animasi jalan bawaan roblox
                    local nextIndex = isReversed and (actualIndex - 1) or (actualIndex + 1)
                    local nextData = RouteData[nextIndex]
                    if nextData then
                        local moveDir = (nextData.cframe.Position - currentData.cframe.Position)
                        local flatMoveDir = Vector3.new(moveDir.X, 0, moveDir.Z) 
                        if flatMoveDir.Magnitude > 0.02 then hum:Move(flatMoveDir.Unit, false) 
                        else hum:Move(Vector3.zero, false) end
                    else 
                        hum:Move(Vector3.zero, false) 
                    end
                    
                    -- Penambahan Kecepatan Desimal
                    if isReversed then
                        floatIndex = floatIndex - playSpeed
                    else
                        floatIndex = floatIndex + playSpeed
                    end
                else
                    -- RUTE SELESAI
                    if isLooping then
                        -- Reset index & jalan lagi ke awal
                        floatIndex = isReversed and #RouteData or 1
                        isAutoWalkingToStart = true
                    else
                        StopPlayback()
                        WindUI:Notify({Title="Selesai", Content="Rute Auto Walk tercapai!", Duration=2})
                    end
                end
            end
        end)
    end)

    -- ==========================================
    -- TAB WIND UI (HANYA TOMBOL LOAD & LOOP)
    -- ==========================================
    pcall(function()
        AutoWalkTab:Toggle({
            Title = "🔁 Loop Auto Walk",
            Default = false,
            Callback = function(state)
                isLooping = state
            end
        })
    end)

    pcall(function()
        LoadBtn = AutoWalkTab:Button({
            Title = "☁️ Load Auto Walk",
            Callback = function()
                if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
                
                SafeSetTitle(LoadBtn, "⏳ Loading...")
                
                task.spawn(function()
                    local isLocalFound = ScanLocalCache()
                    if isLocalFound then
                        SafeSetTitle(LoadBtn, "✅ Successfully Load Asset")
                        FloatingUI.Enabled = true 
                        WindUI:Notify({Title="Sukses", Content="Rute dimuat! Panel (🏃) muncul.", Duration=3, Icon="check"})
                        return
                    end
                    
                    local isCloudFound = DirectCloudFetch()
                    if isCloudFound then
                        SafeSetTitle(LoadBtn, "✅ Successfully Load Asset")
                        FloatingUI.Enabled = true 
                        WindUI:Notify({Title="Sukses", Content="Rute diunduh & dimuat!", Duration=3, Icon="check"})
                    else
                        SafeSetTitle(LoadBtn, "☁️ Load Auto Walk")
                        WindUI:Notify({Title="Gagal", Content="Rute belum ada.", Duration=3, Icon="x"})
                    end
                end)
            end
        })
    end)
end
