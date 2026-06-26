# Vanta Linux - one-step build and test for Windows
# Uses Docker to build the ISO, then QEMU to test it.
#
# Usage:
#   .\scripts\build-local.ps1 [--no-test]
#
# Flags:
#   --no-test  Build only, don't launch QEMU

param([switch]$NoTest = $false)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Vanta Linux - Build + Test Pipeline" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build ISO
Write-Host "[1/2] Building ISO..." -ForegroundColor Green
Set-Location $RepoRoot
& .\scripts\build-docker.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}

# Step 2: Test in QEMU
if (-not $NoTest) {
    Write-Host "[2/2] Launching QEMU..." -ForegroundColor Green
    & .\scripts\test-qemu.ps1
}

Write-Host "Done." -ForegroundColor Cyan
