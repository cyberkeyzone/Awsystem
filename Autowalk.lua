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
    local playConn = nil
    local playSpeed = 1 

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
    -- CUSTOM LOCAL UI (SCREEN GUI KECIL & PAS)
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

    -- 2. Main Panel (Kecil, Horizontal)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 180, 0, 90)
    MainFrame.Position = UDim2.new(0.5, -90, 0.1, 55)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false 
    MainFrame.Parent = FloatingUI

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(41, 248, 155)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = MainFrame

    -- Tombol Play (Kiri)
    local PlayPanelBtn = Instance.new("TextButton")
    PlayPanelBtn.Size = UDim2.new(0, 75, 0, 30)
    PlayPanelBtn.Position = UDim2.new(0, 10, 0, 10)
    PlayPanelBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 230)
    PlayPanelBtn.Text = "▶️ Play"
    PlayPanelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayPanelBtn.Font = Enum.Font.GothamBold
    PlayPanelBtn.TextSize = 12
    Instance.new("UICorner", PlayPanelBtn).CornerRadius = UDim.new(0, 6)
    PlayPanelBtn.Parent = MainFrame

    -- Tombol Stop (Kanan)
    local StopPanelBtn = Instance.new("TextButton")
    StopPanelBtn.Size = UDim2.new(0, 75, 0, 30)
    StopPanelBtn.Position = UDim2.new(1, -85, 0, 10)
    StopPanelBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    StopPanelBtn.Text = "⏹️ Stop"
    StopPanelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopPanelBtn.Font = Enum.Font.GothamBold
    StopPanelBtn.TextSize = 12
    Instance.new("UICorner", StopPanelBtn).CornerRadius = UDim.new(0, 6)
    StopPanelBtn.Parent = MainFrame

    -- Info Speed
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, -20, 0, 15)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 48)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed: 1x"
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 11
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = MainFrame

    -- Custom Slider (Bawah)
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 8)
    SliderTrack.Position = UDim2.new(0, 10, 0, 68)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)
    SliderTrack.Parent = MainFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(41, 248, 155)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    SliderFill.Parent = SliderTrack

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 16, 0, 16)
    SliderKnob.Position = UDim2.new(1, -8, 0.5, -8)
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
    -- LOGIKA DRAG UI & TOGGLE
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
            if not hasMoved then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingWidget and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - widgetDragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved then
                WidgetBtn.Position = UDim2.new(widgetStartPos.X.Scale, widgetStartPos.X.Offset + delta.X, widgetStartPos.Y.Scale, widgetStartPos.Y.Offset + delta.Y)
                -- Panel mengikuti tombol bulat
                MainFrame.Position = UDim2.new(WidgetBtn.Position.X.Scale, WidgetBtn.Position.X.Offset - 70, WidgetBtn.Position.Y.Scale, WidgetBtn.Position.Y.Offset + 55)
            end
        end
    end)

    -- ==========================================
    -- LOGIKA SLIDER CUSTOM
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
            
            -- Hitung speed 1x sampai 25x
            playSpeed = math.floor(1 + (percent * 24))
            SpeedLabel.Text = "Speed: " .. playSpeed .. "x"
        end
    end)

    -- ==========================================
    -- LOGIKA PLAYBACK (LANGSUNG TITIK TERDEKAT)
    -- ==========================================
    PlayPanelBtn.MouseButton1Click:Connect(function()
        if not RouteData or isPlaying then return end
        
        isPlaying = true
        PlayPanelBtn.Text = "🔄 Proses"
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Cari frame terdekat, dan LANGSUNG MULAI dari sana (Tidak ada kebingungan jalan)
        local floatIndex = hrp and FindNearestFrameIndex(RouteData, hrp.Position) or 1
        
        if playConn then playConn:Disconnect() end
        playConn = RunService.Stepped:Connect(function()
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if not hrp or not hum then return end
            
            -- Biarkan physics aktif (Anchored = false) agar bisa menyentuh Checkpoint
            hrp.Anchored = false 
            hum.AutoRotate = false
            
            local actualIndex = math.floor(floatIndex)
            
            if RouteData[actualIndex] then
                local currentData = RouteData[actualIndex]
                
                -- Inject CFrame dan Velocity
                hrp.CFrame = currentData.cframe
                hrp.AssemblyLinearVelocity = currentData.vel
                if hum:GetState() ~= currentData.state then hum:ChangeState(currentData.state) end
                
                -- Picu animasi kaki berlari
                local nextData = RouteData[actualIndex + 1]
                if nextData then
                    local moveDir = (nextData.cframe.Position - currentData.cframe.Position)
                    local flatMoveDir = Vector3.new(moveDir.X, 0, moveDir.Z) 
                    if flatMoveDir.Magnitude > 0.02 then hum:Move(flatMoveDir.Unit, false) 
                    else hum:Move(Vector3.zero, false) end
                else 
                    hum:Move(Vector3.zero, false) 
                end
                
                -- Mempercepat frame
                floatIndex = floatIndex + playSpeed
            else
                -- SELESAI
                if playConn then playConn:Disconnect() end
                hum.AutoRotate = true
                hum:Move(Vector3.zero, false) 
                hum:ChangeState(Enum.HumanoidStateType.Running)
                
                isPlaying = false
                PlayPanelBtn.Text = "▶️ Play"
                WindUI:Notify({Title="Selesai", Content="Auto Walk mencapai tujuan!", Duration=2})
            end
        end)
    end)

    StopPanelBtn.MouseButton1Click:Connect(function()
        if not RouteData then return end 
        
        if playConn then playConn:Disconnect() end
        local char = lp.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp then hrp.Anchored = false end
            if hum then 
                hum.AutoRotate = true
                hum:Move(Vector3.zero, false) 
            end
        end
        
        isPlaying = false
        PlayPanelBtn.Text = "▶️ Play"
    end)

    -- ==========================================
    -- TAB WIND UI (SANGAT BERSIH & MINIMALIS)
    -- ==========================================
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
                        FloatingUI.Enabled = true -- Munculkan tombol lingkaran
                        WindUI:Notify({Title="Sukses", Content="Rute dimuat! Tombol Auto Walk (🏃) muncul di layar.", Duration=3, Icon="check"})
                        return
                    end
                    
                    local isCloudFound = DirectCloudFetch()
                    if isCloudFound then
                        SafeSetTitle(LoadBtn, "✅ Successfully Load Asset")
                        FloatingUI.Enabled = true -- Munculkan tombol lingkaran
                        WindUI:Notify({Title="Sukses", Content="Rute diunduh & dimuat! Tombol Auto Walk (🏃) muncul di layar.", Duration=3, Icon="check"})
                    else
                        SafeSetTitle(LoadBtn, "☁️ Load Auto Walk (Gagal)")
                        WindUI:Notify({Title="Gagal", Content="Rute untuk map ini belum ada.", Duration=3, Icon="x"})
                    end
                end)
            end
        })
    end)

end
