#!/usr/bin/env bash
# vanta-init: Vanta Linux first-boot initializer
set -euo pipefail

VANTA_CFG="/etc/vanta"

apply() {
  echo "Applying Vanta system settings..."

  # GTK
  mkdir -p /etc/gtk-3.0
  cp "${VANTA_CFG}/gtk-settings.ini" /etc/gtk-3.0/settings.ini 2>/dev/null || true

  # Fontconfig
  cp "${VANTA_CFG}/fonts-local.conf" /etc/fonts/local.conf 2>/dev/null || true

  # Sysctl
  sysctl --system >/dev/null 2>&1 || true

  # Dconf
  if command -v dconf >/dev/null 2>&1 && [ -f "${VANTA_CFG}/dconf-defaults" ]; then
    while IFS=' ' read -r key value; do
      [[ -z "${key}" || "${key}" == \#* ]] && continue
      dconf write "${key}" "${value}" 2>/dev/null || true
    done < "${VANTA_CFG}/dconf-defaults"
  fi

  # Services
  systemctl enable --now vanta-updater.timer 2>/dev/null || true
  systemctl enable --now fstrim.timer 2>/dev/null || true

  # Font cache
  fc-cache -f >/dev/null 2>&1 || true

  echo "OK"
}

status() {
  echo "Vanta configuration status:"
  for f in dconf-defaults gtk-settings.ini fonts-local.conf; do
    echo "  ${f}: $([ -f "${VANTA_CFG}/${f}" ] && echo "present" || echo "absent")"
  done
}

case "${1:-}" in
  --apply)  apply ;;
  --status) status ;;
  *)
    echo "Usage: vanta-init [--apply | --status]"
    exit 1
    ;;
esac
