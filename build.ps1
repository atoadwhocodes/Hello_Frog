param(
    [string]$Python = "python",
    [string]$Assembler = "ca65",
    [string]$Linker = "ld65",
    [string]$AsmSource = "hello-pond.asm",
    [string]$ObjectFile = "hello-pond.o",
    [string]$AudioDriverObject = "audio_vrc6.o",
    [string]$AudioSfxObject = "audio_sfx_data_vrc6.o",
    [string]$AudioMusicObject = "audio_music_data_vrc6.o",
    [string]$ConfigFile = "nes.cfg",
    [string]$RomFile = "hello-pond.nes"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Assert-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Invoke-Step {
    param(
        [string]$Label,
        [scriptblock]$Action
    )

    Write-Host "==> $Label"
    & $Action
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE."
    }
}

Push-Location $PSScriptRoot
try {
    Assert-Command $Python
    Assert-Command $Assembler
    Assert-Command $Linker

    $audioPackRoot = Join-Path $PSScriptRoot "frog assets\music & Sound Fx\hello_frog_vrc6_audio_pack_v1\hello_frog_vrc6_audio_pack_v1"
    $audioDriverSource = Join-Path $audioPackRoot "audio\audio_vrc6.asm"
    $audioSfxSource = Join-Path $audioPackRoot "audio\audio_sfx_data_vrc6.asm"
    $audioMusicSource = Join-Path $audioPackRoot "audio\audio_music_data_vrc6.asm"

    foreach ($path in @($audioPackRoot, $audioDriverSource, $audioSfxSource, $audioMusicSource)) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Required audio asset path was not found: $path"
        }
    }

    Write-Host "==> Checking Pillow"
    & $Python -c "import PIL"
    if ($LASTEXITCODE -ne 0) {
        throw "Python dependency 'Pillow' is missing. Install it with: python -m pip install pillow"
    }

    Invoke-Step "Generating CHR assets" {
        & $Python "gen-chr.py"
    }

    Invoke-Step "Assembling $AsmSource" {
        & $Assembler $AsmSource "-I" $audioPackRoot "-o" $ObjectFile
    }

    Invoke-Step "Assembling VRC6 audio driver" {
        & $Assembler $audioDriverSource "-I" $audioPackRoot "-o" $AudioDriverObject
    }

    Invoke-Step "Assembling VRC6 SFX data" {
        & $Assembler $audioSfxSource "-I" $audioPackRoot "-o" $AudioSfxObject
    }

    Invoke-Step "Assembling VRC6 music data" {
        & $Assembler $audioMusicSource "-I" $audioPackRoot "-o" $AudioMusicObject
    }

    Invoke-Step "Linking $RomFile" {
        & $Linker $ObjectFile $AudioDriverObject $AudioSfxObject $AudioMusicObject "-C" $ConfigFile "-o" $RomFile
    }

    Write-Host "Build completed: $RomFile"
}
finally {
    Pop-Location
}
