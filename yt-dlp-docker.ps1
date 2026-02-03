param ()

$ErrorActionPreference = "Stop"

# Ensure latest yt-dlp on each run
pip install --upgrade yt-dlp | Out-Null

# ==================================================
# Paths
# ==================================================
$BaseDir      = "/downloads"
$ConfigDir    = "/config"

$Cookies      = "$ConfigDir/cookies.txt"
$PlaylistsTxt = "$ConfigDir/playlists.txt"
$OptsTxt      = "$ConfigDir/yt-dlp-options.txt"

$RetryQueue   = "$BaseDir/retry_queue.txt"
$LogDir       = "$BaseDir/logs"
$Archive      = "$BaseDir/Archive"

# ==================================================
# Init directories
# ==================================================
New-Item -ItemType Directory -Force -Path $LogDir     | Out-Null
New-Item -ItemType Directory -Force -Path $Archive   | Out-Null

$TS = Get-Date -Format "yyyyMMdd_HHmmss"
$MasterLog = "$LogDir/run_$TS.log"

"==================================================" | Out-File $MasterLog
"Started   : $(Get-Date)"                              | Out-File -Append $MasterLog
"MODE      : DOCKER"                                   | Out-File -Append $MasterLog
"==================================================" | Out-File -Append $MasterLog
"" | Out-File -Append $MasterLog

# ==================================================
# Safety checks
# ==================================================
foreach ($File in @($Cookies, $PlaylistsTxt, $OptsTxt)) {
    if (-not (Test-Path $File)) {
        "ERROR: Missing required file $File" | Out-File -Append $MasterLog
        throw "Missing required file: $File"
    }
}

# ==================================================
# Load yt-dlp options
# ==================================================
$CommonOpts = Get-Content $OptsTxt |
    Where-Object { $_ -and -not $_.Trim().StartsWith("#") }

$CommonOpts += @("--cookies", $Cookies)

# ==================================================
# Load playlist / URL list
# ==================================================
$Playlists = Get-Content $PlaylistsTxt |
    Where-Object { $_ -and -not $_.Trim().StartsWith("#") }

# ==================================================
# Download phase
# ==================================================
foreach ($URL in $Playlists) {

    "Downloading: $URL" | Out-File -Append $MasterLog

    & yt-dlp `
        @CommonOpts `
        "-o" "$BaseDir/%(uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" `
        $URL 2>&1 | Out-File -Append $MasterLog

    if ($LASTEXITCODE -ne 0) {
        "FAILED: $URL" | Out-File -Append $MasterLog
        $URL | Out-File -Append $RetryQueue
    }
}

# ==================================================
# Retry failed URLs (persistent across runs)
# ==================================================
if (Test-Path $RetryQueue) {

    "" | Out-File -Append $MasterLog
    "Retrying failed URLs..." | Out-File -Append $MasterLog

    $NewQueue = "$RetryQueue.new"

    Get-Content $RetryQueue | Sort-Object -Unique | ForEach-Object {

        "Retrying: $_" | Out-File -Append $MasterLog

        & yt-dlp `
            @CommonOpts `
            "-o" "$BaseDir/%(uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" `
            $_ 2>&1 | Out-File -Append $MasterLog

        if ($LASTEXITCODE -ne 0) {
            $_ | Out-File -Append $NewQueue
        }
    }

    if (Test-Path $NewQueue) {
        Move-Item -Force $NewQueue $RetryQueue
    } else {
        Remove-Item -Force $RetryQueue
    }
}

# ==================================================
# Archive old files (30+ days)
# ==================================================
$Now = Get-Date

Get-ChildItem -Path $BaseDir -Filter *.mp4 -Recurse |
Where-Object { $_.LastWriteTime -lt $Now.AddDays(-30) } |
ForEach-Object {

    $YM = $Now.ToString("yyyy-MM")
    $Dest = Join-Path $Archive $YM

    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Move-Item $_.FullName $Dest
}

# ==================================================
# Done
# ==================================================
"" | Out-File -Append $MasterLog
"Finished  : $(Get-Date)" | Out-File -Append $MasterLog
"==================================================" | Out-File -Append $MasterLog