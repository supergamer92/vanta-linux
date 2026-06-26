#!/usr/bin/env bash
# Vanta Linux - development environment setup
# Run on an Arch Linux system to prepare for Vanta development.
#
# Usage:
#   curl -fsSL https://vanta.linux/setup | bash
#   # or: ./scripts/dev-setup.sh

set -euo pipefail

log() { echo -e "\033[0;32m[SETUP]\033[0m $*"; }
err() { echo -e "\033[0;31m[ERROR]\033[0m $*"; exit 1; }

log "Vanta Linux development environment setup"

# Verify Arch Linux
if [ ! -f /etc/arch-release ]; then
  err "This script must be run on Arch Linux."
fi

# Install prerequisites
log "Installing build prerequisites..."
sudo pacman -Syu --noconfirm archiso base-devel git rust cargo snapper \
  grub-btrfs btrfs-progs inotify-tools plasma-meta kwin sddm calamares \
  flatpak pamac

# Create package repository directory
sudo mkdir -p /repo/vanta/x86_64

# Clone the Vanta repository if not already present
if [ ! -d vanta ]; then
  log "Cloning Vanta repository..."
  git clone https://github.com/vanta-linux/vanta.git
  cd vanta
fi

log "Building all Vanta packages..."
bash scripts/build-packages.sh --repo /repo/vanta

log "Development environment ready."
echo ""
echo "To build the ISO:"
echo "  ./scripts/build-iso.sh"
echo ""
echo "To apply Vanta settings to this system:"
echo "  sudo ./scripts/vanta-init.sh --apply"
