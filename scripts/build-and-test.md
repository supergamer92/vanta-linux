# Vanta Linux - Build & Test Quickstart

## Prerequisites

You need a Linux environment to build. On Windows, choose one:

### Option A: Docker Desktop (easiest)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) with WSL2 backend
2. Open PowerShell in the repo root
3. Run:
```powershell
.\scripts\build-docker.ps1
```
4. The ISO appears in `out\vanta-linux-*.iso`

### Option B: Vagrant VM

1. Install [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org)
2. From repo root:
```bash
vagrant up
vagrant ssh -c "cd /vanta && ./scripts/build-packages.sh && ./scripts/build-iso.sh"
```

### Option C: WSL2 with Arch (manual)

1. Install [Arch WSL](https://github.com/yuk7/ArchWSL) or any Arch container
2. Inside Arch:
```bash
pacman -Syu archiso base-devel git rust cargo
cd /path/to/vanta
./scripts/build-packages.sh
./scripts/build-iso.sh
```

### Option D: GitHub Actions (no local build)

1. Fork/push the repo to GitHub
2. Go to Actions -> "Build Vanta ISO" -> "Run workflow"
3. Download the ISO artifact

## Testing in a VM

### QEMU (recommended)

**On Windows (PowerShell):**
```powershell
.\scripts\test-qemu.ps1
```
This boots the ISO in QEMU with UEFI, KVM/WHPX acceleration, a 32GB test disk, and audio.

**On Linux:**
```bash
./scripts/test-qemu.sh
```

### VirtualBox

1. New VM -> Type: Linux, Version: Arch Linux (64-bit)
2. RAM: 4096 MB
3. Disk: 32 GB (VDI)
4. Settings -> System -> Enable EFI
5. Settings -> Display -> Video Memory: 128 MB, Graphics Controller: VMSVGA
6. Settings -> Storage -> Attach the ISO
7. Start the VM

### VMware Workstation

1. New VM -> Custom -> Linux -> Other Linux 5.x kernel 64-bit
2. RAM: 4096 MB
3. Disk: 32 GB
4. VM Settings -> Options -> Advanced -> UEFI
5. VM Settings -> Hardware -> CD/DVD -> Use ISO image
6. Power on

## Live Environment

- **Login**: root / vanta (autologin, but this is the fallback)
- **Desktop**: KDE Plasma on Wayland with Vanta theming
- **Install**: Double-click "Install Vanta Linux" on the desktop, or run `calamares`
- **Terminal**: Konsole with Vanta color scheme and JetBrains Mono

## Developing Changes

1. Edit files in the repo
2. Rebuild: `./scripts/build-iso.sh` (takes ~10-20 minutes)
3. For quick testing of config changes without full rebuild:
   - Theme can be tested live: copy config files to ~/.local/share/plasma/...
   - KWin rules: edit and `kwin_x11 --replace` (on X11) or restart session (Wayland)
   - Colors: System Settings -> Colors -> Install from File
