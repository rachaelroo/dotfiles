#!/bin/bash
# One-time setup for a fresh clone: link dotfiles into ~ and scripts into ~/.local/bin.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

# Non-dotfile entries at the repo root that must never be linked into ~.
SKIP=(.git .DS_Store)

is_skipped() {
    for s in "${SKIP[@]}"; do
        [[ "$1" == "$s" ]] && return 0
    done
    return 1
}

echo "Linking dotfiles into $HOME..."
for path in "$DOTFILES_DIR"/.??*; do
    file="$(basename "$path")"
    is_skipped "$file" && continue
    [[ -f "$path" ]] || continue
    target="$HOME/$file"
    if [[ -e "$target" || -L "$target" ]] && [[ ! -L "$target" ]]; then
        # A real file already exists: back it up instead of clobbering it.
        backup="$target.backup.$(date +%Y%m%d%H%M%S)"
        echo "  $file exists, backing up to $(basename "$backup")"
        mv "$target" "$backup"
    fi
    ln -sfn "$DOTFILES_DIR/$file" "$target"
    echo "  linked $file"
done

echo "Linking scripts into $BIN_DIR..."
mkdir -p "$BIN_DIR"
for script in "$DOTFILES_DIR"/scripts/*; do
    [[ -e "$script" ]] || continue
    name="$(basename "$script")"
    chmod +x "$script"
    ln -sfn "$script" "$BIN_DIR/$name"
    echo "  linked $name"
done

echo
echo "Done. Make sure $BIN_DIR is on your PATH (it should be, via the shell rc files)."
