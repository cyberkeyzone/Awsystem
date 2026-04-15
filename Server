return function(WindUI, ServerTab)
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")

    ServerTab:Paragraph({
        Title = "🌐 Server System (Auto Hop)",
        Desc = "Sistem ini akan melacak dan memindahkanmu ke Server Publik yang PALING SEPI (0-1 Pemain) agar serasa bermain di Private Server.",
        Color = Color3.fromHex("#4287f5")
    })

    ServerTab:Button({
        Title = "🚀 Go To Private / Empty SERVER",
        Callback = function()
            WindUI:Notify({
                Title = "Melacak Server...",
                Content = "Sedang mencari server paling kosong, harap tunggu beberapa detik!",
                Duration = 4
            })

            -- Menjalankan pencarian server di background agar UI tidak freeze
            task.spawn(function()
                local placeId = game.PlaceId
                local currentJobId = game.JobId
                
                -- Menggunakan sortOrder=Asc akan mengurutkan server dari pemain yang paling sedikit (0, 1, 2...)
                local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
                
                -- Mencoba request langsung ke Roblox API
                local success, result = pcall(function()
                    return game:HttpGet(url)
                end)

                -- Fallback (Bypass) menggunakan RoProxy jika eksekutor memblokir API Roblox
                if not success then
                    url = "https://games.roproxy.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
                    success, result = pcall(function()
                        return game:HttpGet(url)
                    end)
                end

                if success and result then
                    local decoded = HttpService:JSONDecode(result)
                    if decoded and decoded.data then
                        for _, server in ipairs(decoded.data) do
                            -- Syarat: Server tidak penuh, dan bukan server kita saat ini
                            if server.playing and server.playing < server.maxPlayers and server.id ~= currentJobId then
                                WindUI:Notify({
                                    Title = "Server Ditemukan!",
                                    Content = "Menemukan server dengan " .. tostring(server.playing) .. " pemain. Teleporting...",
                                    Duration = 5
                                })
                                
                                task.wait(1.5) -- Jeda sebentar sebelum teleport
                                
                                pcall(function()
                                    TeleportService:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
                                end)
                                return
                            end
                        end
                    end
                end
                
                WindUI:Notify({
                    Title = "Gagal Teleport",
                    Content = "Tidak dapat menemukan server kosong saat ini. Silakan coba lagi nanti.",
                    Duration = 3
                })
            end)
        end
    })
    
    ServerTab:Button({
        Title = "🔄 Rejoin Current Server",
        Callback = function()
            WindUI:Notify({
                Title = "Rejoining...",
                Content = "Masuk kembali ke server ini untuk mereset game.",
                Duration = 3
            })
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        end
    })
end
