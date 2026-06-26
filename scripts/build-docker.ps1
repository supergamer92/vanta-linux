# Vanta Linux - Docker-based ISO build for Windows
# Requires: Docker Desktop (enable WSL2 backend for best performance)
#
# Usage:
#   .\scripts\build-docker.ps1
#
# The built ISO will appear in .\out\

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

Write-Host "==> Building Vanta Linux ISO via Docker..." -ForegroundColor Green

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker not found. Install Docker Desktop from https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    exit 1
}

# Build the builder image
Write-Host "==> Building Vanta build image..." -ForegroundColor Cyan
Push-Location $RepoRoot
docker build -f scripts/Dockerfile -t vanta-builder .

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Run the build. WSL2 backend doesn't need --privileged, but Hyper-V does.
# On Windows, we mount the source and let the container produce the ISO into out/
try {
    docker run --rm -v "${RepoRoot}:/build:ro" -v "${RepoRoot}\out:/build/out" vanta-builder
} catch {
    # Fallback: build without volume mounts for output
    Write-Host "Volume mount failed. Building in container and copying out..." -ForegroundColor Yellow
    $containerId = docker create vanta-builder
    docker start -a $containerId
    mkdir -p "${RepoRoot}\out" -Force
    docker cp "${containerId}:/build/out/." "${RepoRoot}\out\"
    docker rm $containerId
}

Pop-Location

# List the built ISO
$isoFiles = Get-ChildItem "${RepoRoot}\out\*.iso"
if ($isoFiles) {
    Write-Host "==> ISO build complete!" -ForegroundColor Green
    foreach ($iso in $isoFiles) {
        $size = "{0:N2} MB" -f ($iso.Length / 1MB)
        Write-Host "    $($iso.Name)  ($size)" -ForegroundColor Cyan
    }
} else {
    Write-Host "WARNING: No ISO found in out/. Check Docker logs above for errors." -ForegroundColor Yellow
}
