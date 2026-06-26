# Vanta Linux - QEMU test script for Windows
# Tests the built ISO in a QEMU virtual machine.
#
# Prerequisites:
#   1. Install QEMU (choco install qemu or from https://www.qemu.org/download/#windows)
#   2. Build the ISO first (.\scripts\build-docker.ps1)
#   3. The ISO will be at .\out\vanta-linux-*.iso
#
# Usage:
#   .\scripts\test-qemu.ps1 [--uefi] [--iso PATH] [--ram 4096] [--cpus 4] [--gpu]

param(
    [switch]$Uefi = $true,
    [string]$Iso = "",
    [int]$Ram = 4096,
    [int]$Cpus = 4,
    [switch]$Gpu = $false
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

# Find the ISO
if (-not $Iso) {
    $isoFiles = Get-ChildItem "${RepoRoot}\out\*.iso"
    if (-not $isoFiles) {
        Write-Host "ERROR: No ISO found in out/. Build one first with .\scripts\build-docker.ps1" -ForegroundColor Red
        exit 1
    }
    $Iso = $isoFiles[0].FullName
}

# Find QEMU
$qemuPath = Get-Command qemu-system-x86_64 -ErrorAction SilentlyContinue
if (-not $qemuPath) {
    # Check common paths
    $paths = @(
        "C:\Program Files\qemu\qemu-system-x86_64.exe",
        "C:\Program Files (x86)\qemu\qemu-system-x86_64.exe",
        "${env:ProgramFiles}\qemu\qemu-system-x86_64.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $qemuPath = $p
            break
        }
    }
}

if (-not $qemuPath) {
    Write-Host "ERROR: QEMU not found. Install via choco: choco install qemu" -ForegroundColor Red
    Write-Host "  Or download from: https://www.qemu.org/download/#windows" -ForegroundColor Yellow
    exit 1
}

$qemuCmd = if ($qemuPath -is [array]) { $qemuPath[0].Source } else { $qemuPath }

Write-Host "==> Testing Vanta Linux ISO in QEMU..." -ForegroundColor Cyan
Write-Host "    ISO:  $Iso"
Write-Host "    RAM:  ${Ram}MB"
Write-Host "    CPUs: $Cpus"
Write-Host "    UEFI: $Uefi"
Write-Host ""

# Build QEMU arguments
$args = @(
    "-m", $Ram,
    "-smp", $Cpus,
    "-cdrom", "`"$Iso`"",
    "-boot", "d",
    "-vga", "virtio",
    "-display", "gtk,gl=$($Gpu.ToString().ToLower())",
    "-machine", "type=q35,accel=whpx$($Gpu ? ',kvm=on' : '')",
    "-cpu", "host",
    "-netdev", "user,id=net0",
    "-device", "virtio-net-pci,netdev=net0",
    "-audiodev", "sdlaudio,id=sound0",
    "-device", "intel-hda",
    "-device", "hda-duplex,audiodev=sound0",
    "-usb",
    "-device", "usb-tablet"
)

if ($Uefi) {
    # Find OVMF firmware
    $ovmfPaths = @(
        "C:\Program Files\qemu\share\edk2-x86_64-code.fd",
        "C:\Program Files (x86)\qemu\share\edk2-x86_64-code.fd",
        "${env:ProgramFiles}\qemu\share\edk2-x86_64-code.fd",
        # MSYS2 / UCRT64 paths
        "${env:ProgramFiles}\msys2\ucrt64\share\qemu\edk2-x86_64-code.fd"
    )
    $ovmf = $null
    foreach ($p in $ovmfPaths) {
        if (Test-Path $p) {
            $ovmf = $p
            break
        }
    }
    if ($ovmf) {
        $args += @("-bios", "`"$ovmf`"")
        Write-Host "  Using OVMF: $ovmf" -ForegroundColor Gray
    } else {
        Write-Host "  WARNING: OVMF firmware not found, booting without UEFI" -ForegroundColor Yellow
    }
}

# Create a virtual disk for testing installation
$testDisk = "${RepoRoot}\out\vanta-test-disk.qcow2"
if (-not (Test-Path $testDisk)) {
    Write-Host "==> Creating test disk (32GB)..." -ForegroundColor Cyan
    & "qemu-img" create -f qcow2 "`"$testDisk`"" 32G 2>&1 | Out-Null
}
$args += @("-drive", "file=`"$testDisk`",format=qcow2,if=virtio")

Write-Host "==> Starting QEMU. Close the window to stop." -ForegroundColor Green
Write-Host ""
Write-Host "  In the VM:"
Write-Host "  - Login as root (password: vanta)"
Write-Host "  - Double-click 'Install Vanta Linux' on the desktop to run Calamares"
Write-Host "  - Or run: calamares"
Write-Host ""

# Launch QEMU
$procArgs = @{
    FilePath = $qemuCmd
    ArgumentList = $args
    NoNewWindow = $true
    Wait = $true
}
Start-Process @procArgs

Write-Host "==> QEMU stopped." -ForegroundColor Cyan
