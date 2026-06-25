# NFI Güncelleme Kontrolü - PowerShell
# Her çalıştığında GitHub'daki son NFI commit'ini kontrol eder
# Yeni commit varsa <YENİ COMMIT> yazar, aynıysa <GÜNCEL> yazar

$NFI_REPO = "https://api.github.com/repos/iterativv/NostalgiaForInfinity/commits/main"
$STATE_FILE = "$PSScriptRoot\nfi_last_commit.txt"

try {
    $latest = (Invoke-RestMethod -Uri $NFI_REPO -TimeoutSec 10).sha.Substring(0,7)
    
    if (Test-Path $STATE_FILE) {
        $previous = (Get-Content $STATE_FILE).Trim()
    } else {
        $previous = ""
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    
    if ($previous -eq "") {
        # Ilk calistirma
        $latest | Out-File -FilePath $STATE_FILE -NoNewline
        Write-Output "$timestamp Ilk kontrol kaydedildi: $latest"
    } elseif ($latest -ne $previous) {
        # Yeni commit var!
        $latest | Out-File -FilePath $STATE_FILE -NoNewline
        Write-Output "$timestamp <YENI COMMIT> $previous -> $latest"
    } else {
        Write-Output "$timestamp <GUNCEL> $latest"
    }
} catch {
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm') <HATA> GitHub'a erisilemedi: $_"
}
