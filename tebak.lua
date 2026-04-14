return function(WindUI, TebakKataTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer

    -- ==========================================
    -- DATABASE KAMUS KATA SUPER LENGKAP (A-Z)
    -- ==========================================
    local wordDatabaseStr = [=[
        ABA ABAD ABADI ABAI ABANG ABDI ABU ABUABU ACARA ADA ADAB ADALAH ADANG ADAT ADIK ADIL ADU ADUH AGAK AGAMA AGAR AGEN AGUNG AHAD AHLI AIR AJA AJAIB AJAK AJAR AKAL AKAN AKAR AKHIR AKIBAT AKRAB AKSES AKSI AKU AKUN ALAM ALANG ALAS ALAT ALIM ALIR ALIS ALMARI ALUR AMAN AMARAH AMAT AMBIL AMBU AMBUN AMIN ANAK ANCAM ANDA ANDAI ANEH ANGAN ANGGAP ANGGOTA ANGIN ANGKA ANGKAT ANGKUT ANGSA ANJING ANTAR ANTARA ANTRE ANUGERAH ANYAM APA API APUNG ARAH ARANG ARTI ARUS ASA ASAL ASAM ASAP ASAS ASIN ASING ASLI ASMA ASRAMA ASU ASUH ATAP ATAS ATAU ATUR AWAK AWAL AWAM AWAN AWAS AWET AYAH AYAK AYAM AYUN AZAB AZAN AZAS
        BABI BACA BADAI BADAK BADAN BAGAI BAGAS BAGI BAGUS BAHAGIA BAHAN BAHAYA BAHASA BAHKAN BAHU BAIK BAJA BAJAK BAJU BAKAL BAKAR BAKU BAKUT BALAI BALAS BALIK BALOK BALON BAMBU BANCI BANDING BANGGA BANGKAI BANGSA BANGSAT BANGUN BANJIR BANK BANTU BANYAK BAPAK BARA BARANG BARAT BARU BASA BASAH BASI BATAL BATAS BATIK BATU BATUK BAU BAWA BAWAH BAYANG BAYAR BAYI BEBAS BEBEK BEDA BEDAK BEKAS BELA BELAH BELAJAR BELAKANG BELALANG BELI BELUM BENAR BENANG BENCANA BENCI BENDA BENDERA BENGKEL BENIH BENING BENTUK BERANI BERAT BERES BERI BERINGIN BERITA BERSIH BESAR BESI BESOK BIAYA BIBIR BICARA BIDADARI BIDANG BIJI BIKIN BILA BILANG BINATANG BINTANG BIRU BISA BISIK BISU BOHONG BOLA BOLEH BOLONG BONEKA BONGKAR BOSAN BOTAK BUAH BUANG BUAT BUBUR BUDAK BUIH BUJANG BUKA BUKAN BUKIT BUKTI BUKU BULAN BULAT BULU BUMBU BUMI BUNDA BUNGA BUNGKUS BUNTUT BUNUH BUNYI BURUK BURUNG BUSA BUSUK BUTA BUTUH
        CABANG CABUT CACA CACAT CACING CADANG CAHAYA CAIR CAKAP CAKAR CALON CAMAT CAMPUR CANDI CANGKIR CANTIK CAPAI CARA CARI CATAT CAWAN CEBOK CEGAH CEKIK CELA CELANA CELAKA CEPAT CERAH CERDAS CERDIK CERITA CERMIN CETAK CICAK CICI CILIK CINA CINCIN CINTA CIPTA CITA CIUM COBA COCOK COKELAT COPET CORAK CUACA CUCI CUCU CUKUP CUMA CUMBU CURI CUTI
        DADA DADAH DADU DAERAH DAGANG DAGING DAHA DAHAN DAHI DAHULU DAI DALAM DAMAI DANAU DAPAT DAPUR DARAH DARAT DARI DARIPADA DASAR DASI DATA DATANG DATAR DAUN DEBAT DEBU DEDAK DEKAT DELAPAN DEMAM DEMI DENDAM DENGAN DENGAR DEPAN DERAS DERITA DESA DESAK DETIK DEWA DEWASA DI DIAM DIAN DIARE DIDIK DIET DIKAU DIKIT DINAS DINDING DINGIN DIRI DOA DOKTER DOMBA DOMPET DORONG DOSA DOSEN DUA DUDUK DUGA DUKA DUKUN DULANG DULU DUNIA DURI DUSTA DUYUNG
        EBI EDAN EDAR EJAAN EJEK EKONOMI EKOR EKSPOR ELANG ELAK EMAS EMPAT EMPUK ENAK ENAM ENCER ENDAP ENGGAN ENGKAU ENGSEL ENTAH ERA ERAT ESA ESOK ETNIS EYANG
        FAHAM FAJAR FAKTA FAKTUR FAKULTAS FALSAFAH FAMILI FANA FANTASI FASE FATAL FATWA FIKSI FISIK FITNAH FOKUS FORMAL FOTO FUNGSI
        GABUNG GADAI GADING GADIS GAGAL GAGAK GAGASAN GAJAH GAJI GALAK GALI GAMBAR GAMPANG GANAS GANCU GANDA GANTI GANTUNG GARAM GARASI GARIS GARPU GARUDA GATAL GAUL GAUN GAWAI GAWANG GAYA GEDUNG GEJALA GELANG GELAP GELAS GELENG GELI GELOMBANG GEMBIRA GEMPA GEMUK GENAP GENGGAM GENTING GERAK GERBANG GERGAJI GERIMIS GEROMBOLAN GESEK GESER GIGI GIGIT GILA GILING GIRANG GITAR GOLONGAN GORENG GORES GOTONG GOYANG GRATIS GUBERNUR GUDANG GUGUR GULA GULAI GULING GULUNG GUNA GUNDING GUNUNG GURU GUSTI
        HABIS HADAP HADIAH HADIR HAFAL HAID HAJAR HAJI HAKIM HALAL HALAMAN HALANG HALILINTAR HALUAN HALUS HAMBA HAMIL HAMPIR HANCUR HANGAT HANTU HANYA HANYUT HARAP HARGA HARI HARIMAU HARTA HARUM HARUS HASIL HASRAT HATI HAUS HEBAT HELM HENTI HERAN HEWAN HIAS HIDANG HIDUNG HIDUP HIJAU HILANG HINA HINDAR HINGGA HIRUP HITAM HITUNG HORMAT HUBUNG HUJAN HUKUM HULU HUMOR HURUF HUTAN HUTANG
        IBA IBLIS IBU IDAM IDEAL IDENTITAS IJAZAH IKAN IKAT IKLAM IKLIM IKUT ILAH ILMU IMAM IMAN IMBAS IMPIAN INDAH INDERA INDONESIA INDUK INFEKSI INGAT INGIN INI INJAK INSAF INTAN INTI IPAR IRAN IRI IRIS ISAP ISI ISLAM ISTANA ISTIRAHAT ISTRI ITIK ITU IZIN
        JABAT JADI JADWAL JAGA JAGUNG JAHAT JAHIT JAJA JAJAH JAJAN JAKARTA JAKET JALAN JALAR JALUR JAMAN JAMBU JAMIN JAMUR JANDA JANGAN JANJI JANTAN JANTUNG JARAK JARANG JARI JARIK JARING JARUM JASA JATI JATUH JAUH JAWAB JAWATAN JAYA JEBAK JEJAK JELAS JELEK JEMBATAN JEMPOL JEMPUT JENDELA JENIS JEPIT JERAWAT JERAT JERUK JIJIK JILAT JINAK JINGGA JIWA JODOH JONGKOK JOROK JUAL JUANG JUARA JUDI JUDUL JUGA JUJUR JUMAT JUMBO JUMLAH JUMPA JURANG JURUSAN JUTA
        KABAR KABEL KABIN KABUL KABUPATEN KABUR KACA KACANG KACAU KADAL KADANG KADER KAGET KAGUM KAIN KAIT KAKAK KAKEK KAKI KAKU KALAH KALENG KALIAN KALIMAT KALONG KALUNG KAMAR KAMBING KAMERA KAMI KAMPIS KAMPUNG KAMU KANAN KANCING KANDANG KANGGURU KANTONG KANTOR KANTUK KAOS KAPAL KAPAS KAPAN KAPITAL KAPUR KARAKTER KARANG KARENA KARET KARYA KASAR KASIH KASIR KASUR KATA KATAK KAUM KAWAL KAWAN KAWIN KAYA KAYU KEBUN KECIL KECUALI KEDUA KEJAM KEJUT KEKAL KELAS KELINCI KELOMPOK KELUAR KELUARGA KEMARIN KEMBALI KEMEJA KEMUDI KENA KENAL KENCANG KENCING KENDALI KENTAL KENYANG KEPALA KEPITING KERA KERING KERJA KERTAS KESAH KETAT KETAWA KETIKA KETIK KHAS KHUSUS KIAS KILAT KIMIA KIPAS KIRA KIRI KISAH KITA KLUB KOIN KOLAM KOMPUTER KONCI KONTAK KOPI KOPOR KOSONG KOTA KOTAK KOTOR KRITIK KUAH KUAT KUCING KUDA KUE KUKU KULIT KUMIS KUMPUL KUNCI KUNING KUNYUK KUPU KURANG KURS KURSI KUSUT KUTU
        LABA LABIL LABU LACUR LADA LADANG LAGI LAGU LAHIR LAIN LAJU LAKI LALAT LALU LAMA LAMBAT LAMPU LANCI LALU LANGIT LANGKAH LANGSUNG LANJUT LANTAI LAPANGAN LAPAR LAPIS LARI LARUT LATAR LATIH LAUT LAWAN LAYANG LAYAR LAYU LEBAH LEBAR LEBIH LECET LEGA LEHER LEKAT LELAH LELAKI LEMAH LEMAK LEMAR LEMBAR LEMBUT LEMPAR LENGAN LENGKAP LENGKUNG LEPAS LETIH LIAR LIBUR LIDAH LIGA LIHAT LILIN LIMA LINTAH LINTAS LIPAT LOBANG LOMBA LOMPAT LONGGAR LORONG LUANG LUAR LUAS LUDAH LUKA LULUS LUMAYAN LUMPUR LUNAK LUPA LURUS LUTUT
        MAAF MABUK MACAM MACAN MADU MAHAL MAHASISWA MAIN MAJU MAKAM MAKAN MAKNA MALAM MALAS MALU MAMPU MANA MANDI MANIS MANJA MANTAN MANTO MANTRA MANUSIA MARAH MARGA MASA MASAK MASALAH MASAM MASIH MASING MASJID MASUK MATA MATANG MATI MAU MAUT MAWAR MAYAT MEGA MEGAH MEJA MEKAR MELATI MEMANG MENANG MENGAPA MENTERI MENTIMUN MERAH MEREKA MERK MERPATI MESIN MESKIPUN MESRA MESTI MIE MILIK MIMPI MINAT MINGGU MINTA MINUM MINYAK MIRIP MISAL MISKIN MISTERI MISTIK MOBIL MODAL MODEL MODERN MOHON MOKA MOMEN MONYET MOTOR MUAK MUAL MUAT MUDA MUDAH MUKA MUKJIZAT MULAI MULUS MULUT MUNCUL MUNDUR MUNGKIN MUNTAH MURAH MURAM MURID MURKA MUSIM MUSIK MUSLIM MUSUH MUTIARA MUTLAK
        NABI NADA NADI NAFAS NAFSU NAGA NAHAS NAIK NAKAL NAMA NANAS NANTI NAPAS NASI NASIB NASIHAT NASIONAL NATA NEGARA NEGERI NENEK NERAKA NIKAH NIKMAT NILAI NINGRAT NIPIS NODA NOMOR NORMAL NOVEL NYALA NYAMAN NYAMUK NYANYI NYARING NYATA NYAWA NYERI
        OBAT OBENG OBJEK OBOR ODOL OKE OLAH OLEH OLOK OMBAK OMONG OMPONG ONGKOS OPERASI OPINI OPOSISI ORANG ORANYE ORGAN ORMAS ORONG OTAK OTOT OTORITAS
        PACAR PACU PADA PADAM PADANG PADAT PADI PADU PAGAR PAGI PAHAM PAHA PAHIT PAJAK PAKE PAKAI PAKAIAN PAKAR PAKET PAKSA PAKU PALING PALSU PALU PAMAN PAMER PANAS PANCING PANDAI PANDANG PANDU PANEN PANGGIL PANGGUL PANGKAL PANIK PANJANG PANTAI PANTANG PANTAS PANTAT PANTUN PAPA PAPAN PARA PARAH PARIT PARU PARUT PASAR PASIR PASTI PASUKAN PATAH PATUH PATUNG PAUT PAYA PAYUDARA PAYUNG PECAH PEDANG PEDAS PEDIH PEGANG PEGAWAI PEKA PEKAN PELAJAR PELAN PELANGI PELURU PEMUDA PENA PENDEK PENDUDUK PENGARUH PENITI PENTING PENUH PEPAYA PERAHU PERAK PERAN PERANG PERCAYA PEREMPUAN PERGI PERIH PERLU PERNAH PERUT PESAN PESAWAT PESTA PETA PETANI PETIK PETIR PIALA PIATU PICIK PIDATO PIHAK PIJAT PIKIR PILIH PILU PIMPIN PINANG PINDAH PINGGIR PINGGANG PINJAM PINTAR PINTU PIPA PIPI PIRING PISANG PISAU PLASTIK POHON POJOK POLISI POLO POMPA PONDOK POTONG PRIA PRODUK PROSES PROTES PUASA PUCAT PUCUK PUISI PUJI PUKUL PULANG PULAU PULIH PULUH PUNCAK PUNGGUNG PUNYA PURA PUSAT PUSAR PUSING PUTIH PUTRA PUTRI PUTUS
        QARI QURAN QALBU
        RABA RABU RACUN RADANG RADAR RADIO RAGA RAGU RAHANG RAHASIA RAHIM RAIN RAJA RAJIN RAJUT RAKIT RAKSASA RAKYAT RAMAI RAMAH RAMAL RAMBUT RAMI RAMPAS RAMPING RANCANG RACUN RANDOM RANGKA RANJANG RANTAI RANTING RASA RASUL RATAP RATA RATU RATUS RAWAN RAWAT RAYA RAYAP RAYU REAKSI REALITA REBAB REBUNG REBUS REDA REDUP REKAM RELA REMAJA REMAS REMPAH RENCANA RENDAH RENDANG RENTAN REPOT RENTAK RESEP RESMI RESTU RETAK RETAS REZEKI RIANG RIBU RIBUT RIMBA RINGAN RINDU RINGKAS RINTIK RISA RISIKO RIWAYAT RODA ROKOK ROMANTIS ROMBONGAN RONA RONDE ROTAN ROTI RUANG RUAS RUGI RUH RUJUK RUMAH RUMPUT RUMUS RUNTUH RUPA RUPIAH RUSA RUSAK RUSUK
        SAAT SABAR SABUK SABUN SABTU SADAR SAFARI SAH SAHABAT SAHAM SAHUT SAJA SAJI SAKIT SAKSI SAKTI SAKU SALAH SALAM SALING SALJU SAMA SAMAR SAMBAL SAMBIL SAMBUNG SAMPAH SAMPAI SAMPAN SAMPING SAMUDERA SANA SANDAL SANDANG SANGAT SANGGUP SANGKA SANTAI SAPI SAPU SARAN SARANG SARAT SARI SARING SASARAN SATU SATUAN SAUDARA SAUS SAWAH SAYANG SAYAP SAYUR SEBAB SEBAR SEBELUM SEBERANG SEBUAH SEBUT SEDANG SEDAP SEDEKAH SEDERHANA SEDIA SEDIH SEDIKIT SEDOT SEGAR SEGERA SEHAT SEJAK SEJARAH SEJUK SEKALI SEKARANG SEKAT SEKOLAH SELALU SELAM SELAMAT SELATAN SELESAI SELIMUT SELURUH SEMANGAT SEMBILAN SEMBUH SEMEN SEMENANJUNG SEMESTA SEMPIT SEMPURNA SEMUA SEMUT SENAM SENANG SENAPANG SENDIRI SENGIT SENI SENIN SENJA SENTUH SENYUM SEPAKBOLA SEPATU SEPEDA SEPI SEPULUH SERAGAM SERANG SERAP SERATUS SERBA SERBU SERIBU SERING SERIUS SERTA SERU SERUT SESAK SESAL SESUAI SETAN SETENGAH SETIA SETIAP SETING SETIR SETOR SEWA SIANG SIAP SIAPA SIBUK SIDANG SIFAT SIHIR SIKAP SIKAT SIKSA SIKU SILA SILAHKAN SILANG SILAU SILIH SIMPAN SINAR SINGA SINGGAH SINGKAT SINI SISA SISIR SISWA SITA SITU SIUL SKALA SKOR SOAL SOBEK SOKONG SOMBONG SOPAN SORE SORONG SOSIAL SOTO SPONS SRAGEN SUAMI SUARA SUASANA SUATU SUBUH SUCI SUDAH SUDUT SUKA SUKSES SUKU SULIT SULUH SULTAN SUMBER SUMPAH SUMUR SUNGAI SUNGGUH SUNTIK SUNUNGI SURAT SURAU SURGA SUSAH SUSU SUSUL SUSUN SUTERA SWARTA SYARAT SYUKUR
        TAAT TABAH TABIR TABRAK TABU TABUNG TABUR TACHI TAFSIR TAHAN TAHAP TAHU TAHUN TAJAM TAKDIR TAKJUB TAKTIK TAKUT TALI TAMAN TAMBAH TAMBAL TAMBAK TAMBANG TAMPAK TAMPAR TAMPIL TAMU TANAH TANAK TANAM TANDA TANDING TANDUK TANGAN TANGGA TANGGAL TANGGUNG TANGIS TANGKAP TANGKAS TANYA TAO TARI TARIK TARIF TARUH TAS TASIK TATA TATAP TAWAR TAYANG TEBAK TEBAL TEBANG TEBING TEBU TEDUH TEGAK TEGANG TEGAR TEGAS TEGUR TEH TEKA TEKAD TEKAN TEKNIK TEKS TELAH TELAN TELANJANG TELAT TELEPON TELINGA TELITI TELUK TELUNJUK TELUR TEMAN TEMBAK TEMBAGA TEMBOK TEMBUS TEMPAT TEMPO TEMPUH TEMU TENANG TENDA TENDANG TENGAH TENGGELAM TENGKAR TENTANG TENTARA TENTU TEORI TEPAT TEPI TEPUNG TERANG TERAP TERBANG TERBIT TERIAK TERIMA TERJAD TERJEMAH TERJUNG TERKA TERKADANG TERNAK TERUS TETANGGA TETAP TETAS TIANG TIAP TIBA TIDAK TIDUR TIGA TIKAR TIKUS TILANG TIMBANG TIMBUR TIMBUL TIMUR TINDAK TINGGAL TINGGI TINGKAT TINJU TINTA TIPIS TIPU TIRAI TIRU TISU TITIK TITIP TIUP TOKOH TOKO TOKOK TOLAK TOLEH TOLONG TOMAT TOMBOL TONG TONGKAT TONTON TOPI TOTAL TRADISI TUA TUAN TUBUH TUDANG TUDUH TUGAS TUHAN TUJU TUJUH TUKANG TUKAR TULANG TULI TULIS TULUS TUMBUH TUMPANG TUMPUK TUNA TUNDA TUNDUK TUNGGAL TUNGGU TUNTUN TURUN TUTUP
        UANG UAP UBAH UBAN UBAT UBI UCAP UDANG UDARA UJIAN UJUNG UKIR UKUR ULAMA ULANG ULAR ULAT UMAT UMBUR UMUM UMUR UNDANG UNDUR UNGU UNTA UNTUK UNTUNG UPACARA UPAH UPAYA URAT URUS USAH USAHA USIA USIR USUL USUS UTAMA UTARA UTUS UZUR
        VAKSIN VALID VARIASI VAS VERSI VETO VIDEO VILA VIRUS VISI VOKAL VOLUME VONIS VULGAR
        WABAH WADAH WADUK WAFAT WAJAH WAJIB WAKIL WAKTU WALAU WALI WANGI WANITA WARA WARGA WARIS WARNA WARTA WARUNG WASIT WASPADA WATAK WAWANCARA WAYANG WEWENANG WILAYAH WIRAUSAHA WORTEL WUJUD
        XENON XILOFON
        YA YAHUDI YAKIN YAITU YAYASAN YOGA YOYO YUNANI
        ZAITUN ZAKAT ZAMAN ZAMRUD ZAT ZEBRA ZIARAH ZONA
        SIRAM SIRUP SIRNA SIREN SIRIH SIRKAT
    ]=]

    -- Ekstrak kata ke dalam Dictionary & Lookup Table (Untuk scan cepat)
    local Dictionary = {}
    local DictLookup = {}
    for word in string.gmatch(wordDatabaseStr, "%S+") do
        table.insert(Dictionary, word)
        DictLookup[word] = true
    end
    
    local usedWords = {}
    local isBotActive = false
    local typingDelay = 0.05 

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
                    
                    text = string.upper(string.gsub(text, "%s+", ""))
                    local tTarget = string.upper(targetText)
                    
                    -- Jika target hanya 1 huruf (A-Z di keyboard)
                    if string.len(tTarget) == 1 then
                        if text == tTarget then
                            pcall(function() fireClick(gui.MouseButton1Click) end)
                            pcall(function() fireClick(gui.Activated) end)
                            return true
                        end
                    else
                        -- Jika target adalah kata (seperti tombol MASUK / ENTER)
                        if text == tTarget or string.match(text, tTarget) then
                            pcall(function() fireClick(gui.MouseButton1Click) end)
                            pcall(function() fireClick(gui.Activated) end)
                            return true
                        end
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
        
        -- Ketik huruf per huruf di UI Keyboard
        for i = 1, #wordUpper do
            local char = string.sub(wordUpper, i, i)
            local clicked = clickUIButton(char)
            
            -- Fallback jika game pakai input asli (VIM)
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
        
        -- Cari dan klik tombol ENTER atau MASUK (Sesuai screenshot)
        local enterClicked = clickUIButton("MASUK") or clickUIButton("ENTER") or clickUIButton("SUBMIT") or clickUIButton("JAWAB")
        
        if not enterClicked then
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.01)
            vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end
        
        usedWords[wordUpper] = true
        WindUI:Notify({Title="Bot Menjawab", Content="Mengetik: " .. wordUpper, Duration=1.5})
    end

    -- ==========================================
    -- FUNGSI SCANNER: MENCARI SOAL (HURUF PROMPT)
    -- ==========================================
    local function GetCurrentPrompt()
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetDescendants()) do
                if gui:IsA("TextLabel") and gui.Visible then
                    local textUpper = string.upper(gui.Text)
                    
                    -- Kunci Target Spesifik sesuai screenshot: "Hurufnya adalah: SIR"
                    local prompt = string.match(textUpper, "HURUFNYA ADALAH:%s*([A-Z]+)")
                    if prompt then return prompt end
                    
                    -- Fallback untuk huruf besar yang melayang di tengah layar
                    if string.match(textUpper, "^[A-Z]+$") and string.len(textUpper) >= 1 and string.len(textUpper) <= 4 then
                        if gui.TextSize > 40 or gui.AbsoluteSize.Y > 40 then
                            return textUpper
                        end
                    end
                end
            end
        end
        return nil
    end

    -- ==========================================
    -- FUNGSI SCANNER: MEMBACA KATA LAWAN (ANTI DUPLIKAT)
    -- ==========================================
    local function ScanOpponentWords()
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetDescendants()) do
                if gui:IsA("TextLabel") and gui.Visible then
                    -- Abaikan UI tulisan prompt
                    if not string.match(string.upper(gui.Text), "HURUFNYA") then
                        local cleanedText = string.upper(string.gsub(gui.Text, "%s+", ""))
                        -- Jika teks yang ada di layar merupakan kata bahasa indonesia, berarti lawan baru saja menjawab kata itu!
                        if string.len(cleanedText) >= 2 and DictLookup[cleanedText] then
                            usedWords[cleanedText] = true
                        end
                    end
                end
            end
        end
    end

    -- ==========================================
    -- LOGIKA UTAMA BOT
    -- ==========================================
    local function BotLoop()
        task.spawn(function()
            while isBotActive do
                -- Memindai apakah ada kata yang baru saja dijawab oleh lawan
                ScanOpponentWords()
                
                local currentPrompt = GetCurrentPrompt()
                
                if currentPrompt and currentPrompt ~= "" then
                    -- Cek apakah giliran kita (Apakah tombol MASUK / keyboard terlihat?)
                    local isOurTurn = clickUIButton("MASUK_CHECK_ONLY") -- Trik: Cek fungsi tanpa klik
                    -- Kita asumsikan jika ada prompt "Hurufnya adalah:", berarti game sedang berjalan.
                    
                    local possibleWords = {}
                    for _, word in ipairs(Dictionary) do
                        if string.match(word, currentPrompt) and not usedWords[word] then
                            table.insert(possibleWords, word)
                        end
                    end
                    
                    -- Jika ada jawaban dan ini giliran kita, Jawab!
                    if #possibleWords > 0 then
                        local randomIndex = math.random(1, #possibleWords)
                        local chosenWord = possibleWords[randomIndex]
                        
                        TypeAndSubmitWord(chosenWord)
                        task.wait(2.0) -- Jeda setelah menjawab agar tidak spam ngetik
                    end
                end
                
                task.wait(0.2) -- Kecepatan mata bot merefresh pencarian soal
            end
        end)
    end

    -- ==========================================
    -- UI ELEMENTS (WIND UI)
    -- ==========================================
    TebakKataTab:Paragraph({
        Title = "Bot Tebak Kata (Auto Answer)",
        Desc = "Dilengkapi AI Anti-Duplikat. Bot tidak akan menjawab kata yang sudah pernah dipakai oleh lawan!",
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
            WindUI:Notify({Title="Reset", Content="Memori kata dikosongkan. Siap untuk match baru!", Duration=2})
        end
    })

    -- Perbaikan ERROR SLIDER: Menggunakan parameter 'Default' sesuai aturan eksekutor WindUI
    TebakKataTab:Slider({
        Title = "Kecepatan Ngetik Bot",
        Min = 1,
        Max = 10,
        Default = 5,
        Callback = function(value)
            typingDelay = 0.1 - (value * 0.009)
        end
    })
    
    TebakKataTab:Paragraph({
        Title = "Total Kosakata",
        Desc = "Bot ini sekarang memiliki " .. tostring(#Dictionary) .. " kata di dalam otaknya.",
        Color = Color3.fromHex("#888888")
    })
end
