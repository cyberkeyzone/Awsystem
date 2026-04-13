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
    local GITHUB_FOLDER = "Routes" -- Folder tempat menyimpan JSON di GitHub

    -- ==========================================
    -- VARIABEL SISTEM & STATE
    -- ==========================================
    local isUnlocked = (lp.Name == "myzzkey") 
    local currentPlaceId = game.PlaceId
    
    local cacheFolderName = "Recording" -- Sinkronisasi dengan folder hasil rekaman panel Record
    if isfolder and not isfolder(cacheFolderName) then makefolder(cacheFolderName) end

    local RouteData = nil
    local loadedRouteName = ""
    
    local isPlaying = false
    local playConn = nil
    local playSpeed = 1 

    -- Deklarasi UI Global
    local LoadBtn, PlayBtn, StopBtn, StatusPara

    -- ==========================================
    -- FUNGSI INTERNAL
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
    -- FUNGSI SMART SCANNER (LOKAL & CLOUD)
    -- ==========================================
    local function ScanLocalCache()
        if not listfiles or not isfolder(cacheFolderName) then return false end
        
        for _, filePath in ipairs(listfiles(cacheFolderName)) do
            if filePath:match("%.json$") then
                local fileName = filePath:match("([^/\\]+)$")
                local success, fileData = pcall(function() return readfile(filePath) end)
                
                if success and fileData then
                    local jsonSuccess, jsonData = pcall(function() return HttpService:JSONDecode(fileData) end)
                    if jsonSuccess and jsonData.PlaceId and tostring(jsonData.PlaceId) == tostring(currentPlaceId) then
                        local framesToProcess = jsonData.Frames or jsonData
                        RouteData = DeserializeData(framesToProcess)
                        loadedRouteName = fileName
                        return true, "Rute ditemukan di memori Lokal: " .. fileName
                    end
                end
            end
        end
        return false, "Tidak ada di lokal."
    end

    local function ScanGithubCloud()
        local apiUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", GITHUB_OWNER, GITHUB_REPO, GITHUB_FOLDER)
        if GITHUB_FOLDER == "" then
            apiUrl = string.format("https://api.github.com/repos/%s/%s/contents", GITHUB_OWNER, GITHUB_REPO)
        end

        local success, result = pcall(function() return game:HttpGet(apiUrl) end)
        
        if success and result and not result:match("404: Not Found") then
            local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(result) end)
            
            if decodeSuccess and type(decodedData) == "table" then
                for _, file in ipairs(decodedData) do
                    if file.name and file.name:match("%.json$") then
                        StatusPara:SetDesc("Mendownload & mengecek: " .. file.name .. "...")
                        
                        local dlSuccess, dlResult = pcall(function() return game:HttpGet(file.download_url) end)
                        
                        if dlSuccess and dlResult then
                            local jsonSuccess, jsonData = pcall(function() return HttpService:JSONDecode(dlResult) end)
                            
                            -- SMART MATCHING: Cek PlaceId
                            if jsonSuccess and jsonData.PlaceId and tostring(jsonData.PlaceId) == tostring(currentPlaceId) then
                                local framesToProcess = jsonData.Frames or jsonData
                                RouteData = DeserializeData(framesToProcess)
                                loadedRouteName = file.name
                                
                                -- Save ke lokal agar next time tidak usah download
                                if writefile then pcall(function() writefile(cacheFolderName .. "/" .. file.name, dlResult) end) end
                                
                                return true, "Rute Cloud cocok: " .. file.name
                            end
                        end
                    end
                end
                return false, "Tidak ada rute di GitHub untuk Map ini (ID: " .. tostring(currentPlaceId) .. ")"
            end
        end
        return false, "Gagal terhubung ke GitHub atau Folder salah."
    end

    -- ==========================================
    -- UI ELEMENTS (WIND UI)
    -- ==========================================
    StatusPara = AutoWalkTab:Paragraph({
        Title = "Auto Walk (Smart Scanner)",
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

    -- 1. TOMBOL LOAD (Pencarian Cerdas)
    LoadBtn = AutoWalkTab:Button({
        Title = "☁️ Load Auto Walk (Cari Rute)",
        Callback = function()
            if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
            
            WindUI:Notify({Title="Scanning", Content="Mencari rute untuk map ini...", Duration=2})
            StatusPara:SetDesc("Status: Sedang mencari di memori HP...")
            
            task.spawn(function()
                -- 1. Cari di memori HP dulu (Cepat)
                local isLocalFound, localMsg = ScanLocalCache()
                
                if isLocalFound then
                    WindUI:Notify({Title="Rute Ditemukan!", Content=localMsg, Duration=2, Icon="check"})
                    StatusPara:SetDesc("Status: Siap! (" .. loadedRouteName .. ")")
                    SetUIVisible(LoadBtn, false)
                    SetUIVisible(PlayBtn, true)
                    SetUIVisible(StopBtn, true)
                    return
                end
                
                -- 2. Jika tidak ada di HP, baru cari di GitHub
                StatusPara:SetDesc("Status: Mencari ke GitHub Cloud...")
                local isCloudFound, cloudMsg = ScanGithubCloud()
                
                if isCloudFound then
                    WindUI:Notify({Title="Rute Ditemukan!", Content=cloudMsg, Duration=2, Icon="check"})
                    StatusPara:SetDesc("Status: Siap! (" .. loadedRouteName .. ")")
                    SetUIVisible(LoadBtn, false)
                    SetUIVisible(PlayBtn, true)
                    SetUIVisible(StopBtn, true)
                else
                    WindUI:Notify({Title="Gagal Load", Content=cloudMsg, Duration=4, Icon="x"})
                    StatusPara:SetDesc("Status: Rute untuk map ini belum dibuat.")
                end
            end)
        end
    })

    -- 2. TOMBOL PLAY
    PlayBtn = AutoWalkTab:Button({
        Title = "▶️ Play Auto Walk",
        Callback = function()
            if not isUnlocked or isPlaying or not RouteData then return end
            
            isPlaying = true
            SetUIVisible(PlayBtn, false)
            
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
                
                -- Matikan AutoRotate & Anchor agar tidak nyangkut / glitch kepala
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
                    SetUIVisible(PlayBtn, true) 
                end
            end)
        end
    })

    -- 3. TOMBOL STOP
    StopBtn = AutoWalkTab:Button({
        Title = "⏹️ Stop Auto Walk",
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
            SetUIVisible(PlayBtn, true)
        end
    })

    -- INISIALISASI
    SetUIVisible(PlayBtn, false)
    SetUIVisible(StopBtn, false)
end
