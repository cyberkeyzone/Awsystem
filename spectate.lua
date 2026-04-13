return function(WindUI, OptionalTab)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    -- ==========================================
    -- UI HEADER
    -- ==========================================
    OptionalTab:Paragraph({
        Title = "Spectate System",
        Desc = "Pantau pergerakan pemain lain di server secara real-time.",
        Color = Color3.fromHex("#0F7BFF")
    })

    -- ==========================================
    -- FUNGSI GET PLAYER LIST
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

    -- ==========================================
    -- UI ELEMENTS (SPECTATE)
    -- ==========================================
    local selectedTargetPlayer = ""
    
    local PlayerDropdown = OptionalTab:Dropdown({
        Title = "👤 Pilih Player",
        Values = GetPlayerList(),
        Value = "Pilih Pemain",
        SearchBarEnabled = true,
        Callback = function(opt)
            selectedTargetPlayer = type(opt) == "table" and opt.Title or opt
        end
    })

    OptionalTab:Button({
        Title = "🔄 Refresh Daftar Player",
        Callback = function()
            if PlayerDropdown then
                PlayerDropdown:Refresh(GetPlayerList())
                WindUI:Notify({Title="Refresh", Content="Daftar pemain diperbarui!", Duration=1.5})
            end
        end
    })

    OptionalTab:Divider()

    OptionalTab:Button({
        Title = "👁️ Spectate Player",
        Callback = function()
            if selectedTargetPlayer == "" or selectedTargetPlayer == "Pilih Pemain" or selectedTargetPlayer == "Tidak ada pemain lain" then 
                return WindUI:Notify({Title="Error", Content="Pilih pemain terlebih dahulu!", Duration=2, Icon="x"}) 
            end
            
            -- Ekstrak username asli dari format "DisplayName (@Username)"
            local targetName = string.match(selectedTargetPlayer, "@([^%)]+)") or selectedTargetPlayer
            local targetPlr = Players:FindFirstChild(targetName)
            
            if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = targetPlr.Character.Humanoid
                WindUI:Notify({Title="Spectating", Content="Menonton: " .. targetName, Duration=2, Icon="check"})
            else
                WindUI:Notify({Title="Gagal", Content="Karakter pemain tidak ditemukan / belum spawn!", Duration=2, Icon="x"})
            end
        end
    })

    OptionalTab:Button({
        Title = "🛑 Stop Spectate (Kembali)",
        Callback = function()
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
                WindUI:Notify({Title="Stop", Content="Kamera kembali normal.", Duration=2})
            else
                WindUI:Notify({Title="Gagal", Content="Karaktermu belum spawn!", Duration=2})
            end
        end
    })
end
