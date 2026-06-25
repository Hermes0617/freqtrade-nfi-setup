# Freqtrade + NFI X6 — PC Docker Setup

Kendi bilgisayarında Freqtrade + NostalgiaForInfinity X6 stratejisini Docker'da çalıştır.

## Donanım Gereksinimi

- **Minimum:** 4 GB RAM, 4 CPU çekirdek
- **Önerilen:** 8+ GB RAM, 6+ CPU

VPS'te 40 pair analiz 284 saniye sürüyordu (çok yavaş). PC'de daha hızlı olacak.

---

## Kurulum

### 1. Repoyu indir

```powershell
cd C:\

### NFI Güncelleme Takibi
```powershell
# Günlük kontrol görevi oluştur (yönetici olarak):
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File C:\freqtrade-nfi-setup\nfi-check.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "09:00"
Register-ScheduledTask -TaskName "NFI Check" -Action $action -Trigger $trigger -Description "NFI strateji güncelleme kontrolü"

# Sonucu görmek için:
Get-Content C:\freqtrade-nfi-setup\nfi_last_commit.txt
```
git clone https://github.com/Hermes0617/freqtrade-nfi-setup.git
cd freqtrade-nfi-setup
```

Git yoksa: yeşil "Code" butonu → Download ZIP → `C:\freqtrade-nfi-setup\` olarak aç.

### 2. Klasörleri oluştur

```powershell
mkdir user_data\strategies
mkdir user_data\data
mkdir logs
```

### 3. NFI stratejisini indir

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/iterativv/NostalgiaForInfinity/main/NostalgiaForInfinityX6.py" -OutFile "user_data\strategies\NostalgiaForInfinityX6.py"
```

### 4. Verileri önceden indir (~10 dk)

```powershell
docker compose run --rm freqtrade download-data --config /freqtrade/config/config.json --exchange binance --timeframes 5m 15m 1h 4h 1d --timerange 20260401-20260625
```

### 5. Başlat

```powershell
docker compose up -d
```

30 saniye bekle → tarayıcıdan http://localhost:8080 aç.

---

## FreqUI Giriş

Sağ üstte **Login** butonu:

| Alan | Değer |
|------|-------|
| Bot Name | `NFI PC` |
| API Url | `http://localhost:8080` |
| Username | `admin` |
| Password | `Mahir.0617` |

---

## Durum Kontrolü

```powershell
docker compose logs -f --tail 30
```

`NostalgiaForInfinityX6` ve `Searching for USDT pairs` görmen lazım.

⚠️ İlk 15-30 dk trade açılmaması normal — NFI 800 mum warmup ister.

---

## Config

- **40 coin** — PC CPU'suna uygun
- **Dry-run** (sahte para) — cüzdanda korkma
- **Strateji:** NostalgiaForInfinityX6 (stabil sürüm)
- **Timeframe:** 5 dakika

Gerçek para için `config\config.json`'da `"dry_run": false` yap + Binance API key ekle.
