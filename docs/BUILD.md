# Building and Testing Vanta Linux

## Quickest Path to an ISO

### 1. Push to GitHub, use Actions (no local build needed)

```bash
git init && git add . && git commit -m "initial"
gh repo create vanta-linux --public --push
# Then: github.com/<user>/vanta-linux -> Actions -> Build Vanta ISO -> Run workflow
```

### 2. Build on Windows with Docker

```powershell
# Install Docker Desktop, then:
.\scripts\build-docker.ps1
```

### 3. Build with Vagrant

```bash
vagrant up
vagrant ssh -c "cd /vanta && ./scripts/build-packages.sh && ./scripts/build-iso.sh"
```

### 4. Build on native Arch

```bash
sudo pacman -Syu archiso base-devel rust cargo
./scripts/build-packages.sh
./scripts/build-iso.sh
```

## Testing the ISO

### QEMU (Windows)

```powershell
.\scripts\test-qemu.ps1
```

### QEMU (Linux)

```bash
./scripts/test-qemu.sh
```

### VirtualBox

- Arch Linux (64-bit), 4GB RAM, 32GB disk
- Enable EFI
- Boot from ISO

## Live Session

| What | How |
|------|-----|
| Login | Automatic (root, no password in live) |
| Install | Desktop icon "Install Vanta Linux" |
| Terminal | Konsole (Ctrl+Alt+T) |
| Themes | Pre-applied via vanta-init |
| NVIDIA | Modesetting enabled by default |

## Packages

After boot, these Vanta packages are installed:

- `vanta-meta` - metapackage
- `vanta-fonts` - Inter + JetBrains Mono
- `vanta-settings` - system defaults, dconf, sysctl
- `vanta-updater` - atomic Btrfs updater + timer
- `vanta-theme-plasma` - Plasma global theme
- `vanta-theme-kwin` - KWin decorations
- `vanta-theme-sddm` - login screen
- `vanta-theme-plymouth` - boot splash
- `vanta-theme-grub` - bootloader theme
- `vanta-theme-icons` - icon set
- `vanta-theme-cursors` - cursor set
- `vanta-theme-sounds` - sound theme
- `vanta-installer` - Calamares modules

## Development Loop

```
edit config/ -> rebuild package -> rebuild ISO -> test in QEMU
```

For rapid iteration on visual changes:

```bash
# On a running Vanta system:
sudo vanta-init --apply          # re-apply all settings
# OR manually copy a single file:
cp config/plasma/Vanta.colors ~/.local/share/color-schemes/
```
