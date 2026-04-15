return function(WindUI, TebakKataTab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
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
        SAAT SABAR SABUK SABUN SABTU SADAR SAFARI SAH SAHABAT SAHAM SAHUT SAJA SAJI SAKIT SAKSI SAKTI SAKU SALAH SALAM SALING SALJU SAMA SAMAR SAMBAL SAMBIL SAMBUNG SAMPAH SAMPAI SAMPAN SAMPING SAMUDERA SANA SANDAL SANDANG SANGAT SANGGUP SANGKA SANTAI SAPI SAPU SARAN SARANG SARAT SARI SASARAN SATU SATUAN SAUDARA SAUS SAWAH SAYANG SAYAP SAYUR SEBAB SEBAR SEBELUM SEBERANG SEBUAH SEBUT SEDANG SEDAP SEDEKAH SEDERHANA SEDIA SEDIH SEDIKIT SEDOT SEGAR SEGERA SEHAT SEJAK SEJARAH SEJUK SEKALI SEKARANG SEKAT SEKOLAH SELALU SELAM SELAMAT SELATAN SELESAI SELIMUT SELURUH SEMANGAT SEMBILAN SEMBUH SEMEN SEMENANJUNG SEMESTA SEMPIT SEMPURNA SEMUA SEMUT SENAM SENANG SENAPANG SENDIRI SENGIT SENI SENIN SENJA SENTUH SENYUM SEPAKBOLA SEPATU SEPEDA SEPI SEPULUH SERAGAM SERANG SERAP SERATUS SERBA SERBU SERIBU SERING SERIUS SERTA SERU SERUT SESAK SESAL SESUAI SETAN SETENGAH SETIA SETIAP SETING SETIR SETOR SEWA SIANG SIAP SIAPA SIBUK SIDANG SIFAT SIHIR SIKAP SIKAT SIKSA SIKU SILA SILAHKAN SILANG SILAU SILIH SIMPAN SINAR SINGA SINGGAH SINGKAT SINI SISA SISIR SISWA SITA SITU SIUL SKALA SKOR SOAL SOBEK SOKONG SOMBONG SOPAN SORE SORONG SOSIAL SOTO SPONS SRAGEN SUAMI SUARA SUASANA SUATU SUBUH SUCI SUDAH SUDUT SUKA SUKSES SUKU SULIT SULUH SULTAN SUMBER SUMPAH SUMUR SUNGAI SUNGGUH SUNTIK SUNUNGI SURAT SURAU SURGA SUSAH SUSU SUSUL SUSUN SUTERA SWARTA SYARAT SYUKUR
        TAAT TABAH TABIR TABRAK TABU TABUNG TABUR TACHI TAFSIR TAHAN TAHAP TAHU TAHUN TAJAM TAKDIR TAKJUB TAKTIK TAKUT TALI TAMAN TAMBAH TAMBAL TAMBAK TAMBANG TAMPAK TAMPAR TAMPIL TAMU TANAH TANAK TANAM TANDA TANDING TANDUK TANGAN TANGGA TANGGAL TANGGUNG TANGIS TANGKAP TANGKAS TANYA TAO TARI TARIK TARIF TARUH TAS TASIK TATA TATAP TAWAR TAYANG TEBAK TEBAL TEBANG TEBING TEBU TEDUH TEGAK TEGANG TEGAR TEGAS TEGUR TEH TEKA TEKAD TEKAN TEKNIK TEKS TELAH TELAN TELANJANG TELAT TELEPON TELINGA TELITI TELUK TELUNJUK TELUR TEMAN TEMBAK TEMBAGA TEMBOK TEMBUS TEMPAT TEMPO TEMPUH TEMU TENANG TENDA TENDANG TENGAH TENGGELAM TENGKAR TENTANG TENTARA TENTU TEORI TEPAT TEPI TEPUNG TERANG TERAP TERBANG TERBIT TERIAK TERIMA TERJAD TERJEMAH TERJUNG TERKA TERKADANG TERNAK TERUS TETANGGA TETAP TETAS TIANG TIAP TIBA TIDAK TIDUR TIGA TIKAR TIKUS TILANG TIMBANG TIMBUR TIMBUL TIMUR TINDAK TINGGAL TINGGI TINGKAT TINJU TINTA TIPIS TIPU TIRAI TIRU TISU TITIK TITIP TIUP TOKOH TOKO TOKOK TOLAK TOLEH TOLONG TOMAT TOMBOL TONG TONGKAT TONTON TOPI TOTAL TRADISI TUA TUAN TUBUH TUDANG TUDUH TUGAS TUHAN TUJU TUJUH TUKANG TUKAR TULANG TULI TULIS TULUS TUMBUH TUMPANG TUMPUK TUNA TUNDA TUNDUK TUNGGAL TUNGGU TUNTUN TURUN TUTUP
        UANG UAP UBAH UBAN UBAT UBI UCAP UDANG UDARA UJIAN UJUNG UKIR UKUR ULAMA ULANG ULAR ULAT UMAT UMBUR UMUM UMUR UNDANG UNDUR UNGU UNTA UNTUK UNTUNG UPACARA UPAH UPAYA URAT URUS USAH USAHA USIA USIR USUL USUS UTAMA UTARA UTUS UZUR
        VAKSIN VALID VARIASI VAS VERSI VETO VIDEO VILA VIRUS VISI VOKAL VOLUME VONIS VULGAR
        WABAH WADAH WADUK WAFAT WAJAH WAJIB WAKIL WAKTU WALAU WALI WANGI WANITA WARA WARGA WARIS WARNA WARTA WARUNG WASIT WASPADA WATAK WAWANCARA WAYANG WEWENANG WILAYAH WIRAUSAHA WORTEL WUJUD
        XENON XILOFON
        YA YAHUDI YAKIN YAITU YAYASAN YOGA YOYO YUNANI
        ZAITUN ZAKAT ZAMAN ZAMRUD ZAT ZEBRA ZIARAH ZONA
        SIRAM SIRUP SIRNA SIREN SIRIH SIRKAT KITA SEKITAR SAKIT BUKIT KAMU KAMI MEREKA ISAP ISI ISLAM ISTANA ISTIRAHAT ISTRI ITEM MINYAK MINGGU MINUM MINTA MINA MISAL MISTERI MISKIN AYAM AYAT AYAH UPIL UPAH UPA UPACARA KAKI KAKAK KAKEK HARUS HARI HALO
    ]=]

    local Dictionary = {}
    local DictLookup = {}
    for word in string.gmatch(wordDatabaseStr, "%S+") do
        table.insert(Dictionary, word)
        DictLookup[word] = true
    end

    local usedWords = {}
    local isBotActive = false
    local typingDelay = 0.05 
    local botStateStatus = "Standby..."
    local StatusLabelUI = nil 

    local function UpdateStatus(text)
        botStateStatus = text
        if StatusLabelUI then StatusLabelUI.Text = "Status: " .. text end
    end

    -- ==========================================
    -- CUSTOM FLOATING UI (SCREEN GUI)
    -- ==========================================
    local FloatingUI = Instance.new("ScreenGui")
    FloatingUI.Name = "SYNC_TebakKataGUI"
    FloatingUI.ResetOnSpawn = false
    FloatingUI.Enabled = false
    FloatingUI.Parent = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or lp.PlayerGui

    local CircleWidget = Instance.new("TextButton")
    CircleWidget.Size = UDim2.new(0, 45, 0, 45)
    CircleWidget.Position = UDim2.new(0.5, -22, 0.1, 0)
    CircleWidget.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    CircleWidget.Text = "⌨️"
    CircleWidget.TextSize = 20
    CircleWidget.Parent = FloatingUI
    Instance.new("UICorner", CircleWidget).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", CircleWidget).Color = Color3.fromRGB(41, 248, 155)
    Instance.new("UIStroke", CircleWidget).Thickness = 2

    local MainPanel = Instance.new("Frame")
    MainPanel.Size = UDim2.new(0, 240, 0, 130)
    MainPanel.Position = UDim2.new(0.5, -120, 0.1, 55)
    MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainPanel.Visible = false
    MainPanel.Parent = FloatingUI
    Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", MainPanel).Color = Color3.fromRGB(41, 248, 155)
    Instance.new("UIStroke", MainPanel).Thickness = 1.5

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 25)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Bot Tebak Kata"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.Parent = MainPanel

    StatusLabelUI = Instance.new("TextLabel")
    StatusLabelUI.Size = UDim2.new(1, -10, 0, 20)
    StatusLabelUI.Position = UDim2.new(0, 5, 0, 25)
    StatusLabelUI.BackgroundTransparency = 1
    StatusLabelUI.Text = "Status: " .. botStateStatus
    StatusLabelUI.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabelUI.Font = Enum.Font.Gotham
    StatusLabelUI.TextSize = 11
    StatusLabelUI.TextWrapped = true
    StatusLabelUI.Parent = MainPanel

    local ToggleBotBtn = Instance.new("TextButton")
    ToggleBotBtn.Size = UDim2.new(1, -20, 0, 30)
    ToggleBotBtn.Position = UDim2.new(0, 10, 0, 50)
    ToggleBotBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    ToggleBotBtn.Text = "BOT: OFF"
    ToggleBotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBotBtn.Font = Enum.Font.GothamBold
    ToggleBotBtn.TextSize = 12
    Instance.new("UICorner", ToggleBotBtn).CornerRadius = UDim.new(0, 6)
    ToggleBotBtn.Parent = MainPanel

    local isDraggingWidget = false
    local dragStart, startPos, hasMoved

    CircleWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingWidget = true; hasMoved = false; dragStart = input.Position; startPos = CircleWidget.Position
        end
    end)
    CircleWidget.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingWidget = false; if not hasMoved then MainPanel.Visible = not MainPanel.Visible end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingWidget and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved then
                CircleWidget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                MainPanel.Position = UDim2.new(CircleWidget.Position.X.Scale, CircleWidget.Position.X.Offset - 97, CircleWidget.Position.Y.Scale, CircleWidget.Position.Y.Offset + 55)
            end
        end
    end)

    -- ==========================================
    -- FUNGSI GAIB: SINGLE-THREAD CLICKER (ANTI-SPAM)
    -- ==========================================
    local function DeepFindButtonText(gui)
        local text = ""
        if gui:IsA("TextButton") or gui:IsA("TextLabel") then text = gui.Text end
        if text == "" or string.match(text, "^%s*$") then
            local lbl = gui:FindFirstChildOfClass("TextLabel")
            if lbl then text = lbl.Text end
        end
        if text == "" or string.match(text, "^%s*$") then text = gui.Name end
        return string.upper(string.gsub(string.gsub(text, "<[^>]+>", ""), "%s+", ""))
    end

    local function SafeSingleClick(gui)
        local success = false
        -- Metode Anti-Double: Hanya tembak 1 sinyal koneksi pertama yang valid!
        if typeof(getconnections) == "function" then
            pcall(function()
                local clickConns = getconnections(gui.MouseButton1Click)
                if #clickConns > 0 then
                    clickConns[1]:Fire() 
                    success = true
                else
                    local actConns = getconnections(gui.Activated)
                    if #actConns > 0 then
                        actConns[1]:Fire()
                        success = true
                    end
                end
            end)
        end
        
        -- Fallback jika eksekutor tidak punya getconnections
        if not success and typeof(firesignal) == "function" then
            pcall(function() firesignal(gui.MouseButton1Click) end)
            success = true
        end
        
        return success
    end

    local function clickUIButton(targetText)
        local pg = lp:FindFirstChild("PlayerGui")
        if not pg then return false end
        
        local tTarget = string.upper(targetText)
        for _, screenGui in ipairs(pg:GetChildren()) do
            if screenGui:IsA("ScreenGui") and screenGui.Enabled and screenGui.Name ~= "SYNC_TebakKataGUI" then
                for _, gui in ipairs(screenGui:GetDescendants()) do
                    if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and gui.AbsoluteSize.X > 0 then
                        local text = DeepFindButtonText(gui)
                        
                        local isMatch = false
                        if string.len(tTarget) == 1 then
                            if text == tTarget then isMatch = true end
                        else
                            if text == tTarget or string.match(text, tTarget) then isMatch = true end
                        end

                        if isMatch then
                            SafeSingleClick(gui)
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    -- ==========================================
    -- TURN DETECTOR: Cek Apakah Keyboard Muncul
    -- ==========================================
    local function IsItMyTurn()
        local pg = lp:FindFirstChild("PlayerGui")
        if not pg then return false end
        
        for _, screenGui in ipairs(pg:GetChildren()) do
            if screenGui:IsA("ScreenGui") and screenGui.Enabled and screenGui.Name ~= "SYNC_TebakKataGUI" then
                for _, gui in ipairs(screenGui:GetDescendants()) do
                    if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and gui.AbsoluteSize.X > 0 then
                        local text = DeepFindButtonText(gui)
                        if text == "MASUK" or text == "JAWAB" or text == "ENTER" then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    -- ==========================================
    -- FUNGSI GAIB: SMART SUFFIX TYPER (PEMOTONG KATA)
    -- ==========================================
    local function TypeAndSubmitWord(word, prompt)
        local wordUpper = string.upper(word)
        local promptUpper = string.upper(prompt or "")
        
        -- KITA HANYA NGETIK SISA HURUFNYA
        -- Contoh: Word="KAKI", Prompt="KA" -> stringToType="KI"
        local stringToType = wordUpper
        if promptUpper ~= "" and string.sub(wordUpper, 1, string.len(promptUpper)) == promptUpper then
            stringToType = string.sub(wordUpper, string.len(promptUpper) + 1)
        end
        
        for i = 1, #stringToType do
            local char = string.sub(stringToType, i, i)
            clickUIButton(char)
            task.wait(typingDelay)
        end
        
        task.wait(0.1)
        clickUIButton("MASUK")
        
        usedWords[wordUpper] = true
    end

    -- ==========================================
    -- FUNGSI SCANNER: Y-AXIS ALIGNMENT (ANTI SALAH BACA)
    -- ==========================================
    local function GetCurrentPrompt()
        local pg = lp:FindFirstChild("PlayerGui")
        if not pg then return nil end
        
        local hurufnyaY = nil
        
        -- 1. Cari jangkar koordinat Y dari tulisan "Hurufnya adalah:"
        for _, screenGui in ipairs(pg:GetChildren()) do
            if screenGui:IsA("ScreenGui") and screenGui.Enabled and screenGui.Name ~= "SYNC_TebakKataGUI" then
                for _, gui in ipairs(screenGui:GetDescendants()) do
                    if gui:IsA("TextLabel") and gui.Visible and gui.AbsoluteSize.X > 0 then
                        local rawText = string.upper(string.gsub(gui.Text, "<[^>]+>", ""))
                        if string.find(rawText, "HURUFNYA") then
                            hurufnyaY = gui.AbsolutePosition.Y
                            
                            -- Jika game menggabungkannya di 1 label (HURUFNYA ADALAH: KA)
                            local exactMatch = string.match(rawText, "HURUFNYA[^:]*:%s*([A-Z]+)")
                            if exactMatch and string.len(exactMatch) >= 1 and string.len(exactMatch) <= 4 then
                                return exactMatch
                            end
                            break
                        end
                    end
                end
            end
        end

        -- 2. Jika dipisah, cari TextLabel yang berada di garis lurus (Y-Axis) yang sama!
        if hurufnyaY then
            for _, screenGui in ipairs(pg:GetChildren()) do
                if screenGui:IsA("ScreenGui") and screenGui.Enabled and screenGui.Name ~= "SYNC_TebakKataGUI" then
                    for _, gui in ipairs(screenGui:GetDescendants()) do
                        if gui:IsA("TextLabel") and gui.Visible and gui.AbsoluteSize.X > 0 then
                            local rawText = string.upper(string.gsub(gui.Text, "<[^>]+>", ""))
                            local stripped = string.gsub(rawText, "%s+", "")
                            
                            -- Pastikan itu berisi 1-4 huruf A-Z murni
                            if string.match(stripped, "^[A-Z]+$") and string.len(stripped) >= 1 and string.len(stripped) <= 4 then
                                -- MENCEGAH BACA UI LAIN: Posisi Y nya harus sama/sejajar dengan "Hurufnya adalah:"
                                local diff = math.abs(gui.AbsolutePosition.Y - hurufnyaY)
                                if diff < 30 then
                                    return stripped
                                end
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local function ScanOpponentWords()
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            for _, screenGui in ipairs(pg:GetChildren()) do
                if screenGui:IsA("ScreenGui") and screenGui.Enabled and screenGui.Name ~= "SYNC_TebakKataGUI" then
                    for _, gui in ipairs(screenGui:GetDescendants()) do
                        if gui:IsA("TextLabel") and gui.Visible then
                            local textUpper = string.upper(string.gsub(gui.Text, "<[^>]+>", ""))
                            if not string.match(textUpper, "HURUFNYA") then
                                local cleanedText = string.gsub(textUpper, "%s+", "")
                                if string.len(cleanedText) >= 2 and DictLookup[cleanedText] then
                                    usedWords[cleanedText] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- ==========================================
    -- LOGIKA UTAMA BOT (PURE TURN-BASED)
    -- ==========================================
    local function BotLoop()
        task.spawn(function()
            local lastPrompt = ""
            local answeredThisTurn = false
            
            while isBotActive do
                ScanOpponentWords()
                local myTurn = IsItMyTurn()
                
                if myTurn then
                    -- ================== GILIRAN KITA (KEYBOARD ADA DI LAYAR) ==================
                    local currentPrompt = GetCurrentPrompt()
                    
                    if currentPrompt then
                        if currentPrompt ~= lastPrompt then
                            UpdateStatus("GILIRAN KITA! Soal: " .. currentPrompt)
                            
                            -- Cari kata yang DIAWALI dengan prompt
                            local possibleWords = {}
                            for _, word in ipairs(Dictionary) do
                                if string.match(word, "^" .. currentPrompt) and not usedWords[word] then
                                    table.insert(possibleWords, word)
                                end
                            end
                            
                            if #possibleWords > 0 then
                                local chosenWord = possibleWords[math.random(1, #possibleWords)]
                                task.wait(0.3) 
                                TypeAndSubmitWord(chosenWord, currentPrompt)
                                
                                lastPrompt = currentPrompt
                                answeredThisTurn = true
                            else
                                UpdateStatus("Kosakata habis untuk: " .. currentPrompt)
                                lastPrompt = currentPrompt
                                answeredThisTurn = true
                            end
                        else
                            if answeredThisTurn then
                                UpdateStatus("Menunggu soal berikutnya...")
                            else
                                UpdateStatus("Memproses: " .. currentPrompt)
                            end
                        end
                    else
                        UpdateStatus("Mencari soal...")
                    end
                else
                    -- ================== BUKAN GILIRAN KITA ==================
                    -- RESET KUNCIAN: Otak bot kembali segar untuk giliran selanjutnya
                    lastPrompt = ""
                    answeredThisTurn = false
                    UpdateStatus("Menunggu Giliran / Match Dimulai...")
                end
                
                task.wait(0.3) 
            end
        end)
    end

    -- ==========================================
    -- EVENT TOMBOL BOT
    -- ==========================================
    ToggleBotBtn.MouseButton1Click:Connect(function()
        isBotActive = not isBotActive
        if isBotActive then
            ToggleBotBtn.Text = "BOT: ON"
            ToggleBotBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
            usedWords = {} -- Reset memori otomatis saat bot dinyalakan
            UpdateStatus("Sistem Bot Siap.")
            BotLoop()
        else
            ToggleBotBtn.Text = "BOT: OFF"
            ToggleBotBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            UpdateStatus("Bot Dimatikan.")
        end
    end)

    TebakKataTab:Dropdown({
        Title = "Kecepatan Ngetik Bot",
        Values = {"Sangat Lambat", "Lambat", "Normal", "Cepat", "Super Cepat"},
        Value = "Normal",
        Callback = function(opt)
            local choice = type(opt) == "table" and opt.Title or opt
            if choice == "Sangat Lambat" then typingDelay = 0.15
            elseif choice == "Lambat" then typingDelay = 0.1
            elseif choice == "Normal" then typingDelay = 0.05
            elseif choice == "Cepat" then typingDelay = 0.02
            elseif choice == "Super Cepat" then typingDelay = 0.005
            end
        end
    })

    TebakKataTab:Paragraph({
        Title = "Bot Tebak Kata (V14 - The God Tier)",
        Desc = "Pembaruan total. Anti salah baca (Y-Axis Scanner) dan anti ngetik spam (Single-Thread Clicker).",
        Color = Color3.fromHex("#0F7BFF")
    })

    TebakKataTab:Button({
        Title = "🖥️ Open Panel Tebak Kata System",
        Callback = function()
            FloatingUI.Enabled = not FloatingUI.Enabled
            if FloatingUI.Enabled then
                WindUI:Notify({Title="Panel Terbuka", Content="Silakan klik icon ⌨️ di layar.", Duration=2})
            end
        end
    })
end
