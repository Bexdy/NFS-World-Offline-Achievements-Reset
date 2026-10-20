
@echo off
setlocal
title NFS World - Reset Driver Template

set "NFS_RESET_BAT=%~f0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$f=$env:NFS_RESET_BAT; $t=Get-Content -Raw -LiteralPath $f; $m='#---'+'POWERSHELL-CODE---'; $i=$t.IndexOf($m); if($i -lt 0){throw 'Embedded script not found.'}; $s=$t.Substring($i+$m.Length); Invoke-Expression $s"

set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo ERROR: The reset failed. See the message above.
    pause
    exit /b %RC%
)

echo Press any key to close.
pause >nul
exit /b 0

#---POWERSHELL-CODE---

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $f
Set-Location -LiteralPath $root

$achievementsPath = Join-Path $root "config\DriverTemplate\loadall.xml"
$personaInfoPath = Join-Path $root "config\DriverTemplate\GetPersonaInfo.xml"

try {
    # Check both files exist.
    foreach ($path in @($achievementsPath, $personaInfoPath)) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "File not found: $path"
        }
    }

    # Load both XML files before changing anything.
    [xml]$achievementsXml = Get-Content -LiteralPath $achievementsPath -Raw
    [xml]$personaInfoXml = Get-Content -LiteralPath $personaInfoPath -Raw

    $definitions = $achievementsXml.SelectNodes(
        "/AchievementsPacket/Definitions/AchievementDefinitionPacket"
    )

    if ($definitions.Count -eq 0) {
        throw "No achievement definitions found. Check the XML structure."
    }

    $scoreNode = $personaInfoXml.SelectSingleNode("/ProfileData/Score")

    if ($null -eq $scoreNode) {
        throw "Could not find ProfileData/Score."
    }

    # Reset achievement progress and rank states.
    $totalRanks = 0

    foreach ($definition in $definitions) {
        $currentValue = $definition.SelectSingleNode("./CurrentValue")

        if ($null -ne $currentValue) {
            $currentValue.InnerText = "0"
        }

        $ranks = $definition.SelectNodes(
            "./AchievementRanks/AchievementRankPacket"
        )

        foreach ($rank in $ranks) {
            $rankNode = $rank.SelectSingleNode("./Rank")
            $state = $rank.SelectSingleNode("./State")

            if ($null -eq $rankNode -or $null -eq $state) {
                throw "A rank has no Rank or State element."
            }

            $rankNumber = 0
            if (-not [int]::TryParse($rankNode.InnerText, [ref]$rankNumber)) {
                throw "Invalid rank number: $($rankNode.InnerText)"
            }

            if ($rankNumber -eq 1) {
                $state.InnerText = "InProgress"
            }
            else {
                $state.InnerText = "Locked"
            }

            $achievedOn = $rank.SelectSingleNode("./AchievedOn")
            if ($null -ne $achievedOn) {
                $achievedOn.InnerText = "0001-01-01T00:00:00"
            }

            $totalRanks++
        }
    }

    if ($totalRanks -eq 0) {
        throw "No achievement ranks found. Check the XML structure."
    }

    # Reset profile score.
    $scoreNode.InnerText = "0"

    # Back up both originals before saving changes.
    Copy-Item -LiteralPath $achievementsPath `
        -Destination "$achievementsPath.bak" -Force

    Copy-Item -LiteralPath $personaInfoPath `
        -Destination "$personaInfoPath.bak" -Force

    # Save modified XML files.
    $achievementsXml.Save($achievementsPath)
    $personaInfoXml.Save($personaInfoPath)

    Write-Host ""
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "Achievement definitions: $($definitions.Count)"
    Write-Host "Achievement ranks reset: $totalRanks"
    Write-Host "Achievement progress values: 0"
    Write-Host "Rank 1: InProgress; higher ranks: Locked"
    Write-Host "Profile Score: 0"
    Write-Host ""
    Write-Host "Original files backed up as .bak files."
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
