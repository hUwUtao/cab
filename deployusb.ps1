param(
    [Parameter(Mandatory=$true)]
    [string]$UsbRoot
)

$sourceFolder = Join-Path $PSScriptRoot "nixos"
$destinationFolder = $UsbRoot

if (-not $PSScriptRoot) {
    Write-Error "PSScriptRoot is null. Make sure you're running this script from a file, not directly in the console."
    exit 1
}

if (-not (Test-Path $sourceFolder)) {
    Write-Error "Source folder '$sourceFolder' not found."
    exit 1
}

if (-not (Test-Path $destinationFolder -PathType Container)) {
    Write-Error "Destination USB root folder not found or is not a directory: $UsbRoot"
    exit 1
}

try {
    Copy-Item -Path "$sourceFolder\*" -Destination $destinationFolder -Recurse -Force
    Write-Host "Files copied successfully from '$sourceFolder' to $UsbRoot"
} catch {
    Write-Error "An error occurred while copying files: $_"
    exit 1
}
