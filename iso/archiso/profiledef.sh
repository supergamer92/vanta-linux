#!/usr/bin/env bash
# Vanta Linux - ArchISO profile definition for a bootable live ISO.
#
# Build with: mkarchiso -v -w /tmp/vanta-work -o out/ .

iso_name="vanta-linux"
iso_label="VANTA_LIVE"
iso_publisher="Vanta Linux <https://vanta.linux>"
iso_application="Vanta Linux Live/Installer"
iso_version="$(date +%Y.%m)"
install_dir="vanta"
buildmodes=('iso')
bootmodes=(
  'bios.syslinux.mbr'
  'bios.syslinux.eltorito'
  'uefi-x64.systemd-boot.esp'
  'uefi.systemd-boot'
)
arch='x86_64'
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
file_permissions=(
  ["/root"]="0:0:750"
  ["/root/Desktop"]="0:0:755"
  ["/root/Desktop/install-vanta.desktop"]="0:0:755"
)
