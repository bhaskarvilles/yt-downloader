#!/usr/bin/env bash
set -euo pipefail

# Build a Linux binary with PyInstaller and package it as a .deb for Debian/Kali.
#
# Prerequisites (install once):
#   sudo apt install python3-pip python3-venv pyinstaller yt-dlp fakeroot
#
# Usage:
#   chmod +x build_deb.sh
#   ./build_deb.sh

APP_NAME="yt-downloader"
VERSION="1.0.0"
ARCH="$(dpkg --print-architecture)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
BUILD_DIR="${ROOT_DIR}/deb_build"
DEBIAN_DIR="${BUILD_DIR}/DEBIAN"
BIN_DIR="${BUILD_DIR}/usr/bin"

echo "==> Cleaning previous builds..."
rm -rf "${BUILD_DIR}"
mkdir -p "${DEBIAN_DIR}" "${BIN_DIR}"

echo "==> Building standalone binary with PyInstaller..."
pyinstaller \
  --onefile \
  --noconsole \
  --name "${APP_NAME}" \
  "${ROOT_DIR}/main.py"

echo "==> Copying binary into package structure..."
cp "${DIST_DIR}/${APP_NAME}" "${BIN_DIR}/${APP_NAME}"
chmod 755 "${BIN_DIR}/${APP_NAME}"

echo "==> Writing DEBIAN/control file..."
cat > "${DEBIAN_DIR}/control" <<EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: yt-dlp
Maintainer: You <you@example.com>
Description: YouTube downloader GUI using yt-dlp and Tkinter.
 A simple GUI wrapper around yt-dlp to download YouTube videos and playlists
 with quality selection and MP3-only mode.
EOF

echo "==> Building .deb package..."
OUTPUT_DEB="${ROOT_DIR}/${APP_NAME}_${VERSION}_${ARCH}.deb"
fakeroot dpkg-deb --build "${BUILD_DIR}" "${OUTPUT_DEB}"

echo
echo "Build complete:"
echo "  ${OUTPUT_DEB}"
echo
echo "Install with:"
echo "  sudo dpkg -i \"${OUTPUT_DEB}\""
echo
echo "After install, run with:"
echo "  ${APP_NAME}"


