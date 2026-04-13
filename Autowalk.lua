return function(WindUI, AutoWalkTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local lp = Players.LocalPlayer

    -- ==========================================
    -- KONFIGURASI GITHUB API
    -- ==========================================
    local GITHUB_OWNER = "cyberkeyzone" 
    local GITHUB_REPO = "Awsystem" 
    local GITHUB_FOLDER = "" -- Kosongkan jika file JSON ada di luar/root

    -- ==========================================
    -- VARIABEL SISTEM & STATE
    -- ==========================================
    local isUnlocked = (lp.Name == "myzzkey") 
    local currentPlaceId = game.PlaceId
    
    local cacheFolderName = "SYNC_AutoWalkCache"
    if isfolder and not isfolder(cacheFolderName) then makefolder(cacheFolderName) end

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
            deserialized[i] = {
                cframe = CFrame.new(unpack(frame.cframe)),
                vel = Vector3.new(unpack(frame.vel)),
                state = Enum.HumanoidStateType[frame.state]
            }
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

    local function SetUIVisible(element, isVisible)
        if element and element.Instance then
            pcall(function() element.Instance.Visible = isVisible end)
        end
    end

    -- ==========================================
    -- FUNGSI SMART SCANNER (CLOUD MATCHING)
    -- ==========================================
    local function AutoScanAndLoadRoute()
        local apiUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", GITHUB_OWNER, GITHUB_REPO, GITHUB_FOLDER)
        if GITHUB_FOLDER == "" then
            apiUrl = string.format("https://api.github.com/repos/%s/%s/contents", GITHUB_OWNER, GITHUB_REPO)
        end

        local success, result = pcall(function() return game:HttpGet(apiUrl) end)
        
        if success and result and not result:match("404: Not Found") then
            local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(result) end)
            
            if decodeSuccess and type(decodedData) == "table" then
                -- Looping mencari file JSON yang cocok dengan PlaceId game ini
                for _, file in ipairs(decodedData) do
                    if file.name and file.name:match("%.json$") then
                        StatusPara:SetDesc("Mengecek file: " .. file.name .. "...")
                        
                        -- Download isi JSON-nya
                        local dlSuccess, dlResult = pcall(function() return game:HttpGet(file.download_url) end)
                        
                        if dlSuccess and dlResult then
                            local jsonSuccess, jsonData = pcall(function() return HttpService:JSONDecode(dlResult) end)
                            
                            -- SMART MATCHING: Cek apakah PlaceId cocok
                            if jsonSuccess and jsonData.PlaceId and tostring(jsonData.PlaceId) == tostring(currentPlaceId) then
                                -- Rute Cocok Ditemukan!
                                local framesToProcess = jsonData.Frames or jsonData
                                RouteData = DeserializeData(framesToProcess)
                                loadedRouteName = file.name
                                
                                -- Simpan ke Cache Lokal agar tidak perlu download lagi nanti
                                if writefile then writefile(cacheFolderName .. "/" .. file.name, dlResult) end
                                
                                return true, "Rute cocok ditemukan: " .. file.name
                            end
                        end
                    end
                end
                return false, "Tidak ada rute di GitHub yang cocok untuk Map ini (Place ID: " .. tostring(currentPlaceId) .. ")"
            end
        end
        return false, "Gagal terhubung ke GitHub."
    end

    -- ==========================================
    -- UI ELEMENTS (WIND UI)
    -- ==========================================
    StatusPara = AutoWalkTab:Paragraph({
        Title = "Sistem Auto Walk (Smart Mode)",
        Desc = "Status: Menunggu Load... (Map ID: " .. tostring(currentPlaceId) .. ")",
        Color = Color3.fromHex("#0F7BFF")
    })

    AutoWalkTab:Slider({
        Title = "⚡ Playspeed Auto Walk",
        Min = 1, Max = 25, Value = 1,
        Callback = function(value)
            playSpeed = value
            if isPlaying then
                StatusPara:SetDesc(string.format("Status: Berjalan (Speed: %dx)", playSpeed))
            end
        end
    })

    AutoWalkTab:Space()

    -- 1. TOMBOL LOAD (Otomatis Scan & Match)
    LoadBtn = AutoWalkTab:Button({
        Title = "☁️ Load Auto Walk (Auto Detect)",
        Callback = function()
            if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
            
            LoadBtn:SetTitle("⏳ Sedang Mencari Rute...")
            WindUI:Notify({Title="Scanning", Content="Mencari rute yang cocok untuk map ini...", Duration=2})
            
            -- Eksekusi proses pencarian di background agar tidak freeze (lag)
            task.spawn(function()
                local success, msg = AutoScanAndLoadRoute()
                
                if success then
                    WindUI:Notify({Title="Rute Ditemukan!", Content=msg, Duration=2, Icon="check"})
                    StatusPara:SetDesc("Status: Siap! (" .. loadedRouteName .. ")")
                    
                    -- Sembunyikan tombol Load, Tampilkan Play & Stop
                    SetUIVisible(LoadBtn, false)
                    SetUIVisible(PlayBtn, true)
                    SetUIVisible(StopBtn, true)
                else
                    WindUI:Notify({Title="Gagal Load", Content=msg, Duration=4, Icon="x"})
                    LoadBtn:SetTitle("☁️ Load Auto Walk (Coba Lagi)")
                    StatusPara:SetDesc("Status: Gagal menemukan rute.")
                end
            end)
        end
    })

    -- 2. TOMBOL PLAY (Disembunyikan di awal)
    PlayBtn = AutoWalkTab:Button({
        Title = "▶️ Play Auto Walk",
        Callback = function()
            if not isUnlocked then return end
            if isPlaying then return end
            if not RouteData then return WindUI:Notify({Title="Error", Content="Data rute kosong!"}) end
            
            isPlaying = true
            SetUIVisible(PlayBtn, false) -- Sembunyikan saat sedang jalan
            
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            -- Mulai dari titik terdekat (Tidak mengulang dari awal)
            local floatIndex = hrp and FindNearestFrameIndex(RouteData, hrp.Position) or 1
            
            WindUI:Notify({Title="Auto Walk", Content="Berjalan dari titik terdekat!", Duration=2})
            StatusPara:SetDesc(string.format("Status: Berjalan (%dx Speed)", playSpeed))
            
            if playConn then playConn:Disconnect() end
            playConn = RunService.Stepped:Connect(function()
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not hum then return end
                
                -- Bekukan Fisika agar tidak nyangkut tembok saat kecepatan 25x
                hrp.Anchored = true 
                
                local actualIndex = math.floor(floatIndex)
                
                if RouteData[actualIndex] then
                    local currentData = RouteData[actualIndex]
                    
                    hrp.CFrame = currentData.cframe
                    hrp.AssemblyLinearVelocity = currentData.vel
                    if hum:GetState() ~= currentData.state then hum:ChangeState(currentData.state) end
                    
                    -- Kalkulasi rotasi kepala/badan (AutoRotate manual)
                    local nextData = RouteData[actualIndex + 1]
                    if nextData then
                        local moveDir = (nextData.cframe.Position - currentData.cframe.Position)
                        local flatMoveDir = Vector3.new(moveDir.X, 0, moveDir.Z) 
                        if flatMoveDir.Magnitude > 0.02 then hum:Move(flatMoveDir.Unit, false) 
                        else hum:Move(Vector3.zero, false) end
                    else 
                        hum:Move(Vector3.zero, false) 
                    end
                    
                    -- Mempercepat playback sesuai nilai slider (1x - 25x)
                    floatIndex = floatIndex + playSpeed
                else
                    -- Rute Selesai
                    if playConn then playConn:Disconnect() end
                    hrp.Anchored = false
                    hum:Move(Vector3.zero, false) 
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    
                    isPlaying = false
                    StatusPara:SetDesc("Status: Tujuan Tercapai.")
                    WindUI:Notify({Title="Selesai", Content="Tujuan rute telah dicapai!", Duration=2})
                    SetUIVisible(PlayBtn, true) -- Munculkan Play lagi
                end
            end)
        end
    })

    -- 3. TOMBOL STOP (Disembunyikan di awal)
    StopBtn = AutoWalkTab:Button({
        Title = "⏹️ Stop Auto Walk",
        Callback = function()
            if not RouteData then return end -- Cegah stop jika rute belum di-load
            
            if playConn then playConn:Disconnect() end
            local char = lp.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp then hrp.Anchored = false end
                if hum then hum:Move(Vector3.zero, false) end
            end
            
            isPlaying = false
            StatusPara:SetDesc("Status: Dihentikan (Standby).")
            WindUI:Notify({Title="Stop", Content="Auto Walk dihentikan.", Duration=1.5})
            SetUIVisible(PlayBtn, true) -- Pastikan tombol Play muncul kembali
        end
    })

    -- ==========================================
    -- INISIALISASI UI
    -- ==========================================
    -- Sembunyikan Play dan Stop di awal karena belum ada rute yang ter-load
    SetUIVisible(PlayBtn, false)
    SetUIVisible(StopBtn, false)
end
