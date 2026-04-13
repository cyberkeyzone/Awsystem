return function(WindUI, AutoWalkTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local lp = Players.LocalPlayer

    -- ==========================================
    -- VARIABEL & KONFIGURASI
    -- ==========================================
    local isUnlocked = (lp.Name == "myzzkey") 
    local currentPlaceId = game.PlaceId
    
    -- [!] UBAH INI KE LINK RAW FOLDER GITHUB KAMU (Pastikan diakhiri dengan garis miring /)
    -- Contoh: Jika file kamu ada di "Imt/main/Routes/Rute1.json", maka URL-nya:
    local GITHUB_REPO_URL = "https://raw.githubusercontent.com/cyberkeyzone/Imt/refs/heads/main/Routes/"

    local cacheFolderName = "SYNC_AutoWalkCache"
    if isfolder and not isfolder(cacheFolderName) then makefolder(cacheFolderName) end

    local AvailableRoutes = {}
    local selectedRoute = "Kosong"
    local RouteData = nil
    
    local isPlaying = false
    local playConn = nil
    local playbackIndex = 1
    local playSpeed = 1 -- Default 1x

    -- ==========================================
    -- FUNGSI INTERNAL (DATA & CACHE)
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

    local function LoadLocalCache()
        AvailableRoutes = {}
        if listfiles and isfolder(cacheFolderName) then
            for _, filePath in ipairs(listfiles(cacheFolderName)) do
                if filePath:match("%.json$") then
                    local fileName = filePath:match("([^/\\]+)$")
                    table.insert(AvailableRoutes, fileName)
                end
            end
        end
        return AvailableRoutes
    end

    local function DownloadRouteFromGithub(fileName)
        -- Pastikan ekstensi .json
        if not fileName:match("%.json$") then fileName = fileName .. ".json" end
        
        local url = GITHUB_REPO_URL .. fileName
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)

        if success and result and not result:match("404: Not Found") then
            -- Cek apakah file JSON valid dan PlaceId cocok (Format Baru)
            local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(result) end)
            
            if decodeSuccess then
                -- Sistem Validasi Place ID
                if decodedData.PlaceId and tostring(decodedData.PlaceId) ~= tostring(currentPlaceId) then
                    return false, "Route ini bukan untuk Map/Game ini! (Beda Place ID)"
                end

                -- Simpan ke Cache Lokal
                local savePath = cacheFolderName .. "/" .. fileName
                if writefile then
                    writefile(savePath, result)
                    return true, "Berhasil mendownload & cache: " .. fileName
                end
            else
                return false, "Format JSON rusak/tidak valid dari GitHub."
            end
        end
        return false, "Gagal mendownload. File tidak ditemukan di GitHub."
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

    -- ==========================================
    -- UI ELEMENTS (WIND UI)
    -- ==========================================
    AutoWalkTab:Paragraph({
        Title = "Cloud Auto Walk",
        Desc = "Download rute JSON dari GitHub dan jalankan secara otomatis. Dilengkapi deteksi Map (Place ID) agar tidak error.",
        Color = Color3.fromHex("#0F7BFF")
    })

    local InfoPara = AutoWalkTab:Paragraph({
        Title = "Status",
        Desc = "Idle. Place ID saat ini: " .. tostring(currentPlaceId),
        Color = Color3.fromHex("#29F89B")
    })

    -- 1. CLOUD DOWNLOADER
    AutoWalkTab:Divider()
    local githubInputText = ""
    AutoWalkTab:Input({
        Title = "Download JSON dari GitHub",
        Placeholder = "Ketik nama file (contoh: Rute_A.json)",
        Callback = function(text)
            githubInputText = text
        end
    })

    local RouteDropdown -- Deklarasi awal agar bisa di-refresh

    AutoWalkTab:Button({
        Title = "☁️ Redownload / Fetch dari GitHub",
        Icon = "download",
        Callback = function()
            if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
            if githubInputText == "" then return WindUI:Notify({Title="Error", Content="Masukkan nama file terlebih dahulu!", Duration=2}) end
            
            WindUI:Notify({Title="Mendownload", Content="Mengambil data dari GitHub...", Duration=1.5})
            local success, msg = DownloadRouteFromGithub(githubInputText)
            
            if success then
                WindUI:Notify({Title="Sukses", Content=msg, Duration=2, Icon="check"})
                -- Refresh dropdown
                local list = LoadLocalCache()
                if #list == 0 then table.insert(list, "Kosong") end
                if RouteDropdown then RouteDropdown:Refresh(list) end
            else
                WindUI:Notify({Title="Gagal", Content=msg, Duration=3, Icon="x"})
            end
        end
    })

    -- 2. LOCAL CACHE MANAGER
    AutoWalkTab:Divider()
    RouteDropdown = AutoWalkTab:Dropdown({
        Title = "Pilih Rute (Local Cache)",
        Values = {"Kosong"},
        Value = "Kosong",
        SearchBarEnabled = true,
        Callback = function(opt)
            selectedRoute = type(opt) == "table" and opt.Title or opt
        end
    })

    AutoWalkTab:Button({
        Title = "🗑️ Hapus Semua Cache JSON",
        Icon = "trash",
        Callback = function()
            if not isUnlocked then return end
            if isPlaying then return WindUI:Notify({Title="Gagal", Content="Matikan Auto Walk terlebih dahulu!"}) end
            
            if isfolder(cacheFolderName) then
                if delfolder then
                    delfolder(cacheFolderName)
                    makefolder(cacheFolderName)
                else
                    -- Fallback untuk executor yg tidak punya delfolder
                    for _, file in ipairs(listfiles(cacheFolderName)) do
                        if delfile then delfile(file) end
                    end
                end
                
                WindUI:Notify({Title="Cache Dihapus", Content="Semua file JSON lokal telah dibersihkan.", Duration=2, Icon="trash"})
                local list = LoadLocalCache()
                if #list == 0 then table.insert(list, "Kosong") end
                if RouteDropdown then RouteDropdown:Refresh(list) end
            end
        end
    })

    -- 3. PLAYBACK CONTROLS & SPEED
    AutoWalkTab:Divider()
    AutoWalkTab:Slider({
        Title = "Kecepatan Playback (Speed)",
        Min = 1,
        Max = 25,
        Value = 1,
        Callback = function(value)
            playSpeed = value
            InfoPara:SetDesc("Speed diatur ke: " .. playSpeed .. "x")
        end
    })

    local PlayBtn = AutoWalkTab:Button({
        Title = "▶️ Mulai Auto Walk",
        Icon = "play",
        Callback = function()
            if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
            if isPlaying then return WindUI:Notify({Title="Gagal", Content="Sudah berjalan!"}) end
            if selectedRoute == "Kosong" then return WindUI:Notify({Title="Error", Content="Pilih rute dari cache!"}) end
            
            -- Load JSON dari Cache
            local filePath = cacheFolderName .. "/" .. selectedRoute
            if not isfile(filePath) then return WindUI:Notify({Title="Error", Content="File tidak ditemukan di cache!"}) end
            
            local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
            if not decodeSuccess or not decodedData.Frames then
                return WindUI:Notify({Title="Error", Content="File JSON rusak atau tidak kompatibel!"})
            end

            -- Validasi Keamanan Place ID
            if decodedData.PlaceId and tostring(decodedData.PlaceId) ~= tostring(currentPlaceId) then
                return WindUI:Notify({Title="Aman", Content="Auto Walk dibatalkan. Rute ini untuk Map lain!", Duration=3})
            end

            RouteData = DeserializeData(decodedData.Frames)
            
            -- Mulai Playback
            isPlaying = true
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            -- Cari posisi terdekat
            local floatIndex = hrp and FindNearestFrameIndex(RouteData, hrp.Position) or 1
            
            WindUI:Notify({Title="Mulai", Content="Auto Walk berjalan (".. playSpeed .."x speed)", Duration=2})
            
            if playConn then playConn:Disconnect() end
            playConn = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not hum then return end
                
                -- Kalkulasi Speed Multiplier
                local actualIndex = math.floor(floatIndex)
                
                if RouteData[actualIndex] then
                    local currentData = RouteData[actualIndex]
                    local nextData = RouteData[actualIndex + 1]
                    
                    hrp.CFrame = currentData.cframe
                    hrp.AssemblyLinearVelocity = currentData.vel
                    if hum:GetState() ~= currentData.state then hum:ChangeState(currentData.state) end
                    
                    if nextData then
                        local moveDir = (nextData.cframe.Position - currentData.cframe.Position)
                        local flatMoveDir = Vector3.new(moveDir.X, 0, moveDir.Z) 
                        if flatMoveDir.Magnitude > 0.02 then hum:Move(flatMoveDir.Unit, false) 
                        else hum:Move(Vector3.zero, false) end
                    else hum:Move(Vector3.zero, false) end

                    InfoPara:SetDesc(string.format("Menjalankan: %s\nFrame: %d / %d (Speed: %dx)", selectedRoute, actualIndex, #RouteData, playSpeed))
                    
                    -- Loncat Frame sesuai kecepatan
                    floatIndex = floatIndex + playSpeed
                else
                    -- Selesai
                    if playConn then playConn:Disconnect() end
                    hum:Move(Vector3.zero, false) 
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    
                    isPlaying = false
                    InfoPara:SetDesc("Status: Selesai / Idle.")
                    WindUI:Notify({Title="Selesai", Content="Rute Auto Walk selesai!", Duration=2})
                end
            end)
        end
    })

    AutoWalkTab:Button({
        Title = "⏹️ Stop Auto Walk",
        Icon = "square",
        Callback = function()
            if playConn then playConn:Disconnect() end
            local char = lp.Character
            if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid"):Move(Vector3.zero, false) end
            
            isPlaying = false
            InfoPara:SetDesc("Status: Auto Walk dihentikan paksa.")
            WindUI:Notify({Title="Stop", Content="Berhasil dihentikan.", Duration=1.5})
        end
    })

    -- INIT CACHE SAAT DIBUKA
    local initList = LoadLocalCache()
    if #initList == 0 then table.insert(initList, "Kosong") end
    if RouteDropdown then RouteDropdown:Refresh(initList) end
end
