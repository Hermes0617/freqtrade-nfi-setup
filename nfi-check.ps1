# NFI Otomatik Güncelleme - PowerShell
# Her çalıştığında GitHub'daki son NFI commit'ini kontrol eder
# Yeni commit varsa OTOMATİK indirir ve botu restart eder

$NFI_REPO = "https://api.github.com/repos/iterativv/NostalgiaForInfinity/commits/main"
$NFI_RAW  = "https://raw.githubusercontent.com/iterativv/NostalgiaForInfinity/main/NostalgiaForInfinityX6.py"
$STATE_FILE = "$PSScriptRoot\nfi_last_commit.txt"
$STRATEGY_FILE = "$PSScriptRoot\user_data\strategies\NostalgiaForInfinityX6.py"

try {
    $latest = (Invoke-RestMethod -Uri $NFI_REPO -TimeoutSec 10).sha.Substring(0,7)
    
    if (Test-Path $STATE_FILE) {
        $previous = (Get-Content $STATE_FILE).Trim()
    } else {
        $previous = ""
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    
    if ($previous -eq "") {
        $latest | Out-File -FilePath $STATE_FILE -NoNewline
        Write-Output "$timestamp Ilk kayit: $latest"
    } elseif ($latest -ne $previous) {
        Write-Output "$timestamp YENI COMMIT: $previous -> $latest. Indiriliyor..."

        # Yeni stratejiyi indir
        Invoke-WebRequest -Uri $NFI_RAW -OutFile $STRATEGY_FILE
        
        # Commit hash'ini guncelle
        $latest | Out-File -FilePath $STATE_FILE -NoNewline
        
        # Botu restart et
        Set-Location $PSScriptRoot
        docker compose restart
        
        Write-Output "$timestamp GUNCELLENDI ve restart edildi: $latest"
    } else {
        Write-Output "$timestamp GUNCEL: $latest"
    }
} catch {
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm') HATA: $_"
}
