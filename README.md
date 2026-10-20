# NFS-World-Offline-Achievements-Reset
It changes the "DriverTemplate", so any new account created starts with all achievements at 0, and can be progressed and completed.

# Powershell Script

In powershell use the command "cd" to the server folder

Server Folder Structure
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        20/10/2026     04:06                config
d-----        20/10/2026     04:06                data
d-----        20/10/2026     05:42                drivers
d-----        20/10/2026     04:08                node_modules
d-----        20/10/2026     04:06                src
-a----        19/10/2026     01:32             32 .gitignore
-a----        19/10/2026     01:32          35149 LICENSE
-a----        20/10/2026     04:08          55555 package-lock.json
-a----        19/10/2026     01:32            799 package.json
-a----        19/10/2026     01:32          11836 README.md
-a----        19/10/2026     01:32         591872 ServerEditor.exe
-a----        19/10/2026     01:32            456 start.bat

```
cd "C:\Need for Speed World Offline Server"

Then Copy all the script into Powershell

```
$ErrorActionPreference = "Stop"

# ============================================================
# 1. Reset achievements in the driver template
# ============================================================

$achievementsPath = ".\config\DriverTemplate\loadall.xml"

if (-not (Test-Path $achievementsPath)) {
    throw "Could not find $achievementsPath. Run this script from the repository root."
}

Copy-Item $achievementsPath "$achievementsPath.bak" -Force

[xml]$achievementsXml = Get-Content -LiteralPath $achievementsPath -Raw

$definitions = $achievementsXml.SelectNodes(
    "/AchievementsPacket/Definitions/AchievementDefinitionPacket"
)

if ($definitions.Count -eq 0) {
    throw "No achievement definitions found. Check the XML structure."
}

foreach ($definition in $definitions) {

    # Reset achievement progress
    $currentValue = $definition.SelectSingleNode("./CurrentValue")
    if ($null -ne $currentValue) {
        $currentValue.InnerText = "0"
    }

    # Reset each achievement rank
    $ranks = $definition.SelectNodes(
        "./AchievementRanks/AchievementRankPacket"
    )

    foreach ($rank in $ranks) {

        $rankNode = $rank.SelectSingleNode("./Rank")
        $state = $rank.SelectSingleNode("./State")

        if ($null -eq $rankNode -or $null -eq $state) {
            throw "A rank is missing its Rank or State element."
        }

        $rankNumber = [int]$rankNode.InnerText

        if ($rankNumber -eq 1) {
            $state.InnerText = "InProgress"
        }
        else {
            $state.InnerText = "Locked"
        }

        # Reset completion timestamp if present
        $achievedOn = $rank.SelectSingleNode("./AchievedOn")
        if ($null -ne $achievedOn) {
            $achievedOn.InnerText = "0001-01-01T00:00:00"
        }
    }
}

$achievementsXml.Save((Resolve-Path $achievementsPath).Path)

Write-Host "Achievements reset in loadall.xml."
Write-Host "Backup: $achievementsPath.bak"


# ============================================================
# 2. Reset Score in GetPersonaInfo.xml
# ============================================================

$personaInfoPath = ".\config\DriverTemplate\GetPersonaInfo.xml"

if (-not (Test-Path $personaInfoPath)) {
    throw "Could not find $personaInfoPath. Check the file location."
}

Copy-Item $personaInfoPath "$personaInfoPath.bak" -Force

[xml]$personaInfoXml = Get-Content -LiteralPath $personaInfoPath -Raw

$scoreNode = $personaInfoXml.SelectSingleNode("/ProfileData/Score")

if ($null -eq $scoreNode) {
    throw "Could not find the Score element under ProfileData."
}

$scoreNode.InnerText = "0"

$personaInfoXml.Save((Resolve-Path $personaInfoPath).Path)

Write-Host "Score reset to 0 in GetPersonaInfo.xml."
Write-Host "Backup: $personaInfoPath.bak"

Write-Host ""
Write-Host "All template changes completed successfully."

```

# .bat File

Extract the "Achievements Reset.bat" to the folder "server folder"

Server Folder Structure
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        20/10/2026     04:06                config
d-----        20/10/2026     04:06                data
d-----        20/10/2026     05:42                drivers
d-----        20/10/2026     04:08                node_modules
d-----        20/10/2026     04:06                src
-a----        19/10/2026     01:32             32 .gitignore
-a----        19/10/2026     01:32          35149 LICENSE
-a----        20/10/2026     04:08          55555 package-lock.json
-a----        19/10/2026     01:32            799 package.json
-a----        19/10/2026     01:32          11836 README.md
-a----        19/10/2026     01:32         591872 ServerEditor.exe
-a----        19/10/2026     01:32            456 start.bat

```

Open "Achievements Reset.bat"


# For already created accounts (not recommended)

Based on the "loudall.xml" in the "DriverTemplate" after the "Achievements Reset.bat"

Copy the "loadall.xml" into the driver's account folder

.\drivers folder structure (driver1 is the first account created)

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        20/10/2026     06:10                driver1
-a----        20/10/2026     05:43             61 DefaultPersonaIdx.xml
-a----        19/10/2026     01:32            262 README.txt
```

.\driver1 folder Structure (driver's account folder)

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        20/10/2026     05:43           3277 carslots.xml
-a----        20/10/2026     05:43            299 GetPersonaInfo.xml
-a----        20/10/2026     05:42            192 gettreasurehunteventsession.xml
-a----        20/10/2026     05:42         216580 loadall.xml
-a----        20/10/2026     05:43           4039 objects.xml
```
