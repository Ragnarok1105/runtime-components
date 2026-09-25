#!/usr/bin/env bash
set -eu

FILES=".bashrc .zshrc .vimrc .gdbinit"
OMZ_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
DRY_RUN=0
INSTALL_OMZ=1

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run) DRY_RUN=1 ;;
        --no-omz) INSTALL_OMZ=0 ;;
        -h|--help)
            echo "Usage: ./install.sh [--dry-run] [--no-omz]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

REPO_DIR="$(cd "$(dirname "$0")" && pwd -P)"
STAMP="$(date +%Y%m%d-%H%M%S)"

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would run: $*"
    else
        "$@"
    fi
}

install_file() {
    local src="$REPO_DIR/$1"
    local dest="$HOME/$1"

    if [ ! -e "$src" ]; then
        echo "Skip $1: file missing"
        return
    fi

    if [ -f "$dest" ] && [ ! -L "$dest" ] && cmp -s "$src" "$dest"; then
        echo "Already installed: $1"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local bak="$dest.backup-$STAMP" n=1
        while [ -e "$bak" ] || [ -L "$bak" ]; do
            bak="$dest.backup-$STAMP-$n"
            n=$((n + 1))
        done
        run mv "$dest" "$bak"
    fi

    run cp "$src" "$dest"
}

setup_gitconfig() {
    local src="$REPO_DIR/.gitconfig"
    local dest="$HOME/.gitconfig.rc"

    if [ ! -e "$src" ]; then
        echo "Skip Git configuration: file missing"
        return
    fi

    if git config -f "$src" --get user.name >/dev/null 2>&1 ||
       git config -f "$src" --get user.email >/dev/null 2>&1; then
        echo "Remove personal name/email from the repository's .gitconfig."
        return
    fi

    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        echo "Git settings already copied"
    else
        run cp "$src" "$dest"
    fi

    if git config --global --get-all include.path 2>/dev/null |
       grep -qxF "$dest"; then
        echo "Git settings already included"
    else
        run git config --global --add include.path "$dest"
    fi
}

install_omz() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "Skip Oh My Zsh: zsh is not installed"
        return
    fi

    if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
        echo "Oh My Zsh is already installed"
        return
    fi

    local fetch
    if command -v curl >/dev/null 2>&1; then
        fetch="curl -fsSL"
    elif command -v wget >/dev/null 2>&1; then
        fetch="wget -qO-"
    else
        echo "Skip Oh My Zsh: curl or wget is required"
        return
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would download and run: $OMZ_URL"
        return
    fi

    local tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/omz-install.XXXXXX")"

    if ! $fetch "$OMZ_URL" > "$tmp"; then
        echo "Could not download Oh My Zsh"
        rm -f "$tmp"
        return
    fi

    KEEP_ZSHRC=yes sh "$tmp" --unattended
    rm -f "$tmp"
}

echo "Installing from $REPO_DIR"
if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run: nothing will be changed"
fi

for f in $FILES; do
    install_file "$f"
done

setup_gitconfig

if [ "$INSTALL_OMZ" -eq 1 ]; then
    install_omz
fi

echo "Done."
