# Vanta Linux

A dark-first Linux distribution built on Arch Linux and KDE Plasma.
Minimalist Noir. Unix Power. Zero Visual Debt.

## Decision Log

| ID | Category | Decision | Status |
|----|----------|----------|--------|
| D01 | Name | Vanta | LOCKED |
| D02 | Base System | Arch Linux | LOCKED |
| D03 | Display Server | Wayland | LOCKED |
| D04 | Compositor | KWin on Wayland | LOCKED |
| D05 | Desktop Environment | KDE Plasma | LOCKED |
| D06 | Graphics | NVIDIA first-class (modeset=1, fbdev=1, explicit sync) | LOCKED |
| D07 | Release Model | Hybrid atomic (Btrfs snapshots + transactional updates) | LOCKED |
| D08 | Filesystem | Btrfs | LOCKED |
| D09 | Init | systemd | LOCKED |
| D10 | Visual Identity | Minimalist Noir (dark-only, matte primary, amber accent) | LOCKED |
| D11 | Accent Color | Amber (#e66100) | LOCKED |
| D12 | Typography | Inter (UI) + JetBrains Mono (code) | LOCKED |
| D13 | Update Mechanism | Btrfs snapper snapshots before/after every pacman transaction | LOCKED |
| D14 | Package Format | pacman (base) + Flatpak (app layer) | LOCKED |
| D15 | Icon Style | Monochrome/duotone | DECIDED |
| D16 | Sound Philosophy | Minimal, purposeful audio cues | DECIDED |
| D17 | Developer Tooling | Includes git, base-devel, rust, go, python | DECIDED |

## Design Philosophy

- **Does it improve usability?** Every decision starts here.
- **Does it fit the visual identity?** Dark-only, matte, amber accent.
- **Would someone use this daily without getting tired of it?** Restraint over spectacle.
- **Is it consistent with existing decisions?** Prior decisions are locked; changes must be justified against them.
- **Is it realistic to ship?** We prefer extending existing projects over building from scratch.

### Visual Principles

- Matte surfaces with depth (elevation through shadow, not translucency)
- Frosted glass used only for fleeting surfaces (notifications, menus, tooltips)
- Soft shadows that imply layer hierarchy
- Consistent 8px corner radius throughout
- Subtle luminosity-based gradients (never harsh color transitions)
- One accent color (amber). No rainbow system.
- Typography legible at every size, beautiful at large sizes
- Animations that communicate state, not perform
- Negative space as a deliberate design element

## Repository Structure

```
vanta/
  branding/          Logo, wallpapers, color palette, typography spec
  config/            Plasma theme, KWin rules, SDDM, Plymouth, GRUB, fonts, GTK, sysctl
  packages/          PKGBUILDs for all custom vanta-* packages
  apps/              Custom application source (installer, settings)
  iso/               ArchISO profile for building the installable ISO
  scripts/           Build helpers (build-iso.sh, build-packages.sh, vanta-init.sh)
  docs/              Documentation
```

## Build

```bash
# 1. Build all custom packages
./scripts/build-packages.sh

# 2. Build the ISO
./scripts/build-iso.sh
```

## Package Architecture

| Package | Purpose |
|---------|---------|
| vanta-meta | Metapackage pulling in everything |
| vanta-fonts | Inter + JetBrains Mono |
| vanta-theme-plasma | Plasma global theme, colors, panel layout |
| vanta-theme-kwin | KWin decoration and window rules |
| vanta-theme-grub | GRUB bootloader theme |
| vanta-theme-sddm | SDDM login screen |
| vanta-theme-plymouth | Boot splash |
| vanta-theme-icons | Monochrome icon theme |
| vanta-theme-cursors | Custom cursor set |
| vanta-theme-sounds | System sound theme |
| vanta-settings | Dconf defaults, sysctl, systemd units |
| vanta-updater | Atomic Btrfs snapshot updater (Rust) |
| vanta-installer | Calamares installer branding and modules |

## Atomic Updates

Vanta uses Btrfs snapshots for transactional system updates:

1. `vanta-update --check` -- check for available updates
2. `vanta-update --apply` -- snapshot -> pacman -Syu -> snapshot
3. `vanta-rollback <num>` -- restore a pre-update snapshot

Snapper timeline is configured to keep 5 hourly, 7 daily, and 4 weekly snapshots.
GRUB boot entries include snapshot access for manual rollback.
