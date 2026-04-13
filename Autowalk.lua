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
    local GITHUB_FOLDER = "Routes" -- Mencari di dalam folder Routes

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
    local playConn = nil
    local playSpeed = 1 

    -- Deklarasi UI Global
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
        if btn then
            pcall(function() btn:SetTitle(newTitle) end)
        end
    end

    -- ==========================================
    -- FUNGSI LOAD INSTAN (BYPASS API LIMIT)
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
        if GITHUB_FOLDER == "" then
            baseUrl = string.format("https://raw.githubusercontent.com/%s/%s/main", GITHUB_OWNER, GITHUB_REPO)
        end

        -- PRIORITAS 1: Coba file bernama "[PlaceId].json"
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

        -- PRIORITAS 2: Coba file bernama "record.json" (Fallback manual)
        local url2 = baseUrl .. "/record.json"
        local s2, r2 = pcall(function() return game:HttpGet(url2) end)
        
        if s2 and r2 and not r2:match("404: Not Found") then
            local js, jd = pcall(function() return HttpService:JSONDecode(r2) end)
            if js and type(jd) == "table" then
                if jd.PlaceId and tostring(jd.PlaceId) ~= tostring(currentPlaceId) then
                    return false, "File record.json ada di GitHub, tapi Place ID beda!"
                end
                
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

        return false, "Rute belum tersedia di GitHub."
    end

    -- ==========================================
    -- UI ELEMENTS (WIND UI)
    -- ==========================================
    StatusPara = AutoWalkTab:Paragraph({
        Title = "Auto Walk (Smart Tracker)",
        Desc = "Status: Menunggu Load... (Map ID: " .. tostring(currentPlaceId) .. ")",
        Color = Color3.fromHex("#0F7BFF")
    })

    -- Slider Speed (Aman dari crash)
    AutoWalkTab:Slider({
        Title = "⚡ Playspeed Auto Walk",
        Min = 1, 
        Max = 25, 
        Default = 1,
        Value = 1,
        Callback = function(value)
            playSpeed = value
            if isPlaying then
                StatusPara:SetDesc(string.format("Status: Berjalan (Speed: %dx)", playSpeed))
            end
        end
    })

    -- 1. TOMBOL LOAD (Pencarian Cerdas Anti-Stuck)
    LoadBtn = AutoWalkTab:Button({
        Title = "☁️ Load Auto Walk",
        Callback = function()
            if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
            
            SafeSetTitle(LoadBtn, "⏳ Menarik Data...")
            StatusPara:SetDesc("Status: Memeriksa Local & Cloud...")
            
            task.spawn(function()
                -- Cek Cache Lokal terlebih dahulu
                local isLocalFound, localMsg = ScanLocalCache()
                if isLocalFound then
                    WindUI:Notify({Title="Rute Terpasang", Content=localMsg, Duration=2, Icon="check"})
                    StatusPara:SetDesc("Status: Siap! (" .. loadedRouteName .. ")")
                    SafeSetTitle(LoadBtn, "✅ Rute Ter-Load (" .. loadedRouteName .. ")")
                    SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
                    SafeSetTitle(StopBtn, "⏹️ Stop Auto Walk")
                    return
                end
                
                -- Jika tidak ada di Lokal, tembak ke URL GitHub
                local isCloudFound, cloudMsg = DirectCloudFetch()
                if isCloudFound then
                    WindUI:Notify({Title="Rute Terunduh", Content=cloudMsg, Duration=2, Icon="check"})
                    StatusPara:SetDesc("Status: Siap! (" .. loadedRouteName .. ")")
                    SafeSetTitle(LoadBtn, "✅ Rute Ter-Load (" .. loadedRouteName .. ")")
                    SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
                    SafeSetTitle(StopBtn, "⏹️ Stop Auto Walk")
                else
                    WindUI:Notify({Title="Tidak Ditemukan", Content=cloudMsg, Duration=3, Icon="x"})
                    StatusPara:SetDesc("Status: Gagal. " .. cloudMsg)
                    SafeSetTitle(LoadBtn, "☁️ Load Auto Walk (Coba Lagi)")
                end
            end)
        end
    })

    -- 2. TOMBOL PLAY (Mode Terkunci di Awal)
    PlayBtn = AutoWalkTab:Button({
        Title = "🚫 Play (Terkunci)",
        Callback = function()
            if not isUnlocked or isPlaying or not RouteData then 
                if not RouteData then WindUI:Notify({Title="Gagal", Content="Load Rute terlebih dahulu!", Duration=2}) end
                return 
            end
            
            isPlaying = true
            SafeSetTitle(PlayBtn, "🔄 Sedang Berjalan...")
            
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            -- Loncati Frame: Mulai dari titik terdekat
            local floatIndex = hrp and FindNearestFrameIndex(RouteData, hrp.Position) or 1
            
            WindUI:Notify({Title="Auto Walk", Content="Melanjutkan dari posisi terdekat!", Duration=2})
            StatusPara:SetDesc(string.format("Status: Berjalan (%dx Speed)", playSpeed))
            
            if playConn then playConn:Disconnect() end
            playConn = RunService.Stepped:Connect(function()
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not hum then return end
                
                hrp.Anchored = true 
                hum.AutoRotate = false
                
                local actualIndex = math.floor(floatIndex)
                
                if RouteData[actualIndex] then
                    local currentData = RouteData[actualIndex]
                    
                    hrp.CFrame = currentData.cframe
                    hrp.AssemblyLinearVelocity = currentData.vel
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
                    if playConn then playConn:Disconnect() end
                    hrp.Anchored = false
                    hum.AutoRotate = true
                    hum:Move(Vector3.zero, false) 
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    
                    isPlaying = false
                    StatusPara:SetDesc("Status: Tujuan Tercapai.")
                    WindUI:Notify({Title="Selesai", Content="Rute Auto Walk tercapai!", Duration=2})
                    SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
                end
            end)
        end
    })

    -- 3. TOMBOL STOP (Mode Terkunci di Awal)
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
            StatusPara:SetDesc("Status: Dihentikan (Standby).")
            WindUI:Notify({Title="Stop", Content="Auto Walk dihentikan.", Duration=1.5})
            SafeSetTitle(PlayBtn, "▶️ Play Auto Walk")
        end
    })

end
