#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  OpenClaw Pocket Server — Bootstrap Installer
#  One-liner: curl -sL <RAW_URL>/bootstrap.sh | bash
# ============================================================
set -euo pipefail

REPO="PsProsen-Dev/openclaw-pocket-server"
BRANCH="main"
BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${MAGENTA}${BOLD}"
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║          -: J A R V I S  (R T X ⚡) :-                   ║"
echo "  ║   ─────────────────────────────────────────────────      ║"
echo "  ║   🦞 OpenClaw 24/7 Pocket Server Installer 🦞           ║"
echo "  ║   One Command. Full AI Server. Android.                  ║"
echo "  ║                                                          ║"
echo "  ║   Make any Android phone into a production-grade         ║"
echo "  ║   24/7 pocket server.                                    ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${CYAN}Built by ${BOLD}PsProsen-Dev${NC} ${CYAN}&${NC} ${BOLD}${MAGENTA}Jarvis (RTX⚡)${NC}"
echo -e "  ${YELLOW}github.com/PsProsen-Dev/openclaw-pocket-server${NC}"
echo ""

# --- Verify Termux ---
if [ -z "${PREFIX:-}" ] || [[ "$PREFIX" != */com.termux/* ]]; then
  echo -e "${RED}[ERROR] This script must be run inside Termux.${NC}"
  echo "        Install Termux from F-Droid: https://f-droid.org/en/packages/com.termux/"
  exit 1
fi

# --- Download all files ---
INSTALL_DIR="$HOME/openclaw-pocket-server"
mkdir -p "$INSTALL_DIR"/{scripts,patches,tests,docs}

FILES=(
  "install.sh"
  "scripts/check-env.sh"
  "scripts/install-deps.sh"
  "scripts/setup-env.sh"
  "scripts/setup-ssh.sh"
  "scripts/setup-tmux.sh"
  "scripts/setup-boot.sh"
  "patches/termux-compat.h"
  "patches/bionic-compat.js"
  "patches/spawn.h"
  "patches/patch-paths.sh"
  "patches/apply-patches.sh"
  "patches/systemctl"
  "tests/verify-install.sh"
)

echo -e "${CYAN}[INFO]${NC} Downloading files..."
FAIL=0
for f in "${FILES[@]}"; do
  if curl -sfL "${BASE}/${f}" -o "${INSTALL_DIR}/${f}"; then
    chmod +x "${INSTALL_DIR}/${f}" 2>/dev/null || true
  else
    echo -e "${RED}[FAIL]${NC} Failed to download: ${f}"
    FAIL=1
  fi
done

if [ "$FAIL" -eq 1 ]; then
  echo -e "${RED}[ERROR] Some files failed to download. Check your internet connection.${NC}"
  exit 1
fi

echo -e "${GREEN}[OK]${NC}   All files downloaded to ${INSTALL_DIR}"

# --- Run installer ---
echo ""
exec bash "${INSTALL_DIR}/install.sh"
