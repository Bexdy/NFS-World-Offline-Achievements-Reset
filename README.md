# NFS World Offline — Achievement Reset

A small community contribution for NFS-World-Offline by Lawin0129.

This project provides a script and modified driver-template configuration intended to let newly created drivers begin with zero completed achievements, while retaining the ability to progress through and complete achievements during gameplay. 

**(It changes the "DriverTemplate", so any new account created starts with all achievements at 0, and can be progressed and completed. REQUIRES SERVER TO BE DOWN FOR THESE CHANGES)**

This project builds upon the work of existing developers and community projects. Their work is acknowledged below.

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

# Based on
NFS-World-Offline — Lawin0129

Original project: https://github.com/Lawin0129/NFS-World-Offline

The original project provides the Node.js backend used to run Need for Speed: World locally. This repository builds upon its driver-template structure and achievement data.

Credit: Lawin0129 is the creator of the original NFS-World-Offline project. The original project's authorship remains with its respective author.

Please visit the original repository for the full server implementation, documentation, features, and original credits.

# Acknowledgements
## Soapbox Race World

Project: https://github.com/SoapboxRaceWorld

Soapbox Race World is an important community project dedicated to keeping Need for Speed: World playable through community-developed infrastructure.

The NFS-World-Offline README acknowledges Soapbox Race World for NFS World data files. This project recognizes that contribution and the broader community's work in preserving the game.
Soapbox Race Offline 1.9.0

Original project: https://github.com/berkay2578/soapbox-race-offline-1.9.0

The NFS-World-Offline project credits berkay2578 and Nilzao for contributions associated with catalog and basket XML files, the Server Editor, and the XMPP message subject hash algorithm.

These acknowledgements are retained in recognition of the work documented by the original project.

## My contribution

My contribution is the focused modification of the driver template and the accompanying automation script for initializing achievement progress and profile score values.

The goal is to make the initial driver experience more suitable for players who want to earn achievements through gameplay rather than begin with achievements already marked as completed.

I do not claim authorship of the original server, the original game data, or the work of the projects acknowledged above.

# Disclaimer

This is an unofficial, community-made project. It is not affiliated with, endorsed by, or supported by Electronic Arts or the original developers of Need for Speed: World.

Need for Speed and Need for Speed: World are trademarks of their respective owners. This repository is intended for community preservation and modification purposes.
