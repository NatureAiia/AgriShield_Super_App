<#
  AgriShield - download real placeholder photos from Unsplash.

  Searches Unsplash for one photo per spot in the app and saves it with the
  file name the app looks for, into BOTH photo folders:
    frontend/assets/photos/       (web app)
    frontend/app/assets/photos/   (Flutter app)
  Any spot with no photo keeps its drawing, so this is always safe to run.

  You need your Unsplash ACCESS KEY (not the Secret key - the secret is
  only for user log-in flows, which this script doesn't use). Find it at
  https://unsplash.com/oauth/applications -> your app -> "Keys".
  Run from the project folder:

    powershell -ExecutionPolicy Bypass -File scripts\get-unsplash-photos.ps1 -AccessKey "YOUR_ACCESS_KEY"

  Re-running replaces the photos. Change a search below, or pass
  -Pick 2 (or 3...) to take the 2nd/3rd search result instead of the 1st.
  Unsplash photos are free to use; photographer credits (required by the
  Unsplash API guidelines) are saved to frontend/assets/photos/CREDITS.txt.
#>
param(
  [Parameter(Mandatory = $true)][string]$AccessKey,
  [int]$Pick = 1
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Targets = @(
  (Join-Path $Root 'frontend\assets\photos'),
  (Join-Path $Root 'frontend\app\assets\photos')
)
foreach ($t in $Targets) { New-Item -ItemType Directory -Force -Path $t | Out-Null }

# name = file the app looks for; query = what to search; orientation = shape
$Spots = @(
  @{ name = 'onboarding'; query = 'african farmer maize field';  orientation = 'portrait'  },
  @{ name = 'home';       query = 'green maize field sunny';     orientation = 'landscape' },
  @{ name = 'storage';    query = 'grain silo farm';             orientation = 'landscape' },
  @{ name = 'scan';       query = 'green plant leaf close up';   orientation = 'landscape' },
  @{ name = 'map';        query = 'aerial view farmland fields'; orientation = 'landscape' },
  @{ name = 'advice';     query = 'farmer crops field africa';   orientation = 'landscape' }
)

$Headers = @{ Authorization = "Client-ID $AccessKey"; 'Accept-Version' = 'v1' }
$Utm = 'utm_source=agrishield&utm_medium=referral'
$Credits = @("AgriShield placeholder photos - from Unsplash (https://unsplash.com/license)", "")

foreach ($s in $Spots) {
  $q = [uri]::EscapeDataString($s.query)
  $perPage = [Math]::Max($Pick, 5)
  $url = "https://api.unsplash.com/search/photos?query=$q&orientation=$($s.orientation)&per_page=$perPage&content_filter=high"
  Write-Host ("Searching '{0}' for {1}.jpg ..." -f $s.query, $s.name) -ForegroundColor Cyan
  try {
    $res = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get
  } catch {
    Write-Host "  Search failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  (Check you used the ACCESS key, and that this PC is online. Demo apps allow 50 requests/hour.)" -ForegroundColor Red
    continue
  }
  if (-not $res.results -or $res.results.Count -lt 1) {
    Write-Host "  No results - this spot keeps its drawing." -ForegroundColor Yellow
    continue
  }
  $index = [Math]::Min($Pick, $res.results.Count) - 1
  $photo = $res.results[$index]

  # Ask Unsplash's image CDN for a small, cropped JPG (fast on slow networks)
  if ($s.orientation -eq 'portrait') { $size = 'w=800&h=1200' } else { $size = 'w=1200&h=630' }
  $img = "$($photo.urls.raw)&$size&fit=crop&crop=entropy&fm=jpg&q=75"

  $first = Join-Path $Targets[0] "$($s.name).jpg"
  Invoke-WebRequest -Uri $img -OutFile $first -UseBasicParsing
  for ($i = 1; $i -lt $Targets.Count; $i++) {
    Copy-Item $first (Join-Path $Targets[$i] "$($s.name).jpg") -Force
  }

  # Unsplash API guidelines: tell Unsplash the photo was downloaded
  try { Invoke-RestMethod -Uri $photo.links.download_location -Headers $Headers -Method Get | Out-Null } catch { }

  $kb = [Math]::Round((Get-Item $first).Length / 1KB)
  $who = $photo.user.name
  Write-Host ("  Saved {0}.jpg ({1} KB) - photo by {2}" -f $s.name, $kb, $who) -ForegroundColor Green
  $Credits += ("{0}.jpg - Photo by {1} ({2}?{3}) on Unsplash - {4}?{3}" -f $s.name, $who, $photo.user.links.html, $Utm, $photo.links.html)
}

foreach ($t in $Targets) { $Credits | Set-Content -Path (Join-Path $t 'CREDITS.txt') -Encoding UTF8 }
Write-Host ""
Write-Host "Done. Restart 'npm run dev' (web) or fully restart the Flutter app to see the photos." -ForegroundColor Green
