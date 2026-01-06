#!/usr/bin/env bash
set -euo pipefail

#
# Installer for Linux (Debian/Ubuntu/Kali and derivatives)
#
# Features:
#   - Can add an APT repository (hosted via GitHub Pages or similar)
#   - Can install the latest .deb from GitHub Releases as a fallback
#
# Usage (for your users, after you publish this somewhere):
#   curl -fsSL https://your-domain.com/path/install_linux.sh | bash
#
# BEFORE USING IN PRODUCTION:
#   1. Set APP_NAME, GITHUB_OWNER, GITHUB_REPO, APT_REPO_URL, GPG_KEY_URL below.
#   2. Make sure you actually host the APT repo and GPG key at those URLs.
#   3. Ensure your GitHub Releases contain .deb assets named consistently
#      (see INSTALL_FROM_GITHUB_DEB() notes).
#

APP_NAME="yt-downloader"               # Debian package and CLI name
GITHUB_OWNER="bhaskarvilles"          # Your GitHub username/org
GITHUB_REPO="yt-downloader"           # Your GitHub repo name

# We will publish a Debian repo via GitHub Pages using the GitHub Action in:
#   .github/workflows/release.yml
# That action will put the repo at:
#   https://bhaskarvilles.github.io/yt-downloader
# Adjust APT_REPO_URL/APT_DIST/APT_COMPONENT only if you change that layout.
APT_REPO_URL="https://bhaskarvilles.github.io/yt-downloader"
APT_DIST="stable"
APT_COMPONENT="main"

# Public GPG key for signing your APT repository (host this yourself).
# For a simple unsigned repo you can comment out add_apt_repo usage and
# use only the GitHub .deb installer path. For production you should sign.
GPG_KEY_URL="https://bhaskarvilles.github.io/yt-downloader/KEY.gpg"

ARCH="$(dpkg --print-architecture 2>/dev/null || echo "amd64")"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required but not installed." >&2
    exit 1
  fi
}

ensure_apt_system() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "This installer only supports Debian/Ubuntu/Kali-style systems (with apt-get)." >&2
    exit 1
  fi
}

add_apt_repo() {
  echo "==> Configuring APT repository for ${APP_NAME}..."

  require_cmd curl
  require_cmd sudo

  local keyring="/usr/share/keyrings/${APP_NAME}-archive-keyring.gpg"
  local list_file="/etc/apt/sources.list.d/${APP_NAME}.list"

  echo "  - Downloading and installing GPG key from: ${GPG_KEY_URL}"
  curl -fsSL "${GPG_KEY_URL}" | sudo tee "${keyring}" >/dev/null
  sudo chmod 644 "${keyring}"

  echo "  - Writing APT source list: ${list_file}"
  echo "deb [signed-by=${keyring} arch=${ARCH}] ${APT_REPO_URL} ${APT_DIST} ${APT_COMPONENT}" \
    | sudo tee "${list_file}" >/dev/null

  echo "  - Updating package lists..."
  sudo apt-get update
}

install_from_apt() {
  echo "==> Installing ${APP_NAME} from APT repository..."
  require_cmd sudo
  sudo apt-get install -y "${APP_NAME}"
}

install_from_github_deb() {
  echo "==> Installing ${APP_NAME} from GitHub Releases (.deb asset)..."
  require_cmd curl
  require_cmd sudo

  # You control how you name your release assets.
  # One simple pattern is to always publish a file such as:
  #   ${APP_NAME}_${ARCH}.deb
  # under the "latest" release. For example:
  #   yt-downloader_amd64.deb
  #
  # Then the URL for the latest asset is:
  #   https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest/download/${APP_NAME}_${ARCH}.deb

  local tmp_deb="/tmp/${APP_NAME}_${ARCH}.deb"
  local deb_url="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest/download/${APP_NAME}_${ARCH}.deb"

  echo "  - Downloading .deb from: ${deb_url}"
  if ! curl -fL "${deb_url}" -o "${tmp_deb}"; then
    echo "Error: Failed to download .deb from GitHub. Check that the URL and asset exist." >&2
    exit 1
  fi

  echo "  - Installing .deb with dpkg..."
  sudo dpkg -i "${tmp_deb}" || {
    echo "  - Resolving dependencies with apt-get -f install..."
    sudo apt-get -f install -y
  }

  echo "  - Cleaning up temporary .deb"
  rm -f "${tmp_deb}"
}

main() {
  ensure_apt_system

  echo "Installing ${APP_NAME} for architecture: ${ARCH}"

  # First, try to configure the APT repo and install from it.
  # If that fails (e.g. repo not yet published), fall back to GitHub Releases.
  if add_apt_repo && install_from_apt; then
    echo "==> ${APP_NAME} installed via APT repository."
    echo
    echo "Run it with:"
    echo "  ${APP_NAME}"
    exit 0
  fi

  echo "!! APT repo installation failed, falling back to GitHub Releases ..." >&2

  install_from_github_deb

  echo "==> ${APP_NAME} installed from GitHub .deb."
  echo
  echo "Run it with:"
  echo "  ${APP_NAME}"
}

main "$@"


