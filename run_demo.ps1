# AgriShield 1-click demo launcher (Hack4Africa pitch day).
# Starts backend (FastAPI) + Flutter web app (Chrome) together.
# Usage: pwsh -File run_demo.ps1 [-Port 8000] [-SkipPubGet]

param(
  [int]$Port = 8000,
  [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $Root "backend"
$AppDir = Join-Path $Root "app"
$ApiUrl = "http://localhost:$Port"

function Write-Step([string]$Msg) { Write-Host "`n==> $Msg" -ForegroundColor Green }

# 1. Preflight checks
Write-Step "Checking tools"
$python = Get-Command python -ErrorAction SilentlyContinue
if ($null -eq $python) { throw "python not found on PATH. Install Python 3.11+ first." }
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $flutter) {
  Write-Host "WARNING: 'flutter' not found on PATH. Backend will still start, but the app cannot launch." -ForegroundColor Yellow
  Write-Host "Install Flutter SDK: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
}
python --version
if ($flutter) { flutter --version }

# 2. Start backend as background job
Write-Step "Starting backend on $ApiUrl"
$existing = Get-Job -Name "agrishield-backend" -ErrorAction SilentlyContinue
if ($existing) { $existing | Stop-Job; $existing | Remove-Job }

$backendJob = Start-Job -Name "agrishield-backend" -ScriptBlock {
  param($Dir, $DbUrl, $BackendPort)
  Set-Location -LiteralPath $Dir
  $env:DATABASE_URL = $DbUrl
  python -m uvicorn app.main:app --host 127.0.0.1 --port $BackendPort
} -ArgumentList $BackendDir, "sqlite:///./demo.db", $Port

# 3. Wait for /health (max ~30s)
Write-Step "Waiting for backend /health"
$healthy = $false
for ($i = 1; $i -le 30; $i++) {
  try {
    $res = Invoke-RestMethod -Uri "$ApiUrl/health" -TimeoutSec 3
    if ($res.status -eq "ok") { $healthy = $true; break }
  } catch { Start-Sleep -Seconds 1 }
}
if (-not $healthy) {
  Receive-Job -Name "agrishield-backend" | Select-Object -First 30
  throw "Backend did not become healthy at $ApiUrl/health. See job log above. Stop with: Stop-Job agrishield-backend; Remove-Job agrishield-backend"
}
Write-Host "Backend healthy: $ApiUrl/health -> ok" -ForegroundColor Cyan

# 4. Launch Flutter app (foreground so Ctrl+C stops everything)
try {
  if ($flutter) {
    Set-Location -LiteralPath $AppDir
    if (-not $SkipPubGet) {
      Write-Step "flutter pub get"
      flutter pub get
    }
    Write-Step "Launching app in Chrome -> $ApiUrl"
    Write-Host "Demo tips: keep this terminal open. Cooler gap grows live. Toggle SN/EN on Home. Press R in terminal for hot-reload." -ForegroundColor Cyan
    flutter run -d chrome --dart-define=AGRISHIELD_API_BASE_URL=$ApiUrl
  } else {
    Write-Host "`nBackend is running in background job 'agrishield-backend'." -ForegroundColor Cyan
    Write-Host "Open docs or install Flutter, then run:" -ForegroundColor Cyan
    Write-Host "  cd app; flutter run -d chrome --dart-define=AGRISHIELD_API_BASE_URL=$ApiUrl" -ForegroundColor White
    Write-Host "`nPress Enter to stop the backend and exit."
    Read-Host | Out-Null
  }
} finally {
  Write-Step "Stopping backend"
  Get-Job -Name "agrishield-backend" -ErrorAction SilentlyContinue | Stop-Job
  Get-Job -Name "agrishield-backend" -ErrorAction SilentlyContinue | Remove-Job
  Set-Location -LiteralPath $Root
  Write-Host "Demo stopped. Good luck on stage!" -ForegroundColor Green
}
