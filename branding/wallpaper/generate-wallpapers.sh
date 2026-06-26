#!/usr/bin/env bash
# Generate Vanta wallpapers
# Requires ImageMagick
#
# Usage: ./generate-wallpapers.sh [output-dir]

set -euo pipefail

OUTDIR="${1:-./generated}"
mkdir -p "${OUTDIR}"

# Vanta Default - solid dark with amber accent line at bottom
magick -size 3840x2160 gradient:'#0c0c0d'-'#101013' \
    -fill '#e66100' -draw "rectangle 0,2156 3840,2160" \
    "${OUTDIR}/vanta-default.jpg"

# Vanta Dark Grain - noise texture overlay
magick -size 3840x2160 xc:'#0c0c0d' \
    -attenuate 0.03 +noise Gaussian \
    "${OUTDIR}/vanta-grain.jpg"

# Vanta Amber Drift - radial glow from bottom-right
magick -size 3840x2160 xc:'#0c0c0d' \
    -fill '#cc5800' -draw "circle 3400,2000 3400,1600" \
    -fill '#8a3c00' -draw "circle 3400,2000 3400,1200" \
    -blur 0x120 \
    "${OUTDIR}/vanta-amber.jpg"

# Vanta Observatory
magick -size 3840x2160 xc:'#0a0a0f' \
    -attenuate 0.8 +noise Poisson \
    -brightness-contrast 300,0 \
    -blur 0x0.5 \
    "${OUTDIR}/vanta-observatory.jpg"

echo "Wallpapers generated in ${OUTDIR}:"
ls -lh "${OUTDIR}"
