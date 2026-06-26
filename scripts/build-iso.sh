#!/usr/bin/env bash
# Vanta Linux - ISO build script
# Builds the full installable ISO from Arch Linux base.
#
# Prerequisites:
#   - Arch Linux system (or container) with archiso installed
#   - All custom packages built and placed in /repo/vanta/
#   - Run from the vanta repository root
#
# Usage:
#   ./scripts/build-iso.sh [--clean] [--local-pkgs PATH]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ISO_DIR="${REPO_ROOT}/iso/archiso"
WORK_DIR="/tmp/vanta-iso-work"
OUT_DIR="${REPO_ROOT}/out"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log()  { echo -e "${GREEN}[BUILD]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# Parse arguments
CLEAN=false
LOCAL_PKGS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean)     CLEAN=true; shift ;;
    --local-pkgs) LOCAL_PKGS="$2"; shift 2 ;;
    *) err "Unknown option: $1" ;;
  esac
done

# Check prerequisites
command -v mkarchiso >/dev/null 2>&1 || err "mkarchiso not found. Install archiso."

# Clean previous build
if [ "$CLEAN" = true ]; then
  log "Cleaning previous build..."
  rm -rf "${WORK_DIR}" "${OUT_DIR}"
fi

mkdir -p "${OUT_DIR}"

# Copy local packages if provided
if [ -n "${LOCAL_PKGS}" ]; then
  log "Copying local packages from ${LOCAL_PKGS}..."
  mkdir -p "${ISO_DIR}/airootfs/root/packages"
  cp -v "${LOCAL_PKGS}"/*.pkg.tar.zst "${ISO_DIR}/airootfs/root/packages/" 2>/dev/null || true
fi

# Build the ISO
log "Building Vanta Linux ISO..."
cd "${ISO_DIR}"
mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" .

log "ISO build complete!"
log "Output: ${OUT_DIR}/vanta-linux-*.iso"
ls -lh "${OUT_DIR}"/*.iso 2>/dev/null || true

# Clean up working directory
if [ "$CLEAN" = true ]; then
  rm -rf "${WORK_DIR}"
fi
