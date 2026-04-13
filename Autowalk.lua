return function(WindUI, AutoWalkTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local lp = Players.LocalPlayer

    -- ==========================================
    -- KONFIGURASI GITHUB API (PENTING!)
    -- ==========================================
    -- Sesuaikan dengan repository tempat kamu menyimpan file JSON rekaman
    local GITHUB_OWNER = "cyberkeyzone" 
    local GITHUB_REPO = "Awsystem" -- Atau ganti "Imt" jika kamu simpan di repo Imt
    local GITHUB_FOLDER = "Routes" -- Nama folder di dalam repo tempat nyimpen JSON (Kosongkan "" jika di luar folder)

    -- ==========================================
    -- VARIABEL SISTEM
    -- ==========================================
    local isUnlocked = (lp.Name == "myzzkey") 
    local currentPlaceId = game.PlaceId
    
    local cacheFolderName = "SYNC_AutoWalkCache"
    if isfolder and not isfolder(cacheFolderName) then makefolder(cacheFolderName) end

    -- Cloud Variables
    local CloudRoutesData = {} -- Menyimpan link download spesifik tiap file dari GitHub
    local selectedCloudRoute = "Kosong"
    
    -- Local Variables
    local AvailableLocalRoutes = {}
    local selectedLocalRoute = "Kosong"
    local RouteData = nil
    
    local isPlaying = false
    local playConn = nil
    local playbackIndex = 1
    local playSpeed = 1 

    -- Deklarasi UI Global
    local CloudDropdown, LocalDropdown

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
        AvailableLocalRoutes = {}
        if listfiles and isfolder(cacheFolderName) then
            for _, filePath in ipairs(listfiles(cacheFolderName)) do
                if filePath:match("%.json$") then
                    local fileName = filePath:match("([^/\\]+)$")
                    table.insert(AvailableLocalRoutes, fileName)
                end
            end
        end
        table.sort(AvailableLocalRoutes)
        return AvailableLocalRoutes
    end

    -- FUNGSI BARU: Mengambil daftar file langsung dari GitHub API
    local function FetchGithubRoutes()
        local apiUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", GITHUB_OWNER, GITHUB_REPO, GITHUB_FOLDER)
        if GITHUB_FOLDER == "" then
            apiUrl = string.format("https://api.github.com/repos/%s/%s/contents", GITHUB_OWNER, GITHUB_REPO)
        end

        local success, result = pcall(function() return game:HttpGet(apiUrl) end)
        
        if success and result and not result:match("404: Not Found") then
            local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(result) end)
            if decodeSuccess and type(decodedData) == "table" then
                local list = {}
                CloudRoutesData = {} -- Reset data lama
                
                for _, file in ipairs(decodedData) do
                    -- Hanya ambil file yang berakhiran .json
                    if file.name and file.name:match("%.json$") then
                        table.insert(list, file.name)
                        CloudRoutesData[file.name] = file.download_url -- Simpan raw URL-nya
                    end
                end
                table.sort(list)
                return true, list
            end
        end
        return false, "Gagal terhubung ke GitHub atau folder tidak ditemukan."
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
        Title = "Cloud Auto Walk System",
        Desc = "Scan daftar rute langsung dari GitHub, Download, dan jalankan otomatis. (Place ID: " .. tostring(currentPlaceId) .. ")",
        Color = Color3.fromHex("#0F7BFF")
    })

    local InfoPara = AutoWalkTab:Paragraph({
        Title = "Status Sistem",
        Desc = "Siap digunakan. Silakan scan rute dari Cloud atau pilih dari Local Cache.",
        Color = Color3.fromHex("#29F89B")
    })

    -- ==========================================
    -- 1. CLOUD DOWNLOADER (DARI GITHUB)
    -- ==========================================
    AutoWalkTab:Divider()
    
    AutoWalkTab:Button({
        Title = "🔄 Scan Rute di GitHub",
        Icon = "search",
        Callback = function()
            if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
            WindUI:Notify({Title="Scanning", Content="Mencari file .json di GitHub...", Duration=1.5})
            
            local success, dataList = FetchGithubRoutes()
            if success then
                if #dataList > 0 then
                    CloudDropdown:Refresh(dataList)
                    WindUI:Notify({Title="Sukses", Content="Menemukan " .. #dataList .. " rute di Cloud!", Duration=2, Icon="check"})
                else
                    CloudDropdown:Refresh({"Kosong (Tidak ada .json)"})
                    WindUI:Notify({Title="Kosong", Content="Tidak ada file JSON di folder GitHub tersebut.", Duration=2})
                end
            else
                WindUI:Notify({Title="Error API", Content=dataList, Duration=3, Icon="x"})
            end
        end
    })

    CloudDropdown = AutoWalkTab:Dropdown({
        Title = "☁️ Pilih Rute dari Cloud",
        Values = {"Klik Scan Rute Dulu"},
        Value = "Klik Scan Rute Dulu",
        SearchBarEnabled = true,
        Callback = function(opt)
            selectedCloudRoute = type(opt) == "table" and opt.Title or opt
        end
    })

    AutoWalkTab:Button({
        Title = "⬇️ Download & Masukkan ke Cache",
        Icon = "download",
        Callback = function()
            if not isUnlocked then return end
            if not CloudRoutesData[selectedCloudRoute] then
                return WindUI:Notify({Title="Error", Content="Pilih rute yang valid dari Cloud Dropdown!", Duration=2})
            end
            
            local downloadUrl = CloudRoutesData[selectedCloudRoute]
            WindUI:Notify({Title="Mendownload", Content="Mengunduh " .. selectedCloudRoute .. "...", Duration=1.5})
            
            local success, result = pcall(function() return game:HttpGet(downloadUrl) end)
            if success and result then
                local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(result) end)
                
                if decodeSuccess then
                    -- Sistem Validasi Place ID Otomatis
                    if decodedData.PlaceId and tostring(decodedData.PlaceId) ~= tostring(currentPlaceId) then
                        return WindUI:Notify({Title="Ditolak", Content="Rute ini untuk game lain! (Beda Place ID)", Duration=3, Icon="x"})
                    end

                    -- Simpan ke Cache Lokal
                    if writefile then
                        local savePath = cacheFolderName .. "/" .. selectedCloudRoute
                        writefile(savePath, result)
                        WindUI:Notify({Title="Sukses", Content=selectedCloudRoute .. " berhasil disimpan ke Cache!", Duration=2, Icon="check"})
                        
                        -- Auto refresh Local Cache Dropdown
                        local list = LoadLocalCache()
                        if #list == 0 then table.insert(list, "Kosong") end
                        if LocalDropdown then LocalDropdown:Refresh(list) end
                    end
                else
                    WindUI:Notify({Title="Error", Content="File JSON rusak/tidak valid.", Duration=2})
                end
            else
                WindUI:Notify({Title="Error", Content="Gagal mengunduh dari GitHub.", Duration=2})
            end
        end
    })

    -- ==========================================
    -- 2. LOCAL CACHE MANAGER
    -- ==========================================
    AutoWalkTab:Divider()
    
    LocalDropdown = AutoWalkTab:Dropdown({
        Title = "📁 Pilih Rute (Local Cache)",
        Values = {"Kosong"},
        Value = "Kosong",
        SearchBarEnabled = true,
        Callback = function(opt)
            selectedLocalRoute = type(opt) == "table" and opt.Title or opt
        end
    })

    AutoWalkTab:Button({
        Title = "🗑️ Hapus Semua Cache Rute",
        Icon = "trash",
        Callback = function()
            if not isUnlocked then return end
            if isPlaying then return WindUI:Notify({Title="Gagal", Content="Matikan Auto Walk terlebih dahulu!"}) end
            
            if isfolder(cacheFolderName) then
                if delfolder then
                    delfolder(cacheFolderName)
                    makefolder(cacheFolderName)
                else
                    for _, file in ipairs(listfiles(cacheFolderName)) do
                        if delfile then delfile(file) end
                    end
                end
                
                WindUI:Notify({Title="Cache Bersih", Content="Semua rute lokal dihapus.", Duration=2, Icon="trash"})
                local list = LoadLocalCache()
                if #list == 0 then table.insert(list, "Kosong") end
                if LocalDropdown then LocalDropdown:Refresh(list) end
            end
        end
    })

    -- ==========================================
    -- 3. PLAYBACK CONTROLS & SPEED
    -- ==========================================
    AutoWalkTab:Divider()
    
    AutoWalkTab:Slider({
        Title = "Kecepatan (Speed Multiplier)",
        Min = 1, Max = 25, Value = 1,
        Callback = function(value)
            playSpeed = value
            if not isPlaying then
                InfoPara:SetDesc("Speed diatur ke: " .. playSpeed .. "x")
            end
        end
    })

    AutoWalkTab:Button({
        Title = "▶️ Mulai Auto Walk",
        Icon = "play",
        Callback = function()
            if not isUnlocked then return WindUI:Notify({Title="Terkunci", Content="Akses ditolak."}) end
            if isPlaying then return WindUI:Notify({Title="Gagal", Content="Sudah berjalan!"}) end
            if selectedLocalRoute == "Kosong" then return WindUI:Notify({Title="Error", Content="Pilih rute dari Local Cache!"}) end
            
            local filePath = cacheFolderName .. "/" .. selectedLocalRoute
            if not isfile(filePath) then return WindUI:Notify({Title="Error", Content="File tidak ada di cache!"}) end
            
            local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
            if not decodeSuccess or not decodedData.Frames then
                return WindUI:Notify({Title="Error", Content="Data rekaman rusak!"})
            end

            -- Validasi Terakhir Place ID
            if decodedData.PlaceId and tostring(decodedData.PlaceId) ~= tostring(currentPlaceId) then
                return WindUI:Notify({Title="Aman", Content="Auto Walk dibatalkan. Rute ini untuk Map lain!", Duration=3})
            end

            RouteData = DeserializeData(decodedData.Frames)
            
            isPlaying = true
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            -- Cari posisi terdekat agar smooth
            local floatIndex = hrp and FindNearestFrameIndex(RouteData, hrp.Position) or 1
            
            WindUI:Notify({Title="Mulai", Content="Menjalankan rute (".. playSpeed .."x speed)", Duration=2})
            
            if playConn then playConn:Disconnect() end
            playConn = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not hum then return end
                
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

                    InfoPara:SetDesc(string.format("🟢 Berjalan: %s\nFrame: %d / %d\nKecepatan: %dx", selectedLocalRoute, actualIndex, #RouteData, playSpeed))
                    
                    -- Loncati frame sesuai Speed Multiplier
                    floatIndex = floatIndex + playSpeed
                else
                    if playConn then playConn:Disconnect() end
                    hum:Move(Vector3.zero, false) 
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    
                    isPlaying = false
                    InfoPara:SetDesc("✅ Rute Selesai / Idle.")
                    WindUI:Notify({Title="Selesai", Content="Rute Auto Walk tercapai!", Duration=2})
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
            InfoPara:SetDesc("⏹️ Dihentikan paksa / Idle.")
            WindUI:Notify({Title="Stop", Content="Berhasil dihentikan.", Duration=1.5})
        end
    })

    -- INIT CACHE LOKAL SAAT DIBUKA
    local initList = LoadLocalCache()
    if #initList == 0 then table.insert(initList, "Kosong") end
    if LocalDropdown then LocalDropdown:Refresh(initList) end
end
