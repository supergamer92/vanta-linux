#!/usr/bin/env bash
# Vanta Linux - customize the live environment rootfs
# Runs inside archiso chroot during ISO build.

set -euo pipefail

echo "Customizing Vanta Live environment..."

# ==== Root password ====
echo "root:vanta" | chpasswd

# ==== Locale ====
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf
locale-gen

# ==== Hostname ====
echo "vanta-live" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   vanta-live.localdomain vanta-live
EOF

# ==== Timezone ====
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# ==== Vanta autologin (SDDM for Wayland) ====
cat > /etc/sddm.conf.d/vanta-live.conf << 'EOF'
[Autologin]
User=root
Session=plasmawayland
Relogin=false

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
Numlock=on

[Theme]
Current=vanta
CursorTheme=Vanta
Font=Inter,12
EOF

# ==== Vanta settings for live session ====
if command -v vanta-init &>/dev/null; then
  vanta-init --apply
fi

# ==== NetworkManager for live networking ====
systemctl enable NetworkManager
systemctl enable bluetooth

# ==== Enable SDDM ====
systemctl enable sddm

# ==== Set default target ====
systemctl set-default graphical.target

# ==== Configure sudo for live environment ====
echo "root ALL=(ALL) ALL" > /etc/sudoers.d/vanta-live
chmod 440 /etc/sudoers.d/vanta-live

# ==== Plymouth ====
systemctl enable plymouth-start

# ==== Create live desktop shortcut for installer ====
mkdir -p /root/Desktop
cat > /root/Desktop/install-vanta.desktop << 'EOF'
[Desktop Entry]
Name=Install Vanta Linux
Comment=Install Vanta Linux to your hard drive
Exec=calamares
Icon=drive-harddisk
Terminal=false
Type=Application
Categories=System;
EOF
chmod +x /root/Desktop/install-vanta.desktop

# ==== Clean up ====
rm -rf /var/cache/pacman/pkg/*
rm -f /etc/machine-id
touch /etc/machine-id
