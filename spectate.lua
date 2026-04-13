return function(WindUI, OptionalTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    OptionalTab:Paragraph({
        Title = "Force Spectate System",
        Desc = "Kamera akan terus memaksa mengunci target dan memaksa server merender area di sekitarnya.",
        Color = Color3.fromHex("#0F7BFF")
    })

    -- ==========================================
    -- AUTO-UPDATE PLAYER LIST
    -- ==========================================
    local function GetPlayerList()
        local list = {}
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp then
                table.insert(list, v.DisplayName .. " (@" .. v.Name .. ")")
            end
        end
        table.sort(list)
        if #list == 0 then table.insert(list, "Tidak ada pemain lain") end
        return list
    end

    local selectedTargetPlayer = ""
    local spectateConn = nil
    
    local PlayerDropdown = OptionalTab:Dropdown({
        Title = "👤 Pilih Player",
        Values = GetPlayerList(),
        Value = "Pilih Pemain",
        SearchBarEnabled = true,
        Callback = function(opt)
            selectedTargetPlayer = type(opt) == "table" and opt.Title or opt
        end
    })

    -- Refresh otomatis jika ada pemain yang masuk/keluar
    Players.PlayerAdded:Connect(function()
        if PlayerDropdown then pcall(function() PlayerDropdown:Refresh(GetPlayerList()) end) end
    end)
    Players.PlayerRemoving:Connect(function()
        if PlayerDropdown then pcall(function() PlayerDropdown:Refresh(GetPlayerList()) end) end
    end)

    OptionalTab:Divider()

    -- ==========================================
    -- LOGIKA SPECTATE
    -- ==========================================
    local function StopSpectating()
        if spectateConn then 
            spectateConn:Disconnect() 
            spectateConn = nil
        end
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = lp.Character.Humanoid
        end
    end

    OptionalTab:Button({
        Title = "👁️ Force Spectate Player",
        Callback = function()
            if selectedTargetPlayer == "" or selectedTargetPlayer == "Pilih Pemain" or selectedTargetPlayer == "Tidak ada pemain lain" then 
                return WindUI:Notify({Title="Error", Content="Pilih pemain terlebih dahulu!", Duration=2, Icon="x"}) 
            end
            
            local targetName = string.match(selectedTargetPlayer, "@([^%)]+)") or selectedTargetPlayer
            
            WindUI:Notify({Title="Force Lock", Content="Menghubungkan ke " .. targetName .. "...", Duration=2})
            StopSpectating() 
            
            -- LOOP TAK TERBATAS: Memaksa menembus StreamingEnabled
            spectateConn = RunService.RenderStepped:Connect(function()
                local tPlr = Players:FindFirstChild(targetName)
                if tPlr and tPlr.Character then
                    -- Cari bagian tubuh mana saja yang dirender oleh server
                    local hum = tPlr.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = tPlr.Character:FindFirstChild("HumanoidRootPart")
                    local head = tPlr.Character:FindFirstChild("Head")
                    local anyPart = tPlr.Character:FindFirstChildWhichIsA("BasePart")
                    
                    local subject = hum or hrp or head or anyPart
                    
                    if subject then
                        camera.CameraSubject = subject
                        
                        -- PING SERVER: Paksa server mengirim data visual area sekitar target ke HP kita
                        if subject:IsA("BasePart") then
                            pcall(function() lp:RequestStreamAroundAsync(subject.Position) end)
                        elseif subject:IsA("Humanoid") and subject.RootPart then
                            pcall(function() lp:RequestStreamAroundAsync(subject.RootPart.Position) end)
                        end
                    end
                end
            end)
        end
    })

    OptionalTab:Button({
        Title = "🛑 Stop Spectate",
        Callback = function()
            StopSpectating()
            WindUI:Notify({Title="Stop", Content="Kamera kembali ke karaktermu.", Duration=2})
        end
    })
end
