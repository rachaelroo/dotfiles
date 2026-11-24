#!/bin/bash
# One-time setup for a fresh clone: link dotfiles into ~ and scripts into ~/.local/bin.
# Usage: ./setup.sh [--dry-run]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run)
            DRY_RUN=1
            ;;
        -h|--help)
            echo "Usage: ./setup.sh [--dry-run]"
            echo "  Links every root dotfile into ~ and every script into ~/.local/bin."
            exit 0
            ;;
        *)
            echo "Unknown option: $arg (try --help)" >&2
            exit 2
            ;;
    esac
done

# Root dotfiles that must never be linked into ~.
SKIP=(.git .gitignore .DS_Store)

is_skipped() {
    for s in "${SKIP[@]}"; do
        [[ "$1" == "$s" ]] && return 0
    done
    return 1
}

# link <source> <target>
# Symlinks source to target, backing up a pre-existing real file first.
link() {
    local src="$1" target="$2" backup
    if [[ -e "$target" || -L "$target" ]] && [[ ! -L "$target" ]]; then
        backup="$target.backup.$(date +%Y%m%d%H%M%S)"
        if (( DRY_RUN )); then
            echo "  $(basename "$target") exists, would back up to $(basename "$backup")"
        else
            mv "$target" "$backup"
            echo "  $(basename "$target") exists, backed up to $(basename "$backup")"
        fi
    fi
    if (( DRY_RUN )); then
        echo "  would link $(basename "$target") -> $src"
    else
        ln -sfn "$src" "$target"
        echo "  linked $(basename "$target")"
    fi
}

if (( DRY_RUN )); then
    echo "Dry run: no changes will be made."
    echo
fi

echo "Linking dotfiles into $HOME..."
for path in "$DOTFILES_DIR"/.??*; do
    file="$(basename "$path")"
    is_skipped "$file" && continue
    [[ -f "$path" ]] || continue
    link "$path" "$HOME/$file"
done

echo "Linking scripts into $BIN_DIR..."
(( DRY_RUN )) || mkdir -p "$BIN_DIR"
for script in "$DOTFILES_DIR"/scripts/*; do
    [[ -e "$script" ]] || continue
    (( DRY_RUN )) || chmod +x "$script"
    link "$script" "$BIN_DIR/$(basename "$script")"
done

# The rc files add $BIN_DIR themselves, so only warn when a new shell would
# still not see it (e.g. the rc files failed to link or were replaced).
if (( ! DRY_RUN )); then
    case ":${PATH-}:" in
        *":$BIN_DIR:"*)
            ;;
        *)
            if ! grep -qs '\.local/bin' "$HOME/.bashrc" "$HOME/.zshrc" 2>/dev/null; then
                echo
                echo "Warning: $BIN_DIR is not on your PATH and your shell rc files"
                echo "         don't add it. Add it to ~/.bashrc.local or ~/.zshrc.local."
            fi
            ;;
    esac

    echo
    echo "Done. Open a new shell (or run 'exec \$SHELL') to pick up the changes."
else
    echo
    echo "Dry run complete."
fi
