#!/usr/bin/env bash
# Vanta Linux - QEMU test script for Linux
# Tests the built ISO in a QEMU virtual machine with hardware acceleration.
#
# Prerequisites:
#   sudo pacman -S qemu-desktop edk2-ovmf
#   or: apt install qemu-system-x86 ovmf
#
# Usage:
#   ./scripts/test-qemu.sh [--iso path/to/vanta.iso] [--ram 4096] [--cpus 4]

set -euo pipefail

ISO="${1:-out/vanta-linux-*.iso}"
RAM="${2:-4096}"
CPUS="${4:-4}"

# Find ISO
shopt -s nullglob
iso_files=( $ISO )
if [ ${#iso_files[@]} -eq 0 ]; then
  echo "ERROR: No ISO found. Build one first: ./scripts/build-iso.sh"
  exit 1
fi
ISO="${iso_files[0]}"

echo "==> Testing Vanta Linux ISO in QEMU..."
echo "    ISO:  $ISO"
echo "    RAM:  ${RAM}MB"
echo "    CPUs: $CPUS"
echo ""

# Check for KVM
KVM_FLAG=""
if [ -e /dev/kvm ]; then
  KVM_FLAG="-accel kvm"
  echo "  KVM acceleration: available"
else
  echo "  KVM: not available (VM will be slow)"
fi

# Check for OVMF UEFI firmware
OVMF=""
for path in \
  /usr/share/edk2/x64/OVMF_CODE.fd \
  /usr/share/edk2-ovmf/OVMF_CODE.fd \
  /usr/share/qemu/edk2-x86_64-code.fd \
  /usr/share/OVMF/OVMF_CODE_4M.fd; do
  if [ -f "$path" ]; then
    OVMF="$path"
    break
  fi
done

UEFI_ARGS=""
if [ -n "$OVMF" ]; then
  UEFI_ARGS="-bios $OVMF"
  echo "  UEFI firmware: $OVMF"
else
  echo "  WARNING: OVMF not found, booting legacy BIOS"
fi

# Create a test disk for installation testing
test_disk="out/vanta-test-disk.qcow2"
if [ ! -f "$test_disk" ]; then
  echo "==> Creating test disk (32GB)..."
  qemu-img create -f qcow2 "$test_disk" 32G
fi

echo ""
echo "  In the VM:"
echo "  - Login as root (password: vanta)"
echo "  - Run: calamares"
echo ""

# Launch QEMU
exec qemu-system-x86_64 \
  -m "$RAM" \
  -smp "$CPUS" \
  -cdrom "$ISO" \
  -boot d \
  $KVM_FLAG \
  $UEFI_ARGS \
  -vga virtio \
  -display gtk,gl=on \
  -machine q35 \
  -cpu host \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -audiodev pa,id=sound0 \
  -device intel-hda \
  -device hda-duplex,audiodev=sound0 \
  -drive file="$test_disk",format=qcow2,if=virtio \
  -usb \
  -device usb-tablet
