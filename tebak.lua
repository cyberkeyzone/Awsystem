return function(WindUI, TebakKataTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer

    -- ==========================================
    -- DATABASE KAMUS KATA (INDONESIA)
    -- ==========================================
    -- Kumpulan kata untuk bot. (Bisa kamu tambah sendiri nanti)
    local wordDatabaseStr = "AKU KAMU DIA MEREKA KITA KAMI BUKU MEJA KURSI PINTU JENDELA ATAP LANTAI DINDING RUMAH SEKOLAH PASAR JALAN KOTA DESA MOBIL MOTOR SEPEDA KERETA PESAWAT KAPAL LAUT SUNGAI GUNUNG HUTAN POHON BUNGA DAUN RUMPUT HEWAN KUCING ANJING BURUNG IKAN AYAM SAPI KAMBING BABI ULAR NYAMUK LALAT SEMUT MAKANAN MINUMAN NASI ROTI KUE SUSU AIR KOPI TEH BUAH APEL JERUK MANGGA PISANG SAYUR DAGING AYAM GORENG BAKAR REBUS MASAK DAPUR PIRING GELAS SENDOK GARPU PISAU BAJU CELANA SEPATU TOPI TAS DOMPET UANG EMAS PERAK BESI KAYU BATU TANAH PASIR API AIR ANGIN UDARA PANAS DINGIN HUJAN SALJU MATAHARI BULAN BINTANG LANGIT BUMI DUNIA ALAM WAKTU JAM MENIT DETIK HARI MINGGU BULAN TAHUN PAGI SIANG SORE MALAM HARI INI BESOK KEMARIN SEKARANG NANTI PERNAH SELALU KADANG JARANG BANYAK SEDIKIT BESAR KECIL PANJANG PENDEK TINGGI RENDAH BERAT RINGAN LUAS SEMPIT BARU LAMA BAIK BURUK BENAR SALAH CANTIK JELEK BERSIH KOTOR TERANG GELAP MUDA TUA HIDUP MATI SEHAT SAKIT KUAT LEMAH CEPAT LAMBAT KERAS LEMBUT KASAR HALUS MANIS PAHIT ASAM ASIN PEDAS MERAH KUNING HIJAU BIRU HITAM PUTIH ABU COKELAT UNGU ORANYE MERAH MUDA SATU DUA TIGA EMPAT LIMA ENAM TUJUH DELAPAN SEMBILAN SEPULUH RATUS RIBU JUTA MILIAR TRILIUN PERTAMA KEDUA KETIGA TERAKHIR AWAL TENGAH AKHIR ATAS BAWAH DEPAN BELAKANG KIRI KANAN DALAM LUAR DEKAT JAUH SINI SANA SITU MANA APA SIAPA KAPAN MENGAPA BAGAIMANA BERAPA YA TIDAK BUKAN MUNGKIN PASTI TENTU BISA BOLEH HARUS JANGAN SILAKAN TOLONG MAAF TERIMA KASIH SAMA HALO SELAMAT TINGGAL CINTA BENCI SUKA DUKA SENANG SEDIH MARAH TAKUT BERANI MALU BANGGA BINGUNG TERKEJUT BACA TULIS HITUNG BELAJAR MENGAJAR MAIN KERJA ISTIRAHAT TIDUR BANGUN DUDUK BERDIRI JALAN LARI LOMPAT TERBANG BERENANG NYANYI MENARI BICARA DENGAR LIHAT RASA CIUM SENTUH PEGANG BAWA LEMPAR TANGKAP PUKUL TENDANG POTONG SAMBUNG BUKA TUTUP MASUK KELUAR NAIK TURUN TARIK DORONG BELI JUAL BAYAR HUTANG PINJAM KEMBALI MINTA BERI DAPAT HILANG CARI TEMU SIMPAN BUANG PAKAI LEPAS GANTI CUCI MANDI SIKAT POTONG SISIR RIAS DANDAN OBAT DOKTER PERAWAT RUMAH SAKIT APOTEK POLISI TENTARA GURU MURID MAHASISWA DOSEN PEGAWAI KARYAWAN BOS PEMIMPIN PRESIDEN MENTERI GUBERNUR BUPATI CAMAT LURAH RT RW WARGA RAKYAT NEGARA BANGSA SUKU AGAMA BUDAYA SENI MUSIK FILM BUKU MAJALAH KORAN BERITA RADIO TELEVISI INTERNET KOMPUTER HANDPHONE TELEPON KAMERA FOTO VIDEO SURAT PESAN PAKET KOTAK TAS KARUNG BOTOL KALENG PLASTIK KERTAS KARDUS KACA BESI BAJA ALUMINIUM TEMBAGA KUNINGAN PERAK EMAS BERLIAN MUTIARA INTAN RUBI SAFIR ZAMRUD OPAL BATU BATA SEMEN PASIR KERIKIL TANAH LIAT KERAMIK MARMER GRANIT KAYU BAMBU ROTAN KARET KULIT KAIN KAPAS SUTRA WOL NILON POLIESTER PLASTIK KARET BUSA SPONS GABUS KAWAT TALI BENANG PITA RANTAI ENGSEL PAKU SEKRUP BAUT MUR LEM SELOTIP LAKBAN TALI RAFIA KARET GELANG PENITI JARUM PENTUL KANCING RITSLETING SABUK GESPER DASI SYAL TOPI HELM PAYUNG JAS HUJAN MANTEL JAKET KEMEJA KAOS GAUN ROK CELANA DALAM KUTANG KAOS KAKI SEPATU SANDAL BOOT SNEAKER BANDO JEPIT RAMBUT SISIR SIKAT GIGI PASTA GIGI SABUN SHAMPO KONDISIONER DEODORAN PARFUM BEDAK LIPSTIK MASKARA EYELINER EYESHADOW BLUSH ON FOUNDATION CONCEALER KACA MATA LENSA KONTAK JAM TANGAN GELANG CINCIN ANTING KALUNG LIONTIN BROS PIN KOPER RANSEL TAS SELEMPANG TAS TANGAN TAS BELANJA DOMPET KARTU KOIN UANG KERTAS CEK KARTU KREDIT KARTU DEBIT KARTU IDENTITAS KTP SIM PASPOR TIKET VOUCHER KUPON KUITANSI FAKTUR BON STROK BUKU TABUNGAN POLIS ASURANSI SERTIFIKAT IJAZAH PIAGAM SURAT IZIN SURAT PERJANJIAN SURAT KUASA SURAT LAMARAN CV RESUME PORTOFOLIO ASI ASLI ASU BASTIAN KASUR PASTI KAPAS NAFAS TAS"
    
    local Dictionary = string.split(wordDatabaseStr, " ")
    local usedWords = {}

    local isBotActive = false
    local typingDelay = 0.05 -- Kecepatan ngetik

    -- ==========================================
    -- FUNGSI GAIB: KLIK UI KEYBOARD
    -- ==========================================
    local function clickUIButton(targetText)
        local fireClick = getgenv().firesignal or firesignal
        if not fireClick then return false end
        
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetDescendants()) do
                if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                    local text = gui:IsA("TextButton") and gui.Text or gui.Name
                    
                    -- Bersihkan text UI (hilangkan spasi dsb)
                    text = string.upper(string.gsub(text, "%s+", ""))
                    local tTarget = string.upper(targetText)
                    
                    if text == tTarget or string.match(text, tTarget) then
                        pcall(function() fireClick(gui.MouseButton1Click) end)
                        pcall(function() fireClick(gui.Activated) end)
                        return true
                    end
                end
            end
        end
        return false
    end

    -- ==========================================
    -- FUNGSI GAIB: AUTO TYPE & ENTER
    -- ==========================================
    local function TypeAndSubmitWord(word)
        local wordUpper = string.upper(word)
        
        -- 1. Ketik huruf per huruf di UI Keyboard
        for i = 1, #wordUpper do
            local char = string.sub(wordUpper, i, i)
            local clicked = clickUIButton(char)
            
            -- Fallback jika game pakai input keyboard asli
            if not clicked then
                local vim = game:GetService("VirtualInputManager")
                local keycode = Enum.KeyCode[char]
                if keycode then
                    vim:SendKeyEvent(true, keycode, false, game)
                    task.wait(0.01)
                    vim:SendKeyEvent(false, keycode, false, game)
                end
            end
            task.wait(typingDelay)
        end
        
        -- 2. Cari dan klik tombol ENTER/SUBMIT
        local enterClicked = clickUIButton("ENTER") or clickUIButton("SUBMIT") or clickUIButton("JAWAB") or clickUIButton("OK") or clickUIButton(">")
        
        if not enterClicked then
            -- Fallback keyboard enter asli
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.01)
            vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end
        
        -- Tandai kata sudah dipakai di match ini
        usedWords[wordUpper] = true
        WindUI:Notify({Title="Bot Menjawab", Content="Mengetik: " .. wordUpper, Duration=1.5})
    end

    -- ==========================================
    -- FUNGSI SCANNER: MENCARI SOAL (HURUF PROMPT)
    -- ==========================================
    local function GetCurrentPrompt()
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            -- Scan seluruh teks di layar
            for _, gui in ipairs(pg:GetDescendants()) do
                if gui:IsA("TextLabel") and gui.Visible then
                    local text = gui.Text
                    
                    -- Asumsi: Prompt biasanya 1-4 huruf kapital, tanpa spasi
                    if string.match(text, "^[A-Z]+$") and string.len(text) >= 1 and string.len(text) <= 4 then
                        -- Syarat ukuran font agar tidak salah baca UI lain
                        if gui.TextSize > 25 or gui.AbsoluteSize.Y > 30 then
                            return text
                        end
                    end
                end
            end
        end
        return nil
    end

    -- ==========================================
    -- LOGIKA UTAMA BOT
    -- ==========================================
    local function BotLoop()
        task.spawn(function()
            local lastPrompt = ""
            
            while isBotActive do
                local currentPrompt = GetCurrentPrompt()
                
                if currentPrompt and currentPrompt ~= "" then
                    -- Cari kata di kamus
                    local foundWord = nil
                    for _, word in ipairs(Dictionary) do
                        if string.match(word, currentPrompt) and not usedWords[word] then
                            foundWord = word
                            break
                        end
                    end
                    
                    -- Jika ketemu, jawab!
                    if foundWord then
                        TypeAndSubmitWord(foundWord)
                        lastPrompt = currentPrompt
                        task.wait(2) -- Jeda agar tidak spam (tunggu giliran lewat)
                    end
                end
                
                task.wait(0.5) -- Kecepatan mata bot mencari soal
            end
        end)
    end

    -- ==========================================
    -- UI ELEMENTS (WIND UI)
    -- ==========================================
    TebakKataTab:Paragraph({
        Title = "Bot Tebak Kata (Auto Answer)",
        Desc = "Bot ini akan otomatis mencari jawaban bahasa Indonesia dan mengetikkannya di Keyboard UI game saat mendapat soal.",
        Color = Color3.fromHex("#0F7BFF")
    })

    TebakKataTab:Toggle({
        Title = "🤖 Aktifkan Bot Tebak Kata",
        Default = false,
        Callback = function(state)
            isBotActive = state
            if isBotActive then
                WindUI:Notify({Title="Bot Aktif", Content="Mata bot sedang mencari soal di layar...", Duration=2, Icon="check"})
                BotLoop()
            else
                WindUI:Notify({Title="Bot Mati", Content="Bot tebak kata dinonaktifkan.", Duration=1.5})
            end
        end
    })

    TebakKataTab:Divider()

    TebakKataTab:Button({
        Title = "🔄 Reset Memori Kata (Match Baru)",
        Callback = function()
            usedWords = {}
            WindUI:Notify({Title="Reset", Content="Memori kata dikosongkan. Bot bisa menjawab ulang kata yang sama di match baru.", Duration=2})
        end
    })

    TebakKataTab:Slider({
        Title = "Kecepatan Ngetik Bot",
        Min = 1,
        Max = 10,
        Value = 5,
        Callback = function(value)
            -- Konversi: value 1 (lambat) -> 0.1s, value 10 (cepat) -> 0.01s
            typingDelay = 0.1 - (value * 0.009)
        end
    })
end
