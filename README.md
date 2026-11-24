# dotfiles

Portable, dependency-free config for bash, zsh, tmux, and vim, plus a small
collection of scripts.

## Install

```sh
git clone https://github.com/rachaelroo/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles
./setup.sh
```

`setup.sh` symlinks every root dotfile into `~` and everything in `scripts/`
into `~/.local/bin` (creating it if needed). Symlinks are used rather than
copies, so edits in the repo take effect immediately.

- Preview without touching anything: `./setup.sh --dry-run`
- Re-running is safe; links are simply re-pointed.
- A pre-existing *real* file at a target (e.g. an old `~/.zshrc`) is moved to
  `~/.zshrc.backup.<timestamp>` instead of being overwritten.

After installing, open a new shell (or `exec $SHELL`) to pick up the changes.

## Machine-specific settings

Anything that shouldn't be committed — tokens, work-only exports, one-off
aliases — goes in the matching `.local` file, which is sourced at the end of
each config and is never tracked:

| Tool | Local file            |
| ---- | --------------------- |
| bash | `~/.bashrc.local`     |
| zsh  | `~/.zshrc.local`      |
| vim  | `~/.vimrc.local`      |
| tmux | `~/.tmux.local.conf`  |

Keep this repo secret-free; it is public.

## Adding things

- **A script**: drop it in `scripts/`. The setup script picks up anything
  there automatically and makes it executable.
- **A dotfile**: add it at the repo root. Any dot-prefixed file is linked into
  `~` automatically.
- **A root file that must not be linked** (like `.gitignore`): add its name to
  the `SKIP` array in `setup.sh`.

## Layout

```
.bash_profile   login shell entry point, sources .bashrc
.bashrc         bash config (Bash 3.2+)
.zshrc          zsh config
.tmux.conf      tmux config
.vimrc          vim/neovim config, plugin-free
scripts/        linked into ~/.local/bin
setup.sh        installer
```
