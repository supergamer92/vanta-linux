# Vanta Linux - build environment
# Builds the full ISO in a containerized Arch Linux environment.
#
# Usage:
#   docker build -t vanta-builder .
#   docker run --rm --privileged -v .:/build -v /dev:/dev vanta-builder
#
# The --privileged flag is needed for mkarchiso (loop devices, chroot).

FROM archlinux:latest

# Install build dependencies
RUN pacman -Syu --noconfirm && \
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
        snapper \
        && \
    pacman -Scc --noconfirm

WORKDIR /build
COPY . .

RUN mkdir -p /repo/vanta/x86_64

# Build all custom packages
RUN bash scripts/build-packages.sh --repo /repo/vanta || true

# Build the ISO
RUN bash scripts/build-iso.sh --clean

VOLUME ["/build/out"]

CMD ["cp", "-v", "/build/out/vanta-linux-*.iso", "/build/out/"]
