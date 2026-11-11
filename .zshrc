# ============================================================================
#  zshrc - minimal, portable, dependency-free
#  Copy/symlink to ~/.zshrc. Works with interactive and login shells on Linux/macOS.
# ============================================================================

# Leave scripts and non-interactive SSH commands alone.
[[ -o interactive ]] || return

# --- PATH -------------------------------------------------------------------
# Zsh keeps these arrays tied to PATH and its completion search path, respectively.
# Keep the first occurrence of each entry when adding directories.
typeset -U path fpath

# Later additions take priority; personal tools win over package-manager tools.
for _bin in \
    /usr/local/sbin /usr/local/bin \
    /home/linuxbrew/.linuxbrew/sbin /home/linuxbrew/.linuxbrew/bin \
    "$HOME/.linuxbrew/sbin" "$HOME/.linuxbrew/bin" \
    /opt/homebrew/sbin /opt/homebrew/bin \
    "$HOME/bin" "$HOME/.local/bin"
do
    [[ -d $_bin ]] && path=("$_bin" "${path[@]}")
done
export PATH
unset _bin

# --- History / navigation ---------------------------------------------------
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=10000
SAVEHIST=20000
setopt APPEND_HISTORY          # Don't overwrite history from other terminals.
setopt HIST_IGNORE_DUPS        # Skip consecutive duplicates.
setopt HIST_IGNORE_SPACE       # Don't save commands starting with a space.

# Type a prefix, then use Up/Down to search matching history entries.
# Support Emacs and vi insert mode, plus application-mode arrow keys.
for _keymap in emacs viins; do
    bindkey -M "$_keymap" '^[[A' history-beginning-search-backward
    bindkey -M "$_keymap" '^[[B' history-beginning-search-forward
    bindkey -M "$_keymap" '^[OA' history-beginning-search-backward
    bindkey -M "$_keymap" '^[OB' history-beginning-search-forward
done
unset _keymap

# --- Tab completion ---------------------------------------------------------
# Include Homebrew and personal completion functions before initializing Zsh's
# built-in completion system (which already includes Git and common commands).
for _completion_dir in \
    /usr/local/share/zsh/site-functions \
    /home/linuxbrew/.linuxbrew/share/zsh/site-functions \
    "$HOME/.linuxbrew/share/zsh/site-functions" \
    /opt/homebrew/share/zsh/site-functions \
    "$HOME/.local/share/zsh/site-functions"
do
    [[ -d $_completion_dir ]] && fpath=("$_completion_dir" "${fpath[@]}")
done
unset _completion_dir
autoload -Uz compinit
compinit -i                   # Ignore insecure directories; don't bypass checks.

# --- Defaults ---------------------------------------------------------------
if [[ -z ${EDITOR-} ]]; then
    if command -v vim >/dev/null 2>&1; then
        export EDITOR=vim
    else
        export EDITOR=vi
    fi
fi
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"    # Color support; quit if output fits one screen.

# --- Aliases ----------------------------------------------------------------
case ${OSTYPE-} in
    darwin*|freebsd*)
        alias ls='ls -G'
        ;;
    linux*)
        alias ls='ls --color=auto'
        ;;
esac
alias ll='ls -alF'
alias la='ls -A'
alias lla='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'
alias h='history'
alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate -20'

# --- Prompt -----------------------------------------------------------------
# user@host directory (branch*) $ — * marks tracked or untracked changes.
# Detached HEAD shows the short commit ID; outside a repo, omit the Git segment.
_git_prompt() {
    command -v git >/dev/null 2>&1 || return 0
    local branch dirty
    branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        branch=$(command git rev-parse --short HEAD 2>/dev/null) || return 0
    if [[ -n $(GIT_OPTIONAL_LOCKS=0 command git status --porcelain 2>/dev/null) ]]; then
        dirty='*'
    fi
    # Git branch names can contain %, which Zsh would treat as prompt escapes.
    printf ' (%s%s)' "${branch//\%/%%}" "$dirty"
}

setopt PROMPT_SUBST
# Native color escapes keep wrapping and line editing correct without extra markup.
# %1~ shows just the current directory; the final symbol is $ (or # for root).
case ${TERM-} in
    xterm*|screen*|tmux*|rxvt*|linux|ansi|alacritty*|foot*|wezterm*)
        PROMPT='%F{green}%n@%m%f %F{cyan}%1~%F{yellow}$(_git_prompt)%f %(!.#.$) '
        ;;
    *)
        PROMPT='%n@%m %1~$(_git_prompt) %(!.#.$) '
        ;;
esac

# --- Machine-specific additions (not tracked) -------------------------------
if [[ -f "$HOME/.zshrc.local" ]]; then
    . "$HOME/.zshrc.local"
fi
