return function(WindUI, AutoWalkTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
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
    if isfolder and not isfolder(cacheFolderName) then 
        pcall(function() makefolder(cacheFolderName) end) 
    end

    local RouteData = nil
    local loadedRouteName = ""
    
    local isPlaying = false
    local isAutoWalkingToStart = false
    local playConn = nil
    local playSpeed = 1 

    local LoadBtn, PlayBtn, StopBtn, StatusPara

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
                local fileName = filePath:match("([^/\\]+)$")
                local success, fileData = pcall(function() return readfile(filePath) end)
                if success and fileData then
                    local jsonSuccess, jsonData = pcall(function() return HttpService:JSONDecode(fileData) end)
                    if jsonSuccess and type(jsonData) == "table" and jsonData.PlaceId then
                        if tostring(jsonData.PlaceId) == tostring(currentPlaceId) then
                            local framesToProcess = jsonData.Frames or jsonData
                            local desSuccess, resultData = pcall(function() return DeserializeData(framesToProcess) end)
                            if desSuccess and resultData and #resultData > 0 then
                                RouteData = resultData
                                loadedRouteName = fileName
                                return true, "Rute Lokal: " .. fileName
                            end
                        end
                    end
                end
            end
        end
        return false, "Tidak ada di lokal."
    end

    local function DirectCloudFetch()
        local baseUrl = string.format("https://raw.githubusercontent.com/%s/%s/main/%s", GITHUB_OWNER, GITHUB_REPO, GITHUB_FOLDER)
        if GITHUB_FOLDER == "" then baseUrl = string.format("https://raw.githubusercontent.com/%s/%s/main", GITHUB_OWNER, GITHUB_REPO) end

        local url1 = baseUrl .. "/" .. tostring(currentPlaceId) .. ".json"
        local s1, r1 = pcall(function() return game:HttpGet(url1) end)
        if s1 and r1 and not r1:match("404: Not Found") then
            local js, jd = pcall(function() return HttpService:JSONDecode(r1) end)
            if js and type(jd) == "table" then
                local framesToProcess = jd.Frames or jd
                local desSuccess, resultData = pcall(function() return DeserializeData(framesToProcess) end)
                if desSuccess and resultData and #resultData > 0 then
                    RouteData = resultData
                    loadedRouteName = tostring(currentPlaceId) .. ".json"
                    if writefile then pcall(function() writefile(cacheFolderName .. "/" .. loadedRouteName, r1) end) end
                    return true, "Rute Cloud: " .. loadedRouteName
                end
            end
        end

        local url2 = baseUrl .. "/record.json"
        local s2, r2 = pcall(function() return game:HttpGet(url2) end)
        if s2 and r2 and not r2:match("404: Not Found") then
            local js, jd = pcall(function() return HttpService:JSONDecode(r2) end)
            if js and type(jd) == "table" then
                if jd.PlaceId and tostring(jd.PlaceId) ~= tostring(currentPlaceId) then return false, "Beda Place ID!" end
                local framesToProcess = jd.Frames or jd
                local desSuccess, resultData = pcall(function() return DeserializeData(framesToProcess) end)
                if desSuccess and resultData and #resultData > 0 then
                    RouteData = resultData
                    loadedRouteName = "record.json"
                    if writefile then pcall(function() writefile(cacheFolderName .. "/record.json", r2) end) end
                    return true, "Rute Cloud: record.json"
                end
            end
        end
        return false, "Belum tersedia di GitHub."
    end

    -- ==========================================
    -- UI ELEMENTS DENGAN PCALL (ANTI-CRASH 100%)
    -- ==========================================
    pcall(function()
        StatusPara = AutoWalkTab:Paragraph({
            Title = "Auto Walk (Smart Tracker)",
            Desc = "Status: Menunggu Load... (Map ID: " .. tostring(currentPlaceId) .. ")"
        })
    end)

    pcall(function()
        AutoWalkTab:Slider({
            Title = "⚡ Playspeed",
            Min = 1, 
            Max = 25, 
            Value = 1,
            Callback = function(value)
                playSpeed = value
                if isPlaying and not isAutoWalkingToStart and StatusPara then
                    pcall(function() StatusPara:SetDesc("Status: Berjalan (Speed: " .. playSpeed .. "x)") end)
                end
            end
        })
    end)

    -- 1. TOMBOL LOAD
    pcall(function()
        LoadBtn = AutoWalkTab:Button({
            Title = "☁️ Load Auto Walk",
            Callback = function()
                if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
                
                SafeSetTitle(LoadBtn, "⏳ Menarik Data...")
                if StatusPara then pcall(function() StatusPara:SetDesc("Status: Memeriksa Local & Cloud...") end) end
                
                task.spawn(function()
                    local isLocalFound, localMsg = ScanLocalCache()
                    if isLocalFound then
                        WindUI:Notify({Title="Rute Siap", Content=localMsg, Duration=2, Icon="check"})
                        if StatusPara then pcall(function() StatusPara:SetDesc("Status: Siap! (" .. loadedRouteName .. ")") end) end
                        SafeSetTitle(LoadBtn, "✅ Rute Ter-Load (" .. loadedRouteName .. ")")
                        SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
                        SafeSetTitle(StopBtn, "⏹️ Stop Auto Walk")
                        return
                    end
                    
                    local isCloudFound, cloudMsg = DirectCloudFetch()
                    if isCloudFound then
                        WindUI:Notify({Title="Rute Terunduh", Content=cloudMsg, Duration=2, Icon="check"})
                        if StatusPara then pcall(function() StatusPara:SetDesc("Status: Siap! (" .. loadedRouteName .. ")") end) end
                        SafeSetTitle(LoadBtn, "✅ Rute Ter-Load (" .. loadedRouteName .. ")")
                        SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
                        SafeSetTitle(StopBtn, "⏹️ Stop Auto Walk")
                    else
                        WindUI:Notify({Title="Gagal", Content=cloudMsg, Duration=3, Icon="x"})
                        if StatusPara then pcall(function() StatusPara:SetDesc("Status: Gagal. " .. cloudMsg) end) end
                        SafeSetTitle(LoadBtn, "☁️ Load Auto Walk (Coba Lagi)")
                    end
                end)
            end
        })
    end)

    -- 2. TOMBOL PLAY
    pcall(function()
        PlayBtn = AutoWalkTab:Button({
            Title = "🚫 Play (Terkunci - Load Dulu)",
            Callback = function()
                if not isUnlocked or isPlaying or not RouteData then return end
                
                isPlaying = true
                SafeSetTitle(PlayBtn, "🔄 Sedang Berjalan...")
                
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local floatIndex = hrp and FindNearestFrameIndex(RouteData, hrp.Position) or 1
                isAutoWalkingToStart = true
                
                WindUI:Notify({Title="Auto Walk", Content="Berjalan menuju rute terdekat!", Duration=2})
                
                if playConn then playConn:Disconnect() end
                playConn = RunService.Stepped:Connect(function()
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not hum then return end
                    
                    if isAutoWalkingToStart then
                        -- FASE 1: JALAN KE TITIK TERDEKAT (BUKAN TELEPORT)
                        hrp.Anchored = false
                        hum.AutoRotate = true

                        local targetPos = RouteData[math.floor(floatIndex)].cframe.Position
                        local dist = (hrp.Position - targetPos).Magnitude
                        
                        if dist > 3 then
                            hum:MoveTo(targetPos)
                            if StatusPara then pcall(function() StatusPara:SetDesc(string.format("Status: Menuju titik terdekat... (%d Studs)", math.floor(dist))) end) end
                        else
                            isAutoWalkingToStart = false 
                            WindUI:Notify({Title="Sinkronisasi", Content="Memulai rute utama!", Duration=1.5})
                            if StatusPara then pcall(function() StatusPara:SetDesc("Status: Berjalan (Speed: " .. playSpeed .. "x)") end) end
                        end
                    else
                        -- FASE 2: PLAYBACK RUTE (BISA SENTUH CHECKPOINT)
                        hrp.Anchored = false -- ANTI BUG: Karakter tidak dibekukan, bisa sentuh trigger/CP!
                        hum.AutoRotate = false
                        
                        local actualIndex = math.floor(floatIndex)
                        local currentData = RouteData[actualIndex]
                        
                        if currentData then
                            hrp.AssemblyLinearVelocity = currentData.vel
                            hrp.CFrame = currentData.cframe
                            if hum:GetState() ~= currentData.state then hum:ChangeState(currentData.state) end
                            
                            local nextData = RouteData[actualIndex + 1]
                            if nextData then
                                local moveDir = (nextData.cframe.Position - currentData.cframe.Position)
                                local flatMoveDir = Vector3.new(moveDir.X, 0, moveDir.Z) 
                                if flatMoveDir.Magnitude > 0.02 then hum:Move(flatMoveDir.Unit, false) 
                                else hum:Move(Vector3.zero, false) end
                            else 
                                hum:Move(Vector3.zero, false) 
                            end
                            
                            floatIndex = floatIndex + playSpeed
                        else
                            -- RUTE SELESAI
                            if playConn then playConn:Disconnect() end
                            hrp.Anchored = false
                            hum.AutoRotate = true
                            hum:Move(Vector3.zero, false) 
                            hum:ChangeState(Enum.HumanoidStateType.Running)
                            
                            isPlaying = false
                            if StatusPara then pcall(function() StatusPara:SetDesc("Status: Tujuan Tercapai.") end) end
                            WindUI:Notify({Title="Selesai", Content="Rute Auto Walk tercapai!", Duration=2})
                            SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
                        end
                    end
                end)
            end
        })
    end)

    -- 3. TOMBOL STOP
    pcall(function()
        StopBtn = AutoWalkTab:Button({
            Title = "🚫 Stop (Terkunci)",
            Callback = function()
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
                isAutoWalkingToStart = false
                if StatusPara then pcall(function() StatusPara:SetDesc("Status: Dihentikan (Standby).") end) end
                WindUI:Notify({Title="Stop", Content="Auto Walk dihentikan.", Duration=1.5})
                SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
            end
        })
    end)

end
