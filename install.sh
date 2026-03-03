#!/bin/bash
# xsay installer — works from cloned repo or via: curl -fsSL <url> | bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
REPO_URL="https://github.com/serglavren/xsay.git"

main() {
  echo "xsay installer"
  echo "─────────────────────────────"

  # Detect if running inside a cloned repo
  if [ -f "bin/xsay" ] && [ -d "share/xsay/soundfx" ]; then
    echo "Detected local repo. Installing from here..."
    do_install "."
  else
    echo "Cloning xsay..."
    local tmpdir="/tmp/xsay-install-$$"
    trap 'rm -rf "$tmpdir"' EXIT
    git clone --depth 1 "$REPO_URL" "$tmpdir" 2>/dev/null
    echo "Installing..."
    do_install "$tmpdir"
  fi

  echo ""
  echo "Installed successfully!"
  echo "  Run: xsay \"hello world\""

  # Check PATH
  case ":${PATH}:" in
    *":${PREFIX}/bin:"*) ;;
    *)
      echo ""
      echo "  NOTE: Add ${PREFIX}/bin to your PATH:"
      echo "    export PATH=\"${PREFIX}/bin:\$PATH\""
      echo ""
      echo "  Add to ~/.zshrc (or ~/.bashrc) to make permanent."
      ;;
  esac
}

do_install() {
  local src="$1"

  install -d "${PREFIX}/bin"
  install -d "${PREFIX}/share/xsay/soundfx"
  install -m 755 "${src}/bin/xsay" "${PREFIX}/bin/xsay"
  install -m 644 "${src}/share/xsay/xsay.conf" "${PREFIX}/share/xsay/xsay.conf"
  install -m 644 "${src}/share/xsay/soundfx/"*.aiff "${PREFIX}/share/xsay/soundfx/"

  # Create user config if missing
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/xsay"
  mkdir -p "$config_dir"
  if [ ! -f "${config_dir}/xsay.conf" ]; then
    cp "${src}/share/xsay/xsay.conf" "${config_dir}/xsay.conf"
  fi
}

main "$@"
