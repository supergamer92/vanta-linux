# Vanta Linux - Vagrant build environment
# Spins up an Arch Linux VM with all build dependencies pre-installed.
#
# Usage:
#   vagrant up
#   vagrant ssh -c "cd /vanta && ./scripts/build-iso.sh"
#   # ISO will be in /vanta/out/
#
# Prerequisites:
#   - Vagrant (https://www.vagrantup.com)
#   - VirtualBox or libvirt provider
#   - At least 4GB RAM allocated to the VM

Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  config.vm.synced_folder ".", "/vanta", type: "virtualbox"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 4
    vb.name = "vanta-builder"
  end

  config.vm.provision "shell", inline: <<-SHELL
    pacman -Syu --noconfirm
    pacman -S --noconfirm \
      archiso \
      base-devel \
      git \
      rust \
      cargo \
      squashfs-tools \
      grub \
      dosfstools \
      mtools \
      xorriso \
      btrfs-progs \
      snapper
    mkdir -p /repo/vanta/x86_64
  SHELL

  config.vm.post_up_message = <<-MSG
    Vanta Linux build environment ready.

    To build the ISO:
      vagrant ssh
      cd /vanta
      ./scripts/build-packages.sh
      ./scripts/build-iso.sh

    The built ISO will be in /vanta/out/
  MSG
end
