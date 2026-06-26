#!/usr/bin/env bash
# vanta-init: Vanta Linux first-boot initializer
# Applies dconf defaults, system settings, and theming.
#
# Usage: vanta-init [--apply | --status | --reset]
#   --apply   Apply all Vanta defaults (idempotent)
#   --status  Show current configuration diff
#   --reset   Reset all Vanta settings to defaults

set -euo pipefail

VANTA_CONFIG_DIR="/etc/vanta"
DCONF_FILE="${VANTA_CONFIG_DIR}/dconf-defaults"

apply_settings() {
  echo "Applying Vanta system settings..."

  # GTK settings
  mkdir -p /etc/gtk-3.0
  cp /etc/vanta/gtk-settings.ini /etc/gtk-3.0/settings.ini 2>/dev/null || true

  # Fontconfig
  mkdir -p /etc/fonts
  cp /etc/vanta/fonts-local.conf /etc/fonts/local.conf 2>/dev/null || true

  # Dconf (user-level settings for first user)
  if command -v dconf >/dev/null 2>&1 && [ -f "${DCONF_FILE}" ]; then
    while IFS=' ' read -r key value; do
      [[ -z "${key}" || "${key}" == \#* ]] && continue
      dconf write "${key}" "${value}" 2>/dev/null || true
    done < "${DCONF_FILE}"
  fi

  # Systemd services
  systemctl enable --now vanta-updater.timer 2>/dev/null || true
  systemctl enable --now fstrim.timer 2>/dev/null || true

  # NVIDIA module parameters
  mkdir -p /etc/modprobe.d
  cat > /etc/modprobe.d/nvidia-vanta.conf << 'EOF'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

  # Sysctl
  sysctl --system >/dev/null 2>&1 || true

  # Refresh font cache
  fc-cache -f >/dev/null 2>&1 || true

  echo "Vanta settings applied."
}

show_status() {
  echo "Vanta configuration status:"
  echo "  Dconf defaults:  $([ -f "${DCONF_FILE}" ] && echo "present" || echo "absent")"
  echo "  Font config:     $([ -f /etc/fonts/local.conf ] && echo "present" || echo "absent")"
  echo "  GTK settings:    $([ -f /etc/gtk-3.0/settings.ini ] && echo "present" || echo "absent")"
  echo "  NVIDIA modeset:  $([ -f /etc/modprobe.d/nvidia-vanta.conf ] && echo "present" || echo "absent")"
  echo "  Updater timer:   $(systemctl is-enabled vanta-updater.timer 2>/dev/null || echo 'disabled')"
}

reset_settings() {
  echo "Resetting Vanta settings to defaults..."
  rm -f /etc/gtk-3.0/settings.ini
  rm -f /etc/fonts/local.conf
  rm -f /etc/modprobe.d/nvidia-vanta.conf
  apply_settings
}

case "${1:-}" in
  --apply)  apply_settings ;;
  --status) show_status ;;
  --reset)  reset_settings ;;
  *)
    echo "Usage: vanta-init [--apply | --status | --reset]"
    exit 1
    ;;
esac
