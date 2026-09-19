#!/data/data/com.termux/files/usr/bin/env bash
# ============================================================
#  install-mimo.sh — MiMoCode installer for Termux (aarch64)
#  ============================================================
#  HiwALAY na installer para sa MiMoCode (Xiaomi fork ng
#  OpenCode). Kailangan ng proot + grun (glibc-runner) para
#  ma-bypass ang Android seccomp "statx" block.
#
#  One-liner:
#    bash <(curl -fsSL https://raw.githubusercontent.com/heje1221/mimo-install/master/install-mimo.sh) --bootstrap
# ============================================================
set -euo pipefail

MIMO_BIN="$HOME/.mimocode/bin/mimo"
WRAPPER_DIR="$HOME/.local/bin"
GRUN="/data/data/com.termux/files/usr/glibc/bin/grun"
PROOT="/data/data/com.termux/files/usr/bin/proot"

GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; NC='\033[0m'

say()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------
install_deps() {
    say "Installing dependencies: proot, glibc-repo, glibc, glibc-runner, curl, tar, which..."
    pkg update -y
    pkg install -y proot curl tar which glibc-repo || warn "glibc-repo install failed (baka naka-install na)"
    pkg install -y glibc glibc-runner || fail "Hindi ma-install ang glibc/glibc-runner"

    for t in proot curl tar which; do
        command -v "$t" >/dev/null 2>&1 || fail "Missing tool: $t"
    done
    [ -x "$PROOT" ]   || fail "proot not found: $PROOT"
    [ -x "$GRUN" ]    || fail "grun not found: $GRUN (i-install ang glibc-runner)"
    say "Dependencies OK (proot + grun ready)"
}

# ------------------------------------------------------------
# Wrapper (proot + grun, para hindi i-direct ang raw glibc bin)
# ------------------------------------------------------------
make_wrapper() {
    local wrapper="$WRAPPER_DIR/mimo"
    mkdir -p "$WRAPPER_DIR"
    cat > "$wrapper" <<EOF
#!/data/data/com.termux/files/usr/bin/env bash
unset LD_PRELOAD
exec "$PROOT" -k 0x20000000 "$GRUN" "$MIMO_BIN" "\$@"
EOF
    chmod +x "$wrapper"
    say "Wrapper created: $wrapper"
}

# ------------------------------------------------------------
# Install MiMoCode
#    Official installer: curl -fsSL https://mimo.xiaomi.com/install | bash
# ------------------------------------------------------------
install_mimo() {
    say "Installing MiMoCode (Xiaomi installer)..."
    if [ -x "$MIMO_BIN" ]; then
        warn "mimo binary exists na: $MIMO_BIN"
    else
        curl -fsSL https://mimo.xiaomi.com/install | bash \
            || fail "MiMoCode install failed"
    fi
    [ -x "$MIMO_BIN" ] || fail "MiMo binary not found after install"
    make_wrapper
    say "MiMoCode OK. Run: source ~/.bashrc && mimo"
}

# ------------------------------------------------------------
# API key setup (optional)
# ------------------------------------------------------------
setup_env() {
    if grep -qE 'OPENAI_API_KEY|ZEN_API_KEY' "$HOME/.bashrc" 2>/dev/null; then
        say "API keys nasa .bashrc na — skip"
    else
        warn "Walang API key sa .bashrc."
        warn "I-add mo ito (para magamit ang MiMoCode):"
        echo '  export OPENAI_API_KEY="..."   # or ZEN_API_KEY / OPENROUTER_API_KEY'
        echo "Pagkatapos: source ~/.bashrc"
    fi
}

# ------------------------------------------------------------
# Usage
# ------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $0 [options]
  --bootstrap  fresh Termux: deps + MiMoCode (RECO after format)
  --mimo       install deps + MiMoCode (default)
  --deps       dependencies lang
  --env        API key setup reminder
  -h, --help   help

Halimbawa:
  $0 --bootstrap      # fresh Termux
  $0 --mimo           # deps + mimo
EOF
}

# ------------------------------------------------------------
# Interactive menu
# ------------------------------------------------------------
banner() {
    cat <<"EOF"

 ====================================================
      MiMoCode INSTALLER (Xiaomi fork ng OpenCode)
      Termux | Xiaomi Pad 7 (aarch64)
 ====================================================
EOF
}

show_menu() {
    banner
    echo
    echo "  Pumili ka ng gagawin:"
    echo
    echo "    [1] Bootstrap (fresh Termux — deps + mimo)  <-- RECO after format"
    echo "    [2] MiMoCode install (deps + mimo)"
    echo "    [3] Dependencies lang"
    echo "    [4] API key setup reminder"
    echo "    [0] Exit"
    echo
}

menu_loop() {
    local choice
    while true; do
        show_menu
        read -rp "  Pumili [0-4]: " choice
        case "$choice" in
            1) install_deps; install_mimo; setup_env; return ;;
            2) install_deps; install_mimo; return ;;
            3) install_deps; return ;;
            4) setup_env; return ;;
            0) echo "  Bye!"; exit 0 ;;
            *) warn "Invalid choice: $choice"; sleep 1 ;;
        esac
    done
}

# --- entry point ---
if [ "$#" -eq 0 ]; then
    menu_loop
else
    case "${1#--}" in
        bootstrap) install_deps; install_mimo; setup_env ;;
        mimo)      install_deps; install_mimo ;;
        deps)      install_deps ;;
        env)       setup_env ;;
        h|help|-h|--help) usage; exit 0 ;;
        *)         fail "Unknown option: $1" ;;
    esac
fi

say "Done! Restart shell: source ~/.bashrc && mimo"