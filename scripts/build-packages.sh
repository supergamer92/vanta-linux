#!/usr/bin/env bash
# Vanta Linux - package build script
# Builds all custom packages in the correct dependency order.
# Copies required source files from config/ and branding/ into each package dir.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG_DIR="${REPO_ROOT}/packages"
CONFIG_DIR="${REPO_ROOT}/config"
BRANDING_DIR="${REPO_ROOT}/branding"
REPO_DIR="/repo/vanta/x86_64"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_DIR="$2/x86_64"; shift 2 ;;
    *) shift ;;
  esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${GREEN}[BUILD]${NC} $*"; }
err() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ==== Stage 1: Copy source files into package directories ================
log "Stage 1: Preparing package sources..."

prepare_source() {
  local pkg="$1" src_file="$2" dst="$3"
  if [ ! -f "$dst" ]; then
    cp -v "$src_file" "$dst"
  fi
}

# vanta-theme-plasma
prepare_source "vanta-theme-plasma" \
  "${CONFIG_DIR}/plasma/Vanta.colors" \
  "${PKG_DIR}/vanta-theme-plasma/Vanta.colors"
prepare_source "vanta-theme-plasma" \
  "${CONFIG_DIR}/plasma/kdeglobals" \
  "${PKG_DIR}/vanta-theme-plasma/kdeglobals"
prepare_source "vanta-theme-plasma" \
  "${CONFIG_DIR}/plasma/plasma-org.kde.plasma.desktop-appletsrc" \
  "${PKG_DIR}/vanta-theme-plasma/plasma-org.kde.plasma.desktop-appletsrc"
prepare_source "vanta-theme-plasma" \
  "${CONFIG_DIR}/plasma/metadata.desktop" \
  "${PKG_DIR}/vanta-theme-plasma/metadata.desktop"

# vanta-theme-kwin
prepare_source "vanta-theme-kwin" \
  "${CONFIG_DIR}/kwin/kwinrc" \
  "${PKG_DIR}/vanta-theme-kwin/kwinrc"
prepare_source "vanta-theme-kwin" \
  "${CONFIG_DIR}/kwin/kwinrulesrc" \
  "${PKG_DIR}/vanta-theme-kwin/kwinrulesrc"

# vanta-theme-grub
prepare_source "vanta-theme-grub" \
  "${CONFIG_DIR}/grub/theme.txt" \
  "${PKG_DIR}/vanta-theme-grub/theme.txt"
prepare_source "vanta-theme-grub" \
  "${CONFIG_DIR}/grub/vanta.cfg" \
  "${PKG_DIR}/vanta-theme-grub/grub-vanta.cfg"

# vanta-theme-sddm
prepare_source "vanta-theme-sddm" \
  "${CONFIG_DIR}/sddm/Main.qml" \
  "${PKG_DIR}/vanta-theme-sddm/Main.qml"
prepare_source "vanta-theme-sddm" \
  "${CONFIG_DIR}/sddm/sddm.conf" \
  "${PKG_DIR}/vanta-theme-sddm/sddm.conf"
prepare_source "vanta-theme-sddm" \
  "${BRANDING_DIR}/logo/logo.svg" \
  "${PKG_DIR}/vanta-theme-sddm/logo.svg"

# vanta-theme-plymouth
prepare_source "vanta-theme-plymouth" \
  "${CONFIG_DIR}/plymouth/vanta.script" \
  "${PKG_DIR}/vanta-theme-plymouth/vanta.script"
prepare_source "vanta-theme-plymouth" \
  "${CONFIG_DIR}/plymouth/vanta.plymouth" \
  "${PKG_DIR}/vanta-theme-plymouth/vanta.plymouth"
prepare_source "vanta-theme-plymouth" \
  "${BRANDING_DIR}/logo/logo-animated.svg" \
  "${PKG_DIR}/vanta-theme-plymouth/logo-animated.svg"

log "Stage 1 complete."

# ==== Stage 2: Build all packages =========================================
log "Stage 2: Building packages..."

PACKAGES=(
  vanta-fonts
  vanta-theme-cursors
  vanta-theme-icons
  vanta-theme-sounds
  vanta-theme-grub
  vanta-theme-plymouth
  vanta-theme-sddm
  vanta-theme-plasma
  vanta-theme-kwin
  vanta-settings
  vanta-updater
  vanta-installer
  vanta-meta
)

command -v makepkg >/dev/null 2>&1 || err "makepkg not found. Install base-devel."
mkdir -p "${REPO_DIR}"

for pkg in "${PACKAGES[@]}"; do
  PKGPATH="${PKG_DIR}/${pkg}"
  if [ ! -d "${PKGPATH}" ]; then
    log "Skipping ${pkg}: directory not found"
    continue
  fi

  log "Building ${pkg}..."
  cd "${PKGPATH}"

  # Clean previous builds
  rm -rf pkg src *.pkg.tar.zst 2>/dev/null || true

  # Build package
  makepkg -s --noconfirm || err "Failed to build ${pkg}"

  # Copy to local repo
  cp -v *.pkg.tar.zst "${REPO_DIR}/" 2>/dev/null || true

  cd "${REPO_ROOT}"
done

# Update repo database
log "Updating repository database..."
repo-add "${REPO_DIR}/vanta.db.tar.gz" "${REPO_DIR}"/*.pkg.tar.zst

log "All packages built successfully."
log "Repository: ${REPO_DIR}"
